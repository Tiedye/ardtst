const std = @import("std");
const zserial = @import("serial");

const Command = @import("command.zig").Command;
const assert = std.debug.assert;

fn setAbortSignalHandler(comptime handler: *const fn () void) !void {
    const internal_handler = struct {
        fn internal_handler(sig: c_int) callconv(.C) void {
            assert(sig == std.os.SIG.INT);
            handler();
        }
    }.internal_handler;
    const act = std.os.Sigaction{
        .handler = .{ .handler = internal_handler },
        .mask = std.os.empty_sigset,
        .flags = 0,
    };
    try std.os.sigaction(std.os.SIG.INT, &act, null);
}

pub fn main() !void {
    const serial = try std.fs.openFileAbsolute(
        "/dev/ttyACM0",
        .{ .mode = .read_write },
    );
    defer serial.close();
    defer std.debug.print("exiting\n", .{});

    try zserial.configureSerialPort(serial, .{
        .baud_rate = 9600,
        .word_size = 8,
        .parity = .none,
        .stop_bits = .one,
        .handshake = .none,
    });

    try zserial.flushSerialPort(serial, true, true);

    try handshake(serial);

    while (true) {
        const time = std.time.microTimestamp();
        std.debug.print("waiting for response\n", .{});
        _ = try serial.reader().readByte();
        std.debug.print("took {} microseconds\n", .{std.time.microTimestamp() - time});
    }
}

fn handshake(serial: std.fs.File) !void {
    while (true) {
        const byte = try serial.reader().readByte();
        if (byte == 1) {
            break;
        }
    }
    try serial.writer().writeByte(1);
}
