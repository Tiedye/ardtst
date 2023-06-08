const std = @import("std");

const Command = union(enum) {
    tare: .{},
    calibrate: struct { amount: f32 },
    start: .{},
    stop: .{},
    read: .{},
    fetch: .{},

    fn encode(self: Command, buffer: []u8) void {
        switch (self) {
            .tare => buffer[0] = 0x01,
            .calibrate => |calibrate_cmd| {
                buffer[0] = 0x02;
                std.mem.copy(buffer[1..], std.mem.asBytes(&calibrate_cmd.amount));
            },
            .start => buffer[0] = 0x03,
            .stop => buffer[0] = 0x04,
            .read => buffer[0] = 0x05,
            .fetch => buffer[0] = 0x06,
        }
    }
};

fn configurePort(handle: std.os.fd_t) !void {
    var settings = try std.os.tcgetattr(handle);
    const os = std.os.linux;
    const CBAUD = 0o000000010017;
    settings.iflag = 0;
    settings.oflag = 0;
    settings.cflag = os.CREAD;
    settings.lflag = 0;
    settings.ispeed = 0;
    settings.ospeed = 0;

    settings.cflag |= os.CLOCAL;
    settings.cflag |= os.CS8;

    const baudmask = os.B115200;
    settings.cflag &= ~@as(os.tcflag_t, CBAUD);
    settings.cflag |= baudmask;
    settings.ispeed = baudmask;
    settings.ospeed = baudmask;

    try std.os.tcsetattr(handle, .NOW, settings);
}

pub fn main() !void {
    const port = try std.fs.openFileAbsolute("/dev/ttyACM0", .{ .mode = .read_write });
    defer port.close();

    try configurePort(port.handle);

    var buffer: [1024]u8 = undefined;

    while (true) {
        const n = try port.read(buffer[0..]);
        if (n == 0) {
            break;
        }
        _ = try std.io.getStdOut().write(buffer[0..n]);
    }

    // // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    // std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // // stdout is for the actual output of your application, for example if you
    // // are implementing gzip, then only the compressed bytes should be sent to
    // // stdout, not any debugging messages.
    // const stdout_file = std.io.getStdOut().writer();
    // var bw = std.io.bufferedWriter(stdout_file);
    // const stdout = bw.writer();

    // try stdout.print("Run `zig build test` to run the tests.\n", .{});

    // try bw.flush(); // don't forget to flush!
}
