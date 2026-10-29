//! Class used for setting the configuration of BaseStations.
//! Set all the configuration values that you want to change, then verify and
//! apply them to a BaseStation. A setting that is null or empty is left as it
//! is on the BaseStation.

const std = @import("std");
const root = @import("../root.zig");
const BaseStation = @import("../BaseStation.zig");

const Config = @This();

/// The WirelessTypes::TransmitPower value in the Config.
transmit_power: ?root.TransmitPower = null,
/// The WirelessTypes::CommProtocol value in the Config.
communication_protocol: ?root.CommProtocol = null,
/// The BaseStationButton values in the Config for performing a long press on
/// specific buttons.
button_long_press: []const NumberedButton = &.{},
/// The BaseStationButton values in the Config for performing a short press on
/// specific buttons.
button_short_press: []const NumberedButton = &.{},
/// The Analog Pairing Enabled value in the Config.
/// This controls whether all of the other analog pairing settings have any
/// affect.
analog_pairing_enable: ?bool = null,
/// The Analog Timeout Time value (in seconds) in the Config.
/// If this is 0, Analog Timeout is disabled.
analog_timeout_time: ?u16 = null,
/// The Analog Timeout Voltage in the Config.
/// If this is 0, Analog Timeout is disabled.
analog_timeout_voltage: ?f32 = null,
/// The Analog Exceedance Enabled value in the Config.
analog_exceedance_enable: ?bool = null,
/// The BaseStationAnalogPair values in the Config for specific port numbers.
analog_pairing: []const NumberedAnalogPair = &.{},

/// A BaseStationButton for one button. When a number appears more than once,
/// the last one is used.
pub const NumberedButton = struct {
    /// The button number (1 = button 1).
    number: u8,
    button: BaseStation.Button,
};

/// A BaseStationAnalogPair for one port. When a number appears more than
/// once, the last one is used.
pub const NumberedAnalogPair = struct {
    /// The port number (1 = port 1).
    number: u8,
    pair: BaseStation.AnalogPair,
};

/// Frees the lists. Call it only when every list was allocated with `gpa`,
/// like the lists of a Config from `BaseStation.getConfig`.
pub fn deinit(self: Config, gpa: std.mem.Allocator) void {
    gpa.free(self.button_long_press);
    gpa.free(self.button_short_press);
    gpa.free(self.analog_pairing);
}

/// Creates an MSCL BaseStationConfig holding the settings that are set.
/// Destroy it with `root.mscl.mscl_base_station_config_destroy`.
pub fn createHandle(
    self: Config,
) std.mem.Allocator.Error!*root.mscl.mscl_base_station_config {
    var handle: ?*root.mscl.mscl_base_station_config = null;
    const status = root.mscl.mscl_base_station_config_create(&handle);
    switch (status) {
        root.mscl.MSCL_OK => {},
        // Allocating the config failed.
        root.mscl.MSCL_ERROR_OUT_OF_MEMORY => {
            return std.mem.Allocator.Error.OutOfMemory;
        },
        else => unreachable,
    }
    const config = handle.?;

    if (self.transmit_power) |power| {
        _ = root.mscl.mscl_base_station_config_set_transmit_power(
            config,
            @backingInt(power),
        );
    }
    if (self.communication_protocol) |protocol| {
        _ = root.mscl.mscl_base_station_config_set_communication_protocol(
            config,
            @backingInt(protocol),
        );
    }
    for (self.button_long_press) |numbered| {
        _ = root.mscl.mscl_base_station_config_set_button_long_press(
            config,
            numbered.number,
            .{
                .command = @backingInt(numbered.button.command),
                .node_address = numbered.button.node_address,
            },
        );
    }
    for (self.button_short_press) |numbered| {
        _ = root.mscl.mscl_base_station_config_set_button_short_press(
            config,
            numbered.number,
            .{
                .command = @backingInt(numbered.button.command),
                .node_address = numbered.button.node_address,
            },
        );
    }
    if (self.analog_pairing_enable) |enable| {
        _ = root.mscl.mscl_base_station_config_set_analog_pairing_enable(
            config,
            enable,
        );
    }
    if (self.analog_timeout_time) |seconds| {
        _ = root.mscl.mscl_base_station_config_set_analog_timeout_time(
            config,
            seconds,
        );
    }
    if (self.analog_timeout_voltage) |voltage| {
        _ = root.mscl.mscl_base_station_config_set_analog_timeout_voltage(
            config,
            voltage,
        );
    }
    if (self.analog_exceedance_enable) |enable| {
        _ = root.mscl.mscl_base_station_config_set_analog_exceedance_enable(
            config,
            enable,
        );
    }
    for (self.analog_pairing) |numbered| {
        _ = root.mscl.mscl_base_station_config_set_analog_pairing(
            config,
            numbered.number,
            .{
                .node_address = numbered.pair.node_address,
                .node_channel = numbered.pair.node_channel,
                .expect_float_data = numbered.pair.expect_float_data,
                .output_0v = numbered.pair.output_0v,
                .output_3v = numbered.pair.output_3v,
            },
        );
    }
    return config;
}
