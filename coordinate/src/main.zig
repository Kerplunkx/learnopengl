const std = @import("std");
const glfw = @import("mach-glfw");
const gl = @import("zgl");
const stb = @import("zstbi");
const shader = @import("Shader.zig");
const cube = @import("cube.zig");
const za = @import("zalgebra");

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
        gl.clearColor(0.8, 0.8, 0.8, 1.0);
        gl.clear(.{ .color = true, .depth = true });

        gl.activeTexture(.texture_0);
        texture1.bind(.@"2d");
        gl.activeTexture(.texture_1);
        texture2.bind(.@"2d");

        var view = za.Mat4.identity().translate(za.Vec3.new(0.0, 0.0, -3.0));
        var projection = za.Mat4.perspective(45.0, 800.0 / 600.0, 0.1, 100.0);

        shader_program.use();
        shader_program.setMat4("view", view);
        shader_program.setMat4("projection", projection);
        vao.bind();

        for (cube.positions, 0..) |pos, i| {
            var model = za.Mat4.identity().translate(pos).rotate(20.0 * @as(f32, @floatFromInt(i)), za.Vec3.new(1.0, 0.3, 0.5));
            shader_program.setMat4("model", model);
            gl.drawArrays(.triangles, 0, 36);
        }

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
