const std = @import("std");
const rl = @import("raylib");
const lib = @import("lib.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    rl.initWindow(lib.WIDTH, lib.HEIGHT, "Procedural Animation - [Zig + Raylib]");
    defer rl.closeWindow();

    var chain = try lib.Chain.new(8, 50, &allocator);
    defer chain.deinit(&allocator);

    rl.setTargetFPS(60);
    while (!rl.windowShouldClose()) {
        chain.updatePosition();
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.dark_gray);
        for (chain.joints) |link| {
            rl.drawCircleV(link.position, link.size, rl.Color.white);
        }
    }
}
