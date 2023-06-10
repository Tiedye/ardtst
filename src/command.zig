const Command = union(enum) {
    tare: .{},
    calibrate: struct { amount: f32 },
    start: .{},
    stop: .{},
    read: .{},
    fetch: .{},
};
