const hal = @import("microzig").hal;
const gpio = @import("microzig").hal.gpio;
const micro = @import("microzig");
const std = @import("std");

const Port = hal.Uart(0, .{});
const led = hal.parsePin(micro.board.pin_map.D13);

pub fn main() !void {
    const serial = try Port.init(.{
        .baud_rate = 9600,
        .parity = null,
        .stop_bits = .one,
        .data_bits = .eight,
    });
    gpio.setOutput(led);
    gpio.write(led, .low);
    // var v: u16 = 0;
    while (true) {
        // busyloop(100_000);
        gpio.toggle(led);
        const v = read(u16, serial);
        busyloop(1_000_000);
        // gpio.toggle(led);
        write(v + 1, serial);

        // gpio.toggle(led);
        // v += 1;
        // write(v, serial);
        // write("hello world\n", serial);
    }
}

fn write(value: anytype, serial: Port) void {
    var bytes = switch (@typeInfo(@TypeOf(value))) {
        .Pointer => std.mem.asBytes(value),
        else => std.mem.asBytes(&value),
    };
    for (bytes) |byte| {
        serial.tx(byte);
    }
}

fn read(comptime T: type, serial: Port) T {
    var value: T = undefined;
    for (std.mem.asBytes(&value)) |*byte| {
        byte.* = serial.rx();
    }
    return value;
}

fn read_buf(buffer: *[]u8, serial: Port) void {
    for (buffer) |*byte| {
        byte.* = serial.rx();
    }
}

fn busyloop(comptime cycles: comptime_int) void {
    var remaining_cycles: u24 = cycles;
    while (remaining_cycles > 0) : (remaining_cycles -= 1) {
        asm volatile ("");
    }
}
