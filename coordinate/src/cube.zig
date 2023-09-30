const za = @import("zalgebra");

pub const Vertex = struct {
    pos: [3]f32,
    tex_coord: [2]f32,
};

pub const vertices = [_]Vertex{
    // 1st face
    .{ .pos = [3]f32{ -0.5, -0.5, -0.5 }, .tex_coord = [2]f32{ 0.0, 0.0 } },
    .{ .pos = [3]f32{ 0.5, -0.5, -0.5 }, .tex_coord = [2]f32{ 1.0, 0.0 } },
    .{ .pos = [3]f32{ 0.5, 0.5, -0.5 }, .tex_coord = [2]f32{ 1.0, 1.0 } },
    .{ .pos = [3]f32{ 0.5, 0.5, -0.5 }, .tex_coord = [2]f32{ 1.0, 1.0 } },
    .{ .pos = [3]f32{ -0.5, 0.5, -0.5 }, .tex_coord = [2]f32{ 0.0, 1.0 } },
    .{ .pos = [3]f32{ -0.5, -0.5, -0.5 }, .tex_coord = [2]f32{ 0.0, 0.0 } },
    // 2nd face
    .{ .pos = [3]f32{ -0.5, -0.5, 0.5 }, .tex_coord = [2]f32{ 0.0, 0.0 } },
    .{ .pos = [3]f32{ 0.5, -0.5, 0.5 }, .tex_coord = [2]f32{ 1.0, 0.0 } },
    .{ .pos = [3]f32{ 0.5, 0.5, 0.5 }, .tex_coord = [2]f32{ 1.0, 1.0 } },
    .{ .pos = [3]f32{ 0.5, 0.5, 0.5 }, .tex_coord = [2]f32{ 1.0, 1.0 } },
    .{ .pos = [3]f32{ -0.5, 0.5, 0.5 }, .tex_coord = [2]f32{ 0.0, 1.0 } },
    .{ .pos = [3]f32{ -0.5, -0.5, 0.5 }, .tex_coord = [2]f32{ 0.0, 0.0 } },
    // 3rd face
    .{ .pos = [3]f32{ -0.5, 0.5, 0.5 }, .tex_coord = [2]f32{ 1.0, 0.0 } },
    .{ .pos = [3]f32{ -0.5, 0.5, -0.5 }, .tex_coord = [2]f32{ 1.0, 1.0 } },
    .{ .pos = [3]f32{ -0.5, -0.5, -0.5 }, .tex_coord = [2]f32{ 0.0, 1.0 } },
    .{ .pos = [3]f32{ -0.5, -0.5, -0.5 }, .tex_coord = [2]f32{ 0.0, 1.0 } },
    .{ .pos = [3]f32{ -0.5, -0.5, 0.5 }, .tex_coord = [2]f32{ 0.0, 0.0 } },
    .{ .pos = [3]f32{ -0.5, 0.5, 0.5 }, .tex_coord = [2]f32{ 1.0, 0.0 } },
    // 4th face
    .{ .pos = [3]f32{ 0.5, 0.5, 0.5 }, .tex_coord = [2]f32{ 1.0, 0.0 } },
    .{ .pos = [3]f32{ 0.5, 0.5, -0.5 }, .tex_coord = [2]f32{ 1.0, 1.0 } },
    .{ .pos = [3]f32{ 0.5, -0.5, -0.5 }, .tex_coord = [2]f32{ 0.0, 1.0 } },
    .{ .pos = [3]f32{ 0.5, -0.5, -0.5 }, .tex_coord = [2]f32{ 0.0, 1.0 } },
    .{ .pos = [3]f32{ 0.5, -0.5, 0.5 }, .tex_coord = [2]f32{ 0.0, 0.0 } },
    .{ .pos = [3]f32{ 0.5, 0.5, 0.5 }, .tex_coord = [2]f32{ 1.0, 0.0 } },
    // 5th face
    .{ .pos = [3]f32{ -0.5, -0.5, -0.5 }, .tex_coord = [2]f32{ 0.0, 1.0 } },
    .{ .pos = [3]f32{ 0.5, -0.5, -0.5 }, .tex_coord = [2]f32{ 1.0, 1.0 } },
    .{ .pos = [3]f32{ 0.5, -0.5, 0.5 }, .tex_coord = [2]f32{ 1.0, 0.0 } },
    .{ .pos = [3]f32{ 0.5, -0.5, 0.5 }, .tex_coord = [2]f32{ 1.0, 0.0 } },
    .{ .pos = [3]f32{ -0.5, -0.5, 0.5 }, .tex_coord = [2]f32{ 0.0, 0.0 } },
    .{ .pos = [3]f32{ -0.5, -0.5, -0.5 }, .tex_coord = [2]f32{ 0.0, 1.0 } },
    //6th face
    .{ .pos = [3]f32{ -0.5, 0.5, -0.5 }, .tex_coord = [2]f32{ 0.0, 1.0 } },
    .{ .pos = [3]f32{ 0.5, 0.5, -0.5 }, .tex_coord = [2]f32{ 1.0, 1.0 } },
    .{ .pos = [3]f32{ 0.5, 0.5, 0.5 }, .tex_coord = [2]f32{ 1.0, 0.0 } },
    .{ .pos = [3]f32{ 0.5, 0.5, 0.5 }, .tex_coord = [2]f32{ 1.0, 0.0 } },
    .{ .pos = [3]f32{ -0.5, 0.5, 0.5 }, .tex_coord = [2]f32{ 0.0, 0.0 } },
    .{ .pos = [3]f32{ -0.5, 0.5, -0.5 }, .tex_coord = [2]f32{ 0.0, 1.0 } },
};

pub const positions = [_]za.Vec3{
    za.Vec3.new(0.0, 0.0, 0.0),
    za.Vec3.new(2.0, 5.0, -15.0),
    za.Vec3.new(-1.5, -2.2, -2.5),
    za.Vec3.new(-3.8, -2.0, -12.3),
    za.Vec3.new(2.4, -0.4, -3.5),
    za.Vec3.new(-1.7, 3.0, -7.5),
    za.Vec3.new(1.3, -2.0, -2.5),
    za.Vec3.new(1.5, 2.0, -2.5),
    za.Vec3.new(1.5, 0.2, -1.5),
    za.Vec3.new(-1.3, 1.0, -1.5),
};
