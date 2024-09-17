const std = @import("std");
const math = @import("math.zig");
const assert = std.debug.assert;


pub const Canvas = struct {
    const Self = @This();

    width: u32,
    height: u32,
    pixel_grid: [][]const u32,
    alloc: std.mem.Allocator,

    pub fn init(alloc: std.mem.Allocator, width: u32, height: u32) Self {

    }

    pub fn deinit(self: Self) void {
        alloc.free(self.pixel_grid);
    }
};

pub fn canvas() Canvas {
    return Canvas {.width = width, .height = height};
}

test "Creating a canvas" {
    const c = canvas(10, 20);
    assert(c.width == 10);
    assert(c.height == 20);
}