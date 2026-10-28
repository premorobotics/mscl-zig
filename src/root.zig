const std = @import("std");
pub const mscl = @import("mscl");
pub const BaseStation = @import("BaseStation.zig");

pub const Error = error{
    /// The port does not exist.
    InvalidSerialPort,
    /// Any other failure; `mscl.mscl_last_error()` describes it.
    Failed,
};

/// How a device is connected to this computer.
pub const ConnectionType = enum(mscl.mscl_connection_type) {
    serial = mscl.MSCL_CONNECTION_TYPE_SERIAL,
    tcp = mscl.MSCL_CONNECTION_TYPE_TCP,
};

/// The base stations attached to this computer.
pub const BaseStations = struct {
    devices: []mscl.mscl_device_info,

    pub const Error = error{
        OutOfMemory,
        /// `mscl.mscl_last_error()` describes it.
        Failed,
    };

    /// Lists the base stations attached to this computer.
    pub fn list() (BaseStations.Error)!BaseStations {
        var devices: [*c]mscl.mscl_device_info = null;
        var count: usize = 0;
        const status = mscl.mscl_list_base_stations(&devices, &count);
        switch (status) {
            mscl.MSCL_OK => {},
            mscl.MSCL_ERROR_OUT_OF_MEMORY => {
                return BaseStations.Error.OutOfMemory;
            },
            else => unreachable,
        }
        if (count == 0) {
            return .{ .devices = &.{} };
        }
        return .{ .devices = devices[0..count] };
    }

    pub fn deinit(self: BaseStations) void {
        if (self.devices.len == 0) {
            return;
        }
        mscl.mscl_device_infos_free(self.devices.ptr);
    }
};

/// Opens the base station on `port`. USB base stations use a baud rate of
/// 3000000. Close it with `mscl.mscl_base_station_close`.
pub fn openBaseStation(
    port: [*:0]const u8,
    baud_rate: u32,
) Error!*mscl.mscl_base_station {
    var base_station: ?*mscl.mscl_base_station = null;
    const status = mscl.mscl_base_station_open(port, baud_rate, &base_station);
    return switch (status) {
        mscl.MSCL_OK => base_station.?,
        mscl.MSCL_ERROR_INVALID_SERIAL_PORT => Error.InvalidSerialPort,
        else => Error.Failed,
    };
}

test openBaseStation {
    const actual = openBaseStation("/dev/mscl-zig-no-such-port", 3000000);
    try std.testing.expectError(Error.InvalidSerialPort, actual);
}

test {
    _ = BaseStation;
}
