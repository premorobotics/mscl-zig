const std = @import("std");
const mscl_zig = @import("mscl_zig");

pub fn main(init: std.process.Init) !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer: std.Io.File.Writer =
        .init(.stdout(), init.io, &stdout_buffer);
    const stdout = &stdout_writer.interface;

    const args = try init.minimal.args.toSlice(init.arena.allocator());
    if (args.len != 2) {
        std.log.err("usage: {s} <node address>", .{args[0]});
        return error.InvalidArguments;
    }
    const address = std.fmt.parseInt(u32, args[1], 10) catch |err| {
        std.log.err("{t}: node address must be a number", .{err});
        return err;
    };

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

    const node = mscl_zig.Node.init(
        init.gpa,
        base_station,
        address,
    ) catch |err| {
        std.log.err("{t}: {s}", .{ err, mscl_zig.mscl.mscl_last_error() });
        return err;
    };
    defer node.deinit(init.gpa);

    try stdout.print("Node {d} through the base station on {s}\n", .{
        address,
        port,
    });
    const features = node.features;
    try stdout.writeAll("  supports:\n");
    const Supports = @TypeOf(features.supports);
    inline for (@typeInfo(Supports).@"struct".field_names) |name| {
        try stdout.print("    {s}: {}\n", .{
            name,
            @field(features.supports, name),
        });
    }
    try stdout.print(
        \\  sensor delay (us): min {?d}, max {?d}, default {?d}
        \\  inactivity timeout (s): min {d}
        \\  lost beacon timeout (min): min {d}, max {d}
        \\  check radio interval (s): min {d}, max {d}
        \\  sweeps: min {d}
        \\  damage angle count: {d}
        \\  sn curve segment count: {d}
        \\  event trigger count: {d}
        \\  adc voltage input type: {t}
        \\
    , .{
        features.sensor_delay.min,
        features.sensor_delay.max,
        features.sensor_delay.default,
        features.timeout.inactivity,
        features.timeout.lost_beacon.min,
        features.timeout.lost_beacon.max,
        features.check_radio_interval.min,
        features.check_radio_interval.max,
        features.sweeps.min(),
        features.damage_angle_count,
        features.sn_curve_segment_count,
        features.event_trigger_count,
        features.adc_voltage_input_type,
    });
    try printList(stdout, "sampling modes", features.sampling_modes);
    try printList(stdout, "data formats", features.data_formats);
    try printList(stdout, "default modes", features.default_modes);
    try printList(
        stdout,
        "data collection methods",
        features.data_collection_methods,
    );
    try printList(stdout, "comm protocols", features.comm_protocols);
    try printList(stdout, "data modes", features.data_modes);
    try printList(stdout, "transducer types", features.transducer_types);
    try printList(stdout, "fatigue modes", features.fatigue_modes);
    try printList(stdout, "derived data rates", features.derived_data_rates);
    try printList(
        stdout,
        "sensor output modes",
        features.sensor_output_modes,
    );
    try printList(stdout, "cfc filters", features.cfc_filters);
    try printList(
        stdout,
        "histogram transmit rates",
        features.histogram_transmit_rates,
    );
    try printList(
        stdout,
        "storage limit modes",
        features.storage_limit_modes,
    );
    try printList(
        stdout,
        "excitation voltages",
        features.excitation_voltages,
    );
    try printList(
        stdout,
        "anti-aliasing filters",
        features.filter.anti_aliasing,
    );
    try printList(stdout, "low-pass filters", features.filter.low_pass);
    try printList(stdout, "high-pass filters", features.filter.high_pass);
    try printTransmitPowers(stdout, &features, .lxrs);
    try printTransmitPowers(stdout, &features, .lxrs_plus);
    try printChannels(stdout, features.channels);
    try printChannelGroups(stdout, features.channel_groups);
    try printDerivedCategories(stdout, features.channels_per_derived_category);
    try stdout.flush();
}

fn printList(
    stdout: *std.Io.Writer,
    label: []const u8,
    values: anytype,
) std.Io.Writer.Error!void {
    try stdout.print("  {s}:", .{label});
    if (values.len == 0) {
        try stdout.writeAll(" none");
    }
    for (values) |value| {
        try stdout.print(" {t}", .{value});
    }
    try stdout.writeAll("\n");
}

fn printTransmitPowers(
    stdout: *std.Io.Writer,
    features: *const mscl_zig.Node.Features,
    protocol: mscl_zig.CommProtocol,
) std.Io.Writer.Error!void {
    const powers = switch (protocol) {
        .lxrs => features.transmit_powers.lxrs,
        .lxrs_plus => features.transmit_powers.lxrs_plus,
        _ => &.{},
    };
    try stdout.print("  {t} transmit powers:", .{protocol});
    if (powers.len == 0) {
        try stdout.writeAll(" not supported\n");
        return;
    }
    for (powers) |power| {
        try stdout.print(" {t}", .{power});
    }
    try stdout.print(" (max {?t}, min {?t})\n", .{
        features.transmit_powers.max(protocol, .{}),
        features.transmit_powers.min(protocol, .{}),
    });
}

fn printChannels(
    stdout: *std.Io.Writer,
    channels: []const mscl_zig.mscl.mscl_wireless_channel,
) std.Io.Writer.Error!void {
    try stdout.writeAll("  channels:\n");
    for (channels) |*channel| {
        const channel_type: mscl_zig.ChannelType =
            @fromBackingInt(channel.type);
        try stdout.print("    ch{d} {s}: {t}, {s}\n", .{
            channel.channel_number,
            std.mem.sliceTo(&channel.name, 0),
            channel_type,
            std.mem.sliceTo(&channel.description, 0),
        });
    }
}

fn printChannelGroups(
    stdout: *std.Io.Writer,
    groups: []const mscl_zig.mscl.mscl_channel_group,
) std.Io.Writer.Error!void {
    try stdout.writeAll("  channel groups:\n");
    for (groups) |*group| {
        try stdout.print("    {s} (channels 0b{b:0>16}):", .{
            std.mem.sliceTo(&group.name, 0),
            group.channels,
        });
        for (group.settings[0..group.setting_count]) |raw| {
            const setting: mscl_zig.ChannelGroupSetting = @fromBackingInt(raw);
            try stdout.print(" {t}", .{setting});
        }
        try stdout.writeAll("\n");
    }
}

fn printDerivedCategories(
    stdout: *std.Io.Writer,
    masks: []const mscl_zig.mscl.mscl_derived_channel_mask,
) std.Io.Writer.Error!void {
    try stdout.writeAll("  channels per derived category:");
    if (masks.len == 0) {
        try stdout.writeAll(" none");
    }
    try stdout.writeAll("\n");
    for (masks) |mask| {
        const category: mscl_zig.DerivedCategory =
            @fromBackingInt(mask.category);
        try stdout.print("    {t}: 0b{b:0>16}\n", .{ category, mask.mask });
    }
}
