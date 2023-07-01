const std = @import("std");

const Command = union(enum) {
    tare: .{},
    calibrate: struct { amount: f32 },
    start: .{},
    stop: .{},
    read: .{},
    fetch: .{},

    fn parse(reader: anytype) !Command {
        var buf: [128]u8 = undefined;
        var cmd = try reader.readUntilDelimiter(&buf, '\n');
        const cmd_iter = std.mem.split(u8, cmd, ' ');
        const cmd_name = cmd_iter.next() orelse return error.NoCommand;
        _ = cmd_name;
    }
};
