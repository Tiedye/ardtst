const std = @import("std");
const zserial = @import("serial");

const Command = @import("command.zig").Command;
const assert = std.debug.assert;

pub fn main() !void {
    const serial = try std.fs.openFileAbsolute(
        "/dev/ttyACM0",
        .{ .mode = .read_write },
    );
    defer serial.close();
    defer std.debug.print("exiting\n", .{});

    try zserial.configureSerialPort(serial, .{
        .baud_rate = 9600,
    });

    try zserial.flushSerialPort(serial, true, true);

    try handshake(serial);
    std.debug.print("handshake completed\n", .{});

    while (true) {
        const value = try serial.reader().readIntLittle(i24);
        std.debug.print("value: {any}\n", .{value});
    }
}

fn handshake(serial: std.fs.File) !void {
    while (true) {
        const byte = try serial.reader().readByte();
        if (byte == 'A') {
            break;
        }
    }
    try serial.writer().writeByte(1);
}
