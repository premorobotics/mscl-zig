const std = @import("std");
const root = @import("root.zig");
const mscl = root.mscl;
const BaseStation = @import("BaseStation.zig");

const Node = @This();
pub const Config = @import("Node/Config.zig");
pub const Features = @import("Node/Features.zig");

handle: *mscl.mscl_node,
features: Features,

pub const Error = error{
    Connection,
    NodeCommunication,
    NotSupported,
    InvalidConfig,
    /// Any other failure; `root.mscl.mscl_last_error()` describes it.
    MsclFailure,
};

/// Creates a WirelessNode object with the given node address and parent
/// BaseStation.
pub fn init(
    gpa: std.mem.Allocator,
    base_station: BaseStation,
    address: u32,
) (Error || std.mem.Allocator.Error)!Node {
    var handle: ?*mscl.mscl_node = null;
    const status =
        mscl.mscl_node_create(base_station.handle, address, &handle);
    switch (status) {
        mscl.MSCL_OK => {},
        else => {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            return Error.MsclFailure;
        },
    }
    const node = handle.?;
    errdefer mscl.mscl_node_destroy(node);
    return .{ .handle = node, .features = try Features.init(gpa, node) };
}

/// Destroys the node. Deinitialize everything using this node first.
pub fn deinit(self: Node, gpa: std.mem.Allocator) void {
    self.features.deinit(gpa);
    mscl.mscl_node_destroy(self.handle);
}

/// Reads the settings that a WirelessNodeConfig can hold from the Node, with
/// the per-channel settings of `channels`. A setting that the Node does not
/// support for `channels` is null or empty. The equation type cannot be read
/// from the Node, so it is always null.
/// Free the result with `Config.deinit`.
pub fn getConfig(
    self: Node,
    gpa: std.mem.Allocator,
    channels: root.ChannelMask,
) (Error || std.mem.Allocator.Error)!Config {
    var result: Config = std.mem.zeroInit(Config, .{});
    errdefer result.deinit(gpa);

    // A setting that the Node does not support stays null.
    result.default_mode = self.getDefaultMode() catch |err| switch (err) {
        Error.NotSupported => null,
        else => |e| {
            return e;
        },
    };
    result.inactivity_timeout =
        self.getInactivityTimeout() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.check_radio_interval =
        self.getCheckRadioInterval() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.transmit_power = self.getTransmitPower() catch |err| switch (err) {
        Error.NotSupported => null,
        else => |e| {
            return e;
        },
    };
    result.sampling_mode = self.getSamplingMode() catch |err| switch (err) {
        Error.NotSupported => null,
        else => |e| {
            return e;
        },
    };
    result.sample_rate = self.getSampleRate() catch |err| switch (err) {
        Error.NotSupported => null,
        else => |e| {
            return e;
        },
    };
    result.num_sweeps = self.getNumSweeps() catch |err| switch (err) {
        Error.NotSupported => null,
        else => |e| {
            return e;
        },
    };
    result.unlimited_duration =
        self.getUnlimitedDuration() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.data_format = self.getDataFormat() catch |err| switch (err) {
        Error.NotSupported => null,
        else => |e| {
            return e;
        },
    };
    result.data_collection_method =
        self.getDataCollectionMethod() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.time_between_bursts =
        self.getTimeBetweenBursts() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.lost_beacon_timeout =
        self.getLostBeaconTimeout() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.cfc_filter_config =
        self.getCfcFilterConfiguration() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.gauge_resistance =
        self.getGaugeResistance() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.excitation_voltage =
        self.getExcitationVoltage() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.num_active_gauges =
        self.getNumActiveGauges() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.low_battery_threshold =
        self.getLowBatteryThreshold() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.fatigue_options = self.getFatigueOptions() catch |err| switch (err) {
        Error.NotSupported => null,
        else => |e| {
            return e;
        },
    };
    result.histogram_options =
        self.getHistogramOptions() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.activity_sense = self.getActivitySense() catch |err| switch (err) {
        Error.NotSupported => null,
        else => |e| {
            return e;
        },
    };
    result.event_trigger_options =
        self.getEventTriggerOptions() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.diagnostic_interval =
        self.getDiagnosticInterval() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.storage_limit_mode =
        self.getStorageLimitMode() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.sensor_delay = self.getSensorDelay() catch |err| switch (err) {
        Error.NotSupported => null,
        else => |e| {
            return e;
        },
    };
    result.data_mode = self.getDataMode() catch |err| switch (err) {
        Error.NotSupported => null,
        else => |e| {
            return e;
        },
    };
    result.derived_data_rate =
        self.getDerivedDataRate() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.derived_velocity_unit =
        self.getDerivedVelocityUnit() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.communication_protocol =
        self.getCommunicationProtocol() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.sensor_output_mode =
        self.getSensorOutputMode() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };

    const categories = self.features.channels_per_derived_category;
    const derived_channel_masks =
        try gpa.alloc(mscl.mscl_derived_channel_mask, categories.len);
    result.derived_channel_masks = derived_channel_masks;
    for (derived_channel_masks, categories) |*derived, supported| {
        const category: root.DerivedCategory =
            @fromBackingInt(supported.category);
        derived.* = .{
            .category = supported.category,
            .mask = @bitCast(try self.getDerivedChannelMask(category)),
        };
    }

    result.input_range =
        self.getInputRange(channels) catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.hardware_offset =
        self.getHardwareOffset(channels) catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.anti_aliasing_filter =
        self.getAntiAliasingFilter(channels) catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.low_pass_filter =
        self.getLowPassFilter(channels) catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.high_pass_filter =
        self.getHighPassFilter(channels) catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.gauge_factor =
        self.getGaugeFactor(channels) catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.linear_equation =
        self.getLinearEquation(channels) catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.unit = self.getUnit(channels) catch |err| switch (err) {
        Error.NotSupported => null,
        else => |e| {
            return e;
        },
    };
    result.filter_settling_time =
        self.getFilterSettlingTime(channels) catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.thermocouple_type =
        self.getThermocoupleType(channels) catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.temp_sensor_options =
        self.getTempSensorOptions(channels) catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.debounce_filter =
        self.getDebounceFilter(channels) catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.pull_up_resistor =
        self.getPullUpResistor(channels) catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    return result;
}

/// Applies a WirelessNodeConfig to the Node. Note: This applies all options
/// that have been set in the WirelessNodeConfig. Before applying, the options
/// will be validated. Options that are set will also be validated against each
/// other. If an option that needs to be validated isn't currently set, it will
/// be read from the Node.
/// The per-channel settings of `config` are applied to `channels`.
/// When the options are not valid, nothing is applied, `issues` receives one
/// line per problem, NUL-terminated and truncated to fit, and InvalidConfig is
/// returned.
pub fn applyConfig(
    self: Node,
    config: Config,
    channels: root.ChannelMask,
    issues: []u8,
) (Error || std.mem.Allocator.Error)!void {
    const mscl_config = try config.createHandle(channels);
    defer mscl.mscl_node_config_destroy(mscl_config);

    var ok = false;
    const verify_status = mscl.mscl_node_verify_config(
        self.handle,
        mscl_config,
        &ok,
        issues.ptr,
        issues.len,
    );
    switch (verify_status) {
        mscl.MSCL_OK => {},
        // The Node model, or firmware version, is not supported by MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => {
            return Error.NotSupported;
        },
        // Failed to communicate with the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => {
            return Error.NodeCommunication;
        },
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => {
            return Error.Connection;
        },
        else => {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            return Error.MsclFailure;
        },
    }
    if (!ok) {
        // The configuration is invalid; `issues` lists why.
        return Error.InvalidConfig;
    }

    const apply_status = mscl.mscl_node_apply_config(self.handle, mscl_config);
    return switch (apply_status) {
        mscl.MSCL_OK => {},
        // The Node model, or firmware version, is not supported by MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Invalid Configuration. Check the exception for specific details.
        mscl.MSCL_ERROR_INVALID_CONFIG => Error.InvalidConfig,
        // Failed to write to the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Sets which channels are active on the Node. When the sample rate currently
/// set on the Node is faster than the max the Node supports with `channels`,
/// the sample rate is lowered to that max in the same apply.
/// When the options are not valid, nothing is applied, `issues` receives one
/// line per problem, NUL-terminated and truncated to fit, and InvalidConfig is
/// returned.
pub fn setActiveChannels(
    self: Node,
    channels: root.ChannelMask,
    issues: []u8,
) (Error || Features.Error || std.mem.Allocator.Error)!void {
    const sampling_mode = try self.getSamplingMode();
    const collection_method = try self.getDataCollectionMethod();
    const data_mode = try self.getDataMode();
    const sample_rate = try self.getSampleRate();
    const max = try self.features.sample_rate.max(
        sampling_mode,
        channels,
        collection_method,
        data_mode,
    );
    const rate_count = @typeInfo(root.SampleRate).@"enum".field_names.len;
    var buffer: [rate_count]root.SampleRate = undefined;
    const rates = try self.features.sample_rate.list(
        sampling_mode,
        collection_method,
        data_mode,
        &buffer,
    );
    // The rates are listed from the fastest, so a rate listed before the max
    // is faster than the max.
    const max_index = std.mem.findScalar(root.SampleRate, rates, max);
    const rate_index = std.mem.findScalar(root.SampleRate, rates, sample_rate);

    var handle: ?*mscl.mscl_node_config = null;
    const create_status = mscl.mscl_node_config_create(&handle);
    switch (create_status) {
        mscl.MSCL_OK => {},
        // Allocating the config failed.
        mscl.MSCL_ERROR_OUT_OF_MEMORY => {
            return std.mem.Allocator.Error.OutOfMemory;
        },
        else => unreachable,
    }
    const mscl_config = handle.?;
    defer mscl.mscl_node_config_destroy(mscl_config);

    _ = mscl.mscl_node_config_set_active_channels(
        mscl_config,
        @bitCast(channels),
    );
    if (max_index != null and rate_index != null and
        rate_index.? < max_index.?)
    {
        _ = mscl.mscl_node_config_set_sample_rate(
            mscl_config,
            @backingInt(max),
        );
    }

    var ok = false;
    const verify_status = mscl.mscl_node_verify_config(
        self.handle,
        mscl_config,
        &ok,
        issues.ptr,
        issues.len,
    );
    switch (verify_status) {
        mscl.MSCL_OK => {},
        // The Node model, or firmware version, is not supported by MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => {
            return Error.NotSupported;
        },
        // Failed to communicate with the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => {
            return Error.NodeCommunication;
        },
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => {
            return Error.Connection;
        },
        else => {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            return Error.MsclFailure;
        },
    }
    if (!ok) {
        // The configuration is invalid; `issues` lists why.
        return Error.InvalidConfig;
    }

    const apply_status = mscl.mscl_node_apply_config(self.handle, mscl_config);
    return switch (apply_status) {
        mscl.MSCL_OK => {},
        // The Node model, or firmware version, is not supported by MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Invalid Configuration. Check the exception for specific details.
        mscl.MSCL_ERROR_INVALID_CONFIG => Error.InvalidConfig,
        // Failed to write to the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the ChannelMask currently set on the Node, representing which channels
/// are enabled and disabled.
pub fn getActiveChannels(self: Node) Error!root.ChannelMask {
    var mask: u16 = 0;
    const status = mscl.mscl_node_get_active_channels(self.handle, &mask);
    return switch (status) {
        mscl.MSCL_OK => @bitCast(mask),
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the Input Range of the specified ChannelMask currently set on the
/// Node.
pub fn getInputRange(
    self: Node,
    channel_mask: root.ChannelMask,
) Error!root.InputRange {
    var range: mscl.mscl_input_range = 0;
    const status = mscl.mscl_node_get_input_range(
        self.handle,
        @bitCast(channel_mask),
        &range,
    );
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(range),
        // Input range is not supported for the provided ChannelMask.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the hardware offset of the specified ChannelMask currently set on the
/// Node.
pub fn getHardwareOffset(self: Node, channel_mask: root.ChannelMask) Error!u16 {
    var offset: u16 = 0;
    const status = mscl.mscl_node_get_hardware_offset(
        self.handle,
        @bitCast(channel_mask),
        &offset,
    );
    return switch (status) {
        mscl.MSCL_OK => offset,
        // Hardware offset is not supported for the provided ChannelMask.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the Anti-Aliasing Filter of the specified ChannelMask currently set on
/// the Node.
pub fn getAntiAliasingFilter(
    self: Node,
    channel_mask: root.ChannelMask,
) Error!root.Filter {
    var filter: mscl.mscl_filter = 0;
    const status = mscl.mscl_node_get_anti_aliasing_filter(
        self.handle,
        @bitCast(channel_mask),
        &filter,
    );
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(filter),
        // Anti-Aliasing Filter is not supported for the provided ChannelMask.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the Low-Pass Filter of the specified ChannelMask currently set on the
/// Node.
pub fn getLowPassFilter(
    self: Node,
    channel_mask: root.ChannelMask,
) Error!root.Filter {
    var filter: mscl.mscl_filter = 0;
    const status = mscl.mscl_node_get_low_pass_filter(
        self.handle,
        @bitCast(channel_mask),
        &filter,
    );
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(filter),
        // Low-Pass Filter is not supported for the provided ChannelMask.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the High-Pass Filter of the specified ChannelMask currently set on the
/// Node.
pub fn getHighPassFilter(
    self: Node,
    channel_mask: root.ChannelMask,
) Error!root.HighPassFilter {
    var filter: mscl.mscl_high_pass_filter = 0;
    const status = mscl.mscl_node_get_high_pass_filter(
        self.handle,
        @bitCast(channel_mask),
        &filter,
    );
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(filter),
        // High-Pass Filter is not supported for the provided ChannelMask.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the Debounce Filter of the specified ChannelMask currently set on the
/// Node.
pub fn getDebounceFilter(self: Node, channel_mask: root.ChannelMask) Error!u16 {
    var milliseconds: u16 = 0;
    const status = mscl.mscl_node_get_debounce_filter(
        self.handle,
        @bitCast(channel_mask),
        &milliseconds,
    );
    return switch (status) {
        mscl.MSCL_OK => milliseconds,
        // Debounce Filter is not supported for the provided ChannelMask.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets whether the pull-up resistor is enabled on the Node.
pub fn getPullUpResistor(
    self: Node,
    channel_mask: root.ChannelMask,
) Error!bool {
    var enabled: bool = false;
    const status = mscl.mscl_node_get_pull_up_resistor(
        self.handle,
        @bitCast(channel_mask),
        &enabled,
    );
    return switch (status) {
        mscl.MSCL_OK => enabled,
        // Attempted to read an unsupported option.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the gauge factor of the specified ChannelMask currently set on the
/// Node.
pub fn getGaugeFactor(self: Node, channel_mask: root.ChannelMask) Error!f32 {
    var factor: f32 = 0;
    const status = mscl.mscl_node_get_gauge_factor(
        self.handle,
        @bitCast(channel_mask),
        &factor,
    );
    return switch (status) {
        mscl.MSCL_OK => factor,
        // Gauge Factor is not supported for the provided ChannelMask.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the linear equation of the specified ChannelMask currently set on the
/// Node.
pub fn getLinearEquation(
    self: Node,
    channel_mask: root.ChannelMask,
) Error!mscl.mscl_linear_equation {
    var equation = std.mem.zeroes(mscl.mscl_linear_equation);
    const status = mscl.mscl_node_get_linear_equation(
        self.handle,
        @bitCast(channel_mask),
        &equation,
    );
    return switch (status) {
        mscl.MSCL_OK => equation,
        // Linear Equation is not supported for the provided ChannelMask.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to communicate with the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the unit of the specified ChannelMask currently set on the Node. Note:
/// This unit is just used for reference (such as when downloading logged data)
/// and does not affect the actual data value.
pub fn getUnit(
    self: Node,
    channel_mask: root.ChannelMask,
) Error!root.CalCoefUnit {
    var unit: mscl.mscl_cal_coef_unit = 0;
    const status = mscl.mscl_node_get_unit(
        self.handle,
        @bitCast(channel_mask),
        &unit,
    );
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(unit),
        // Unit is not supported for the provided ChannelMask.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to communicate with the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the filter settling time of the specified ChannelMask currently set on
/// the Node.
pub fn getFilterSettlingTime(
    self: Node,
    channel_mask: root.ChannelMask,
) Error!root.SettlingTime {
    var settling_time: mscl.mscl_settling_time = 0;
    const status = mscl.mscl_node_get_filter_settling_time(
        self.handle,
        @bitCast(channel_mask),
        &settling_time,
    );
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(settling_time),
        // Filter Settling Time is not supported for the provided ChannelMask.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the WirelessTypes::ThermocoupleType of the specified ChannelMask
/// currently set on the Node.
pub fn getThermocoupleType(
    self: Node,
    channel_mask: root.ChannelMask,
) Error!root.ThermocoupleType {
    var thermocouple_type: mscl.mscl_thermocouple_type = 0;
    const status = mscl.mscl_node_get_thermocouple_type(
        self.handle,
        @bitCast(channel_mask),
        &thermocouple_type,
    );
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(thermocouple_type),
        // Thermocouple Type is not supported for the provided ChannelMask.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the TempSensorOptions of the specified ChannelMask currently set on
/// the Node.
pub fn getTempSensorOptions(
    self: Node,
    channel_mask: root.ChannelMask,
) Error!mscl.mscl_temp_sensor_options {
    var options = std.mem.zeroes(mscl.mscl_temp_sensor_options);
    const status = mscl.mscl_node_get_temp_sensor_options(
        self.handle,
        @bitCast(channel_mask),
        &options,
    );
    return switch (status) {
        mscl.MSCL_OK => options,
        // TempSensorOptions are not supported for the provided ChannelMask.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the ChannelMask for an individual WirelessTypes::DerivedCategory that
/// is currently set on the Node. This represents which of the actual Node's
/// channels are set to be mapped to derived channels. For example, if the mask
/// for RMS has ch1 and ch3 active, ch1RMS and ch3RMS channels will be output.
pub fn getDerivedChannelMask(
    self: Node,
    category: root.DerivedCategory,
) Error!root.ChannelMask {
    var mask: u16 = 0;
    const status = mscl.mscl_node_get_derived_channel_mask(
        self.handle,
        @backingInt(category),
        &mask,
    );
    return switch (status) {
        mscl.MSCL_OK => @bitCast(mask),
        // Derived Channels are not supported by this Node.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the WirelessTypes::DefaultMode that is currently set on the Node.
fn getDefaultMode(self: Node) Error!root.DefaultMode {
    var mode: mscl.mscl_default_mode = 0;
    const status = mscl.mscl_node_get_default_mode(self.handle, &mode);
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(mode),
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the user inactivity timeout that is currently set on the Node. This
/// controls how many seconds before the Node goes to sleep when idle.
fn getInactivityTimeout(self: Node) Error!u16 {
    var seconds: u16 = 0;
    const status = mscl.mscl_node_get_inactivity_timeout(self.handle, &seconds);
    return switch (status) {
        mscl.MSCL_OK => seconds,
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the check radio interval that is currently set on the Node. This
/// controls how often the Node wakes up from sleep to check for commands.
fn getCheckRadioInterval(self: Node) Error!u8 {
    var seconds: u8 = 0;
    const status = mscl.mscl_node_get_check_radio_interval(
        self.handle,
        &seconds,
    );
    return switch (status) {
        mscl.MSCL_OK => seconds,
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the WirelessTypes::TransmitPower that is currently set on the Node.
fn getTransmitPower(self: Node) Error!root.TransmitPower {
    var power: mscl.mscl_transmit_power = 0;
    const status = mscl.mscl_node_get_transmit_power(self.handle, &power);
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(power),
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the WirelessTypes::SamplingMode that is currently set on the Node.
fn getSamplingMode(self: Node) Error!root.SamplingMode {
    var mode: mscl.mscl_sampling_mode = 0;
    const status = mscl.mscl_node_get_sampling_mode(self.handle, &mode);
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(mode),
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the WirelessTypes::WirelessSampleRate currently set on the Node.
fn getSampleRate(self: Node) Error!root.SampleRate {
    var rate: mscl.mscl_sample_rate = 0;
    const status = mscl.mscl_node_get_sample_rate(self.handle, &rate);
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(rate),
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the number of sweeps currently set on the Node, which affects the
/// duration of sampling if unlimited duration is disabled, or the duration of
/// each burst if the sampling mode is Sync Sampling Burst.
fn getNumSweeps(self: Node) Error!u32 {
    var sweeps: u32 = 0;
    const status = mscl.mscl_node_get_num_sweeps(self.handle, &sweeps);
    return switch (status) {
        mscl.MSCL_OK => sweeps,
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets whether unlimited sampling duration is enabled on the Node.
fn getUnlimitedDuration(self: Node) Error!bool {
    var enabled: bool = false;
    const status = mscl.mscl_node_get_unlimited_duration(self.handle, &enabled);
    return switch (status) {
        mscl.MSCL_OK => enabled,
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the WirelessTypes::DataFormat that is currently set on the Node.
fn getDataFormat(self: Node) Error!root.DataFormat {
    var format: mscl.mscl_data_format = 0;
    const status = mscl.mscl_node_get_data_format(self.handle, &format);
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(format),
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the WirelessTypes::DataCollectionMethod that is currently set on the
/// Node, representing how the data will be collected. Note: this has no effect
/// if the sampling mode is Armed Datalogging, as this mode only operates in
/// "log only".
fn getDataCollectionMethod(self: Node) Error!root.DataCollectionMethod {
    var method: mscl.mscl_data_collection_method = 0;
    const status = mscl.mscl_node_get_data_collection_method(
        self.handle,
        &method,
    );
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(method),
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the amount of time between each burst currently set on the Node. This
/// is only used if the sampling mode is Synchronized Sampling Burst.
fn getTimeBetweenBursts(self: Node) Error!u64 {
    var time_ns: u64 = 0;
    const status = mscl.mscl_node_get_time_between_bursts(
        self.handle,
        &time_ns,
    );
    return switch (status) {
        mscl.MSCL_OK => time_ns,
        // Burst Sampling mode is not supported by the Node.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the lost beacon timeout, in minutes, currently set on the Node. If the
/// Node is Sync Sampling and loses the beacon for a length of time greater than
/// this value, then the node drops into a sleep mode. The Node will re-enter
/// sync sampling within 2 minutes of the beacon reappearing. Note: A value of 0
/// means the lost beacon timeout is disabled.
fn getLostBeaconTimeout(self: Node) Error!u16 {
    var minutes: u16 = 0;
    const status = mscl.mscl_node_get_lost_beacon_timeout(
        self.handle,
        &minutes,
    );
    return switch (status) {
        mscl.MSCL_OK => minutes,
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the channel frequency class filter option set on the Node.
fn getCfcFilterConfiguration(self: Node) Error!root.ChannelFrequencyClass {
    var cfc: mscl.mscl_channel_frequency_class = 0;
    const status = mscl.mscl_node_get_cfc_filter_configuration(
        self.handle,
        &cfc,
    );
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(cfc),
        // High-Pass Filter is not supported for the provided ChannelMask.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the gauge resistance currently set on the Node.
fn getGaugeResistance(self: Node) Error!u16 {
    var resistance: u16 = 0;
    const status = mscl.mscl_node_get_gauge_resistance(
        self.handle,
        &resistance,
    );
    return switch (status) {
        mscl.MSCL_OK => resistance,
        // Gauge Resistance is not supported.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the Excitation WirelessTypes::Voltage currently set on the Node.
fn getExcitationVoltage(self: Node) Error!root.Voltage {
    var voltage: mscl.mscl_voltage = 0;
    const status = mscl.mscl_node_get_excitation_voltage(self.handle, &voltage);
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(voltage),
        // Excitation Voltage is not supported.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the Number of Active Gauges currently set on the Node.
fn getNumActiveGauges(self: Node) Error!u16 {
    var count: u16 = 0;
    const status = mscl.mscl_node_get_num_active_gauges(self.handle, &count);
    return switch (status) {
        mscl.MSCL_OK => count,
        // Number of Active Gauges is not supported.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the threshold at which the low battery diagnostic flag is sent.
fn getLowBatteryThreshold(self: Node) Error!f32 {
    var voltage: f32 = 0;
    const status = mscl.mscl_node_get_low_battery_threshold(
        self.handle,
        &voltage,
    );
    return switch (status) {
        mscl.MSCL_OK => voltage,
        // Low Battery Threshold is not supported.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the FatigueOptions currently set on the Node.
fn getFatigueOptions(self: Node) Error!mscl.mscl_fatigue_options {
    var options = std.mem.zeroes(mscl.mscl_fatigue_options);
    const status = mscl.mscl_node_get_fatigue_options(self.handle, &options);
    return switch (status) {
        mscl.MSCL_OK => options,
        // FatigueOptions configuration is not supported by this Node.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the HistogramOptions currently set on the Node.
fn getHistogramOptions(self: Node) Error!mscl.mscl_histogram_options {
    var options = std.mem.zeroes(mscl.mscl_histogram_options);
    const status = mscl.mscl_node_get_histogram_options(self.handle, &options);
    return switch (status) {
        mscl.MSCL_OK => options,
        // HistogramOptions configuration is not supported by this Node.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the ActivitySense options currently set on the Node.
fn getActivitySense(self: Node) Error!mscl.mscl_activity_sense {
    var activity_sense = std.mem.zeroes(mscl.mscl_activity_sense);
    const status = mscl.mscl_node_get_activity_sense(
        self.handle,
        &activity_sense,
    );
    return switch (status) {
        mscl.MSCL_OK => activity_sense,
        // ActivitySense configuration is not supported by this Node.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the EventTriggerOptions currently set on the Node.
fn getEventTriggerOptions(
    self: Node,
) Error!mscl.mscl_event_trigger_options {
    var options = std.mem.zeroes(mscl.mscl_event_trigger_options);
    const status = mscl.mscl_node_get_event_trigger_options(
        self.handle,
        &options,
    );
    return switch (status) {
        mscl.MSCL_OK => options,
        // Event Triggering is not supported by this Node.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the interval (in seconds) at which the diagnostic info is configured
/// to be sent.
fn getDiagnosticInterval(self: Node) Error!u16 {
    var seconds: u16 = 0;
    const status = mscl.mscl_node_get_diagnostic_interval(
        self.handle,
        &seconds,
    );
    return switch (status) {
        mscl.MSCL_OK => seconds,
        // Diagnostic Info is not supported by this Node.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the WirelessTypes::StorageLimitMode that the Node is configured for.
/// This determines what happens when the datalogging storage limit is reached
/// on the Node.
fn getStorageLimitMode(self: Node) Error!root.StorageLimitMode {
    var mode: mscl.mscl_storage_limit_mode = 0;
    const status = mscl.mscl_node_get_storage_limit_mode(self.handle, &mode);
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(mode),
        // Storage Limit Mode (or datalogging) is not supported by this Node.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the sensor delay (in microseconds) that is currently set on the Node.
/// Note: A value of WirelessNodeConfig::SENSOR_DELAY_ALWAYS_ON indicates that
/// the sensor is always on.
fn getSensorDelay(self: Node) Error!u32 {
    var delay: u32 = 0;
    const status = mscl.mscl_node_get_sensor_delay(self.handle, &delay);
    return switch (status) {
        mscl.MSCL_OK => delay,
        // Sensor Delay is not supported by this Node.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the WirelessTypes::DataMode that is currently set on the Node.
fn getDataMode(self: Node) Error!root.DataMode {
    var mode: mscl.mscl_data_mode = 0;
    const status = mscl.mscl_node_get_data_mode(self.handle, &mode);
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(mode),
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the WirelessTypes::WirelessSampleRate for all Derived Data Channels
/// that is currently set on the Node.
fn getDerivedDataRate(self: Node) Error!root.SampleRate {
    var rate: mscl.mscl_sample_rate = 0;
    const status = mscl.mscl_node_get_derived_data_rate(self.handle, &rate);
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(rate),
        // Derived Channels are not supported by this Node.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the WirelessTypes::DerivedVelocityUnit which indicates which unit the
/// Velocity derived channel is set to.
fn getDerivedVelocityUnit(self: Node) Error!root.DerivedVelocityUnit {
    var unit: mscl.mscl_derived_velocity_unit = 0;
    const status = mscl.mscl_node_get_derived_velocity_unit(self.handle, &unit);
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(unit),
        // The Derived Velocity channel is not supported by this Node.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the WirelessTypes::CommProtocol that the Node is currently set to use.
fn getCommunicationProtocol(self: Node) Error!root.CommProtocol {
    var protocol: mscl.mscl_comm_protocol = 0;
    const status = mscl.mscl_node_get_communication_protocol(
        self.handle,
        &protocol,
    );
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(protocol),
        // Failed to read the value from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the WirelessTypes::SensorOutputMode currently set on the Node.
fn getSensorOutputMode(self: Node) Error!root.SensorOutputMode {
    var mode: mscl.mscl_sensor_output_mode = 0;
    const status = mscl.mscl_node_get_sensor_output_mode(self.handle, &mode);
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(mode),
        // Attempted to read an unsupported option.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}
