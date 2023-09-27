const std = @import("std");
const glfw = @import("mach-glfw");
const gl = @import("zgl");
const shader = @import("Shader.zig");

const vertices = [_]f32{
    0.5,  0.5,  0.0,
    0.5,  -0.5, 0.0,
    -0.5, -0.5, 0.0,
    -0.5, 0.5,  0.0,
};

const indices = [_]u8{
    0, 1, 3,
    1, 2, 3,
};

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

    const shader_program = shader.init("vertex.glsl", "fragment.glsl");
    defer shader_program.deinit();

    const vbo = gl.Buffer.gen();
    const vao = gl.genVertexArray();
    const ebo = gl.Buffer.gen();

    vao.bind();
    vbo.bind(.array_buffer); // vertex attributes
    vbo.data(f32, &vertices, .static_draw);

    ebo.bind(.element_array_buffer);
    ebo.data(u8, &indices, .static_draw);

    gl.vertexAttribPointer(0, 3, .float, false, 3 * @sizeOf(f32), 0);
    gl.enableVertexAttribArray(0);

    while (!window.shouldClose()) {
        gl.clearColor(0.1, 0.1, 0.1, 1.0);
        gl.clear(.{ .color = true });

        vao.bind();
        shader_program.use();
        gl.drawElements(.triangles, 6, .u8, 0);

        shader_program.setFloat("uGreen", @cos(@as(f32, @floatCast(glfw.getTime()))));

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
