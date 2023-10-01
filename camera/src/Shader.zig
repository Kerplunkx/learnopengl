const std = @import("std");
const gl = @import("zgl");
const za = @import("zalgebra");

id: gl.Program,

pub fn init(comptime vertex_src: []const u8, comptime fragment_src: []const u8) @This() {
    const vertex_shader = gl.Shader.create(.vertex);
    defer vertex_shader.delete();
    vertex_shader.source(1, &.{@embedFile(vertex_src)});
    vertex_shader.compile();
    checkCompileErrors(@intFromEnum(vertex_shader), "vertex");

    const fragment_shader = gl.Shader.create(.fragment);
    defer fragment_shader.delete();
    fragment_shader.source(1, &.{@embedFile(fragment_src)});
    fragment_shader.compile();
    checkCompileErrors(@intFromEnum(fragment_shader), "fragment");

    const program = gl.Program.create();
    program.attach(vertex_shader);
    program.attach(fragment_shader);
    program.link();
    checkCompileErrors(@intFromEnum(program), "program");

    return .{
        .id = program,
    };
}

pub fn deinit(self: @This()) void {
    self.id.delete();
}

pub fn use(self: @This()) void {
    self.id.use();
}

pub fn setInt(self: @This(), name: [:0]const u8, value: i32) void {
    const location = gl.getUniformLocation(self.id, name);
    gl.uniform1i(location, value);
}

pub fn setFloat(self: @This(), name: [:0]const u8, value: f32) void {
    const location = gl.getUniformLocation(self.id, name);
    gl.uniform1f(location, value);
}

pub fn setBool(self: @This(), name: [:0]const u8, value: bool) void {
    const location = gl.getUniformLocation(self.id, name);
    gl.uniform1f(location, value);
}

pub fn setVec2(self: @This(), name: [:0]const u8, value: za.Vec2) void {
    const location = gl.getUniformLocation(self.id, name);
    gl.uniform2fv(location, &.{value.data});
}

pub fn setVec3(self: @This(), name: [:0]const u8, value: za.Vec3) void {
    const location = gl.getUniformLocation(self.id, name);
    gl.uniform3fv(location, &.{value.data});
}

pub fn setVec4(self: @This(), name: [:0]const u8, value: za.Vec4) void {
    const location = gl.getUniformLocation(self.id, name);
    gl.uniform4fv(location, &.{value.data});
}

pub fn setMat4(self: @This(), name: [:0]const u8, value: za.Mat4) void {
    const location = gl.getUniformLocation(self.id, name);
    gl.uniformMatrix4fv(location, false, &.{value.data});
}

fn checkCompileErrors(shader: gl.UInt, Type: []const u8) void {
    var succes: gl.Int = undefined;
    var log: [1024]u8 = [_]u8{0} ** 1024;

    if (!std.mem.eql(u8, Type, "program")) {
        gl.binding.getShaderiv(shader, gl.binding.COMPILE_STATUS, &succes);
        if (succes != 1) {
            gl.binding.getShaderInfoLog(shader, 1024, null, &log);
            std.log.err("SHADER COMPILATION ERROR OF TYPE {s}: {s}\n", .{ Type, log });
        }
    } else {
        gl.binding.getProgramiv(shader, gl.binding.LINK_STATUS, &succes);
        if (succes != 1) {
            gl.binding.getProgramInfoLog(shader, 1024, null, &log);
            std.log.err("PROGRAM LINKING ERROR {s}: {s}\n", .{ Type, log });
        }
    }
}
