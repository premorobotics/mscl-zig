const std = @import("std");
const root = @import("../root.zig");
const mscl = root.mscl;

const Features = @This();

/// Owned by the node; valid until the node is deinitialized or its EEPROM
/// cache is cleared.
handle: *const mscl.mscl_node_features,
supports: struct {
    /// Whether the Node supports Input Range for any of its ChannelGroups.
    input_range: bool,
    /// Whether the Node supports Input Range for any of its ChannelGroups, and
    /// has different input ranges depending on a configurable excitation
    /// voltage.
    input_range_per_excitation_voltage: bool,
    /// Whether the Node supports Hardware Offset for any of its ChannelGroups.
    hardware_offset: bool,
    /// Whether the Node supports Anti-Aliasing Filter for any of its
    /// ChannelGroups.
    anti_aliasing_filter: bool,
    /// Whether the Node supports Low-Pass Filter for any of its ChannelGroups.
    low_pass_filter: bool,
    /// Whether the Node supports High-Pass Filter for any of its ChannelGroups.
    high_pass_filter: bool,
    /// Whether the Node supports Gauge Factor for any of its ChannelGroups.
    gauge_factor: bool,
    /// Whether the Node supports the Gauge Resistance option.
    gauge_resistance: bool,
    /// Whether the Node supports the Number of Active Gauges option.
    num_active_gauges: bool,
    /// Whether the Node supports the Lost Beacon Timeout option.
    lost_beacon_timeout: bool,
    /// Whether the Node supports the Pull-up Resistor option.
    pull_up_resistor: bool,
    /// Whether the Node supports Filter Settling Time for any of its
    /// ChannelGroups.
    filter_settling_time: bool,
    /// Whether the Node supports the Thermocouple Type for any of its
    /// ChannelGroups.
    thermocouple_type: bool,
    /// Whether the Node supports the TempSensorOptions configuration for any of
    /// its ChannelGroups.
    temp_sensor_options: bool,
    /// Whether the Node supports the Debounce Filter configuration for any of
    /// its ChannelGroups.
    debounce_filter: bool,
    /// Whether the Node supports FatigueOptions configuration.
    fatigue_config: bool,
    /// Whether the Node supports Young's Modulus (part of FatigueOptions)
    /// configuration.
    youngs_mod_config: bool,
    /// Whether the Node supports Poisson's Ratio (part of FatigueOptions)
    /// configuration.
    poissons_ratio_config: bool,
    /// Whether the Node supports enabling Debug Mode (part of FatigueOptions)
    /// configuration.
    fatigue_debug_mode_config: bool,
    /// Whether the Node supports Fatigue Mode (part of FatigueOptions)
    /// configuration.
    fatigue_mode_config: bool,
    /// Whether the Node supports HistogramOptions configuration.
    histogram_config: bool,
    /// Whether the Node supports Histogram transmit rate (part of
    /// HistogramOptions) configuration.
    histogram_rate_config: bool,
    /// Whether the Node supports turning Histograms on and off (part of
    /// FatigueOptions).
    histogram_enable_config: bool,
    /// Whether the Node supports the ActivitySense feature.
    activity_sense: bool,
    /// Whether the Node supports the Auto Balance command for any of its
    /// ChannelGroups.
    auto_balance: bool,
    /// Whether the Node supports the legacy Shunt Cal for any of its
    /// ChannelGroups.
    legacy_shunt_cal: bool,
    /// Whether the Node supports the AutoCal SHM-Link command.
    auto_cal_shm: bool,
    /// Whether the Node supports the AutoCal SHM-Link-201 command.
    auto_cal_shm201: bool,
    /// Whether the Node supports AutoShuntCal on any of this ChannelGroups.
    auto_shunt_cal: bool,
    /// Whether the Node has factory calibrations stored for any of its
    /// ChannelGroups.
    get_factory_cal: bool,
    /// Whether the Node supports setting a limited duration of sampling.
    limited_duration: bool,
    /// Whether the Node supports Event Trigger sampling.
    event_trigger: bool,
    /// Whether the Node supports sending Diagnostic Info.
    diagnostic_info: bool,
    /// Whether the Node supports logging to internal memory.
    logged_data: bool,
    /// Whether the Node supports the poll command.
    poll: bool,
    /// Whether the Node supports configuration of sensor delay.
    sensor_delay_config: bool,
    /// Whether the Node supports setting the sensor delay value to "Always On."
    sensor_delay_always_on: bool,
    /// Whether the Node supports configuration of the Sensor Output Mode.
    sensor_output_mode: bool,
    /// Whether the Node supports configuration of the channel frequency class
    /// filter.
    cfc_filter_configuration: bool,
    /// Whether the Node configures event duration in 10s of milliseconds or
    /// not.
    centisecond_event_duration: bool,
    /// Whether the Node supports the Get Diagnostic Info command.
    get_diagnostic_info: bool,
    /// Whether the Node supports the version of Non-Sync Sampling that will add
    /// timestamps when logging. If the Node does not support this, when
    /// downloading logged data from the Node, no timestamp information will be
    /// given.
    non_sync_log_with_timestamps: bool,
    /// Whether the Node supports any form of the Raw Data Mode (raw only, raw +
    /// derived, etc).
    raw_data_mode: bool,
    /// Whether the Node supports any form of the Derived Data Mode (derived
    /// only, raw + derived, etc).
    derived_data_mode: bool,
    /// Whether the Node supports configuration of the Derived Velocity Unit.
    derived_velocity_unit_config: bool,
    /// Whether the Node supports configuration of its Excitation Voltage.
    excitation_voltage_config: bool,
    /// Whether the Node supports configuration of its low battery threshold.
    low_battery_threshold_config: bool,
},
/// The sensor delay values (in microseconds) that are supported. Each is null
/// when the sensor delay feature is not supported by this Node.
sensor_delay: SensorDelay,
timeout: struct {
    /// The minimum inactivity timeout (in seconds) that is supported.
    inactivity: u16,
    lost_beacon: struct {
        /// The maximum lost beacon timeout (in minutes) that is supported.
        max: u16,
        /// The minimum lost beacon timeout (in minutes) that is supported.
        /// Note: A value of 0 disable the lost beacon timeout.
        min: u16,
    },
},
check_radio_interval: struct {
    /// The maximum check radio interval (in seconds) that is supported.
    max: u8,
    /// The minimum check radio interval (in seconds) that is supported.
    min: u8,
},
sweeps: Sweeps,
time_between_bursts: TimeBetweenBursts,
event_duration: EventDuration,
sample_rate: SampleRates,
input_ranges: InputRanges,
/// The number of damage angles (see FatigueOptions) on this Node.
damage_angle_count: u8,
/// The number of Sn Curve segments (see FatigueOptions) on this Node.
sn_curve_segment_count: u8,
/// The number of supported event triggers on this Node (0 if event sampling is
/// not supported).
event_trigger_count: u8,
/// The input voltage type of the ADC for this node.
adc_voltage_input_type: root.VoltageType,
/// The WirelessTypes::SamplingModes that are supported by this Node.
sampling_modes: []const root.SamplingMode,
/// The WirelessTypes::DataFormats that are supported by this Node.
data_formats: []const root.DataFormat,
/// The WirelessTypes::DefaultModes that are supported by this Node.
default_modes: []const root.DefaultMode,
/// The WirelessTypes::DataCollectionMethods that are supported by this Node.
data_collection_methods: []const root.DataCollectionMethod,
/// The WirelessTypes::CommProtocols that are supported by this Node.
comm_protocols: []const root.CommProtocol,
/// The WirelessTypes::DataModes that are supported by this Node.
data_modes: []const root.DataMode,
/// The WirelessTypes::TransducerTypes that are supported by this Node.
transducer_types: []const root.TransducerType,
/// The WirelessTypes::FatigueModes that are supported by this Node.
fatigue_modes: []const root.FatigueMode,
/// The WirelessChannels of this Node.
channels: []const mscl.mscl_wireless_channel,
/// The WirelessTypes::DerivedCategory to ChannelMasks that are supported by
/// this Node. The ChannelMask indicates the raw channels that are available for
/// the derived category.
channels_per_derived_category: []const mscl.mscl_derived_channel_mask,
/// The ChannelGroups supported by this Node.
channel_groups: []const mscl.mscl_channel_group,
/// The WirelessTypes::WirelessSampleRates that are supported by this Node for
/// Derived Channels. These are the rates that the Derived Data will be
/// calculated/sent. The standard sampleRates still apply in derived mode and
/// control the sample rate of the raw channels used in the derived data
/// calculations.
derived_data_rates: []const root.SampleRate,
/// The WirelessTypes::SensorOutputModes that are supported by this Node.
sensor_output_modes: []const root.SensorOutputMode,
/// The WirelessTypes::ChannelFrequencyClass options that are supportedby this
/// Node.
cfc_filters: []const root.ChannelFrequencyClass,
/// The Histogram Transmit Rates that are supported by this Node.
histogram_transmit_rates: []const root.SampleRate,
/// The WirelessTypes::StorageLimitModes that are supported by this Node.
storage_limit_modes: []const root.StorageLimitMode,
/// The WirelessTypes::Voltages that are supported by the Node for
/// configuration.
excitation_voltages: []const root.Voltage,
filter: Filters,
/// The WirelessTypes::TransmitPowers that are supported by this Node, for each
/// WirelessTypes::CommProtocol; empty when the Node does not support the
/// protocol. Note: This list is dependent on the WirelessTypes::RegionCode of
/// the device. If this changes, the features should be read again.
transmit_powers: TransmitPowers,

pub const Error = error{
    NotSupported,
    NodeCommunication,
    Connection,
    /// Any other failure; `root.mscl.mscl_last_error()` describes it.
    MsclFailure,
};

/// The WirelessTypes::TransmitPowers that are supported by a Node, for each
/// WirelessTypes::CommProtocol, strongest first.
pub const TransmitPowers = struct {
    lxrs: []const root.TransmitPower,
    lxrs_plus: []const root.TransmitPower,

    /// Gets the maximum WirelessTypes::TransmitPower that is supported for the
    /// given parameters; null when the Node does not support the protocol.
    /// `self` must point at the `transmit_powers` field of a Features.
    pub fn max(
        self: *const TransmitPowers,
        protocol: root.CommProtocol,
        option: struct {
            /// The WirelessTypes::RegionCode to check; null uses the Node's
            /// current region code.
            region: ?root.RegionCode = null,
        },
    ) ?root.TransmitPower {
        const powers = switch (protocol) {
            .lxrs => self.lxrs,
            .lxrs_plus => self.lxrs_plus,
            _ => {
                return null;
            },
        };
        if (powers.len == 0) {
            return null;
        }
        const region = option.region orelse {
            // MSCL sorts transmit powers strongest first.
            return powers[0];
        };
        const features: *const Features =
            @fieldParentPtr("transmit_powers", self);
        var power: mscl.mscl_transmit_power = 0;
        _ = mscl.mscl_node_features_get_region_max_transmit_power(
            features.handle,
            @backingInt(region),
            @backingInt(protocol),
            &power,
        );
        return @fromBackingInt(power);
    }

    /// Gets the minimum WirelessTypes::TransmitPower that is supported for the
    /// given parameters; null when the Node does not support the protocol.
    /// `self` must point at the `transmit_powers` field of a Features.
    pub fn min(
        self: *const TransmitPowers,
        protocol: root.CommProtocol,
        option: struct {
            /// The WirelessTypes::RegionCode to check; null uses the Node's
            /// current region code.
            region: ?root.RegionCode = null,
        },
    ) ?root.TransmitPower {
        const powers = switch (protocol) {
            .lxrs => self.lxrs,
            .lxrs_plus => self.lxrs_plus,
            _ => {
                return null;
            },
        };
        if (powers.len == 0) {
            return null;
        }
        const region = option.region orelse {
            // MSCL sorts transmit powers strongest first, so the weakest
            // is last.
            return powers[powers.len - 1];
        };
        const features: *const Features =
            @fieldParentPtr("transmit_powers", self);
        var power: mscl.mscl_transmit_power = 0;
        _ = mscl.mscl_node_features_get_region_min_transmit_power(
            features.handle,
            @backingInt(region),
            @backingInt(protocol),
            &power,
        );
        return @fromBackingInt(power);
    }
};

/// The number of sweeps a Node can be assigned. It holds no data: each function
/// asks MSCL through the Features that holds it, so `self` must point at the
/// `sweeps` field of a Features.
pub const Sweeps = struct {
    /// Gets the minimum number of sweeps that can be assigned for the duration
    /// of a continuous sampling session.
    pub fn min(self: *const Sweeps) u32 {
        const features: *const Features =
            @alignCast(@fieldParentPtr("sweeps", self));
        var value: u32 = 0;
        _ = mscl.mscl_node_features_get_min_sweeps(features.handle, &value);
        return value;
    }

    /// Gets the maximum number of sweeps that can be assigned for a given
    /// WirelessTypes::SamplingMode. This is the duration of each burst if in
    /// Burst Sync Sampling mode, or the total duration of sampling in other
    /// sampling modes.
    pub fn max(
        self: *const Sweeps,
        sampling_mode: root.SamplingMode,
        data_mode: root.DataMode,
        data_format: root.DataFormat,
        channels: u16,
    ) u32 {
        const features: *const Features =
            @alignCast(@fieldParentPtr("sweeps", self));
        var sweeps: u32 = 0;
        _ = mscl.mscl_node_features_get_max_sweeps(
            features.handle,
            @backingInt(sampling_mode),
            @backingInt(data_mode),
            @backingInt(data_format),
            channels,
            &sweeps,
        );
        return sweeps;
    }

    /// Normalizes the number of sweeps so that it is within range and a
    /// multiple of 100 (rounds up to next multiple).
    pub fn normalize(self: *const Sweeps, sweeps: u32) u32 {
        const features: *const Features =
            @alignCast(@fieldParentPtr("sweeps", self));
        var normalized: u32 = 0;
        _ = mscl.mscl_node_features_normalize_num_sweeps(
            features.handle,
            sweeps,
            &normalized,
        );
        return normalized;
    }
};

/// The sensor delay values (in microseconds) that are supported. `normalize`
/// asks MSCL through the Features that holds it, so call it on the
/// `sensor_delay` field of a Features.
pub const SensorDelay = struct {
    /// The minimum sensor delay value (in microseconds) that is supported.
    /// Null when the sensor delay feature is not supported by this Node.
    min: ?u32,
    /// The maximum sensor delay value (in microseconds) that is supported.
    /// Null when the sensor delay feature is not supported by this Node.
    max: ?u32,
    /// The default sensor delay value (in microseconds) that is supported.
    /// Null when the sensor delay feature is not supported by this Node.
    default: ?u32,

    /// Normalizes the sensor delay so that it is an acceptable value.
    pub fn normalize(self: *const SensorDelay, delay: u32) Error!u32 {
        const features: *const Features =
            @alignCast(@fieldParentPtr("sensor_delay", self));
        var normalized: u32 = 0;
        const status = mscl.mscl_node_features_normalize_sensor_delay(
            features.handle,
            delay,
            &normalized,
        );
        return switch (status) {
            mscl.MSCL_OK => normalized,
            // The sensor delay feature is not supported by this Node.
            mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
            else => mscl: {
                std.log.err("{s}", .{mscl.mscl_last_error()});
                break :mscl Error.MsclFailure;
            },
        };
    }
};

/// The time between bursts of a Burst Sync Sampling session. It holds no data:
/// each function asks MSCL through the Features that holds it, so `self` must
/// point at the `time_between_bursts` field of a Features.
pub const TimeBetweenBursts = struct {
    /// Gets the minimum time that can be assigned for a Burst Sync Sampling
    /// session. The result is in nanoseconds.
    pub fn min(
        self: *const TimeBetweenBursts,
        data_mode: root.DataMode,
        data_format: root.DataFormat,
        raw_channels: u16,
        derived_masks: []const mscl.mscl_derived_channel_mask,
        raw_sample_rate: root.SampleRate,
        sweeps_per_burst: u32,
        protocol: root.CommProtocol,
    ) u64 {
        const features: *const Features =
            @alignCast(@fieldParentPtr("time_between_bursts", self));
        var time_ns: u64 = 0;
        _ = mscl.mscl_node_features_get_min_time_between_bursts(
            features.handle,
            @backingInt(data_mode),
            @backingInt(data_format),
            raw_channels,
            derived_masks.ptr,
            derived_masks.len,
            @backingInt(raw_sample_rate),
            sweeps_per_burst,
            @backingInt(protocol),
            &time_ns,
        );
        return time_ns;
    }

    /// Normalizes a TimeSpan so that it is within an acceptable range for
    /// setting the timeBetweenBursts. A valid range is between 1 second and 24
    /// hours. Seconds above 32767 will be rounded to minutes. When setting the
    /// time between bursts, you should also call minTimeBetweenBursts and
    /// verify it is greater than this.
    pub fn normalize(self: *const TimeBetweenBursts, time_ns: u64) u64 {
        const features: *const Features =
            @alignCast(@fieldParentPtr("time_between_bursts", self));
        var normalized_ns: u64 = 0;
        _ = mscl.mscl_node_features_normalize_time_between_bursts(
            features.handle,
            time_ns,
            &normalized_ns,
        );
        return normalized_ns;
    }
};

/// The pre and post event durations of Event Trigger sampling. It holds no
/// data: each function asks MSCL through the Features that holds it, so `self`
/// must point at the `event_duration` field of a Features.
pub const EventDuration = struct {
    /// Gets the max event trigger duration (in milliseconds) that can be
    /// applied for both the pre and post event durations (combined).
    pub fn max(
        self: *const EventDuration,
        data_mode: root.DataMode,
        data_format: root.DataFormat,
        raw_channels: u16,
        derived_masks: []const mscl.mscl_derived_channel_mask,
        raw_sample_rate: root.SampleRate,
        derived_data_rate: root.SampleRate,
    ) u32 {
        const features: *const Features =
            @alignCast(@fieldParentPtr("event_duration", self));
        var duration: u32 = 0;
        _ = mscl.mscl_node_features_get_max_event_trigger_total_duration(
            features.handle,
            @backingInt(data_mode),
            @backingInt(data_format),
            raw_channels,
            derived_masks.ptr,
            derived_masks.len,
            @backingInt(raw_sample_rate),
            @backingInt(derived_data_rate),
            &duration,
        );
        return duration;
    }

    /// Normalizes the Event Trigger duration so that it is an acceptable value.
    pub fn normalize(self: *const EventDuration, duration: u32) u32 {
        const features: *const Features =
            @alignCast(@fieldParentPtr("event_duration", self));
        var normalized: u32 = 0;
        _ = mscl.mscl_node_features_normalize_event_duration(
            features.handle,
            duration,
            &normalized,
        );
        return normalized;
    }
};

/// The sample rates of a Node. It holds no data: each function asks MSCL
/// through the Features that holds it, so `self` must point at the
/// `sample_rate` field of a Features.
pub const SampleRates = struct {
    /// Gets a list of the WirelessTypes::WirelessSampleRates that are supported
    /// by this Node for the given sampling mode. The list is written into
    /// `buffer`, truncated to fit.
    pub fn list(
        self: *const SampleRates,
        sampling_mode: root.SamplingMode,
        collection_method: root.DataCollectionMethod,
        data_mode: root.DataMode,
        buffer: []root.SampleRate,
    ) Error![]root.SampleRate {
        const features: *const Features =
            @alignCast(@fieldParentPtr("sample_rate", self));
        var count: usize = 0;
        const status = mscl.mscl_node_features_get_sample_rates(
            features.handle,
            @backingInt(sampling_mode),
            @backingInt(collection_method),
            @backingInt(data_mode),
            @ptrCast(buffer.ptr),
            buffer.len,
            &count,
        );
        return switch (status) {
            mscl.MSCL_OK => buffer[0..count],
            // The WirelessTypes::SamplingMode is not supported by this Node.
            // The WirelessTypes::DataCollectionMethod is not supported by this
            // Node.
            mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
            else => mscl: {
                std.log.err("{s}", .{mscl.mscl_last_error()});
                break :mscl Error.MsclFailure;
            },
        };
    }

    /// Checks if a sample rate is supported by the Node for the given
    /// WirelessTypes::SamplingMode.
    pub fn supports(
        self: *const SampleRates,
        rate: root.SampleRate,
        sampling_mode: root.SamplingMode,
        collection_method: root.DataCollectionMethod,
        data_mode: root.DataMode,
    ) bool {
        const features: *const Features =
            @alignCast(@fieldParentPtr("sample_rate", self));
        var supported: bool = false;
        _ = mscl.mscl_node_features_supports_sample_rate(
            features.handle,
            @backingInt(rate),
            @backingInt(sampling_mode),
            @backingInt(collection_method),
            @backingInt(data_mode),
            &supported,
        );
        return supported;
    }

    /// Gets the maximum SampleRate value that is supported by this Node with
    /// the given SamplingMode, ChannelMask, and
    /// WirelessTypes::DataCollectionMethod.
    pub fn max(
        self: *const SampleRates,
        sampling_mode: root.SamplingMode,
        channels: u16,
        collection_method: root.DataCollectionMethod,
        data_mode: root.DataMode,
    ) Error!root.SampleRate {
        const features: *const Features =
            @alignCast(@fieldParentPtr("sample_rate", self));
        var rate: mscl.mscl_sample_rate = 0;
        const status = mscl.mscl_node_features_get_max_sample_rate(
            features.handle,
            @backingInt(sampling_mode),
            channels,
            @backingInt(collection_method),
            @backingInt(data_mode),
            &rate,
        );
        return switch (status) {
            mscl.MSCL_OK => @fromBackingInt(rate),
            // The WirelessTypes::SamplingMode is not supported by this Node.
            // The WirelessTypes::DataCollectionMethod is not supported by this
            // Node.
            mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
            else => mscl: {
                std.log.err("{s}", .{mscl.mscl_last_error()});
                break :mscl Error.MsclFailure;
            },
        };
    }

    /// Gets the maximum SampleRate value that is supported by this Node with
    /// the given WirelessTypes::SettlingTime.
    pub fn maxForSettlingTime(
        self: *const SampleRates,
        settling_time: root.SettlingTime,
        sampling_mode: root.SamplingMode,
        collection_method: root.DataCollectionMethod,
        data_mode: root.DataMode,
    ) Error!root.SampleRate {
        const features: *const Features =
            @alignCast(@fieldParentPtr("sample_rate", self));
        var rate: mscl.mscl_sample_rate = 0;
        const status =
            mscl.mscl_node_features_get_max_sample_rate_for_settling_time(
                features.handle,
                @backingInt(settling_time),
                @backingInt(sampling_mode),
                @backingInt(collection_method),
                @backingInt(data_mode),
                &rate,
            );
        return switch (status) {
            mscl.MSCL_OK => @fromBackingInt(rate),
            // The Filter Settling Time feature is not supported by this Node.
            mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
            else => mscl: {
                std.log.err("{s}", .{mscl.mscl_last_error()});
                break :mscl Error.MsclFailure;
            },
        };
    }

    /// Gets the maximum SampleRate value that is supported by this Node with
    /// the given Low Pass Filter.
    pub fn maxForLowPassFilter(
        self: *const SampleRates,
        filter: root.Filter,
        sampling_mode: root.SamplingMode,
        collection_method: root.DataCollectionMethod,
        data_mode: root.DataMode,
        channels: u16,
    ) Error!root.SampleRate {
        const features: *const Features =
            @alignCast(@fieldParentPtr("sample_rate", self));
        var rate: mscl.mscl_sample_rate = 0;
        const status =
            mscl.mscl_node_features_get_max_sample_rate_for_low_pass_filter(
                features.handle,
                @backingInt(filter),
                @backingInt(sampling_mode),
                @backingInt(collection_method),
                @backingInt(data_mode),
                channels,
                &rate,
            );
        return switch (status) {
            mscl.MSCL_OK => @fromBackingInt(rate),
            // The Low Pass Filter feature is not supported by this Node, or an
            // invalid filter was used.
            mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
            else => mscl: {
                std.log.err("{s}", .{mscl.mscl_last_error()});
                break :mscl Error.MsclFailure;
            },
        };
    }
};

/// The InputRanges of a Node. It holds no data: each function asks MSCL through
/// the Features that holds it, so `self` must point at the `input_ranges` field
/// of a Features.
pub const InputRanges = struct {
    /// Gets a list of InputRanges that are supported by this Node for the
    /// specified channel mask. The list is written into `buffer`, truncated to
    /// fit.
    pub fn list(
        self: *const InputRanges,
        channels: u16,
        buffer: []mscl.mscl_input_range_entry,
        option: struct {
            /// The Excitation WirelessTypes::Voltage to get the input ranges
            /// for; null gets them without an excitation voltage.
            excitation_voltage: ?root.Voltage = null,
        },
    ) []mscl.mscl_input_range_entry {
        const features: *const Features =
            @alignCast(@fieldParentPtr("input_ranges", self));
        var count: usize = 0;
        if (option.excitation_voltage) |voltage| {
            _ = mscl.mscl_node_features_get_input_ranges_for_excitation_voltage(
                features.handle,
                channels,
                @backingInt(voltage),
                buffer.ptr,
                buffer.len,
                &count,
            );
        } else {
            _ = mscl.mscl_node_features_get_input_ranges(
                features.handle,
                channels,
                buffer.ptr,
                buffer.len,
                &count,
            );
        }
        return buffer[0..count];
    }
};

/// The filters that are supported by a Node. `maxSettlingTime` asks MSCL
/// through the Features that holds it, so call it on the `filter` field of a
/// Features.
pub const Filters = struct {
    /// The Anti-Aliasing WirelessTypes::Filters that are supported by this
    /// Node.
    anti_aliasing: []const root.Filter,
    /// The Low-Pass WirelessTypes::Filters that are supported by this Node.
    low_pass: []const root.Filter,
    /// The High-Pass WirelessTypes::Filters that are supported by this Node.
    high_pass: []const root.HighPassFilter,

    /// Gets the maximum WirelessTypes::SettlingTime available for the given
    /// SampleRate.
    pub fn maxSettlingTime(
        self: *const Filters,
        rate: root.SampleRate,
    ) Error!root.SettlingTime {
        const features: *const Features =
            @alignCast(@fieldParentPtr("filter", self));
        var settling_time: mscl.mscl_settling_time = 0;
        const status = mscl.mscl_node_features_get_max_filter_settling_time(
            features.handle,
            @backingInt(rate),
            &settling_time,
        );
        return switch (status) {
            mscl.MSCL_OK => @fromBackingInt(settling_time),
            // The Filter Settling Time feature is not supported by this Node.
            mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
            else => mscl: {
                std.log.err("{s}", .{mscl.mscl_last_error()});
                break :mscl Error.MsclFailure;
            },
        };
    }
};

/// Reads the NodeFeatures of the node. Free the result with `deinit`.
pub fn init(
    gpa: std.mem.Allocator,
    node: *mscl.mscl_node,
) (Error || std.mem.Allocator.Error)!Features {
    var features: ?*const mscl.mscl_node_features = null;
    const status = mscl.mscl_node_get_features(node, &features);
    switch (status) {
        mscl.MSCL_OK => {},
        // The Node model is not supported by MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => {
            return Error.NotSupported;
        },
        // Failed to communicate with the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => {
            return Error.NodeCommunication;
        },
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => {
            return Error.Connection;
        },
        else => {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            return Error.MsclFailure;
        },
    }
    const handle = features.?;

    // A query that fails leaves its field false, 0 or empty.
    var result = std.mem.zeroInit(Features, .{ .handle = handle });
    errdefer result.deinit(gpa);
    _ = mscl.mscl_node_features_supports_input_range(
        handle,
        &result.supports.input_range,
    );
    _ = mscl.mscl_node_features_supports_input_range_per_excitation_voltage(
        handle,
        &result.supports.input_range_per_excitation_voltage,
    );
    _ = mscl.mscl_node_features_supports_hardware_offset(
        handle,
        &result.supports.hardware_offset,
    );
    _ = mscl.mscl_node_features_supports_anti_aliasing_filter(
        handle,
        &result.supports.anti_aliasing_filter,
    );
    _ = mscl.mscl_node_features_supports_low_pass_filter(
        handle,
        &result.supports.low_pass_filter,
    );
    _ = mscl.mscl_node_features_supports_high_pass_filter(
        handle,
        &result.supports.high_pass_filter,
    );
    _ = mscl.mscl_node_features_supports_gauge_factor(
        handle,
        &result.supports.gauge_factor,
    );
    _ = mscl.mscl_node_features_supports_gauge_resistance(
        handle,
        &result.supports.gauge_resistance,
    );
    _ = mscl.mscl_node_features_supports_num_active_gauges(
        handle,
        &result.supports.num_active_gauges,
    );
    _ = mscl.mscl_node_features_supports_lost_beacon_timeout(
        handle,
        &result.supports.lost_beacon_timeout,
    );
    _ = mscl.mscl_node_features_supports_pull_up_resistor(
        handle,
        &result.supports.pull_up_resistor,
    );
    _ = mscl.mscl_node_features_supports_filter_settling_time(
        handle,
        &result.supports.filter_settling_time,
    );
    _ = mscl.mscl_node_features_supports_thermocouple_type(
        handle,
        &result.supports.thermocouple_type,
    );
    _ = mscl.mscl_node_features_supports_temp_sensor_options(
        handle,
        &result.supports.temp_sensor_options,
    );
    _ = mscl.mscl_node_features_supports_debounce_filter(
        handle,
        &result.supports.debounce_filter,
    );
    _ = mscl.mscl_node_features_supports_fatigue_config(
        handle,
        &result.supports.fatigue_config,
    );
    _ = mscl.mscl_node_features_supports_youngs_mod_config(
        handle,
        &result.supports.youngs_mod_config,
    );
    _ = mscl.mscl_node_features_supports_poissons_ratio_config(
        handle,
        &result.supports.poissons_ratio_config,
    );
    _ = mscl.mscl_node_features_supports_fatigue_debug_mode_config(
        handle,
        &result.supports.fatigue_debug_mode_config,
    );
    _ = mscl.mscl_node_features_supports_fatigue_mode_config(
        handle,
        &result.supports.fatigue_mode_config,
    );
    _ = mscl.mscl_node_features_supports_histogram_config(
        handle,
        &result.supports.histogram_config,
    );
    _ = mscl.mscl_node_features_supports_histogram_rate_config(
        handle,
        &result.supports.histogram_rate_config,
    );
    _ = mscl.mscl_node_features_supports_histogram_enable_config(
        handle,
        &result.supports.histogram_enable_config,
    );
    _ = mscl.mscl_node_features_supports_activity_sense(
        handle,
        &result.supports.activity_sense,
    );
    _ = mscl.mscl_node_features_supports_auto_balance(
        handle,
        &result.supports.auto_balance,
    );
    _ = mscl.mscl_node_features_supports_legacy_shunt_cal(
        handle,
        &result.supports.legacy_shunt_cal,
    );
    _ = mscl.mscl_node_features_supports_auto_calshm(
        handle,
        &result.supports.auto_cal_shm,
    );
    _ = mscl.mscl_node_features_supports_auto_calshm201(
        handle,
        &result.supports.auto_cal_shm201,
    );
    _ = mscl.mscl_node_features_supports_auto_shunt_cal(
        handle,
        &result.supports.auto_shunt_cal,
    );
    _ = mscl.mscl_node_features_supports_get_factory_cal(
        handle,
        &result.supports.get_factory_cal,
    );
    _ = mscl.mscl_node_features_supports_limited_duration(
        handle,
        &result.supports.limited_duration,
    );
    _ = mscl.mscl_node_features_supports_event_trigger(
        handle,
        &result.supports.event_trigger,
    );
    _ = mscl.mscl_node_features_supports_diagnostic_info(
        handle,
        &result.supports.diagnostic_info,
    );
    _ = mscl.mscl_node_features_supports_logged_data(
        handle,
        &result.supports.logged_data,
    );
    _ = mscl.mscl_node_features_supports_poll(
        handle,
        &result.supports.poll,
    );
    _ = mscl.mscl_node_features_supports_sensor_delay_config(
        handle,
        &result.supports.sensor_delay_config,
    );
    _ = mscl.mscl_node_features_supports_sensor_delay_always_on(
        handle,
        &result.supports.sensor_delay_always_on,
    );
    _ = mscl.mscl_node_features_supports_sensor_output_mode(
        handle,
        &result.supports.sensor_output_mode,
    );
    _ = mscl.mscl_node_features_supports_cfc_filter_configuration(
        handle,
        &result.supports.cfc_filter_configuration,
    );
    _ = mscl.mscl_node_features_supports_centisecond_event_duration(
        handle,
        &result.supports.centisecond_event_duration,
    );
    _ = mscl.mscl_node_features_supports_get_diagnostic_info(
        handle,
        &result.supports.get_diagnostic_info,
    );
    _ = mscl.mscl_node_features_supports_non_sync_log_with_timestamps(
        handle,
        &result.supports.non_sync_log_with_timestamps,
    );
    _ = mscl.mscl_node_features_supports_raw_data_mode(
        handle,
        &result.supports.raw_data_mode,
    );
    _ = mscl.mscl_node_features_supports_derived_data_mode(
        handle,
        &result.supports.derived_data_mode,
    );
    _ = mscl.mscl_node_features_supports_derived_velocity_unit_config(
        handle,
        &result.supports.derived_velocity_unit_config,
    );
    _ = mscl.mscl_node_features_supports_excitation_voltage_config(
        handle,
        &result.supports.excitation_voltage_config,
    );
    _ = mscl.mscl_node_features_supports_low_battery_threshold_config(
        handle,
        &result.supports.low_battery_threshold_config,
    );
    result.sensor_delay.min =
        result.getMinSensorDelay() catch |err| switch (err) {
            // The sensor delay feature is not supported by this Node.
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.sensor_delay.max =
        result.getMaxSensorDelay() catch |err| switch (err) {
            // The sensor delay feature is not supported by this Node.
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.sensor_delay.default =
        result.getDefaultSensorDelay() catch |err| switch (err) {
            // The sensor delay feature is not supported by this Node.
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    _ = mscl.mscl_node_features_get_min_inactivity_timeout(
        handle,
        &result.timeout.inactivity,
    );
    _ = mscl.mscl_node_features_get_max_lost_beacon_timeout(
        handle,
        &result.timeout.lost_beacon.max,
    );
    _ = mscl.mscl_node_features_get_min_lost_beacon_timeout(
        handle,
        &result.timeout.lost_beacon.min,
    );
    _ = mscl.mscl_node_features_get_max_check_radio_interval(
        handle,
        &result.check_radio_interval.max,
    );
    _ = mscl.mscl_node_features_get_min_check_radio_interval(
        handle,
        &result.check_radio_interval.min,
    );
    _ = mscl.mscl_node_features_get_num_damage_angles(
        handle,
        &result.damage_angle_count,
    );
    _ = mscl.mscl_node_features_get_num_sn_curve_segments(
        handle,
        &result.sn_curve_segment_count,
    );
    _ = mscl.mscl_node_features_get_num_event_triggers(
        handle,
        &result.event_trigger_count,
    );
    _ = mscl.mscl_node_features_get_adc_voltage_input_type(
        handle,
        @ptrCast(&result.adc_voltage_input_type),
    );
    result.sampling_modes = try result.getSamplingModes(gpa);
    result.data_formats = try result.getDataFormats(gpa);
    result.default_modes = try result.getDefaultModes(gpa);
    result.data_collection_methods = try result.getDataCollectionMethods(gpa);
    result.comm_protocols = try result.getCommProtocols(gpa);
    result.data_modes = try result.getDataModes(gpa);
    result.transducer_types = try result.getTransducerTypes(gpa);
    result.fatigue_modes = try result.getFatigueModes(gpa);
    result.channels = try result.getChannels(gpa);
    result.channels_per_derived_category =
        try result.getChannelsPerDerivedCategory(gpa);
    result.channel_groups = try result.getChannelGroups(gpa);
    result.derived_data_rates = try result.getDerivedDataRates(gpa);
    result.sensor_output_modes = try result.getSensorOutputModes(gpa);
    result.cfc_filters = try result.getCfcFilters(gpa);
    result.histogram_transmit_rates = try result.getHistogramTransmitRates(gpa);
    result.storage_limit_modes = try result.getStorageLimitModes(gpa);
    result.excitation_voltages = try result.getExcitationVoltages(gpa);
    result.filter.anti_aliasing = try result.getAntiAliasingFilters(gpa);
    result.filter.low_pass = try result.getLowPassFilters(gpa);
    result.filter.high_pass = try result.getHighPassFilters(gpa);
    result.transmit_powers.lxrs = try result.getTransmitPowers(gpa, .lxrs);
    result.transmit_powers.lxrs_plus =
        try result.getTransmitPowers(gpa, .lxrs_plus);
    return result;
}

pub fn deinit(self: Features, gpa: std.mem.Allocator) void {
    gpa.free(self.sampling_modes);
    gpa.free(self.data_formats);
    gpa.free(self.default_modes);
    gpa.free(self.data_collection_methods);
    gpa.free(self.comm_protocols);
    gpa.free(self.data_modes);
    gpa.free(self.transducer_types);
    gpa.free(self.fatigue_modes);
    gpa.free(self.channels);
    gpa.free(self.channels_per_derived_category);
    gpa.free(self.channel_groups);
    gpa.free(self.derived_data_rates);
    gpa.free(self.sensor_output_modes);
    gpa.free(self.cfc_filters);
    gpa.free(self.histogram_transmit_rates);
    gpa.free(self.storage_limit_modes);
    gpa.free(self.excitation_voltages);
    gpa.free(self.filter.anti_aliasing);
    gpa.free(self.filter.low_pass);
    gpa.free(self.filter.high_pass);
    gpa.free(self.transmit_powers.lxrs);
    gpa.free(self.transmit_powers.lxrs_plus);
}

/// Gets the WirelessTypes::ChannelType for the requested channel number.
pub fn getChannelType(
    self: Features,
    channel_number: u8,
) Error!root.ChannelType {
    var channel_type: mscl.mscl_channel_type = 0;
    const status = mscl.mscl_node_features_get_channel_type(
        self.handle,
        channel_number,
        &channel_type,
    );
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(channel_type),
        // The channel number is not supported by this Node.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the minimum sensor delay value (in microseconds) that is supported.
fn getMinSensorDelay(self: Features) Error!u32 {
    var value: u32 = 0;
    const status = mscl.mscl_node_features_get_min_sensor_delay(
        self.handle,
        &value,
    );
    return switch (status) {
        mscl.MSCL_OK => value,
        // The sensor delay feature is not supported by this Node.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the maximum sensor delay value (in microseconds) that is supported.
fn getMaxSensorDelay(self: Features) Error!u32 {
    var value: u32 = 0;
    const status = mscl.mscl_node_features_get_max_sensor_delay(
        self.handle,
        &value,
    );
    return switch (status) {
        mscl.MSCL_OK => value,
        // The sensor delay feature is not supported by this Node.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the default sensor delay value (in microseconds) that is supported.
fn getDefaultSensorDelay(self: Features) Error!u32 {
    var value: u32 = 0;
    const status = mscl.mscl_node_features_get_default_sensor_delay(
        self.handle,
        &value,
    );
    return switch (status) {
        mscl.MSCL_OK => value,
        // The sensor delay feature is not supported by this Node.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets a list of the WirelessTypes::SamplingModes that are supported by this
/// Node.
fn getSamplingModes(
    self: Features,
    gpa: std.mem.Allocator,
) std.mem.Allocator.Error![]const root.SamplingMode {
    // Each value appears at most once, so every list fits.
    const capacity = @typeInfo(root.SamplingMode).@"enum".field_names.len;
    var buffer: [capacity]root.SamplingMode = undefined;
    var count: usize = 0;
    _ = mscl.mscl_node_features_get_sampling_modes(
        self.handle,
        @ptrCast(&buffer),
        buffer.len,
        &count,
    );
    return try gpa.dupe(root.SamplingMode, buffer[0..count]);
}

/// Gets a list of the WirelessTypes::DataFormats that are supported by this
/// Node.
fn getDataFormats(
    self: Features,
    gpa: std.mem.Allocator,
) std.mem.Allocator.Error![]const root.DataFormat {
    // Each value appears at most once, so every list fits.
    const capacity = @typeInfo(root.DataFormat).@"enum".field_names.len;
    var buffer: [capacity]root.DataFormat = undefined;
    var count: usize = 0;
    _ = mscl.mscl_node_features_get_data_formats(
        self.handle,
        @ptrCast(&buffer),
        buffer.len,
        &count,
    );
    return try gpa.dupe(root.DataFormat, buffer[0..count]);
}

/// Gets a list of the WirelessTypes::DefaultModes that are supported by this
/// Node.
fn getDefaultModes(
    self: Features,
    gpa: std.mem.Allocator,
) std.mem.Allocator.Error![]const root.DefaultMode {
    // Each value appears at most once, so every list fits.
    const capacity = @typeInfo(root.DefaultMode).@"enum".field_names.len;
    var buffer: [capacity]root.DefaultMode = undefined;
    var count: usize = 0;
    _ = mscl.mscl_node_features_get_default_modes(
        self.handle,
        @ptrCast(&buffer),
        buffer.len,
        &count,
    );
    return try gpa.dupe(root.DefaultMode, buffer[0..count]);
}

/// Gets a list of the WirelessTypes::DataCollectionMethods that are supported
/// by this Node.
fn getDataCollectionMethods(
    self: Features,
    gpa: std.mem.Allocator,
) std.mem.Allocator.Error![]const root.DataCollectionMethod {
    // Each value appears at most once, so every list fits.
    const capacity =
        @typeInfo(root.DataCollectionMethod).@"enum".field_names.len;
    var buffer: [capacity]root.DataCollectionMethod = undefined;
    var count: usize = 0;
    _ = mscl.mscl_node_features_get_data_collection_methods(
        self.handle,
        @ptrCast(&buffer),
        buffer.len,
        &count,
    );
    return try gpa.dupe(root.DataCollectionMethod, buffer[0..count]);
}

/// Gets a list of WirelessTypes::CommProtocols that are supported by this Node.
fn getCommProtocols(
    self: Features,
    gpa: std.mem.Allocator,
) std.mem.Allocator.Error![]const root.CommProtocol {
    // Each value appears at most once, so every list fits.
    const capacity = @typeInfo(root.CommProtocol).@"enum".field_names.len;
    var buffer: [capacity]root.CommProtocol = undefined;
    var count: usize = 0;
    _ = mscl.mscl_node_features_get_comm_protocols(
        self.handle,
        @ptrCast(&buffer),
        buffer.len,
        &count,
    );
    return try gpa.dupe(root.CommProtocol, buffer[0..count]);
}

/// Gets a list of WirelessTypes::DataModes that are supported by this Node.
fn getDataModes(
    self: Features,
    gpa: std.mem.Allocator,
) std.mem.Allocator.Error![]const root.DataMode {
    // Each value appears at most once, so every list fits.
    const capacity = @typeInfo(root.DataMode).@"enum".field_names.len;
    var buffer: [capacity]root.DataMode = undefined;
    var count: usize = 0;
    _ = mscl.mscl_node_features_get_data_modes(
        self.handle,
        @ptrCast(&buffer),
        buffer.len,
        &count,
    );
    return try gpa.dupe(root.DataMode, buffer[0..count]);
}

/// Gets a list of WirelessTypes::TransducerTypes that are supported by this
/// Node.
fn getTransducerTypes(
    self: Features,
    gpa: std.mem.Allocator,
) std.mem.Allocator.Error![]const root.TransducerType {
    // Each value appears at most once, so every list fits.
    const capacity = @typeInfo(root.TransducerType).@"enum".field_names.len;
    var buffer: [capacity]root.TransducerType = undefined;
    var count: usize = 0;
    _ = mscl.mscl_node_features_get_transducer_types(
        self.handle,
        @ptrCast(&buffer),
        buffer.len,
        &count,
    );
    return try gpa.dupe(root.TransducerType, buffer[0..count]);
}

/// Gets a list of the WirelessTypes::FatigueModes that are supported by this
/// Node.
fn getFatigueModes(
    self: Features,
    gpa: std.mem.Allocator,
) std.mem.Allocator.Error![]const root.FatigueMode {
    // Each value appears at most once, so every list fits.
    const capacity = @typeInfo(root.FatigueMode).@"enum".field_names.len;
    var buffer: [capacity]root.FatigueMode = undefined;
    var count: usize = 0;
    _ = mscl.mscl_node_features_get_fatigue_modes(
        self.handle,
        @ptrCast(&buffer),
        buffer.len,
        &count,
    );
    return try gpa.dupe(root.FatigueMode, buffer[0..count]);
}

/// Gets a reference to the WirelessChannels of this Node.
fn getChannels(
    self: Features,
    gpa: std.mem.Allocator,
) std.mem.Allocator.Error![]const mscl.mscl_wireless_channel {
    // Each channel is a bit of a ChannelMask, so every list fits.
    const capacity = mscl.MSCL_CHANNEL_MASK_MAX_CHANNELS;
    var buffer: [capacity]mscl.mscl_wireless_channel = undefined;
    var count: usize = 0;
    _ = mscl.mscl_node_features_get_channels(
        self.handle,
        &buffer,
        buffer.len,
        &count,
    );
    return try gpa.dupe(mscl.mscl_wireless_channel, buffer[0..count]);
}

/// Gets a map of WirelessTypes::DerivedCategory to ChannelMasks that are
/// supported by this Node. The ChannelMask indicates the raw channels that are
/// available for the derived category.
fn getChannelsPerDerivedCategory(
    self: Features,
    gpa: std.mem.Allocator,
) std.mem.Allocator.Error![]const mscl.mscl_derived_channel_mask {
    // Each category appears at most once, so every list fits.
    const capacity = @typeInfo(root.DerivedCategory).@"enum".field_names.len;
    var buffer: [capacity]mscl.mscl_derived_channel_mask = undefined;
    var count: usize = 0;
    _ = mscl.mscl_node_features_get_channels_per_derived_category(
        self.handle,
        &buffer,
        buffer.len,
        &count,
    );
    return try gpa.dupe(mscl.mscl_derived_channel_mask, buffer[0..count]);
}

/// Gets the ChannelGroups supported by this Node.
fn getChannelGroups(
    self: Features,
    gpa: std.mem.Allocator,
) std.mem.Allocator.Error![]const mscl.mscl_channel_group {
    // MSCL sets no limit, but no Node has more groups than a ChannelMask
    // has channels.
    const capacity = mscl.MSCL_CHANNEL_MASK_MAX_CHANNELS;
    var buffer: [capacity]mscl.mscl_channel_group = undefined;
    var count: usize = 0;
    _ = mscl.mscl_node_features_get_channel_groups(
        self.handle,
        &buffer,
        buffer.len,
        &count,
    );
    return try gpa.dupe(mscl.mscl_channel_group, buffer[0..count]);
}

/// Gets a list of the WirelessTypes::WirelessSampleRates that are supported by
/// this Node for Derived Channels. These are the rates that the Derived Data
/// will be calculated/sent. The standard sampleRates still apply in derived
/// mode and control the sample rate of the raw channels used in the derived
/// data calculations.
fn getDerivedDataRates(
    self: Features,
    gpa: std.mem.Allocator,
) std.mem.Allocator.Error![]const root.SampleRate {
    // Each value appears at most once, so every list fits.
    const capacity = @typeInfo(root.SampleRate).@"enum".field_names.len;
    var buffer: [capacity]root.SampleRate = undefined;
    var count: usize = 0;
    _ = mscl.mscl_node_features_get_derived_data_rates(
        self.handle,
        @ptrCast(&buffer),
        buffer.len,
        &count,
    );
    return try gpa.dupe(root.SampleRate, buffer[0..count]);
}

/// Gets a list of WirelessTypes::SensorOutputModes that are supported by this
/// Node.
fn getSensorOutputModes(
    self: Features,
    gpa: std.mem.Allocator,
) std.mem.Allocator.Error![]const root.SensorOutputMode {
    // Each value appears at most once, so every list fits.
    const capacity = @typeInfo(root.SensorOutputMode).@"enum".field_names.len;
    var buffer: [capacity]root.SensorOutputMode = undefined;
    var count: usize = 0;
    _ = mscl.mscl_node_features_get_sensor_output_modes(
        self.handle,
        @ptrCast(&buffer),
        buffer.len,
        &count,
    );
    return try gpa.dupe(root.SensorOutputMode, buffer[0..count]);
}

/// Gets a list of WirelessTypes::ChannelFrequencyClass options that are
/// supportedby this Node.
fn getCfcFilters(
    self: Features,
    gpa: std.mem.Allocator,
) std.mem.Allocator.Error![]const root.ChannelFrequencyClass {
    // Each value appears at most once, so every list fits.
    const capacity =
        @typeInfo(root.ChannelFrequencyClass).@"enum".field_names.len;
    var buffer: [capacity]root.ChannelFrequencyClass = undefined;
    var count: usize = 0;
    _ = mscl.mscl_node_features_get_cfc_filters(
        self.handle,
        @ptrCast(&buffer),
        buffer.len,
        &count,
    );
    return try gpa.dupe(root.ChannelFrequencyClass, buffer[0..count]);
}

/// Gets a list of the Histogram Transmit Rates that are supported by this Node.
fn getHistogramTransmitRates(
    self: Features,
    gpa: std.mem.Allocator,
) std.mem.Allocator.Error![]const root.SampleRate {
    // Each value appears at most once, so every list fits.
    const capacity = @typeInfo(root.SampleRate).@"enum".field_names.len;
    var buffer: [capacity]root.SampleRate = undefined;
    var count: usize = 0;
    _ = mscl.mscl_node_features_get_histogram_transmit_rates(
        self.handle,
        @ptrCast(&buffer),
        buffer.len,
        &count,
    );
    return try gpa.dupe(root.SampleRate, buffer[0..count]);
}

/// Gets a list of the Anti-Aliasing WirelessTypes::Filters that are supported
/// by this Node.
fn getAntiAliasingFilters(
    self: Features,
    gpa: std.mem.Allocator,
) std.mem.Allocator.Error![]const root.Filter {
    // Each value appears at most once, so every list fits.
    const capacity = @typeInfo(root.Filter).@"enum".field_names.len;
    var buffer: [capacity]root.Filter = undefined;
    var count: usize = 0;
    _ = mscl.mscl_node_features_get_anti_aliasing_filters(
        self.handle,
        @ptrCast(&buffer),
        buffer.len,
        &count,
    );
    return try gpa.dupe(root.Filter, buffer[0..count]);
}

/// Gets a list of the Low-Pass WirelessTypes::Filters that are supported by
/// this Node.
fn getLowPassFilters(
    self: Features,
    gpa: std.mem.Allocator,
) std.mem.Allocator.Error![]const root.Filter {
    // Each value appears at most once, so every list fits.
    const capacity = @typeInfo(root.Filter).@"enum".field_names.len;
    var buffer: [capacity]root.Filter = undefined;
    var count: usize = 0;
    _ = mscl.mscl_node_features_get_low_pass_filters(
        self.handle,
        @ptrCast(&buffer),
        buffer.len,
        &count,
    );
    return try gpa.dupe(root.Filter, buffer[0..count]);
}

/// Gets a list of the High-Pass WirelessTypes::Filters that are supported by
/// this Node.
fn getHighPassFilters(
    self: Features,
    gpa: std.mem.Allocator,
) std.mem.Allocator.Error![]const root.HighPassFilter {
    // Each value appears at most once, so every list fits.
    const capacity = @typeInfo(root.HighPassFilter).@"enum".field_names.len;
    var buffer: [capacity]root.HighPassFilter = undefined;
    var count: usize = 0;
    _ = mscl.mscl_node_features_get_high_pass_filters(
        self.handle,
        @ptrCast(&buffer),
        buffer.len,
        &count,
    );
    return try gpa.dupe(root.HighPassFilter, buffer[0..count]);
}

/// Gets a list of the WirelessTypes::StorageLimitModes that are supported by
/// this Node.
fn getStorageLimitModes(
    self: Features,
    gpa: std.mem.Allocator,
) std.mem.Allocator.Error![]const root.StorageLimitMode {
    // Each value appears at most once, so every list fits.
    const capacity = @typeInfo(root.StorageLimitMode).@"enum".field_names.len;
    var buffer: [capacity]root.StorageLimitMode = undefined;
    var count: usize = 0;
    _ = mscl.mscl_node_features_get_storage_limit_modes(
        self.handle,
        @ptrCast(&buffer),
        buffer.len,
        &count,
    );
    return try gpa.dupe(root.StorageLimitMode, buffer[0..count]);
}

/// Gets a list of WirelessTypes::Voltages that are supported by the Node for
/// configuration.
fn getExcitationVoltages(
    self: Features,
    gpa: std.mem.Allocator,
) std.mem.Allocator.Error![]const root.Voltage {
    // Each value appears at most once, so every list fits.
    const capacity = @typeInfo(root.Voltage).@"enum".field_names.len;
    var buffer: [capacity]root.Voltage = undefined;
    var count: usize = 0;
    _ = mscl.mscl_node_features_get_excitation_voltages(
        self.handle,
        @ptrCast(&buffer),
        buffer.len,
        &count,
    );
    return try gpa.dupe(root.Voltage, buffer[0..count]);
}

/// Gets a list of the WirelessTypes::TransmitPowers that are supported by this
/// Node, for the given WirelessTypes::CommProtocol; empty when the Node does
/// not support the protocol. Note: This list is dependent on the
/// WirelessTypes::RegionCode of the device. If this changes, this function
/// should be called again.
fn getTransmitPowers(
    self: Features,
    gpa: std.mem.Allocator,
    protocol: root.CommProtocol,
) std.mem.Allocator.Error![]const root.TransmitPower {
    // Ensuring whether specified protocol is supported by the node
    var supported: bool = false;
    _ = mscl.mscl_node_features_supports_communication_protocol(
        self.handle,
        @backingInt(protocol),
        &supported,
    );
    if (!supported) return &.{};
    // Each power appears at most once, so every list fits.
    const capacity = @typeInfo(root.TransmitPower).@"enum".field_names.len;
    var buffer: [capacity]root.TransmitPower = undefined;
    var count: usize = 0;
    _ = mscl.mscl_node_features_get_transmit_powers(
        self.handle,
        @backingInt(protocol),
        @ptrCast(&buffer),
        buffer.len,
        &count,
    );
    return try gpa.dupe(root.TransmitPower, buffer[0..count]);
}
