const std = @import("std");
const io = std.io;
const hal = @import("microzig").hal;
const gpio = @import("microzig").hal.gpio;
const Port = hal.Uart(0, .{});

pub const Serial = struct {
    const Self = @This();

    port: Port,

    pub fn init(config: anytype) !Serial {
        var port = try Port.init(config);
        return Self{ .port = port };
    }

    pub fn read(self: Serial, buffer: []u8) usize {
        for (buffer) |*byte| {
            byte.* = self.port.rx();
        }
        return buffer.len;
    }

    pub const Reader = io.Reader(Serial, error{}, read);

    pub fn reader(self: Serial) Reader {
        return .{ .context = self };
    }

    pub fn write(self: Serial, buffer: []const u8) !usize {
        for (buffer) |byte| {
            self.port.tx(byte);
        }
        return buffer.len;
    }

    pub const Writer = io.Writer(Serial, error{}, write);

    pub fn writer(self: Serial) Writer {
        return .{ .context = self };
    }
};
