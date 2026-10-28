const std = @import("std");
const root = @import("root.zig");

const BaseStation = @This();

handle: *root.mscl.mscl_base_station,

pub const Error = error{
    Connection,
    /// The specified com port is invalid.
    InvalidSerialPort,
    /// Any other failure; `root.mscl.mscl_last_error()` describes it.
    Failed,
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
        else => unreachable,
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
    };
}

/// Sets how many times reading or writing a config option is retried; MSCL
/// starts at 0. The timeout applies to each attempt.
pub fn setRetries(self: BaseStation, retries: u8) Error!void {
    const status = root.mscl.mscl_base_station_set_retries(
        self.handle,
        retries,
    );
    if (status != root.mscl.MSCL_OK) {
        return Error.Failed;
    }
}

/// Starts the beacon from the system time (UTC) and returns that time in
/// nanoseconds since the Unix epoch.
pub fn enableBeacon(self: BaseStation) Error!u64 {
    var beacon_time_ns: u64 = 0;
    const status = root.mscl.mscl_base_station_enable_beacon(
        self.handle,
        &beacon_time_ns,
    );
    if (status != root.mscl.MSCL_OK) {
        return Error.Failed;
    }
    return beacon_time_ns;
}

pub fn disableBeacon(self: BaseStation) Error!void {
    const status = root.mscl.mscl_base_station_disable_beacon(self.handle);
    if (status != root.mscl.MSCL_OK) {
        return Error.Failed;
    }
}
