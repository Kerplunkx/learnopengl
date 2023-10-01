const std = @import("std");
const glfw = @import("mach-glfw");
const gl = @import("zgl");
const stb = @import("zstbi");
const shader = @import("Shader.zig");
const cube = @import("cube.zig");
const za = @import("zalgebra");

var camera_pos = za.Vec3.new(0.0, 0.0, 3.0);
var camera_front = za.Vec3.new(0.0, 0.0, -1.0);
var camera_up = za.Vec3.up();

var first_mouse = true;
var yaw: f32 = -90.0;
var pitch: f32 = 0.0;
var last_x: f32 = 800.0 / 2.0;
var last_y: f32 = 600.0 / 2.0;
var fov: f32 = 45.0;

var delta_time: f32 = 0.0;
var last_frame: f32 = 0.0;

pub fn main() !void {
    glfw.setErrorCallback(errorCallback);
    if (!glfw.init(.{})) {
        std.log.err("failed to initialize GLFW: {?s}", .{glfw.getErrorString()});
        std.process.exit(1);
    }
    defer glfw.terminate();

    const window = glfw.Window.create(800, 600, "Hello, mach-glfw!", null, null, .{
        .opengl_profile = .opengl_core_profile,
        .context_version_major = 4,
        .context_version_minor = 5,
    }) orelse {
        std.log.err("failed to create GLFW window: {?s}", .{glfw.getErrorString()});
        std.process.exit(1);
    };
    defer window.destroy();
    glfw.makeContextCurrent(window);
    window.setInputMode(.cursor, .disabled);

    window.setCursorPosCallback(mouseCallBack);
    window.setScrollCallback(scrollCallback);

    const proc: glfw.GLProc = undefined;
    try gl.loadExtensions(proc, glGetProcAddress);
    gl.viewport(0, 0, 800, 600);
    gl.enable(.depth_test);

    const shader_program = shader.init("vertex.glsl", "fragment.glsl");
    defer shader_program.deinit();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.allocator();
    var allocator = gpa.allocator();

    stb.init(allocator);
    defer stb.deinit();
    stb.setFlipVerticallyOnLoad(true);

    var container_img = try stb.Image.loadFromFile("src/container.jpg", 0);
    defer container_img.deinit();
    var face_img = try stb.Image.loadFromFile("src/awesomeface.png", 0);
    defer face_img.deinit();

    const vbo = gl.Buffer.gen();
    const vao = gl.genVertexArray();
    const texture1 = gl.Texture.gen();
    const texture2 = gl.Texture.gen();

    // Container img.
    gl.activeTexture(.texture_0);
    texture1.bind(.@"2d");
    gl.textureImage2D(.@"2d", 0, .rgb, container_img.width, container_img.height, .rgb, .unsigned_byte, @as(?[*]const u8, @ptrCast(container_img.data)));
    texture1.generateMipmap();
    // Face img.
    gl.activeTexture(.texture_1);
    texture2.bind(.@"2d");
    gl.textureImage2D(.@"2d", 0, .rgb, face_img.width, face_img.height, .rgba, .unsigned_byte, @as(?[*]const u8, @ptrCast(face_img.data)));
    texture2.generateMipmap();

    vao.bind();
    vbo.bind(.array_buffer);
    vbo.data(cube.Vertex, &cube.vertices, .static_draw);

    gl.vertexAttribPointer(0, 3, .float, false, @sizeOf(cube.Vertex), 0);
    gl.enableVertexAttribArray(0);
    gl.vertexAttribPointer(1, 2, .float, false, @sizeOf(cube.Vertex), @offsetOf(cube.Vertex, "tex_coord"));
    gl.enableVertexAttribArray(1);

    shader_program.use();
    shader_program.setInt("texture1", 0);
    shader_program.setInt("texture2", 1);

    while (!window.shouldClose()) {
        var current_frame = @as(f32, @floatCast(glfw.getTime()));
        delta_time = current_frame - last_frame;
        last_frame = current_frame;

        gl.clearColor(0.8, 0.8, 0.8, 1.0);
        gl.clear(.{ .color = true, .depth = true });

        gl.activeTexture(.texture_0);
        texture1.bind(.@"2d");
        gl.activeTexture(.texture_1);
        texture2.bind(.@"2d");

        var view = za.lookAt(camera_pos, camera_pos.add(camera_front), camera_up);
        var projection = za.Mat4.perspective(fov, 800.0 / 600.0, 0.1, 100.0);

        shader_program.use();
        shader_program.setMat4("view", view);
        shader_program.setMat4("projection", projection);
        vao.bind();

        for (cube.positions, 0..) |pos, i| {
            var model = za.Mat4.identity().translate(pos).rotate(20.0 * @as(f32, @floatFromInt(i)), za.Vec3.new(1.0, 0.3, 0.5));
            shader_program.setMat4("model", model);
            gl.drawArrays(.triangles, 0, 36);
        }

        processInput(window);
        window.swapBuffers();
        glfw.pollEvents();
    }
}

fn errorCallback(error_code: glfw.ErrorCode, description: [:0]const u8) void {
    std.log.err("glfw: {}: {s}\n", .{ error_code, description });
}

fn glGetProcAddress(p: glfw.GLProc, proc: [:0]const u8) ?gl.binding.FunctionPointer {
    _ = p;
    return glfw.getProcAddress(proc);
}

fn processInput(window: glfw.Window) void {
    if (window.getKey(.escape) == .press) {
        window.setShouldClose(true);
    }
    const camera_speed = 2.5 * delta_time;
    if (window.getKey(.w) == .press) {
        camera_pos = camera_pos.add(camera_front.scale(camera_speed));
    }
    if (window.getKey(.s) == .press) {
        camera_pos = camera_pos.sub(camera_front.scale(camera_speed));
    }

    if (window.getKey(.a) == .press) {
        camera_pos = camera_pos.sub(camera_front.cross(camera_up).norm().scale(camera_speed));
    }
    if (window.getKey(.d) == .press) {
        camera_pos = camera_pos.add(camera_front.cross(camera_up).norm().scale(camera_speed));
    }
}

fn mouseCallBack(window: glfw.Window, xpos: f64, ypos: f64) void {
    _ = window;

    if (first_mouse) {
        last_x = @as(f32, @floatCast(xpos));
        last_y = @as(f32, @floatCast(ypos));
        first_mouse = false;
    }

    var x_offset = @as(f32, @floatCast(xpos)) - last_x;
    var y_offset = last_y - @as(f32, @floatCast(ypos));
    last_x = @as(f32, @floatCast(xpos));
    last_y = @as(f32, @floatCast(ypos));

    const sensitivity = 0.1;
    x_offset *= sensitivity;
    y_offset *= sensitivity;

    yaw += x_offset;
    pitch += y_offset;

    if (pitch > 89.0) {
        pitch = 89.0;
    }
    if (pitch < -89.0) {
        pitch = -89.0;
    }

    const dir_x = @cos(za.toRadians(yaw)) * @cos(za.toRadians(pitch));
    const dir_y = @sin(za.toRadians(pitch));
    const dir_z = @sin(za.toRadians(yaw)) * @cos(za.toRadians(pitch));
    var direction = za.Vec3.new(dir_x, dir_y, dir_z);
    camera_front = direction.norm();
}

fn scrollCallback(window: glfw.Window, xoffset: f64, yoffset: f64) void {
    _ = xoffset;
    _ = window;
    fov -= @as(f32, @floatCast(yoffset));
    if (fov < 1.0) {
        fov = 1.0;
    }
    if (fov > 45.0) {
        fov = 45.0;
    }
}
