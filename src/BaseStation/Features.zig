const std = @import("std");
const root = @import("../root.zig");

const Features = @This();

supports: struct {
    /// Whether the BaseStation supports Button configuration.
    buttons: bool,
    /// Whether the BaseStation supports Analog Pairing configuration.
    analog_pairing: bool,
    /// Whether the BaseStation supports the beaconStatus command.
    beacon_status: bool,
    /// Whether the BaseStation supports RF Sweep Mode.
    /// Note: This checks if the standard RF sweep mode across the
    /// BaseStation's supported operating frequencies is supported.
    /// Use custom_rf_sweep_mode to check if customizing the frequencies to be
    /// scanned is supported.
    rf_sweep_mode: bool,
    /// Whether the BaseStation supports the Custom RF Sweep Mode (providing
    /// custom frequency ranges).
    custom_rf_sweep_mode: bool,
},
/// The total number of buttons that are supported.
button_count: u8,
/// The total number of analog ports that are supported.
analog_port_count: u8,
/// The WirelessTypes::TransmitPowers that are supported by this BaseStation in
/// its region, for each WirelessTypes::CommProtocol, strongest first; empty
/// when the BaseStation does not support the protocol.
transmit_powers: struct {
    lxrs: []const root.TransmitPower,
    lxrs_plus: []const root.TransmitPower,
},

pub const Error = error{
    NotSupported,
    Communication,
    Connection,
    /// Any other failure; `root.mscl.mscl_last_error()` describes it.
    MsclFailure,
};

/// Reads the BaseStationFeatures of the base station.
/// Free the result with `deinit`.
pub fn init(
    gpa: std.mem.Allocator,
    base_station: *root.mscl.mscl_base_station,
) (Error || std.mem.Allocator.Error)!Features {
    var handle: ?*const root.mscl.mscl_base_station_features = null;
    const status = root.mscl.mscl_base_station_get_features(
        base_station,
        &handle,
    );
    switch (status) {
        root.mscl.MSCL_OK => {},
        // The BaseStation model is not supported by MSCL.
        root.mscl.MSCL_ERROR_NOT_SUPPORTED => {
            return Error.NotSupported;
        },
        // Failed to communicate with the BaseStation.
        root.mscl.MSCL_ERROR_COMMUNICATION => {
            return Error.Communication;
        },
        // A connection error has occurred with the parent BaseStation.
        root.mscl.MSCL_ERROR_CONNECTION => {
            return Error.Connection;
        },
        else => {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            return Error.MsclFailure;
        },
    }
    const features = handle.?;

    // A query that fails leaves its field false, 0 or empty.
    var result = std.mem.zeroes(Features);
    _ = root.mscl.mscl_base_station_features_supports_buttons(
        features,
        &result.supports.buttons,
    );
    _ = root.mscl.mscl_base_station_features_supports_analog_pairing(
        features,
        &result.supports.analog_pairing,
    );
    _ = root.mscl.mscl_base_station_features_supports_beacon_status(
        features,
        &result.supports.beacon_status,
    );
    _ = root.mscl.mscl_base_station_features_supports_rf_sweep_mode(
        features,
        &result.supports.rf_sweep_mode,
    );
    _ = root.mscl.mscl_base_station_features_supports_custom_rf_sweep_mode(
        features,
        &result.supports.custom_rf_sweep_mode,
    );
    _ = root.mscl.mscl_base_station_features_get_button_count(
        features,
        &result.button_count,
    );
    _ = root.mscl.mscl_base_station_features_get_analog_port_count(
        features,
        &result.analog_port_count,
    );
    result.transmit_powers.lxrs = try readTransmitPowers(gpa, features, .lxrs);
    errdefer gpa.free(result.transmit_powers.lxrs);
    result.transmit_powers.lxrs_plus =
        try readTransmitPowers(gpa, features, .lxrs_plus);
    return result;
}

pub fn deinit(self: Features, gpa: std.mem.Allocator) void {
    gpa.free(self.transmit_powers.lxrs);
    gpa.free(self.transmit_powers.lxrs_plus);
}

/// Reads the transmit powers that the BaseStation supports for
/// `comm_protocol` in its region, strongest first; empty when it does not
/// support the protocol.
fn readTransmitPowers(
    gpa: std.mem.Allocator,
    features: *const root.mscl.mscl_base_station_features,
    comm_protocol: root.CommProtocol,
) std.mem.Allocator.Error![]const root.TransmitPower {
    var supported = false;
    _ = root.mscl.mscl_base_station_features_supports_communication_protocol(
        features,
        @backingInt(comm_protocol),
        &supported,
    );
    if (!supported) {
        return &.{};
    }
    // Each power appears at most once, so every list fits.
    const capacity = @typeInfo(root.TransmitPower).@"enum".field_names.len;
    var buffer: [capacity]root.TransmitPower = undefined;
    var count: usize = 0;
    _ = root.mscl.mscl_base_station_features_get_transmit_powers(
        features,
        @backingInt(comm_protocol),
        @ptrCast(&buffer),
        buffer.len,
        &count,
    );
    return gpa.dupe(root.TransmitPower, buffer[0..count]);
}
