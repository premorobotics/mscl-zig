const std = @import("std");
const root = @import("root.zig");

const BaseStation = @This();

handle: *root.mscl.mscl_base_station,

pub const Error = error{
    Connection,
    InvalidSerialPort,
    Communication,
    /// Any other failure; `root.mscl.mscl_last_error()` describes it.
    MsclFailure,
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

/// Returns whether the base station answered.
pub fn ping(self: BaseStation) Error!bool {
    var success = false;
    const status = root.mscl.mscl_base_station_ping(self.handle, &success);
    return switch (status) {
        root.mscl.MSCL_OK => true,
        root.mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Sets how many times reading or writing a config option is retried; MSCL
/// starts at 0. The timeout applies to each attempt.
pub fn setRetries(self: BaseStation, retries: u8) void {
    _ = root.mscl.mscl_base_station_set_retries(
        self.handle,
        retries,
    );
}

/// Returns how many times reading or writing a config option is retried.
pub fn getRetries(self: BaseStation) u8 {
    var retries: u8 = 0;
    _ = root.mscl.mscl_base_station_get_retries(self.handle, &retries);
    return retries;
}

/// Starts the beacon from the system time (UTC) and returns that time in
/// nanoseconds since the Unix epoch.
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
