const std = @import("std");
const mscl_zig = @import("mscl_zig");

pub fn main(init: std.process.Init) !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer: std.Io.File.Writer =
        .init(.stdout(), init.io, &stdout_buffer);
    const stdout = &stdout_writer.interface;

    const base_stations = mscl_zig.BaseStations.list() catch |err| {
        std.log.err("{t}: {s}", .{ err, mscl_zig.mscl.mscl_last_error() });
        return err;
    };
    defer base_stations.deinit();

    if (base_stations.devices.len == 0) {
        try stdout.writeAll("No base stations found.\n");
        try stdout.flush();
        return;
    }
    const device = base_stations.devices[0];
    // MSCL terminates the port with a NUL.
    const port: [*:0]const u8 = @ptrCast(&device.port);

    const base_station = mscl_zig.BaseStation.init(
        init.gpa,
        port,
        .{ .baud_rate = device.baud_rate },
    ) catch |err| {
        std.log.err("{t}: {s}", .{ err, mscl_zig.mscl.mscl_last_error() });
        return err;
    };
    defer base_station.deinit(init.gpa);

    try stdout.print("State of the base station on {s}\n", .{port});
    try printState(stdout, base_station.state);
    try stdout.flush();
}

fn printState(
    stdout: *std.Io.Writer,
    state: mscl_zig.BaseStation.State,
) std.Io.Writer.Error!void {
    try stdout.print(
        \\  model: {?t}
        \\  serial: {?s}
        \\  name: {?s}
        \\
    , .{ state.model, state.serial, state.name });
    if (state.firmware_version) |version| {
        try stdout.print("  firmware version: {f}\n", .{version});
    } else {
        try stdout.writeAll("  firmware version: null\n");
    }
    try stdout.print(
        \\  microcontroller: {?t}
        \\  region code: {?t}
        \\  frequency: {?t}
        \\
    , .{ state.microcontroller, state.region_code, state.frequency });
    if (state.beacon_status) |beacon| {
        try stdout.print("  beacon: enabled: {}, timestamp: {d} ns\n", .{
            beacon.enabled,
            beacon.timestamp_ns,
        });
    } else {
        try stdout.writeAll("  beacon: null\n");
    }
}
