//! Class used for setting the configuration of WirelessNode objects.
//! Set all the configuration values that you want to change, then verify and
//! apply them to a Node. A setting that is null or empty is left as it is on
//! the Node. The per-channel settings apply to the ChannelMask given to
//! `Node.applyConfig`.

const std = @import("std");
const root = @import("../root.zig");
const mscl = root.mscl;

const Config = @This();

/// The WirelessTypes::DefaultMode value in the Config.
default_mode: ?root.DefaultMode = null,
/// The user inactivity timeout value in the Config.
inactivity_timeout: ?u16 = null,
/// The check radio interval value in the Config.
check_radio_interval: ?u8 = null,
/// The WirelessTypes::TransmitPower value in the Config.
transmit_power: ?root.TransmitPower = null,
/// The WirelessTypes::SamplingMode value in the Config.
sampling_mode: ?root.SamplingMode = null,
/// The WirelessTypes::WirelessSampleRate value in the Config.
sample_rate: ?root.SampleRate = null,
/// The number of sweeps value in the Config.
num_sweeps: ?u32 = null,
/// The value of the unlimited duration flag in the Config.
unlimited_duration: ?bool = null,
/// The WirelessTypes::DataFormat value in the Config.
data_format: ?root.DataFormat = null,
/// The WirelessTypes::DataCollectionMethod value in the Config.
data_collection_method: ?root.DataCollectionMethod = null,
/// The amount of time between each burst value in the Config. The value is in
/// nanoseconds.
time_between_bursts: ?u64 = null,
/// The lost beacon timeout in the Config.
lost_beacon_timeout: ?u16 = null,
/// The WirelessTypes::ChannelFrequencyClass in the Config.
cfc_filter_config: ?root.ChannelFrequencyClass = null,
/// The gauge resistance in the Config.
gauge_resistance: ?u16 = null,
/// The Excitation WirelessTypes::Voltage in the Config.
excitation_voltage: ?root.Voltage = null,
/// The number of active gauges in the Config.
num_active_gauges: ?u16 = null,
/// The low battery threshold in the Config.
low_battery_threshold: ?f32 = null,
/// The FatigueOptions in the Config.
fatigue_options: ?mscl.mscl_fatigue_options = null,
/// The HistogramOptions in the Config.
histogram_options: ?mscl.mscl_histogram_options = null,
/// The ActivitySense in the Config.
activity_sense: ?mscl.mscl_activity_sense = null,
/// The EventTriggerOptions in the Config.
event_trigger_options: ?mscl.mscl_event_trigger_options = null,
/// The diagnostic info interval (in seconds) in the Config. A value of 0 is
/// disabled.
diagnostic_interval: ?u16 = null,
/// The WirelessTypes::StorageLimitMode in the Config.
storage_limit_mode: ?root.StorageLimitMode = null,
/// The sensor delay (in microseconds) in the Config. Note: A value of
/// WirelessNodeConfig::SENSOR_DELAY_ALWAYS_ON indicates that the sensor is
/// always on.
sensor_delay: ?u32 = null,
/// The WirelessTypes::DataMode in the Config.
data_mode: ?root.DataMode = null,
/// The WirelessTypes::WirelessSampleRate for the Derived Channels in the
/// Config.
derived_data_rate: ?root.SampleRate = null,
/// The WirelessTypes::DerivedVelocityUnit in the Config.
derived_velocity_unit: ?root.DerivedVelocityUnit = null,
/// The WirelessTypes::CommProtocol in the Config.
communication_protocol: ?root.CommProtocol = null,
/// The WirelessTypes::SensorOutputMode in the Config.
sensor_output_mode: ?root.SensorOutputMode = null,
/// The ChannelMask for each WirelessTypes::DerivedCategory in the Config.
/// This represents which of the Node's channels are mapped to derived
/// channels. When a category appears more than once, the last one is used.
derived_channel_masks: []const mscl.mscl_derived_channel_mask = &.{},

// Per-channel settings, for the ChannelMask given to `Node.applyConfig`.

/// The WirelessTypes::InputRange in the Config.
input_range: ?root.InputRange = null,
/// The hardware offset in the Config.
hardware_offset: ?u16 = null,
/// The anti-aliasing WirelessTypes::Filter in the Config.
anti_aliasing_filter: ?root.Filter = null,
/// The low-pass WirelessTypes::Filter in the Config.
low_pass_filter: ?root.Filter = null,
/// The WirelessTypes::HighPassFilter in the Config.
high_pass_filter: ?root.HighPassFilter = null,
/// The gauge factor in the Config.
gauge_factor: ?f32 = null,
/// The LinearEquation in the Config.
linear_equation: ?mscl.mscl_linear_equation = null,
/// The WirelessTypes::CalCoef_Unit in the Config.
unit: ?root.CalCoefUnit = null,
/// The WirelessTypes::CalCoef_EquationType in the Config.
equation_type: ?root.CalCoefEquationType = null,
/// The WirelessTypes::SettlingTime in the Config.
filter_settling_time: ?root.SettlingTime = null,
/// The WirelessTypes::ThermocoupleType in the Config.
thermocouple_type: ?root.ThermocoupleType = null,
/// The TempSensorOptions in the Config.
temp_sensor_options: ?mscl.mscl_temp_sensor_options = null,
/// The Debounce Filter (in milliseconds) in the Config. Note: The accepted
/// range is 0 - 250ms. Any values outside that range will be truncated before
/// being applied.
debounce_filter: ?u16 = null,
/// The Pull-up Resistor flag in the Config.
pull_up_resistor: ?bool = null,

/// Frees the list. Call it only when the list was allocated with `gpa`, like
/// the list of a Config from `Node.getConfig`.
pub fn deinit(self: Config, gpa: std.mem.Allocator) void {
    gpa.free(self.derived_channel_masks);
}

/// Creates an MSCL WirelessNodeConfig holding the settings that are set, with
/// the per-channel settings for `channels`.
/// Destroy it with `root.mscl.mscl_node_config_destroy`.
pub fn createHandle(
    self: Config,
    channels: root.ChannelMask,
) std.mem.Allocator.Error!*mscl.mscl_node_config {
    var handle: ?*mscl.mscl_node_config = null;
    const status = mscl.mscl_node_config_create(&handle);
    switch (status) {
        mscl.MSCL_OK => {},
        // Allocating the config failed.
        mscl.MSCL_ERROR_OUT_OF_MEMORY => {
            return std.mem.Allocator.Error.OutOfMemory;
        },
        else => unreachable,
    }
    const config = handle.?;

    if (self.default_mode) |value| {
        _ = mscl.mscl_node_config_set_default_mode(
            config,
            @backingInt(value),
        );
    }
    if (self.inactivity_timeout) |value| {
        _ = mscl.mscl_node_config_set_inactivity_timeout(
            config,
            value,
        );
    }
    if (self.check_radio_interval) |value| {
        _ = mscl.mscl_node_config_set_check_radio_interval(
            config,
            value,
        );
    }
    if (self.transmit_power) |value| {
        _ = mscl.mscl_node_config_set_transmit_power(
            config,
            @backingInt(value),
        );
    }
    if (self.sampling_mode) |value| {
        _ = mscl.mscl_node_config_set_sampling_mode(
            config,
            @backingInt(value),
        );
    }
    if (self.sample_rate) |value| {
        _ = mscl.mscl_node_config_set_sample_rate(
            config,
            @backingInt(value),
        );
    }
    if (self.num_sweeps) |value| {
        _ = mscl.mscl_node_config_set_num_sweeps(
            config,
            value,
        );
    }
    if (self.unlimited_duration) |value| {
        _ = mscl.mscl_node_config_set_unlimited_duration(
            config,
            value,
        );
    }
    if (self.data_format) |value| {
        _ = mscl.mscl_node_config_set_data_format(
            config,
            @backingInt(value),
        );
    }
    if (self.data_collection_method) |value| {
        _ = mscl.mscl_node_config_set_data_collection_method(
            config,
            @backingInt(value),
        );
    }
    if (self.time_between_bursts) |value| {
        _ = mscl.mscl_node_config_set_time_between_bursts(
            config,
            value,
        );
    }
    if (self.lost_beacon_timeout) |value| {
        _ = mscl.mscl_node_config_set_lost_beacon_timeout(
            config,
            value,
        );
    }
    if (self.cfc_filter_config) |value| {
        _ = mscl.mscl_node_config_set_cfc_filter_config(
            config,
            @backingInt(value),
        );
    }
    if (self.gauge_resistance) |value| {
        _ = mscl.mscl_node_config_set_gauge_resistance(
            config,
            value,
        );
    }
    if (self.excitation_voltage) |value| {
        _ = mscl.mscl_node_config_set_excitation_voltage(
            config,
            @backingInt(value),
        );
    }
    if (self.num_active_gauges) |value| {
        _ = mscl.mscl_node_config_set_num_active_gauges(
            config,
            value,
        );
    }
    if (self.low_battery_threshold) |value| {
        _ = mscl.mscl_node_config_set_low_battery_threshold(
            config,
            value,
        );
    }
    if (self.fatigue_options) |value| {
        _ = mscl.mscl_node_config_set_fatigue_options(
            config,
            &value,
        );
    }
    if (self.histogram_options) |value| {
        _ = mscl.mscl_node_config_set_histogram_options(
            config,
            &value,
        );
    }
    if (self.activity_sense) |value| {
        _ = mscl.mscl_node_config_set_activity_sense(
            config,
            &value,
        );
    }
    if (self.event_trigger_options) |value| {
        _ = mscl.mscl_node_config_set_event_trigger_options(
            config,
            &value,
        );
    }
    if (self.diagnostic_interval) |value| {
        _ = mscl.mscl_node_config_set_diagnostic_interval(
            config,
            value,
        );
    }
    if (self.storage_limit_mode) |value| {
        _ = mscl.mscl_node_config_set_storage_limit_mode(
            config,
            @backingInt(value),
        );
    }
    if (self.sensor_delay) |value| {
        _ = mscl.mscl_node_config_set_sensor_delay(
            config,
            value,
        );
    }
    if (self.data_mode) |value| {
        _ = mscl.mscl_node_config_set_data_mode(
            config,
            @backingInt(value),
        );
    }
    if (self.derived_data_rate) |value| {
        _ = mscl.mscl_node_config_set_derived_data_rate(
            config,
            @backingInt(value),
        );
    }
    if (self.derived_velocity_unit) |value| {
        _ = mscl.mscl_node_config_set_derived_velocity_unit(
            config,
            @backingInt(value),
        );
    }
    if (self.communication_protocol) |value| {
        _ = mscl.mscl_node_config_set_communication_protocol(
            config,
            @backingInt(value),
        );
    }
    if (self.sensor_output_mode) |value| {
        _ = mscl.mscl_node_config_set_sensor_output_mode(
            config,
            @backingInt(value),
        );
    }
    for (self.derived_channel_masks) |derived| {
        _ = mscl.mscl_node_config_set_derived_channel_mask(
            config,
            derived.category,
            derived.mask,
        );
    }

    if (self.input_range) |value| {
        _ = mscl.mscl_node_config_set_input_range(
            config,
            @bitCast(channels),
            @backingInt(value),
        );
    }
    if (self.hardware_offset) |value| {
        _ = mscl.mscl_node_config_set_hardware_offset(
            config,
            @bitCast(channels),
            value,
        );
    }
    if (self.anti_aliasing_filter) |value| {
        _ = mscl.mscl_node_config_set_anti_aliasing_filter(
            config,
            @bitCast(channels),
            @backingInt(value),
        );
    }
    if (self.low_pass_filter) |value| {
        _ = mscl.mscl_node_config_set_low_pass_filter(
            config,
            @bitCast(channels),
            @backingInt(value),
        );
    }
    if (self.high_pass_filter) |value| {
        _ = mscl.mscl_node_config_set_high_pass_filter(
            config,
            @bitCast(channels),
            @backingInt(value),
        );
    }
    if (self.gauge_factor) |value| {
        _ = mscl.mscl_node_config_set_gauge_factor(
            config,
            @bitCast(channels),
            value,
        );
    }
    if (self.linear_equation) |value| {
        _ = mscl.mscl_node_config_set_linear_equation(
            config,
            @bitCast(channels),
            &value,
        );
    }
    if (self.unit) |value| {
        _ = mscl.mscl_node_config_set_unit(
            config,
            @bitCast(channels),
            @backingInt(value),
        );
    }
    if (self.equation_type) |value| {
        _ = mscl.mscl_node_config_set_equation_type(
            config,
            @bitCast(channels),
            @backingInt(value),
        );
    }
    if (self.filter_settling_time) |value| {
        _ = mscl.mscl_node_config_set_filter_settling_time(
            config,
            @bitCast(channels),
            @backingInt(value),
        );
    }
    if (self.thermocouple_type) |value| {
        _ = mscl.mscl_node_config_set_thermocouple_type(
            config,
            @bitCast(channels),
            @backingInt(value),
        );
    }
    if (self.temp_sensor_options) |value| {
        _ = mscl.mscl_node_config_set_temp_sensor_options(
            config,
            @bitCast(channels),
            &value,
        );
    }
    if (self.debounce_filter) |value| {
        _ = mscl.mscl_node_config_set_debounce_filter(
            config,
            @bitCast(channels),
            value,
        );
    }
    if (self.pull_up_resistor) |value| {
        _ = mscl.mscl_node_config_set_pull_up_resistor(
            config,
            @bitCast(channels),
            value,
        );
    }
    return config;
}
