const std = @import("std");
pub const mscl = @import("mscl");
pub const BaseStation = @import("BaseStation.zig");
pub const SetToIdleStatus = @import("SetToIdleStatus.zig");
pub const Node = @import("Node.zig");

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

/// Represents the frequency (channel) that can be used for Wireless Devices.
pub const Frequency = enum(mscl.mscl_frequency) {
    unknown = mscl.MSCL_FREQUENCY_UNKNOWN,
    frequency_11 = mscl.MSCL_FREQUENCY_11,
    frequency_12 = mscl.MSCL_FREQUENCY_12,
    frequency_13 = mscl.MSCL_FREQUENCY_13,
    frequency_14 = mscl.MSCL_FREQUENCY_14,
    frequency_15 = mscl.MSCL_FREQUENCY_15,
    frequency_16 = mscl.MSCL_FREQUENCY_16,
    frequency_17 = mscl.MSCL_FREQUENCY_17,
    frequency_18 = mscl.MSCL_FREQUENCY_18,
    frequency_19 = mscl.MSCL_FREQUENCY_19,
    frequency_20 = mscl.MSCL_FREQUENCY_20,
    frequency_21 = mscl.MSCL_FREQUENCY_21,
    frequency_22 = mscl.MSCL_FREQUENCY_22,
    frequency_23 = mscl.MSCL_FREQUENCY_23,
    frequency_24 = mscl.MSCL_FREQUENCY_24,
    frequency_25 = mscl.MSCL_FREQUENCY_25,
    frequency_26 = mscl.MSCL_FREQUENCY_26,
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

/// Represents the types of default modes the Node can have.
pub const DefaultMode = enum(mscl.mscl_default_mode) {
    idle = mscl.MSCL_DEFAULT_MODE_IDLE,
    ldc = mscl.MSCL_DEFAULT_MODE_LDC,
    datalog = mscl.MSCL_DEFAULT_MODE_DATALOG,
    sleep = mscl.MSCL_DEFAULT_MODE_SLEEP,
    sync = mscl.MSCL_DEFAULT_MODE_SYNC,
    _,
};

/// Represents the types of sampling modes the Node can be in.
pub const SamplingMode = enum(mscl.mscl_sampling_mode) {
    sync = mscl.MSCL_SAMPLING_MODE_SYNC,
    sync_burst = mscl.MSCL_SAMPLING_MODE_SYNC_BURST,
    non_sync = mscl.MSCL_SAMPLING_MODE_NON_SYNC,
    armed_datalog = mscl.MSCL_SAMPLING_MODE_ARMED_DATALOG,
    sync_event = mscl.MSCL_SAMPLING_MODE_SYNC_EVENT,
    non_sync_event = mscl.MSCL_SAMPLING_MODE_NON_SYNC_EVENT,
    _,
};

/// The possible sample rates that are available for Wireless Nodes.
pub const SampleRate = enum(mscl.mscl_sample_rate) {
    @"104170hz" = mscl.MSCL_SAMPLE_RATE_104170HZ,
    @"78125hz" = mscl.MSCL_SAMPLE_RATE_78125HZ,
    @"62500hz" = mscl.MSCL_SAMPLE_RATE_62500HZ,
    @"25000hz" = mscl.MSCL_SAMPLE_RATE_25000HZ,
    @"12500hz" = mscl.MSCL_SAMPLE_RATE_12500HZ,
    @"3200hz" = mscl.MSCL_SAMPLE_RATE_3200HZ,
    @"1600hz" = mscl.MSCL_SAMPLE_RATE_1600HZ,
    @"800hz" = mscl.MSCL_SAMPLE_RATE_800HZ,
    @"300hz" = mscl.MSCL_SAMPLE_RATE_300HZ,
    @"1k_hz" = mscl.MSCL_SAMPLE_RATE_1K_HZ,
    @"2k_hz" = mscl.MSCL_SAMPLE_RATE_2K_HZ,
    @"3k_hz" = mscl.MSCL_SAMPLE_RATE_3K_HZ,
    @"4k_hz" = mscl.MSCL_SAMPLE_RATE_4K_HZ,
    @"5k_hz" = mscl.MSCL_SAMPLE_RATE_5K_HZ,
    @"6k_hz" = mscl.MSCL_SAMPLE_RATE_6K_HZ,
    @"7k_hz" = mscl.MSCL_SAMPLE_RATE_7K_HZ,
    @"8k_hz" = mscl.MSCL_SAMPLE_RATE_8K_HZ,
    @"9k_hz" = mscl.MSCL_SAMPLE_RATE_9K_HZ,
    @"10k_hz" = mscl.MSCL_SAMPLE_RATE_10K_HZ,
    @"20k_hz" = mscl.MSCL_SAMPLE_RATE_20K_HZ,
    @"30k_hz" = mscl.MSCL_SAMPLE_RATE_30K_HZ,
    @"40k_hz" = mscl.MSCL_SAMPLE_RATE_40K_HZ,
    @"50k_hz" = mscl.MSCL_SAMPLE_RATE_50K_HZ,
    @"60k_hz" = mscl.MSCL_SAMPLE_RATE_60K_HZ,
    @"70k_hz" = mscl.MSCL_SAMPLE_RATE_70K_HZ,
    @"80k_hz" = mscl.MSCL_SAMPLE_RATE_80K_HZ,
    @"90k_hz" = mscl.MSCL_SAMPLE_RATE_90K_HZ,
    @"100k_hz" = mscl.MSCL_SAMPLE_RATE_100K_HZ,
    @"887hz" = mscl.MSCL_SAMPLE_RATE_887HZ,
    @"8192hz" = mscl.MSCL_SAMPLE_RATE_8192HZ,
    @"4096hz" = mscl.MSCL_SAMPLE_RATE_4096HZ,
    @"2048hz" = mscl.MSCL_SAMPLE_RATE_2048HZ,
    @"1024hz" = mscl.MSCL_SAMPLE_RATE_1024HZ,
    @"512hz" = mscl.MSCL_SAMPLE_RATE_512HZ,
    @"256hz" = mscl.MSCL_SAMPLE_RATE_256HZ,
    @"128hz" = mscl.MSCL_SAMPLE_RATE_128HZ,
    @"64hz" = mscl.MSCL_SAMPLE_RATE_64HZ,
    @"32hz" = mscl.MSCL_SAMPLE_RATE_32HZ,
    @"16hz" = mscl.MSCL_SAMPLE_RATE_16HZ,
    @"8hz" = mscl.MSCL_SAMPLE_RATE_8HZ,
    @"4hz" = mscl.MSCL_SAMPLE_RATE_4HZ,
    @"2hz" = mscl.MSCL_SAMPLE_RATE_2HZ,
    @"1hz" = mscl.MSCL_SAMPLE_RATE_1HZ,
    @"2sec" = mscl.MSCL_SAMPLE_RATE_2SEC,
    @"5sec" = mscl.MSCL_SAMPLE_RATE_5SEC,
    @"10sec" = mscl.MSCL_SAMPLE_RATE_10SEC,
    @"30sec" = mscl.MSCL_SAMPLE_RATE_30SEC,
    @"1min" = mscl.MSCL_SAMPLE_RATE_1MIN,
    @"2min" = mscl.MSCL_SAMPLE_RATE_2MIN,
    @"5min" = mscl.MSCL_SAMPLE_RATE_5MIN,
    @"10min" = mscl.MSCL_SAMPLE_RATE_10MIN,
    @"30min" = mscl.MSCL_SAMPLE_RATE_30MIN,
    @"60min" = mscl.MSCL_SAMPLE_RATE_60MIN,
    @"24hours" = mscl.MSCL_SAMPLE_RATE_24HOURS,
    _,
};

/// Represents the types of data formats that Nodes can be configured to send
/// when sampling.
pub const DataFormat = enum(mscl.mscl_data_format) {
    raw_uint16 = mscl.MSCL_DATA_FORMAT_RAW_UINT16,
    cal_float = mscl.MSCL_DATA_FORMAT_CAL_FLOAT,
    raw_uint24 = mscl.MSCL_DATA_FORMAT_RAW_UINT24,
    raw_int24 = mscl.MSCL_DATA_FORMAT_RAW_INT24,
    raw_int16 = mscl.MSCL_DATA_FORMAT_RAW_INT16,
    cal_int16_x10 = mscl.MSCL_DATA_FORMAT_CAL_INT16_X10,
    _,
};

/// Represents the types of data collection methods that can be performed on the
/// Node.
pub const DataCollectionMethod = enum(mscl.mscl_data_collection_method) {
    log_only = mscl.MSCL_DATA_COLLECTION_METHOD_LOG_ONLY,
    transmit_only = mscl.MSCL_DATA_COLLECTION_METHOD_TRANSMIT_ONLY,
    log_and_transmit = mscl.MSCL_DATA_COLLECTION_METHOD_LOG_AND_TRANSMIT,
    _,
};

/// Available Data Modes.
pub const DataMode = enum(mscl.mscl_data_mode) {
    none = mscl.MSCL_DATA_MODE_NONE,
    raw = mscl.MSCL_DATA_MODE_RAW,
    derived = mscl.MSCL_DATA_MODE_DERIVED,
    raw_derived = mscl.MSCL_DATA_MODE_RAW_DERIVED,
    _,
};

/// Available Derived Channel Categories for configuration.
pub const DerivedCategory = enum(mscl.mscl_derived_category) {
    rms = mscl.MSCL_DERIVED_CATEGORY_RMS,
    peak_to_peak = mscl.MSCL_DERIVED_CATEGORY_PEAK_TO_PEAK,
    velocity = mscl.MSCL_DERIVED_CATEGORY_VELOCITY,
    crest_factor = mscl.MSCL_DERIVED_CATEGORY_CREST_FACTOR,
    mean = mscl.MSCL_DERIVED_CATEGORY_MEAN,
    _,
};

/// The filter options (used for anti-aliasing and low-pass filter)
pub const Filter = enum(mscl.mscl_filter) {
    @"33000hz" = mscl.MSCL_FILTER_33000HZ,
    @"20000hz" = mscl.MSCL_FILTER_20000HZ,
    @"10000hz" = mscl.MSCL_FILTER_10000HZ,
    @"5222hz" = mscl.MSCL_FILTER_5222HZ,
    @"5000hz" = mscl.MSCL_FILTER_5000HZ,
    @"4416hz" = mscl.MSCL_FILTER_4416HZ,
    @"4096hz" = mscl.MSCL_FILTER_4096HZ,
    @"4000hz" = mscl.MSCL_FILTER_4000HZ,
    @"2208hz" = mscl.MSCL_FILTER_2208HZ,
    @"2048hz" = mscl.MSCL_FILTER_2048HZ,
    @"2000hz" = mscl.MSCL_FILTER_2000HZ,
    @"1104hz" = mscl.MSCL_FILTER_1104HZ,
    @"1024hz" = mscl.MSCL_FILTER_1024HZ,
    @"1000hz" = mscl.MSCL_FILTER_1000HZ,
    @"800hz" = mscl.MSCL_FILTER_800HZ,
    @"552hz" = mscl.MSCL_FILTER_552HZ,
    @"512hz" = mscl.MSCL_FILTER_512HZ,
    @"500hz" = mscl.MSCL_FILTER_500HZ,
    @"418hz" = mscl.MSCL_FILTER_418HZ,
    @"294hz" = mscl.MSCL_FILTER_294HZ,
    @"256hz" = mscl.MSCL_FILTER_256HZ,
    @"250hz" = mscl.MSCL_FILTER_250HZ,
    @"209hz" = mscl.MSCL_FILTER_209HZ,
    @"200hz" = mscl.MSCL_FILTER_200HZ,
    @"147hz" = mscl.MSCL_FILTER_147HZ,
    @"128hz" = mscl.MSCL_FILTER_128HZ,
    @"125hz" = mscl.MSCL_FILTER_125HZ,
    @"104hz" = mscl.MSCL_FILTER_104HZ,
    @"100hz" = mscl.MSCL_FILTER_100HZ,
    @"62hz" = mscl.MSCL_FILTER_62HZ,
    @"52hz" = mscl.MSCL_FILTER_52HZ,
    @"50hz" = mscl.MSCL_FILTER_50HZ,
    @"31hz" = mscl.MSCL_FILTER_31HZ,
    @"26hz" = mscl.MSCL_FILTER_26HZ,
    @"12_66hz" = mscl.MSCL_FILTER_12_66HZ,
    @"2_6hz" = mscl.MSCL_FILTER_2_6HZ,
    _,
};

/// The high pass filter options.
pub const HighPassFilter = enum(mscl.mscl_high_pass_filter) {
    off = mscl.MSCL_HIGH_PASS_FILTER_OFF,
    auto = mscl.MSCL_HIGH_PASS_FILTER_AUTO,
    _,
};

/// The channel frequency class filter options.
pub const ChannelFrequencyClass = enum(mscl.mscl_channel_frequency_class) {
    @"10" = mscl.MSCL_CHANNEL_FREQUENCY_CLASS_10,
    @"21" = mscl.MSCL_CHANNEL_FREQUENCY_CLASS_21,
    @"60" = mscl.MSCL_CHANNEL_FREQUENCY_CLASS_60,
    _,
};

/// Available Sensor Output Modes.
pub const SensorOutputMode = enum(mscl.mscl_sensor_output_mode) {
    accel = mscl.MSCL_SENSOR_OUTPUT_MODE_ACCEL,
    tilt = mscl.MSCL_SENSOR_OUTPUT_MODE_TILT,
    _,
};

/// Available Voltages.
pub const Voltage = enum(mscl.mscl_voltage) {
    @"5120m_v" = mscl.MSCL_VOLTAGE_5120M_V,
    @"5000m_v" = mscl.MSCL_VOLTAGE_5000M_V,
    @"4096m_v" = mscl.MSCL_VOLTAGE_4096M_V,
    @"3000m_v" = mscl.MSCL_VOLTAGE_3000M_V,
    @"2800m_v" = mscl.MSCL_VOLTAGE_2800M_V,
    @"2750m_v" = mscl.MSCL_VOLTAGE_2750M_V,
    @"2700m_v" = mscl.MSCL_VOLTAGE_2700M_V,
    @"2500m_v" = mscl.MSCL_VOLTAGE_2500M_V,
    @"1500m_v" = mscl.MSCL_VOLTAGE_1500M_V,
    _,
};

/// Represents the possible voltage input types
pub const VoltageType = enum(mscl.mscl_voltage_type) {
    single_ended = mscl.MSCL_VOLTAGE_TYPE_SINGLE_ENDED,
    differential = mscl.MSCL_VOLTAGE_TYPE_DIFFERENTIAL,
    _,
};

/// Represents the settling times used for thermocouple and voltage inputs on
/// some Wireless Nodes.
pub const SettlingTime = enum(mscl.mscl_settling_time) {
    @"4ms" = mscl.MSCL_SETTLING_TIME_4MS,
    @"8ms" = mscl.MSCL_SETTLING_TIME_8MS,
    @"16ms" = mscl.MSCL_SETTLING_TIME_16MS,
    @"32ms" = mscl.MSCL_SETTLING_TIME_32MS,
    @"40ms" = mscl.MSCL_SETTLING_TIME_40MS,
    @"48ms" = mscl.MSCL_SETTLING_TIME_48MS,
    @"60ms" = mscl.MSCL_SETTLING_TIME_60MS,
    @"101ms_90db" = mscl.MSCL_SETTLING_TIME_101MS_90DB,
    @"120ms_80db" = mscl.MSCL_SETTLING_TIME_120MS_80DB,
    @"120ms_65db" = mscl.MSCL_SETTLING_TIME_120MS_65DB,
    @"160ms_69db" = mscl.MSCL_SETTLING_TIME_160MS_69DB,
    @"200ms" = mscl.MSCL_SETTLING_TIME_200MS,
    _,
};

/// Represents the Transducer types supported by some Wireless Nodes.
pub const TransducerType = enum(mscl.mscl_transducer_type) {
    thermocouple = mscl.MSCL_TRANSDUCER_TYPE_THERMOCOUPLE,
    rtd = mscl.MSCL_TRANSDUCER_TYPE_RTD,
    thermistor = mscl.MSCL_TRANSDUCER_TYPE_THERMISTOR,
    _,
};

/// The options available for configuring what happens when the storage limit is
/// reached when logging to a Node.
pub const StorageLimitMode = enum(mscl.mscl_storage_limit_mode) {
    overwrite = mscl.MSCL_STORAGE_LIMIT_MODE_OVERWRITE,
    stop = mscl.MSCL_STORAGE_LIMIT_MODE_STOP,
    _,
};

/// Represents the types of channels on Wireless Nodes.
pub const ChannelType = enum(mscl.mscl_channel_type) {
    none = mscl.MSCL_CHANNEL_TYPE_NONE,
    full_differential = mscl.MSCL_CHANNEL_TYPE_FULL_DIFFERENTIAL,
    single_ended = mscl.MSCL_CHANNEL_TYPE_SINGLE_ENDED,
    battery = mscl.MSCL_CHANNEL_TYPE_BATTERY,
    temperature = mscl.MSCL_CHANNEL_TYPE_TEMPERATURE,
    rh = mscl.MSCL_CHANNEL_TYPE_RH,
    acceleration = mscl.MSCL_CHANNEL_TYPE_ACCELERATION,
    displacement = mscl.MSCL_CHANNEL_TYPE_DISPLACEMENT,
    voltage = mscl.MSCL_CHANNEL_TYPE_VOLTAGE,
    diff_temperature = mscl.MSCL_CHANNEL_TYPE_DIFF_TEMPERATURE,
    digital = mscl.MSCL_CHANNEL_TYPE_DIGITAL,
    tilt = mscl.MSCL_CHANNEL_TYPE_TILT,
    _,
};

/// The different modes a Fatigue Node can operate in.
pub const FatigueMode = enum(mscl.mscl_fatigue_mode) {
    angle_strain = mscl.MSCL_FATIGUE_MODE_ANGLE_STRAIN,
    distributed_angle = mscl.MSCL_FATIGUE_MODE_DISTRIBUTED_ANGLE,
    raw_gauge_strain = mscl.MSCL_FATIGUE_MODE_RAW_GAUGE_STRAIN,
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
