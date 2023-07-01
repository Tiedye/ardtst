const micro = @import("microzig");
const hal = micro.hal;
const gpio = hal.gpio;
const std = @import("std");
const HX711 = @import("hx711.zig").HX711;
const Serial = @import("serial.zig").Serial;

const led = hal.parsePin(micro.board.pin_map.D13);
const pd_sck = hal.parsePin(micro.board.pin_map.D7);
const dout = hal.parsePin(micro.board.pin_map.D6);

pub fn main() !void {
    const hx711 = HX711(pd_sck, dout);
    const serial = try Serial.init(.{
        .baud_rate = 9600,
        .parity = null,
        .stop_bits = .one,
        .data_bits = .eight,
    });
    hx711.init();
    gpio.setOutput(led);
    gpio.write(led, .low);
    handshake(serial);
    gpio.write(led, .high);
    while (true) {
        const value = hx711.read();
        try serial.writer().writeIntLittle(i24, value);
    }
}

fn handshake(serial: Serial) void {
    while (!serial.port.canRead()) {
        _ = try serial.write("A");
        delayMicroseconds(100_000);
    }
    var buf: [1]u8 = undefined;
    _ = serial.read(&buf);
}

fn delayMicroseconds(comptime microseconds: comptime_int) void {
    var remaining_cycles: u32 = microseconds;
    while (remaining_cycles > 0) : (remaining_cycles -= 1) {
        asm volatile (
            \\nop
            \\nop
            \\nop
        );
    }
}
