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

    try stdout.print("Base station on {s}\n", .{port});
    const features = base_station.features orelse {
        try stdout.writeAll("  MSCL does not support its model.\n");
        try stdout.flush();
        return;
    };
    try stdout.print(
        \\  supports:
        \\    buttons: {}
        \\    analog pairing: {}
        \\    beacon status: {}
        \\    rf sweep mode: {}
        \\    custom rf sweep mode: {}
        \\  button count: {d}
        \\  analog port count: {d}
        \\  transmit powers:
        \\
    , .{
        features.supports.buttons,
        features.supports.analog_pairing,
        features.supports.beacon_status,
        features.supports.rf_sweep_mode,
        features.supports.custom_rf_sweep_mode,
        features.button_count,
        features.analog_port_count,
    });
    try printTransmitPowers(stdout, "lxrs", features.transmit_powers.lxrs);
    try printTransmitPowers(
        stdout,
        "lxrs+",
        features.transmit_powers.lxrs_plus,
    );
    try stdout.flush();
}

fn printTransmitPowers(
    stdout: *std.Io.Writer,
    protocol: []const u8,
    powers: []const mscl_zig.TransmitPower,
) std.Io.Writer.Error!void {
    try stdout.print("    {s}:", .{protocol});
    if (powers.len == 0) {
        try stdout.writeAll(" not supported");
    }
    for (powers) |power| {
        try stdout.print(" {t}", .{power});
    }
    try stdout.writeAll("\n");
}
