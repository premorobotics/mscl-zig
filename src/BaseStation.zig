const std = @import("std");
const root = @import("root.zig");

const BaseStation = @This();
pub const Config = @import("BaseStation/Config.zig");
pub const Features = @import("BaseStation/Features.zig");
pub const State = @import("BaseStation/State.zig");

handle: *root.mscl.mscl_base_station,
/// Contains information on which features are supported by this BaseStation;
/// null when MSCL does not support its model.
features: ?Features,
/// Information read from this BaseStation when it is initialized.
state: State,
/// The timeout, in milliseconds, to use when waiting for responses from
/// commands.
/// This timeout is used directly for BaseStation commands, while some
/// additional time is added for Node commands.
/// `setTimeout` updates it.
timeout: u64,
/// The number of retry attempts for reading and writing config options on the
/// BaseStation. By default, the number of retries is 0.
/// Note: The timeout that is set per command will be per read and write
/// attempt, meaning this retry number is multiplied by the timeout for your
/// overall timeout.
/// `setRetries` updates it.
retries: u8,

pub const Error = error{
    Connection,
    InvalidSerialPort,
    Communication,
    NotSupported,
    NoData,
    InvalidConfig,
    /// An argument breaks the rule in the function's documentation; nothing
    /// was sent to the BaseStation.
    InvalidArgument,
    /// Any other failure; `root.mscl.mscl_last_error()` describes it.
    MsclFailure,
};

/// The model numbers for each of the Wireless Base Stations
pub const Model = enum(root.mscl.mscl_base_model) {
    wsda_1000 = root.mscl.MSCL_BASE_MODEL_WSDA_1000,
    wsda_1500 = root.mscl.MSCL_BASE_MODEL_WSDA_1500,
    wsda_2000 = root.mscl.MSCL_BASE_MODEL_WSDA_2000,
    wsda_pro = root.mscl.MSCL_BASE_MODEL_WSDA_PRO,
    wsda_base_200_legacy = root.mscl.MSCL_BASE_MODEL_WSDA_BASE_200_LEGACY,
    wsda_base_200 = root.mscl.MSCL_BASE_MODEL_WSDA_BASE_200,
    wsda_base_200_ext_antenna =
        root.mscl.MSCL_BASE_MODEL_WSDA_BASE_200_EXT_ANTENNA,
    wsda_base_101_analog = root.mscl.MSCL_BASE_MODEL_WSDA_BASE_101_ANALOG,
    wsda_base_102_rs232 = root.mscl.MSCL_BASE_MODEL_WSDA_BASE_102_RS232,
    wsda_base_104_usb = root.mscl.MSCL_BASE_MODEL_WSDA_BASE_104_USB,
    wsi_104 = root.mscl.MSCL_BASE_MODEL_WSI_104,
    wsda_base_mini = root.mscl.MSCL_BASE_MODEL_WSDA_BASE_MINI,
    _,
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
    var result: BaseStation = .{
        .handle = handle.?,
        .features = null,
        .state = std.mem.zeroInit(State, .{}),
        .timeout = 0,
        .retries = 0,
    };
    errdefer result.deinit(gpa);
    result.timeout = result.getTimeout();
    result.retries = result.getRetries();

    result.features =
        Features.init(gpa, result.handle) catch |err| switch (err) {
            // The BaseStation model is not supported by MSCL.
            Features.Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.state.model = try result.model();
    result.state.serial = try result.serial(gpa);
    result.state.name = try result.name(gpa);
    result.state.firmware_version = try result.firmwareVersion();
    result.state.microcontroller = try result.microcontroller();
    result.state.region_code = try result.regionCode();
    result.state.frequency = try result.frequency();
    result.state.beacon_status = try result.beaconStatus();
    return result;
}

/// Disconnects the port. Deinitialize everything using this base station
/// first.
pub fn deinit(self: BaseStation, gpa: std.mem.Allocator) void {
    self.state.deinit(gpa);
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
/// Updates `retries`.
pub fn setRetries(self: *BaseStation, retries: u8) void {
    _ = root.mscl.mscl_base_station_set_retries(
        self.handle,
        retries,
    );
    self.retries = self.getRetries();
}

/// Sets the timeout to use when waiting for responses from commands.
/// This timeout is used directly for BaseStation commands, while some
/// additional time is added for Node commands.
/// Note: Some commands have a minimum timeout that will override this if set
/// lower than the minimum.
/// Updates `timeout`.
pub fn setTimeout(self: *BaseStation, timeout_ms: u64) void {
    _ = root.mscl.mscl_base_station_set_timeout(self.handle, timeout_ms);
    self.timeout = self.getTimeout();
}

/// Enables the beacon on the base station using the system time (UTC) as its
/// starting timestamp.
/// Updates `state.beacon_status`.
pub fn enableBeacon(self: *BaseStation) Error!u64 {
    var beacon_time_ns: u64 = 0;
    const status = root.mscl.mscl_base_station_enable_beacon(
        self.handle,
        &beacon_time_ns,
    );
    switch (status) {
        root.mscl.MSCL_OK => {},
        // A connection error has occurred with the BaseStation
        root.mscl.MSCL_ERROR_CONNECTION => {
            return Error.Connection;
        },
        // The enable beacon command has failed.
        root.mscl.MSCL_ERROR_COMMUNICATION => {
            return Error.Communication;
        },
        else => {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            return Error.MsclFailure;
        },
    }
    self.state.beacon_status = try self.beaconStatus();
    return beacon_time_ns;
}

/// Enables the beacon on the base station using the given UTC timestamp.
/// Updates `state.beacon_status`.
pub fn enableBeaconAt(self: *BaseStation, utc_time_s: u32) Error!u64 {
    var beacon_time_ns: u64 = 0;
    const status = root.mscl.mscl_base_station_enable_beacon_at(
        self.handle,
        utc_time_s,
        &beacon_time_ns,
    );
    switch (status) {
        root.mscl.MSCL_OK => {},
        // A connection error has occurred with the BaseStation
        root.mscl.MSCL_ERROR_CONNECTION => {
            return Error.Connection;
        },
        // The enable beacon command has failed.
        root.mscl.MSCL_ERROR_COMMUNICATION => {
            return Error.Communication;
        },
        else => {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            return Error.MsclFailure;
        },
    }
    self.state.beacon_status = try self.beaconStatus();
    return beacon_time_ns;
}

/// Disables the beacon on the base station.
/// Updates `state.beacon_status`.
pub fn disableBeacon(self: *BaseStation) Error!void {
    const status = root.mscl.mscl_base_station_disable_beacon(self.handle);
    switch (status) {
        root.mscl.MSCL_OK => {},
        // A connection error has occurred with the BaseStation
        root.mscl.MSCL_ERROR_CONNECTION => {
            return Error.Connection;
        },
        // The disable beacon command has failed.
        root.mscl.MSCL_ERROR_COMMUNICATION => {
            return Error.Communication;
        },
        else => {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            return Error.MsclFailure;
        },
    }
    self.state.beacon_status = try self.beaconStatus();
}

/// Gets the Timestamp for the last time MSCL communicated with the
/// BaseStation.
/// Note: EEPROM reads using the cache, and data collection, will not update
/// this timestamp.
pub fn getLastCommunicationTime(self: BaseStation) Error!u64 {
    var time_ns: u64 = 0;
    const status = root.mscl.mscl_base_station_get_last_communication_time(
        self.handle,
        &time_ns,
    );
    return switch (status) {
        root.mscl.MSCL_OK => time_ns,
        // There is no communication time logged for this device.
        root.mscl.MSCL_ERROR_NO_DATA => Error.NoData,
        else => mscl: {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Sets whether to use the eeprom cache when configuring this BaseStation
/// (enabled by default). This can be enabled/disabled at any time.
/// It is highly recommended to have eeprom caching be enabled.
/// Note: The eeprom cache stores the last known value that was written to /
/// read from the BaseStation for each eeprom location. If this is enabled,
/// any reads will get the last known value from the cache if it exists, and
/// any writes will not write to the BaseStation if the value attempting to be
/// written is the same as that stored in the cache. Caching of these values
/// will still be performed if this is disabled, however, read and write
/// operations will then always reach out to the actual device.
pub fn useEepromCache(self: BaseStation, use_cache: bool) void {
    _ = root.mscl.mscl_base_station_use_eeprom_cache(self.handle, use_cache);
}

/// Clears the eeprom cache for this BaseStation.
pub fn clearEepromCache(self: BaseStation) void {
    _ = root.mscl.mscl_base_station_clear_eeprom_cache(self.handle);
}

/// Gets up to the requested amount of DataSweeps of sampled data that was
/// collected by this BaseStation.
pub fn getData(
    self: BaseStation,
    timeout_ms: u32,
    max_sweeps: u32,
) Error!root.DataSweeps {
    var sweeps: [*c]root.mscl.mscl_sweep = null;
    var count: usize = 0;
    const status = root.mscl.mscl_base_station_get_data(
        self.handle,
        timeout_ms,
        max_sweeps,
        &sweeps,
        &count,
    );
    return switch (status) {
        root.mscl.MSCL_OK => .{
            .sweeps = if (count == 0) &.{} else sweeps[0..count],
        },
        // A connection error has occurred with the BaseStation
        root.mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the number of DataSweeps that are currently in the data buffer.
pub fn getTotalData(self: BaseStation) u32 {
    var count: u32 = 0;
    _ = root.mscl.mscl_base_station_get_total_data(self.handle, &count);
    return count;
}

/// Gets the group of Node Discoveries that were collected by this base
/// station.
/// Calling this function clears out the Node Discovery buffer, so successively
/// calling this will give you new Node Discoveries.
pub fn getNodeDiscoveries(self: BaseStation) Error!root.NodeDiscoveries {
    var discoveries: [*c]root.mscl.mscl_node_discovery = null;
    var count: usize = 0;
    const status = root.mscl.mscl_base_station_get_node_discoveries(
        self.handle,
        &discoveries,
        &count,
    );
    return switch (status) {
        root.mscl.MSCL_OK => .{
            .discoveries = if (count == 0) &.{} else discoveries[0..count],
        },
        // A connection error has occurred with the BaseStation
        root.mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads a specific EEPROM address on the Base Station.
/// If the value stored in the eeprom cache is still valid, this will be
/// returned instead.
pub fn readEeprom(self: BaseStation, address: u16) Error!u16 {
    var value: u16 = 0;
    const status = root.mscl.mscl_base_station_read_eeprom(
        self.handle,
        address,
        &value,
    );
    return switch (status) {
        root.mscl.MSCL_OK => value,
        // Unsupported eeprom location.
        root.mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
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

/// Writes the specified value to a specific EEPROM address on the Base
/// Station.
/// If successful, the cache will be updated with the changed value as well.
pub fn writeEeprom(self: BaseStation, address: u16, value: u16) Error!void {
    const status = root.mscl.mscl_base_station_write_eeprom(
        self.handle,
        address,
        value,
    );
    return switch (status) {
        root.mscl.MSCL_OK => {},
        // Unsupported eeprom location or value.
        root.mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to write the value to the BaseStation.
        root.mscl.MSCL_ERROR_COMMUNICATION => Error.Communication,
        // A connection error has occurred with the BaseStation.
        root.mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Starts the BaseStation in RF Sweep Mode.
/// With every option null, this is the fixed RF Sweep Mode, which will sweep
/// over all the supported operating frequencies of the BaseStation. With every
/// option set, it is a custom RF Sweep Mode across the provided frequencies.
/// Setting only some of the options returns InvalidArgument.
/// Note: To exit this Mode, send any command to the BaseStation (such as
/// ping).
pub fn startRfSweepMode(
    self: BaseStation,
    option: struct {
        /// The minimum frequency to use in the scan in kHz (2400000 = 2.4GHz).
        min_freq: ?u32 = null,
        /// The maximum frequency to use in the scan in kHz (2400000 = 2.4GHz).
        max_freq: ?u32 = null,
        /// The interval between frequencies.
        interval: ?u32 = null,
    },
) Error!void {
    const fixed = option.min_freq == null and
        option.max_freq == null and
        option.interval == null;
    const status = if (fixed)
        root.mscl.mscl_base_station_start_rf_sweep_mode(self.handle)
    else
        // A null option here means only some of them are set.
        root.mscl.mscl_base_station_start_custom_rf_sweep_mode(
            self.handle,
            option.min_freq orelse return Error.InvalidArgument,
            option.max_freq orelse return Error.InvalidArgument,
            option.interval orelse return Error.InvalidArgument,
            0,
        );
    return switch (status) {
        root.mscl.MSCL_OK => {},
        // RF Sweep Mode is not supported by this BaseStation; with an option
        // set, Raw RF Sweep Mode is not supported by this BaseStation.
        root.mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // A connection error has occurred with the BaseStation.
        root.mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        // The command has failed.
        root.mscl.MSCL_ERROR_COMMUNICATION => Error.Communication,
        else => mscl: {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Cycles the power on the base station.
pub fn cyclePower(
    self: BaseStation,
    option: struct {
        /// Whether to check for communication (ping) after cycling power
        /// before returning from this function.
        check_comm: bool = true,
    },
) Error!void {
    const status = root.mscl.mscl_base_station_cycle_power(
        self.handle,
        option.check_comm,
    );
    return switch (status) {
        root.mscl.MSCL_OK => {},
        // Attempted to write an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        root.mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // A connection error has occurred with the BaseStation.
        root.mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        // Failed to cycle the power.
        root.mscl.MSCL_ERROR_COMMUNICATION => Error.Communication,
        else => mscl: {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Resets the radio on the base station.
pub fn resetRadio(self: BaseStation) Error!void {
    const status = root.mscl.mscl_base_station_reset_radio(self.handle);
    return switch (status) {
        root.mscl.MSCL_OK => {},
        // Attempted to write an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        root.mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // A connection error has occurred with the BaseStation.
        root.mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        // Failed to cycle the power.
        root.mscl.MSCL_ERROR_COMMUNICATION => Error.Communication,
        else => mscl: {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Changes the radio frequency of the base station.
/// Updates `state.frequency`.
pub fn changeFrequency(
    self: *BaseStation,
    new_frequency: root.Frequency,
) Error!void {
    const status = root.mscl.mscl_base_station_change_frequency(
        self.handle,
        @backingInt(new_frequency),
    );
    switch (status) {
        root.mscl.MSCL_OK => {},
        // Attempted to write an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        root.mscl.MSCL_ERROR_NOT_SUPPORTED => {
            return Error.NotSupported;
        },
        // A connection error has occurred with the BaseStation
        root.mscl.MSCL_ERROR_CONNECTION => {
            return Error.Connection;
        },
        // Failed to change the frequency.
        root.mscl.MSCL_ERROR_COMMUNICATION => {
            return Error.Communication;
        },
        else => {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            return Error.MsclFailure;
        },
    }
    self.state.frequency = try self.frequency();
}

/// Broadcasts the Set to Idle command (will be heard by all nodes on the
/// BaseStation's frequency).
/// Note that this status object will never complete as it is not targeting a
/// specific Node.
pub fn broadcastSetToIdle(self: BaseStation) Error!root.SetToIdleStatus {
    var handle: ?*root.mscl.mscl_set_to_idle_status = null;
    const status = root.mscl.mscl_base_station_broadcast_set_to_idle(
        self.handle,
        &handle,
    );
    return switch (status) {
        root.mscl.MSCL_OK => .{ .handle = handle.? },
        // A connection error has occurred with the BaseStation.
        root.mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
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

/// Gets the model of the BaseStation.
fn model(self: BaseStation) Error!?Model {
    var value: root.mscl.mscl_base_model = 0;
    const status = root.mscl.mscl_base_station_get_model(self.handle, &value);
    return switch (status) {
        root.mscl.MSCL_OK => @as(Model, @fromBackingInt(value)),
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        root.mscl.MSCL_ERROR_NOT_SUPPORTED => null,
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

/// Gets the serial number of the BaseStation.
fn serial(
    self: BaseStation,
    gpa: std.mem.Allocator,
) (Error || std.mem.Allocator.Error)!?[]const u8 {
    // MSCL's serial is "model-class-number", at most 5 + 1 + 4 + 1 + 10
    // characters, so it always fits.
    var buffer: [32]u8 = undefined;
    const status = root.mscl.mscl_base_station_get_serial(
        self.handle,
        &buffer,
        buffer.len,
    );
    return switch (status) {
        root.mscl.MSCL_OK => try gpa.dupe(u8, std.mem.sliceTo(&buffer, 0)),
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        root.mscl.MSCL_ERROR_NOT_SUPPORTED => null,
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
fn name(
    self: BaseStation,
    gpa: std.mem.Allocator,
) (Error || std.mem.Allocator.Error)!?[]const u8 {
    // MSCL's name is "base-" and the serial, at most 5 + 21 characters, so it
    // always fits.
    var buffer: [32]u8 = undefined;
    const status = root.mscl.mscl_base_station_get_name(
        self.handle,
        &buffer,
        buffer.len,
    );
    return switch (status) {
        root.mscl.MSCL_OK => try gpa.dupe(u8, std.mem.sliceTo(&buffer, 0)),
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        root.mscl.MSCL_ERROR_NOT_SUPPORTED => null,
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

/// Gets the firmware version of the BaseStation.
fn firmwareVersion(self: BaseStation) Error!?std.SemanticVersion {
    var version: root.mscl.mscl_version = undefined;
    const status = root.mscl.mscl_base_station_get_firmware_version(
        self.handle,
        &version,
    );
    return switch (status) {
        root.mscl.MSCL_OK => .{
            .major = version.major,
            .minor = version.minor,
            .patch = version.patch,
        },
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        root.mscl.MSCL_ERROR_NOT_SUPPORTED => null,
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

/// Gets the microcontroller of the BaseStation.
fn microcontroller(self: BaseStation) Error!?root.Microcontroller {
    var value: root.mscl.mscl_microcontroller = 0;
    const status = root.mscl.mscl_base_station_get_microcontroller(
        self.handle,
        &value,
    );
    return switch (status) {
        root.mscl.MSCL_OK => @as(root.Microcontroller, @fromBackingInt(value)),
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        root.mscl.MSCL_ERROR_NOT_SUPPORTED => null,
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

/// Gets the region code currently set on the BaseStation.
fn regionCode(self: BaseStation) Error!?root.RegionCode {
    var region_code: root.mscl.mscl_region_code = 0;
    const status = root.mscl.mscl_base_station_get_region_code(
        self.handle,
        &region_code,
    );
    return switch (status) {
        root.mscl.MSCL_OK => @as(root.RegionCode, @fromBackingInt(region_code)),
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        root.mscl.MSCL_ERROR_NOT_SUPPORTED => null,
        // Failed to read from the BaseStation.
        root.mscl.MSCL_ERROR_COMMUNICATION => Error.Communication,
        // A connection error has occurred with the parent BaseStation.
        root.mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the WirelessTypes::Frequency representing the radio frequency of this
/// BaseStation.
fn frequency(self: BaseStation) Error!?root.Frequency {
    var value: root.mscl.mscl_frequency = 0;
    const status = root.mscl.mscl_base_station_get_frequency(
        self.handle,
        &value,
    );
    return switch (status) {
        root.mscl.MSCL_OK => @as(root.Frequency, @fromBackingInt(value)),
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        root.mscl.MSCL_ERROR_NOT_SUPPORTED => null,
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

/// Gets the BeaconStatus of the beacon on the base station.
fn beaconStatus(self: BaseStation) Error!?BeaconStatus {
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
        root.mscl.MSCL_ERROR_NOT_SUPPORTED => null,
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

/// Gets the number of retry attempts for reading and writing config options on
/// the BaseStation. By default, the number of retries is 0.
/// Note: The timeout that is set per command will be per read and write
/// attempt, meaning this retry number is multiplied by the timeout for your
/// overall timeout.
fn getRetries(self: BaseStation) u8 {
    var retries: u8 = 0;
    _ = root.mscl.mscl_base_station_get_retries(self.handle, &retries);
    return retries;
}

/// Gets the current timeout to use when waiting for responses from base
/// station commands.
/// This timeout is used directly for BaseStation commands, while some
/// additional time is added for Node commands.
/// Note: Some commands have a minimum timeout that will override this if set
/// lower than the minimum.
fn getTimeout(self: BaseStation) u64 {
    var timeout_ms: u64 = 0;
    _ = root.mscl.mscl_base_station_get_timeout(self.handle, &timeout_ms);
    return timeout_ms;
}
