const std = @import("std");
const rl = @import("raylib");

pub const WIDTH = 1280;
pub const HEIGHT = 720;

const Link = struct {
    position: rl.Vector2,
    size: f32,
};

pub const Chain = struct {
    joints: []Link,
    link_size: f32,

    pub fn new(chain_size: usize, link_size: f32, allocator: *const std.mem.Allocator) !Chain {
        var chain: Chain = .{
            .link_size = link_size,
            .joints = undefined,
        };

        chain.joints = try allocator.alloc(Link, chain_size);

        chain.joints[0] = Link{
            .position = rl.Vector2.init((WIDTH / 2) - 150, HEIGHT / 2),
            .size = 8,
        };

        var i: usize = 1;
        while (i < chain.joints.len) : (i += 1) {
            chain.joints[i] = Link{
                .position = rl.Vector2.init(
                    chain.joints[i - 1].position.x + chain.link_size,
                    HEIGHT / 2,
                ),
                .size = 8,
            };
        }

        return chain;
    }

    pub fn updatePosition(self: *Chain) void {
        var next_pos = self.joints[0].position;

        if (rl.isKeyDown(rl.KeyboardKey.key_up)) {
            next_pos.y -= 5;
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_down)) {
            next_pos.y += 5;
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_left)) {
            next_pos.x -= 5;
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_right)) {
            next_pos.x += 5;
        }
        self.joints[0].position = self.joints[0].position.moveTowards(next_pos, 5);
        self.moveBody();
    }

    fn moveBody(self: *Chain) void {
        var i: usize = 1;
        while (i < self.joints.len) : (i += 1) {
            constraintDistance(&self.joints[i - 1], &self.joints[i], self.link_size);
        }
    }

    pub fn deinit(self: *Chain, allocator: *const std.mem.Allocator) void {
        allocator.free(self.joints);
    }
};

fn constraintDistance(head: *Link, tail: *Link, link_size: f32) void {
    const delta = head.position.subtract(tail.position);
    const current_distance = rl.Vector2.length(delta);
    if (current_distance == 0.0) return;

    const scale = link_size / current_distance;
    const direction = rl.Vector2{
        .x = delta.x * scale,
        .y = delta.y * scale,
    };

    tail.position = head.position.subtract(direction);
}
