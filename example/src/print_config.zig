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
        device.baud_rate,
    ) catch |err| {
        std.log.err("{t}: {s}", .{ err, mscl_zig.mscl.mscl_last_error() });
        return err;
    };
    defer base_station.deinit(init.gpa);

    const config = base_station.getConfig(init.gpa) catch |err| {
        std.log.err("{t}: {s}", .{ err, mscl_zig.mscl.mscl_last_error() });
        return err;
    };
    defer config.deinit(init.gpa);

    try stdout.print("Config of the base station on {s}\n", .{port});
    try printConfig(stdout, config);
    try stdout.flush();
}

fn printConfig(
    stdout: *std.Io.Writer,
    config: mscl_zig.BaseStation.Config,
) std.Io.Writer.Error!void {
    try stdout.print(
        \\  transmit power: {?t}
        \\  communication protocol: {?t}
        \\
    , .{ config.transmit_power, config.communication_protocol });
    try printButtons(stdout, "button long press", config.button_long_press);
    try printButtons(stdout, "button short press", config.button_short_press);
    try stdout.print(
        \\  analog pairing enable: {?}
        \\  analog timeout time (s): {?d}
        \\  analog timeout voltage (V): {?d}
        \\  analog exceedance enable: {?}
        \\  analog pairing:
    , .{
        config.analog_pairing_enable,
        config.analog_timeout_time,
        config.analog_timeout_voltage,
        config.analog_exceedance_enable,
    });
    if (config.analog_pairing.len == 0) {
        try stdout.writeAll(" none");
    }
    try stdout.writeAll("\n");
    for (config.analog_pairing) |numbered| {
        try stdout.print(
            "    port {d}: node {d}, channel {d}, float data: {}, " ++
                "0 V = {d}, 3 V = {d}\n",
            .{
                numbered.number,
                numbered.pair.node_address,
                numbered.pair.node_channel,
                numbered.pair.expect_float_data,
                numbered.pair.output_0v,
                numbered.pair.output_3v,
            },
        );
    }
}

fn printButtons(
    stdout: *std.Io.Writer,
    label: []const u8,
    buttons: []const mscl_zig.BaseStation.Config.NumberedButton,
) std.Io.Writer.Error!void {
    try stdout.print("  {s}:", .{label});
    if (buttons.len == 0) {
        try stdout.writeAll(" none");
    }
    try stdout.writeAll("\n");
    for (buttons) |numbered| {
        try stdout.print("    button {d}: {t}, node {d}\n", .{
            numbered.number,
            numbered.button.command,
            numbered.button.node_address,
        });
    }
}
