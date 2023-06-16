const std = @import("std");
const atmega = @import("deps/microchip-atmega/build.zig");

const microzig = @import("deps/microchip-atmega/deps/microzig/build.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "ardtst",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    var embedded_exe = microzig.addEmbeddedExecutable(b, .{
        .name = "embedded",
        .source_file = .{
            .path = "src/embedded.zig",
        },
        .backing = .{
            .board = atmega.boards.arduino_uno,
        },
        .optimize = .ReleaseFast,
    });
    embedded_exe.installArtifact(b);

    const serial = b.createModule(.{
        .source_file = .{ .path = "deps/serial/src/serial.zig" },
    });
    exe.addModule("serial", serial);
}
