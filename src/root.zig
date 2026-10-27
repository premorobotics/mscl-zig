const std = @import("std");
const mscl = @import("mscl");

pub const Error = error{
    /// The port does not exist.
    InvalidSerialPort,
    /// Any other failure; `mscl.mscl_last_error()` describes it.
    Failed,
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
