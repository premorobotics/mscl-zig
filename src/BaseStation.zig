const std = @import("std");
const root = @import("root.zig");

const BaseStation = @This();
pub const Config = @import("BaseStation/Config.zig");
pub const Features = @import("BaseStation/Features.zig");

handle: *root.mscl.mscl_base_station,
/// Contains information on which features are supported by this BaseStation;
/// null when MSCL does not support its model.
features: ?Features,

pub const Error = error{
    Connection,
    InvalidSerialPort,
    Communication,
    NotSupported,
    InvalidConfig,
    /// Any other failure; `root.mscl.mscl_last_error()` describes it.
    MsclFailure,
};

/// Represents a single button on a BaseStation
pub const Button = struct {
    command: Command,
    node_address: u16,

    /// Represents the types of commands that a BaseStationButton can
    /// perform.
    pub const Command = enum(root.mscl.mscl_button_command) {
        node_sleep = root.mscl.MSCL_BUTTON_COMMAND_NODE_SLEEP,
        node_stop = root.mscl.MSCL_BUTTON_COMMAND_NODE_STOP,
        enable_beacon = root.mscl.MSCL_BUTTON_COMMAND_ENABLE_BEACON,
        disable_beacon = root.mscl.MSCL_BUTTON_COMMAND_DISABLE_BEACON,
        node_non_sync_sampling =
            root.mscl.MSCL_BUTTON_COMMAND_NODE_NON_SYNC_SAMPLING,
        node_sync_sampling = root.mscl.MSCL_BUTTON_COMMAND_NODE_SYNC_SAMPLING,
        node_armed_datalogging =
            root.mscl.MSCL_BUTTON_COMMAND_NODE_ARMED_DATALOGGING,
        cycle_power = root.mscl.MSCL_BUTTON_COMMAND_CYCLE_POWER,
        disabled = root.mscl.MSCL_BUTTON_COMMAND_DISABLED,
        _,
    };
};

/// Represents an Analog Pairing on a BaseStation.
pub const AnalogPair = struct {
    node_address: u16,
    node_channel: u8,
    expect_float_data: bool,
    output_0v: f32,
    output_3v: f32,
};

/// Represents the status of a BaseStation beacon.
pub const BeaconStatus = struct {
    enabled: bool,
    /// Nanoseconds since the Unix epoch.
    timestamp_ns: u64,
};

/// Opens the base station on `port`. USB base stations use a baud rate of
/// 3000000.
pub fn init(
    gpa: std.mem.Allocator,
    port: [*:0]const u8,
    baud_rate: u32,
) (Error || Features.Error || std.mem.Allocator.Error)!BaseStation {
    var handle: ?*root.mscl.mscl_base_station = null;
    const status = root.mscl.mscl_base_station_open(port, baud_rate, &handle);
    switch (status) {
        root.mscl.MSCL_OK => {},
        // Failed to get or set com port parameters.
        root.mscl.MSCL_ERROR_CONNECTION => {
            return Error.Connection;
        },
        // The specified com port is invalid.
        root.mscl.MSCL_ERROR_INVALID_SERIAL_PORT => {
            return Error.InvalidSerialPort;
        },
        else => {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            return Error.MsclFailure;
        },
    }
    errdefer root.mscl.mscl_base_station_close(handle.?);
    const features = Features.init(gpa, handle.?) catch |err| switch (err) {
        // The BaseStation model is not supported by MSCL.
        Features.Error.NotSupported => null,
        else => |e| {
            return e;
        },
    };
    return .{ .handle = handle.?, .features = features };
}

/// Disconnects the port. Deinitialize everything using this base station
/// first.
pub fn deinit(self: BaseStation, gpa: std.mem.Allocator) void {
    if (self.features) |features| {
        features.deinit(gpa);
    }
    root.mscl.mscl_base_station_close(self.handle);
}

/// Pings the base station
pub fn ping(self: BaseStation) Error!bool {
    var success = false;
    const status = root.mscl.mscl_base_station_ping(self.handle, &success);
    return switch (status) {
        root.mscl.MSCL_OK => true,
        // A connection error has occurred with the BaseStation
        root.mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Sets the number of retry attempts for reading and writing config options on
/// the BaseStation. By default, the number of retries is 0.
/// Note: The timeout that is set per command will be per read and write
/// attempt, meaning this retry number is multiplied by the timeout for your
/// overall timeout.
pub fn setRetries(self: BaseStation, retries: u8) void {
    _ = root.mscl.mscl_base_station_set_retries(
        self.handle,
        retries,
    );
}

/// Gets the number of retry attempts for reading and writing config options on
/// the BaseStation. By default, the number of retries is 0.
/// Note: The timeout that is set per command will be per read and write
/// attempt, meaning this retry number is multiplied by the timeout for your
/// overall timeout.
pub fn getRetries(self: BaseStation) u8 {
    var retries: u8 = 0;
    _ = root.mscl.mscl_base_station_get_retries(self.handle, &retries);
    return retries;
}

/// Enables the beacon on the base station using the system time (UTC) as its
/// starting timestamp.
pub fn enableBeacon(self: BaseStation) Error!u64 {
    var beacon_time_ns: u64 = 0;
    const status = root.mscl.mscl_base_station_enable_beacon(
        self.handle,
        &beacon_time_ns,
    );
    return switch (status) {
        root.mscl.MSCL_OK => beacon_time_ns,
        // A connection error has occurred with the BaseStation
        root.mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        // The enable beacon command has failed.
        root.mscl.MSCL_ERROR_COMMUNICATION => Error.Communication,
        else => mscl: {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Enables the beacon on the base station using the given UTC timestamp.
pub fn enableBeaconAt(self: BaseStation, utc_time_s: u32) Error!u64 {
    var beacon_time_ns: u64 = 0;
    const status = root.mscl.mscl_base_station_enable_beacon_at(
        self.handle,
        utc_time_s,
        &beacon_time_ns,
    );
    return switch (status) {
        root.mscl.MSCL_OK => beacon_time_ns,
        // A connection error has occurred with the BaseStation
        root.mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        // The enable beacon command has failed.
        root.mscl.MSCL_ERROR_COMMUNICATION => Error.Communication,
        else => mscl: {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Disables the beacon on the base station.
pub fn disableBeacon(self: BaseStation) Error!void {
    const status = root.mscl.mscl_base_station_disable_beacon(self.handle);
    return switch (status) {
        root.mscl.MSCL_OK => {},
        // A connection error has occurred with the BaseStation
        root.mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        // The disable beacon command has failed.
        root.mscl.MSCL_ERROR_COMMUNICATION => Error.Communication,
        else => mscl: {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the BeaconStatus of the beacon on the base station.
pub fn getBeaconStatus(self: BaseStation) Error!BeaconStatus {
    var beacon_status: root.mscl.mscl_beacon_status = undefined;
    const status = root.mscl.mscl_base_station_get_beacon_status(
        self.handle,
        &beacon_status,
    );
    return switch (status) {
        root.mscl.MSCL_OK => .{
            .enabled = beacon_status.enabled,
            .timestamp_ns = beacon_status.timestamp_ns,
        },
        // Beacon Status is not supported by this BaseStation.
        root.mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to get the beacon status.
        root.mscl.MSCL_ERROR_COMMUNICATION => Error.Communication,
        // A connection error has occurred with the BaseStation.
        root.mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the name of the BaseStation. This is the universal basestation name
/// that should be used for SensorCloud.
/// This is the same as calling BaseStation::deviceName.
/// The name is written into `buffer`, truncated to fit.
pub fn name(self: BaseStation, buffer: []u8) Error![]u8 {
    const status = root.mscl.mscl_base_station_get_name(
        self.handle,
        buffer.ptr,
        buffer.len,
    );
    return switch (status) {
        root.mscl.MSCL_OK => std.mem.sliceTo(buffer, 0),
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        root.mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read the value from the BaseStation.
        root.mscl.MSCL_ERROR_COMMUNICATION => Error.Communication,
        // A connection error has occurred with the parent BaseStation.
        root.mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the name of the BaseStation. This is the universal basestation name
/// that should be used for SensorCloud.
/// This is the same as calling BaseStation::deviceName.
/// Free the result with `gpa.free`.
pub fn nameAlloc(
    self: BaseStation,
    gpa: std.mem.Allocator,
) (Error || std.mem.Allocator.Error)![]u8 {
    // MSCL's name is "base-" and the serial, at most 5 + 21 characters, so it
    // always fits.
    var buffer: [32]u8 = undefined;
    return gpa.dupe(u8, try self.name(&buffer));
}

/// Reads every setting that a BaseStationConfig can hold from the
/// BaseStation. A setting that the BaseStation does not support is null or
/// empty.
/// Free the result with `Config.deinit`.
pub fn getConfig(
    self: BaseStation,
    gpa: std.mem.Allocator,
) (Error || std.mem.Allocator.Error)!Config {
    var result: Config = std.mem.zeroInit(Config, .{});
    errdefer result.deinit(gpa);

    // A setting that the BaseStation does not support stays null.
    result.transmit_power = self.getTransmitPower() catch |err| switch (err) {
        Error.NotSupported => null,
        else => |e| {
            return e;
        },
    };
    result.communication_protocol = try self.getCommunicationProtocol();
    result.analog_pairing_enable =
        self.getAnalogPairingEnabled() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.analog_timeout_time =
        self.getAnalogTimeoutTime() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.analog_timeout_voltage =
        self.getAnalogTimeoutVoltage() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.analog_exceedance_enable =
        self.getAnalogExceedanceEnabled() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };

    // Without features, the number of buttons and ports is unknown.
    const button_count: u8 =
        if (self.features) |features| features.button_count else 0;
    const analog_port_count: u8 =
        if (self.features) |features| features.analog_port_count else 0;

    const button_long_press =
        try gpa.alloc(Config.NumberedButton, button_count);
    result.button_long_press = button_long_press;
    for (button_long_press, 1..) |*numbered, number| {
        numbered.* = .{
            .number = @intCast(number),
            .button = try self.getButtonLongPress(@intCast(number)),
        };
    }
    const button_short_press =
        try gpa.alloc(Config.NumberedButton, button_count);
    result.button_short_press = button_short_press;
    for (button_short_press, 1..) |*numbered, number| {
        numbered.* = .{
            .number = @intCast(number),
            .button = try self.getButtonShortPress(@intCast(number)),
        };
    }
    const analog_pairing =
        try gpa.alloc(Config.NumberedAnalogPair, analog_port_count);
    result.analog_pairing = analog_pairing;
    for (analog_pairing, 1..) |*numbered, number| {
        numbered.* = .{
            .number = @intCast(number),
            .pair = try self.getAnalogPair(@intCast(number)),
        };
    }
    return result;
}

/// Applies a BaseStationConfig to the Node.
/// Note: This applies all options that have been set in the
/// BaseStationConfig. Before applying, the options will be validated.
/// Options that are set will also be validated against each other. If an
/// option that needs to be validated isn't currently set, it will be read from
/// the BaseStation.
/// When the options are not valid, nothing is applied, `issues` receives one
/// line per problem, NUL-terminated and truncated to fit, and InvalidConfig is
/// returned.
pub fn applyConfig(
    self: BaseStation,
    config: Config,
    issues: []u8,
) (Error || std.mem.Allocator.Error)!void {
    const mscl_config = try config.createHandle();
    defer root.mscl.mscl_base_station_config_destroy(mscl_config);

    var ok = false;
    const verify_status = root.mscl.mscl_base_station_verify_config(
        self.handle,
        mscl_config,
        &ok,
        issues.ptr,
        issues.len,
    );
    switch (verify_status) {
        root.mscl.MSCL_OK => {},
        // The BaseStation model, or firmware version, is not supported by
        // MSCL.
        root.mscl.MSCL_ERROR_NOT_SUPPORTED => {
            return Error.NotSupported;
        },
        // Failed to communicate with the BaseStation.
        root.mscl.MSCL_ERROR_COMMUNICATION => {
            return Error.Communication;
        },
        // A connection error has occurred.
        root.mscl.MSCL_ERROR_CONNECTION => {
            return Error.Connection;
        },
        else => {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            return Error.MsclFailure;
        },
    }
    if (!ok) {
        // The configuration is invalid; `issues` lists why.
        return Error.InvalidConfig;
    }

    const apply_status = root.mscl.mscl_base_station_apply_config(
        self.handle,
        mscl_config,
    );
    return switch (apply_status) {
        root.mscl.MSCL_OK => {},
        // The BaseStation model, or firmware version, is not supported by
        // MSCL.
        root.mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Invalid Configuration. Check the exception for specific details.
        root.mscl.MSCL_ERROR_INVALID_CONFIG => Error.InvalidConfig,
        // Failed to write to the BaseStation.
        root.mscl.MSCL_ERROR_COMMUNICATION => Error.Communication,
        // A connection error has occurred with the parent BaseStation.
        root.mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the WirelessTypes::TransmitPower that is currently set on the
/// BaseStation.
fn getTransmitPower(self: BaseStation) Error!root.TransmitPower {
    var power: root.mscl.mscl_transmit_power = 0;
    const status = root.mscl.mscl_base_station_get_transmit_power(
        self.handle,
        &power,
    );
    return switch (status) {
        root.mscl.MSCL_OK => @fromBackingInt(power),
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        root.mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the BaseStation.
        root.mscl.MSCL_ERROR_COMMUNICATION => Error.Communication,
        // A connection error has occurred with the BaseStation.
        root.mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the button settings for a long press action that are currently set
/// on the BaseStation.
fn getButtonLongPress(self: BaseStation, button_number: u8) Error!Button {
    var button: root.mscl.mscl_base_station_button = undefined;
    const status = root.mscl.mscl_base_station_get_button_long_press(
        self.handle,
        button_number,
        &button,
    );
    return switch (status) {
        root.mscl.MSCL_OK => .{
            .command = @fromBackingInt(button.command),
            .node_address = button.node_address,
        },
        // The BaseStation does not support the requested button.
        root.mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the BaseStation.
        root.mscl.MSCL_ERROR_COMMUNICATION => Error.Communication,
        // A connection error has occurred with the BaseStation.
        root.mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the button settings for a short press action that are currently set
/// on the BaseStation.
fn getButtonShortPress(self: BaseStation, button_number: u8) Error!Button {
    var button: root.mscl.mscl_base_station_button = undefined;
    const status = root.mscl.mscl_base_station_get_button_short_press(
        self.handle,
        button_number,
        &button,
    );
    return switch (status) {
        root.mscl.MSCL_OK => .{
            .command = @fromBackingInt(button.command),
            .node_address = button.node_address,
        },
        // The BaseStation does not support the requested button.
        root.mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the BaseStation.
        root.mscl.MSCL_ERROR_COMMUNICATION => Error.Communication,
        // A connection error has occurred with the BaseStation.
        root.mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the Analog Pairing enabled/disabled setting that is currently set on
/// the BaseStation.
/// If this is disabled, all other analog pairing settings will be disabled.
fn getAnalogPairingEnabled(self: BaseStation) Error!bool {
    var enabled = false;
    const status = root.mscl.mscl_base_station_get_analog_pairing_enabled(
        self.handle,
        &enabled,
    );
    return switch (status) {
        root.mscl.MSCL_OK => enabled,
        // The BaseStation does not support Analog Pairing.
        root.mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the BaseStation.
        root.mscl.MSCL_ERROR_COMMUNICATION => Error.Communication,
        // A connection error has occurred with the BaseStation.
        root.mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the Analog Timeout Time in seconds that is currently set on the
/// BaseStation.
fn getAnalogTimeoutTime(self: BaseStation) Error!u16 {
    var seconds: u16 = 0;
    const status = root.mscl.mscl_base_station_get_analog_timeout_time(
        self.handle,
        &seconds,
    );
    return switch (status) {
        root.mscl.MSCL_OK => seconds,
        // The BaseStation does not support Analog Pairing.
        root.mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the BaseStation.
        root.mscl.MSCL_ERROR_COMMUNICATION => Error.Communication,
        // A connection error has occurred with the BaseStation.
        root.mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the Analog Timeout Voltage that is currently set on the BaseStation.
fn getAnalogTimeoutVoltage(self: BaseStation) Error!f32 {
    var voltage: f32 = 0;
    const status = root.mscl.mscl_base_station_get_analog_timeout_voltage(
        self.handle,
        &voltage,
    );
    return switch (status) {
        root.mscl.MSCL_OK => voltage,
        // The BaseStation does not support Analog Pairing.
        root.mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the BaseStation.
        root.mscl.MSCL_ERROR_COMMUNICATION => Error.Communication,
        // A connection error has occurred with the BaseStation.
        root.mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the Analog Exceedance enabled/disabled setting that is currently set
/// on the BaseStation.
fn getAnalogExceedanceEnabled(self: BaseStation) Error!bool {
    var enabled = false;
    const status = root.mscl.mscl_base_station_get_analog_exceedance_enabled(
        self.handle,
        &enabled,
    );
    return switch (status) {
        root.mscl.MSCL_OK => enabled,
        // The BaseStation does not support Analog Pairing.
        root.mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the BaseStation.
        root.mscl.MSCL_ERROR_COMMUNICATION => Error.Communication,
        // A connection error has occurred with the BaseStation.
        root.mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the BaseStationAnalogPair for the specified port number that is
/// currently set on the BaseStation.
fn getAnalogPair(self: BaseStation, port_number: u8) Error!AnalogPair {
    var pair: root.mscl.mscl_base_station_analog_pair = undefined;
    const status = root.mscl.mscl_base_station_get_analog_pair(
        self.handle,
        port_number,
        &pair,
    );
    return switch (status) {
        root.mscl.MSCL_OK => .{
            .node_address = pair.node_address,
            .node_channel = pair.node_channel,
            .expect_float_data = pair.expect_float_data,
            .output_0v = pair.output_0v,
            .output_3v = pair.output_3v,
        },
        // The BaseStation does not support Analog Pairing.
        root.mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the BaseStation.
        root.mscl.MSCL_ERROR_COMMUNICATION => Error.Communication,
        // A connection error has occurred with the BaseStation.
        root.mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the WirelessTypes::CommProtocol that the BaseStation is currently set
/// to use.
fn getCommunicationProtocol(self: BaseStation) Error!root.CommProtocol {
    var protocol: root.mscl.mscl_comm_protocol = 0;
    const status = root.mscl.mscl_base_station_get_communication_protocol(
        self.handle,
        &protocol,
    );
    return switch (status) {
        root.mscl.MSCL_OK => @fromBackingInt(protocol),
        // Failed to read the value from the BaseStation.
        root.mscl.MSCL_ERROR_COMMUNICATION => Error.Communication,
        // A connection error has occurred with the BaseStation.
        root.mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}
