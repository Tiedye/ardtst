const std = @import("std");
const zserial = @import("serial");

const Command = @import("command.zig").Command;

pub fn main() !void {
    const serial = try std.fs.openFileAbsolute(
        "/dev/ttyACM0",
        .{ .mode = .read_write },
    );
    defer serial.close();

    try zserial.configureSerialPort(serial, .{
        .baud_rate = 9600,
        .word_size = 8,
        .parity = .none,
        .stop_bits = .one,
        .handshake = .none,
    });

    // while (true) {
    //     var v: u16 = 0;
    //     const n = try serial.readAll(std.mem.asBytes(&v));
    //     try zserial.flushSerialPort(serial, true, false);
    //     if (n == 0) {
    //         break;
    //     }
    //     std.debug.print("{x} {any}\n", .{ v, std.mem.asBytes(&v).* });
    // }

    var v: u16 = 0;
    while (true) {
        // std.time.sleep(1_000_000_000);
        std.debug.print("try write\n", .{});
        try serial.writeAll(std.mem.asBytes(&v));
        // try zserial.flushSerialPort(serial, true, true);
        // const bytes = std.mem.toBytes(v)[0..];
        // const bytes = &[_]u8{ 0x00, 0x00 };
        // std.debug.print("try write {}\n", .{bytes.len});
        // try serial.writeAll(bytes);
        // try serial.writeAll(bytes[0..1]);
        // try serial.writeAll(bytes[1..2]);
        // try serial.writeAll(std.mem.asBytes(&v));
        // try zserial.flushSerialPort(serial, true, true);
        std.debug.print("try read\n", .{});
        const n = try serial.readAll(std.mem.asBytes(&v));
        if (n == 0) {
            break;
        }
        std.debug.print("{}\n", .{v});
    }

    // var buffer: [1024]u8 = undefined;

    // while (true) {
    //     const n = try port.read(buffer[0..]);
    //     if (n == 0) {
    //         break;
    //     }
    //     _ = try std.io.getStdOut().write(buffer[0..n]);
    // }
}
