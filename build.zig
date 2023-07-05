const std = @import("std");
const atmega = @import("deps/microchip-atmega/build.zig");

const microzig = @import("deps/microchip-atmega/deps/microzig/build.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const serialMod = b.createModule(.{
        .source_file = .{ .path = "deps/serial/src/serial.zig" },
    });

    const exe = b.addExecutable(.{
        .name = "readhx711",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    exe.addModule("serial", serialMod);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    var embedded_exe = microzig.addEmbeddedExecutable(b, .{
        .name = "driver",
        .source_file = .{
            .path = "src/driver/main.zig",
        },
        .backing = .{
            .board = atmega.boards.arduino_uno,
        },
        .optimize = .ReleaseFast,
    });
    embedded_exe.installArtifact(b);
}
