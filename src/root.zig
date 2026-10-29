const std = @import("std");
pub const mscl = @import("mscl");
pub const BaseStation = @import("BaseStation.zig");
pub const SetToIdleStatus = @import("SetToIdleStatus.zig");

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

/// Represents the frequency (channel) that can be used for Wireless Devices.
pub const Frequency = enum(mscl.mscl_frequency) {
    unknown = mscl.MSCL_FREQUENCY_UNKNOWN,
    channel_11 = mscl.MSCL_FREQUENCY_11,
    channel_12 = mscl.MSCL_FREQUENCY_12,
    channel_13 = mscl.MSCL_FREQUENCY_13,
    channel_14 = mscl.MSCL_FREQUENCY_14,
    channel_15 = mscl.MSCL_FREQUENCY_15,
    channel_16 = mscl.MSCL_FREQUENCY_16,
    channel_17 = mscl.MSCL_FREQUENCY_17,
    channel_18 = mscl.MSCL_FREQUENCY_18,
    channel_19 = mscl.MSCL_FREQUENCY_19,
    channel_20 = mscl.MSCL_FREQUENCY_20,
    channel_21 = mscl.MSCL_FREQUENCY_21,
    channel_22 = mscl.MSCL_FREQUENCY_22,
    channel_23 = mscl.MSCL_FREQUENCY_23,
    channel_24 = mscl.MSCL_FREQUENCY_24,
    channel_25 = mscl.MSCL_FREQUENCY_25,
    channel_26 = mscl.MSCL_FREQUENCY_26,
    _,
};

/// Available Communication Protocol types.
pub const CommProtocol = enum(mscl.mscl_comm_protocol) {
    lxrs = mscl.MSCL_COMM_PROTOCOL_LXRS,
    lxrs_plus = mscl.MSCL_COMM_PROTOCOL_LXRS_PLUS,
    _,
};

/// The possible region codes for the device.
pub const RegionCode = enum(mscl.mscl_region_code) {
    usa = mscl.MSCL_REGION_CODE_USA,
    european_union = mscl.MSCL_REGION_CODE_EUROPEAN_UNION,
    japan = mscl.MSCL_REGION_CODE_JAPAN,
    other = mscl.MSCL_REGION_CODE_OTHER,
    brazil = mscl.MSCL_REGION_CODE_BRAZIL,
    china = mscl.MSCL_REGION_CODE_CHINA,
    australia_new_zealand = mscl.MSCL_REGION_CODE_AUSTRALIA_NEW_ZEALAND,
    singapore = mscl.MSCL_REGION_CODE_SINGAPORE,
    canada = mscl.MSCL_REGION_CODE_CANADA,
    south_africa = mscl.MSCL_REGION_CODE_SOUTH_AFRICA,
    indonesia = mscl.MSCL_REGION_CODE_INDONESIA,
    taiwan = mscl.MSCL_REGION_CODE_TAIWAN,
    _,
};

/// Represents the types of microcontrollers possible on the Wireless Devices.
pub const Microcontroller = enum(mscl.mscl_microcontroller) {
    @"18f452" = mscl.MSCL_MICROCONTROLLER_18F452,
    @"18f4620" = mscl.MSCL_MICROCONTROLLER_18F4620,
    @"18f46k20" = mscl.MSCL_MICROCONTROLLER_18F46K20,
    @"18f67k90" = mscl.MSCL_MICROCONTROLLER_18F67K90,
    efm32wg990f256 = mscl.MSCL_MICROCONTROLLER_EFM32WG990F256,
    efr32fg1p132f256gm48 = mscl.MSCL_MICROCONTROLLER_EFR32FG1P132F256GM48,
    efr32mg1p232f256gm48 = mscl.MSCL_MICROCONTROLLER_EFR32MG1P232F256GM48,
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

/// Typedef for a vector of DataSweep objects.
pub const DataSweeps = struct {
    sweeps: []mscl.mscl_sweep,

    pub fn deinit(self: DataSweeps) void {
        if (self.sweeps.len == 0) {
            return;
        }
        mscl.mscl_sweeps_free(self.sweeps.ptr, self.sweeps.len);
    }
};

/// typedef for a vector of NodeDiscovery objects
pub const NodeDiscoveries = struct {
    discoveries: []mscl.mscl_node_discovery,

    pub fn deinit(self: NodeDiscoveries) void {
        if (self.discoveries.len == 0) {
            return;
        }
        mscl.mscl_node_discoveries_free(self.discoveries.ptr);
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
