const std = @import("std");
const zstbi = @import("libs/zstbi/build.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "coordinate",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    const zstbi_pkg = zstbi.package(b, target, optimize, .{});

    const glfw_dep = b.dependency("mach_glfw", .{
        .target = exe.target,
        .optimize = exe.optimize,
    });
    exe.addModule("mach-glfw", glfw_dep.module("mach-glfw"));
    @import("mach_glfw").link(glfw_dep.builder, exe);
    const zgl = b.dependency("zgl", .{});
    exe.addModule("zgl", zgl.module("zgl"));
    zstbi_pkg.link(exe);
    const zalgebra = b.dependency("zalgebra", .{});
    exe.addModule("zalgebra", zalgebra.module("zalgebra"));

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
