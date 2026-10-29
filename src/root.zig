const std = @import("std");
pub const mscl = @import("mscl");
pub const BaseStation = @import("BaseStation.zig");

pub const Error = error{
    /// The port does not exist.
    InvalidSerialPort,
    /// Any other failure; `mscl.mscl_last_error()` describes it.
    Failed,
};
const _ = 1;
/// How a device is connected to this computer.
pub const ConnectionType = enum(mscl.mscl_connection_type) {
    serial = mscl.MSCL_CONNECTION_TYPE_SERIAL,
    tcp = mscl.MSCL_CONNECTION_TYPE_TCP,
};

/// Available Communication Protocol types.
pub const CommProtocol = enum(mscl.mscl_comm_protocol) {
    lxrs = mscl.MSCL_COMM_PROTOCOL_LXRS,
    lxrs_plus = mscl.MSCL_COMM_PROTOCOL_LXRS_PLUS,
    _,
};

/// Represents the transmit powers that can be used for Wireless Devices.
pub const TransmitPower = enum(mscl.mscl_transmit_power) {
    @"20dbm" = mscl.MSCL_TRANSMIT_POWER_20DBM,
    @"16dbm" = mscl.MSCL_TRANSMIT_POWER_16DBM,
    @"15dbm" = mscl.MSCL_TRANSMIT_POWER_15DBM,
    @"12dbm" = mscl.MSCL_TRANSMIT_POWER_12DBM,
    @"11dbm" = mscl.MSCL_TRANSMIT_POWER_11DBM,
    @"10dbm" = mscl.MSCL_TRANSMIT_POWER_10DBM,
    @"5dbm" = mscl.MSCL_TRANSMIT_POWER_5DBM,
    @"1dbm" = mscl.MSCL_TRANSMIT_POWER_1DBM,
    @"0dbm" = mscl.MSCL_TRANSMIT_POWER_0DBM,
    _,
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
    referenceAll(@This());
}

/// References every public declaration, recursing into structs, so that a
/// build compiles all of them rather than only the ones something uses.
fn referenceAll(comptime T: type) void {
    inline for (@typeInfo(T).@"struct".decl_names) |name| {
        _ = &@field(T, name);
        if (@TypeOf(@field(T, name)) == type) {
            const Inner = @field(T, name);
            // translate-c turns every macro it cannot translate into a
            // `@compileError`, so `mscl` cannot be referenced whole.
            if (Inner != mscl and @typeInfo(Inner) == .@"struct") {
                referenceAll(Inner);
            }
        }
    }
}
