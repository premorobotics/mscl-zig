const std = @import("std");
const root = @import("root.zig");

const BaseStation = @This();

handle: *root.mscl.mscl_base_station,

pub const Error = error{
    Connection,
    InvalidSerialPort,
    Communication,
    NotSupported,
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

/// Represents the status of a BaseStation beacon.
pub const BeaconStatus = struct {
    enabled: bool,
    /// Nanoseconds since the Unix epoch.
    timestamp_ns: u64,
};

/// Opens the base station on `port`. USB base stations use a baud rate of
/// 3000000.
pub fn init(port: [*:0]const u8, baud_rate: u32) Error!BaseStation {
    var handle: ?*root.mscl.mscl_base_station = null;
    const status = root.mscl.mscl_base_station_open(port, baud_rate, &handle);
    return switch (status) {
        root.mscl.MSCL_OK => .{ .handle = handle.? },
        // Failed to get or set com port parameters.
        root.mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        // The specified com port is invalid.
        root.mscl.MSCL_ERROR_INVALID_SERIAL_PORT => Error.InvalidSerialPort,
        else => mscl: {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Disconnects the port. Deinitialize everything using this base station
/// first.
pub fn deinit(self: BaseStation) void {
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

/// Reads the button settings for a long press action that are currently set
/// on the BaseStation.
pub fn getButtonLongPress(self: BaseStation, button_number: u8) Error!Button {
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
pub fn getButtonShortPress(self: BaseStation, button_number: u8) Error!Button {
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
