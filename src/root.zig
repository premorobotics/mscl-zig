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

/// Represents the channel mask (active and inactive channels) for a
/// WirelessNode. `ch1` is the lowest bit, so `@bitCast` converts it to and from
/// MSCL's 16-bit channel mask.
pub const ChannelMask = packed struct(u16) {
    ch1: bool = false,
    ch2: bool = false,
    ch3: bool = false,
    ch4: bool = false,
    ch5: bool = false,
    ch6: bool = false,
    ch7: bool = false,
    ch8: bool = false,
    ch9: bool = false,
    ch10: bool = false,
    ch11: bool = false,
    ch12: bool = false,
    ch13: bool = false,
    ch14: bool = false,
    ch15: bool = false,
    ch16: bool = false,
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

/// The options that can be configured for the velocity derived channel.
pub const DerivedVelocityUnit = enum(mscl.mscl_derived_velocity_unit) {
    ips = mscl.MSCL_DERIVED_VELOCITY_UNIT_IPS,
    mmps = mscl.MSCL_DERIVED_VELOCITY_UNIT_MMPS,
    _,
};

/// The options available for input range on supported Nodes.
pub const InputRange = enum(mscl.mscl_input_range) {
    @"14_545m_v" = mscl.MSCL_INPUT_RANGE_14_545M_V,
    @"10_236m_v" = mscl.MSCL_INPUT_RANGE_10_236M_V,
    @"7_608m_v" = mscl.MSCL_INPUT_RANGE_7_608M_V,
    @"4_046m_v" = mscl.MSCL_INPUT_RANGE_4_046M_V,
    @"2_008m_v" = mscl.MSCL_INPUT_RANGE_2_008M_V,
    @"1_511m_v" = mscl.MSCL_INPUT_RANGE_1_511M_V,
    @"1_001m_v" = mscl.MSCL_INPUT_RANGE_1_001M_V,
    @"0_812m_v" = mscl.MSCL_INPUT_RANGE_0_812M_V,
    @"75m_v" = mscl.MSCL_INPUT_RANGE_75M_V,
    @"37_5m_v" = mscl.MSCL_INPUT_RANGE_37_5M_V,
    @"18_75m_v" = mscl.MSCL_INPUT_RANGE_18_75M_V,
    @"9_38m_v" = mscl.MSCL_INPUT_RANGE_9_38M_V,
    @"4_69m_v" = mscl.MSCL_INPUT_RANGE_4_69M_V,
    @"2_34m_v" = mscl.MSCL_INPUT_RANGE_2_34M_V,
    @"1_17m_v" = mscl.MSCL_INPUT_RANGE_1_17M_V,
    @"0_586m_v" = mscl.MSCL_INPUT_RANGE_0_586M_V,
    @"70m_v" = mscl.MSCL_INPUT_RANGE_70M_V,
    @"35m_v" = mscl.MSCL_INPUT_RANGE_35M_V,
    @"17_5m_v" = mscl.MSCL_INPUT_RANGE_17_5M_V,
    @"8_75m_v" = mscl.MSCL_INPUT_RANGE_8_75M_V,
    @"4_38m_v" = mscl.MSCL_INPUT_RANGE_4_38M_V,
    @"2_19m_v" = mscl.MSCL_INPUT_RANGE_2_19M_V,
    @"1_09m_v" = mscl.MSCL_INPUT_RANGE_1_09M_V,
    @"0_547m_v" = mscl.MSCL_INPUT_RANGE_0_547M_V,
    @"44m_v" = mscl.MSCL_INPUT_RANGE_44M_V,
    @"30m_v" = mscl.MSCL_INPUT_RANGE_30M_V,
    @"20m_v" = mscl.MSCL_INPUT_RANGE_20M_V,
    @"15m_v" = mscl.MSCL_INPUT_RANGE_15M_V,
    @"10m_v" = mscl.MSCL_INPUT_RANGE_10M_V,
    @"5m_v" = mscl.MSCL_INPUT_RANGE_5M_V,
    @"3m_v" = mscl.MSCL_INPUT_RANGE_3M_V,
    @"2m_v" = mscl.MSCL_INPUT_RANGE_2M_V,
    @"6m_v" = mscl.MSCL_INPUT_RANGE_6M_V,
    @"1m_v" = mscl.MSCL_INPUT_RANGE_1M_V,
    @"50m_v" = mscl.MSCL_INPUT_RANGE_50M_V,
    @"2_5m_v" = mscl.MSCL_INPUT_RANGE_2_5M_V,
    @"0_6m_v" = mscl.MSCL_INPUT_RANGE_0_6M_V,
    @"0_35m_v" = mscl.MSCL_INPUT_RANGE_0_35M_V,
    @"0_1m_v" = mscl.MSCL_INPUT_RANGE_0_1M_V,
    @"156m_v" = mscl.MSCL_INPUT_RANGE_156M_V,
    @"78_1m_v" = mscl.MSCL_INPUT_RANGE_78_1M_V,
    @"39m_v" = mscl.MSCL_INPUT_RANGE_39M_V,
    @"19_5m_v" = mscl.MSCL_INPUT_RANGE_19_5M_V,
    @"9_76m_v" = mscl.MSCL_INPUT_RANGE_9_76M_V,
    @"4_88m_v" = mscl.MSCL_INPUT_RANGE_4_88M_V,
    @"2_44m_v" = mscl.MSCL_INPUT_RANGE_2_44M_V,
    @"1_22m_v" = mscl.MSCL_INPUT_RANGE_1_22M_V,
    @"10_24v" = mscl.MSCL_INPUT_RANGE_10_24V,
    @"5_12v" = mscl.MSCL_INPUT_RANGE_5_12V,
    @"2_56v" = mscl.MSCL_INPUT_RANGE_2_56V,
    @"0to10_24v" = mscl.MSCL_INPUT_RANGE_0TO10_24V,
    @"0to5_12v" = mscl.MSCL_INPUT_RANGE_0TO5_12V,
    @"1_147v" = mscl.MSCL_INPUT_RANGE_1_147V,
    @"585m_v" = mscl.MSCL_INPUT_RANGE_585M_V,
    @"292_5m_v" = mscl.MSCL_INPUT_RANGE_292_5M_V,
    @"146_25m_v" = mscl.MSCL_INPUT_RANGE_146_25M_V,
    @"73_13m_v" = mscl.MSCL_INPUT_RANGE_73_13M_V,
    @"36_56m_v" = mscl.MSCL_INPUT_RANGE_36_56M_V,
    @"18_23m_v" = mscl.MSCL_INPUT_RANGE_18_23M_V,
    @"9_14m_v" = mscl.MSCL_INPUT_RANGE_9_14M_V,
    @"5_74v" = mscl.MSCL_INPUT_RANGE_5_74V,
    @"2_93v" = mscl.MSCL_INPUT_RANGE_2_93V,
    @"1_46v" = mscl.MSCL_INPUT_RANGE_1_46V,
    @"731_3m_v" = mscl.MSCL_INPUT_RANGE_731_3M_V,
    @"365_6m_v" = mscl.MSCL_INPUT_RANGE_365_6M_V,
    @"182_8m_v" = mscl.MSCL_INPUT_RANGE_182_8M_V,
    @"91_4m_v" = mscl.MSCL_INPUT_RANGE_91_4M_V,
    @"45_7m_v" = mscl.MSCL_INPUT_RANGE_45_7M_V,
    @"62_5m_v" = mscl.MSCL_INPUT_RANGE_62_5M_V,
    @"31_25m_v" = mscl.MSCL_INPUT_RANGE_31_25M_V,
    @"15_63m_v" = mscl.MSCL_INPUT_RANGE_15_63M_V,
    @"7_81m_v" = mscl.MSCL_INPUT_RANGE_7_81M_V,
    @"3_91m_v" = mscl.MSCL_INPUT_RANGE_3_91M_V,
    @"1_95m_v" = mscl.MSCL_INPUT_RANGE_1_95M_V,
    @"0_976m_v" = mscl.MSCL_INPUT_RANGE_0_976M_V,
    @"0_488m_v" = mscl.MSCL_INPUT_RANGE_0_488M_V,
    @"2g" = mscl.MSCL_INPUT_RANGE_2G,
    @"4g" = mscl.MSCL_INPUT_RANGE_4G,
    @"8g" = mscl.MSCL_INPUT_RANGE_8G,
    @"10g" = mscl.MSCL_INPUT_RANGE_10G,
    @"20g" = mscl.MSCL_INPUT_RANGE_20G,
    @"40g" = mscl.MSCL_INPUT_RANGE_40G,
    @"2_5v" = mscl.MSCL_INPUT_RANGE_2_5V,
    @"1_25v" = mscl.MSCL_INPUT_RANGE_1_25V,
    @"625m_v" = mscl.MSCL_INPUT_RANGE_625M_V,
    @"312_5m_v" = mscl.MSCL_INPUT_RANGE_312_5M_V,
    @"156_25m_v" = mscl.MSCL_INPUT_RANGE_156_25M_V,
    @"78_125m_v" = mscl.MSCL_INPUT_RANGE_78_125M_V,
    @"39_063m_v" = mscl.MSCL_INPUT_RANGE_39_063M_V,
    @"19_532m_v" = mscl.MSCL_INPUT_RANGE_19_532M_V,
    @"0to2_5v" = mscl.MSCL_INPUT_RANGE_0TO2_5V,
    @"0to1_25v" = mscl.MSCL_INPUT_RANGE_0TO1_25V,
    @"0to625m_v" = mscl.MSCL_INPUT_RANGE_0TO625M_V,
    @"0to312_5m_v" = mscl.MSCL_INPUT_RANGE_0TO312_5M_V,
    @"0to156_25m_v" = mscl.MSCL_INPUT_RANGE_0TO156_25M_V,
    @"0to78_125m_v" = mscl.MSCL_INPUT_RANGE_0TO78_125M_V,
    @"0to39_063m_v" = mscl.MSCL_INPUT_RANGE_0TO39_063M_V,
    @"0to19_532m_v" = mscl.MSCL_INPUT_RANGE_0TO19_532M_V,
    @"9_766m_v" = mscl.MSCL_INPUT_RANGE_9_766M_V,
    @"1_35v_or_0to1000000ohm" = mscl.MSCL_INPUT_RANGE_1_35V_OR_0TO1000000OHM,
    @"1_25v_or_0to10000ohm" = mscl.MSCL_INPUT_RANGE_1_25V_OR_0TO10000OHM,
    @"625m_v_or_0to3333_3ohm" = mscl.MSCL_INPUT_RANGE_625M_V_OR_0TO3333_3OHM,
    @"312_5m_v_or_0to1428_6ohm" =
        mscl.MSCL_INPUT_RANGE_312_5M_V_OR_0TO1428_6OHM,
    @"156_25m_v_or_0to666_67ohm" =
        mscl.MSCL_INPUT_RANGE_156_25M_V_OR_0TO666_67OHM,
    @"78_125m_v_or_0to322_58ohm" =
        mscl.MSCL_INPUT_RANGE_78_125M_V_OR_0TO322_58OHM,
    @"39_0625m_v_or_0to158_73ohm" =
        mscl.MSCL_INPUT_RANGE_39_0625M_V_OR_0TO158_73OHM,
    @"19_5313m_v_or_0to78_74ohm" =
        mscl.MSCL_INPUT_RANGE_19_5313M_V_OR_0TO78_74OHM,
    @"750m_v" = mscl.MSCL_INPUT_RANGE_750M_V,
    @"375m_v" = mscl.MSCL_INPUT_RANGE_375M_V,
    @"187_5m_v" = mscl.MSCL_INPUT_RANGE_187_5M_V,
    @"93_75m_v" = mscl.MSCL_INPUT_RANGE_93_75M_V,
    @"46_875m_v" = mscl.MSCL_INPUT_RANGE_46_875M_V,
    @"23_438m_v" = mscl.MSCL_INPUT_RANGE_23_438M_V,
    @"11_719m_v" = mscl.MSCL_INPUT_RANGE_11_719M_V,
    @"5_859m_v" = mscl.MSCL_INPUT_RANGE_5_859M_V,
    @"0to1_5v" = mscl.MSCL_INPUT_RANGE_0TO1_5V,
    @"0to750m_v" = mscl.MSCL_INPUT_RANGE_0TO750M_V,
    @"0to375m_v" = mscl.MSCL_INPUT_RANGE_0TO375M_V,
    @"0to187_5m_v" = mscl.MSCL_INPUT_RANGE_0TO187_5M_V,
    @"0to93_75m_v" = mscl.MSCL_INPUT_RANGE_0TO93_75M_V,
    @"0to46_875m_v" = mscl.MSCL_INPUT_RANGE_0TO46_875M_V,
    @"0to23_438m_v" = mscl.MSCL_INPUT_RANGE_0TO23_438M_V,
    @"0to11_719m_v" = mscl.MSCL_INPUT_RANGE_0TO11_719M_V,
    @"1_5v" = mscl.MSCL_INPUT_RANGE_1_5V,
    @"1_35v" = mscl.MSCL_INPUT_RANGE_1_35V,
    @"0to1000000ohm" = mscl.MSCL_INPUT_RANGE_0TO1000000OHM,
    @"0to10000ohm" = mscl.MSCL_INPUT_RANGE_0TO10000OHM,
    @"0to3333_3ohm" = mscl.MSCL_INPUT_RANGE_0TO3333_3OHM,
    @"0to1428_6ohm" = mscl.MSCL_INPUT_RANGE_0TO1428_6OHM,
    @"0to666_67ohm" = mscl.MSCL_INPUT_RANGE_0TO666_67OHM,
    @"0to322_58ohm" = mscl.MSCL_INPUT_RANGE_0TO322_58OHM,
    @"0to158_73ohm" = mscl.MSCL_INPUT_RANGE_0TO158_73OHM,
    @"0to78_74ohm" = mscl.MSCL_INPUT_RANGE_0TO78_74OHM,
    @"39_0625m_v" = mscl.MSCL_INPUT_RANGE_39_0625M_V,
    @"19_5313m_v" = mscl.MSCL_INPUT_RANGE_19_5313M_V,
    @"125m_v" = mscl.MSCL_INPUT_RANGE_125M_V,
    invalid = mscl.MSCL_INPUT_RANGE_INVALID,
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

/// Represents the unit types that can be used for calibration coefficients on
/// Wireless Nodes.
pub const CalCoefUnit = enum(mscl.mscl_cal_coef_unit) {
    none = mscl.MSCL_CAL_COEF_UNIT_NONE,
    other_bits = mscl.MSCL_CAL_COEF_UNIT_OTHER_BITS,
    strain_strain = mscl.MSCL_CAL_COEF_UNIT_STRAIN_STRAIN,
    strain_micro_strain = mscl.MSCL_CAL_COEF_UNIT_STRAIN_MICRO_STRAIN,
    accel_g = mscl.MSCL_CAL_COEF_UNIT_ACCEL_G,
    accel_m_per_sec2 = mscl.MSCL_CAL_COEF_UNIT_ACCEL_M_PER_SEC2,
    volts_volts = mscl.MSCL_CAL_COEF_UNIT_VOLTS_VOLTS,
    volts_millivolts = mscl.MSCL_CAL_COEF_UNIT_VOLTS_MILLIVOLTS,
    volts_microvolts = mscl.MSCL_CAL_COEF_UNIT_VOLTS_MICROVOLTS,
    temp_celsius = mscl.MSCL_CAL_COEF_UNIT_TEMP_CELSIUS,
    temp_kelvin = mscl.MSCL_CAL_COEF_UNIT_TEMP_KELVIN,
    temp_fahrenheit = mscl.MSCL_CAL_COEF_UNIT_TEMP_FAHRENHEIT,
    displacement_meters = mscl.MSCL_CAL_COEF_UNIT_DISPLACEMENT_METERS,
    displacement_millimeters = mscl.MSCL_CAL_COEF_UNIT_DISPLACEMENT_MILLIMETERS,
    displacement_micrometers = mscl.MSCL_CAL_COEF_UNIT_DISPLACEMENT_MICROMETERS,
    force_lbf = mscl.MSCL_CAL_COEF_UNIT_FORCE_LBF,
    force_newtons = mscl.MSCL_CAL_COEF_UNIT_FORCE_NEWTONS,
    force_kilo_newtons = mscl.MSCL_CAL_COEF_UNIT_FORCE_KILO_NEWTONS,
    mass_kilograms = mscl.MSCL_CAL_COEF_UNIT_MASS_KILOGRAMS,
    pressure_bar = mscl.MSCL_CAL_COEF_UNIT_PRESSURE_BAR,
    pressure_psi = mscl.MSCL_CAL_COEF_UNIT_PRESSURE_PSI,
    pressure_atm = mscl.MSCL_CAL_COEF_UNIT_PRESSURE_ATM,
    pressure_mm_hg = mscl.MSCL_CAL_COEF_UNIT_PRESSURE_MM_HG,
    pressure_pascal = mscl.MSCL_CAL_COEF_UNIT_PRESSURE_PASCAL,
    pressure_mega_pascal = mscl.MSCL_CAL_COEF_UNIT_PRESSURE_MEGA_PASCAL,
    pressure_kilo_pascal = mscl.MSCL_CAL_COEF_UNIT_PRESSURE_KILO_PASCAL,
    ang_displacement_degrees = mscl.MSCL_CAL_COEF_UNIT_ANG_DISPLACEMENT_DEGREES,
    ang_velocity_degrees_per_sec =
        mscl.MSCL_CAL_COEF_UNIT_ANG_VELOCITY_DEGREES_PER_SEC,
    ang_velocity_radians_per_sec =
        mscl.MSCL_CAL_COEF_UNIT_ANG_VELOCITY_RADIANS_PER_SEC,
    other_percent = mscl.MSCL_CAL_COEF_UNIT_OTHER_PERCENT,
    freq_rpm = mscl.MSCL_CAL_COEF_UNIT_FREQ_RPM,
    freq_hertz = mscl.MSCL_CAL_COEF_UNIT_FREQ_HERTZ,
    rh_percent_rh = mscl.MSCL_CAL_COEF_UNIT_RH_PERCENT_RH,
    other_m_vper_v = mscl.MSCL_CAL_COEF_UNIT_OTHER_M_VPER_V,
    accel_milli_g = mscl.MSCL_CAL_COEF_UNIT_ACCEL_MILLI_G,
    accel_ft_per_sec2 = mscl.MSCL_CAL_COEF_UNIT_ACCEL_FT_PER_SEC2,
    other_percent_life = mscl.MSCL_CAL_COEF_UNIT_OTHER_PERCENT_LIFE,
    other_count = mscl.MSCL_CAL_COEF_UNIT_OTHER_COUNT,
    displacement_feet = mscl.MSCL_CAL_COEF_UNIT_DISPLACEMENT_FEET,
    displacement_inches = mscl.MSCL_CAL_COEF_UNIT_DISPLACEMENT_INCHES,
    displacement_yards = mscl.MSCL_CAL_COEF_UNIT_DISPLACEMENT_YARDS,
    displacement_miles = mscl.MSCL_CAL_COEF_UNIT_DISPLACEMENT_MILES,
    displacement_naut_miles = mscl.MSCL_CAL_COEF_UNIT_DISPLACEMENT_NAUT_MILES,
    displacement_thou_inch = mscl.MSCL_CAL_COEF_UNIT_DISPLACEMENT_THOU_INCH,
    displacement_hund_inch = mscl.MSCL_CAL_COEF_UNIT_DISPLACEMENT_HUND_INCH,
    displacement_kilometers = mscl.MSCL_CAL_COEF_UNIT_DISPLACEMENT_KILOMETERS,
    displacement_centimeters = mscl.MSCL_CAL_COEF_UNIT_DISPLACEMENT_CENTIMETERS,
    irradiance_watts_per_sq_meter =
        mscl.MSCL_CAL_COEF_UNIT_IRRADIANCE_WATTS_PER_SQ_METER,
    par_micro_einstein = mscl.MSCL_CAL_COEF_UNIT_PAR_MICRO_EINSTEIN,
    mass_pound = mscl.MSCL_CAL_COEF_UNIT_MASS_POUND,
    power_watt = mscl.MSCL_CAL_COEF_UNIT_POWER_WATT,
    power_milliwatt = mscl.MSCL_CAL_COEF_UNIT_POWER_MILLIWATT,
    power_horsepower = mscl.MSCL_CAL_COEF_UNIT_POWER_HORSEPOWER,
    reactive_power_var = mscl.MSCL_CAL_COEF_UNIT_REACTIVE_POWER_VAR,
    energy_watt_hour = mscl.MSCL_CAL_COEF_UNIT_ENERGY_WATT_HOUR,
    energy_kilo_watt_hour = mscl.MSCL_CAL_COEF_UNIT_ENERGY_KILO_WATT_HOUR,
    reactive_energy_varh = mscl.MSCL_CAL_COEF_UNIT_REACTIVE_ENERGY_VARH,
    reactive_energy_k_varh = mscl.MSCL_CAL_COEF_UNIT_REACTIVE_ENERGY_K_VARH,
    current_ampere = mscl.MSCL_CAL_COEF_UNIT_CURRENT_AMPERE,
    current_milliampere = mscl.MSCL_CAL_COEF_UNIT_CURRENT_MILLIAMPERE,
    current_microampere = mscl.MSCL_CAL_COEF_UNIT_CURRENT_MICROAMPERE,
    pressure_millibar = mscl.MSCL_CAL_COEF_UNIT_PRESSURE_MILLIBAR,
    pressure_in_hg = mscl.MSCL_CAL_COEF_UNIT_PRESSURE_IN_HG,
    rssi_d_bm = mscl.MSCL_CAL_COEF_UNIT_RSSI_D_BM,
    freq_kilo_hertz = mscl.MSCL_CAL_COEF_UNIT_FREQ_KILO_HERTZ,
    ang_displacement_radians = mscl.MSCL_CAL_COEF_UNIT_ANG_DISPLACEMENT_RADIANS,
    velocity_meters_per_sec = mscl.MSCL_CAL_COEF_UNIT_VELOCITY_METERS_PER_SEC,
    velocity_kilometers_per_sec =
        mscl.MSCL_CAL_COEF_UNIT_VELOCITY_KILOMETERS_PER_SEC,
    velocity_kilometers_per_hr =
        mscl.MSCL_CAL_COEF_UNIT_VELOCITY_KILOMETERS_PER_HR,
    velocity_miles_per_hr = mscl.MSCL_CAL_COEF_UNIT_VELOCITY_MILES_PER_HR,
    velocity_knots = mscl.MSCL_CAL_COEF_UNIT_VELOCITY_KNOTS,
    volume_cubic_meter = mscl.MSCL_CAL_COEF_UNIT_VOLUME_CUBIC_METER,
    volume_cubic_ft = mscl.MSCL_CAL_COEF_UNIT_VOLUME_CUBIC_FT,
    volume_liters = mscl.MSCL_CAL_COEF_UNIT_VOLUME_LITERS,
    volume_gallon = mscl.MSCL_CAL_COEF_UNIT_VOLUME_GALLON,
    flow_rate_cubic_meters_per_sec =
        mscl.MSCL_CAL_COEF_UNIT_FLOW_RATE_CUBIC_METERS_PER_SEC,
    flow_rate_cubic_ft_per_sec =
        mscl.MSCL_CAL_COEF_UNIT_FLOW_RATE_CUBIC_FT_PER_SEC,
    torque_newton_meter = mscl.MSCL_CAL_COEF_UNIT_TORQUE_NEWTON_METER,
    torque_foot_pounds = mscl.MSCL_CAL_COEF_UNIT_TORQUE_FOOT_POUNDS,
    torque_inch_pounds = mscl.MSCL_CAL_COEF_UNIT_TORQUE_INCH_POUNDS,
    time_secs = mscl.MSCL_CAL_COEF_UNIT_TIME_SECS,
    time_nanosecs = mscl.MSCL_CAL_COEF_UNIT_TIME_NANOSECS,
    time_microsecs = mscl.MSCL_CAL_COEF_UNIT_TIME_MICROSECS,
    time_millisecs = mscl.MSCL_CAL_COEF_UNIT_TIME_MILLISECS,
    time_minutes = mscl.MSCL_CAL_COEF_UNIT_TIME_MINUTES,
    time_hours = mscl.MSCL_CAL_COEF_UNIT_TIME_HOURS,
    time_days = mscl.MSCL_CAL_COEF_UNIT_TIME_DAYS,
    time_weeks = mscl.MSCL_CAL_COEF_UNIT_TIME_WEEKS,
    other_value = mscl.MSCL_CAL_COEF_UNIT_OTHER_VALUE,
    magnetic_flux_gauss = mscl.MSCL_CAL_COEF_UNIT_MAGNETIC_FLUX_GAUSS,
    other_g_sec = mscl.MSCL_CAL_COEF_UNIT_OTHER_G_SEC,
    other_secs_per_sec = mscl.MSCL_CAL_COEF_UNIT_OTHER_SECS_PER_SEC,
    rssi_d_bhz = mscl.MSCL_CAL_COEF_UNIT_RSSI_D_BHZ,
    density_kg_per_meter3 = mscl.MSCL_CAL_COEF_UNIT_DENSITY_KG_PER_METER3,
    other_unitless = mscl.MSCL_CAL_COEF_UNIT_OTHER_UNITLESS,
    velocity_inches_per_sec = mscl.MSCL_CAL_COEF_UNIT_VELOCITY_INCHES_PER_SEC,
    force_kg = mscl.MSCL_CAL_COEF_UNIT_FORCE_KG,
    raw_voltage_volts = mscl.MSCL_CAL_COEF_UNIT_RAW_VOLTAGE_VOLTS,
    raw_voltage_millivolts = mscl.MSCL_CAL_COEF_UNIT_RAW_VOLTAGE_MILLIVOLTS,
    raw_voltage_microvolts = mscl.MSCL_CAL_COEF_UNIT_RAW_VOLTAGE_MICROVOLTS,
    resistance_ohm = mscl.MSCL_CAL_COEF_UNIT_RESISTANCE_OHM,
    resistance_milliohm = mscl.MSCL_CAL_COEF_UNIT_RESISTANCE_MILLIOHM,
    resistance_kiloohm = mscl.MSCL_CAL_COEF_UNIT_RESISTANCE_KILOOHM,
    velocity_mm_per_sec = mscl.MSCL_CAL_COEF_UNIT_VELOCITY_MM_PER_SEC,
    mass_grams = mscl.MSCL_CAL_COEF_UNIT_MASS_GRAMS,
    mass_ton = mscl.MSCL_CAL_COEF_UNIT_MASS_TON,
    mass_tonne = mscl.MSCL_CAL_COEF_UNIT_MASS_TONNE,
    _,
};

/// Represents the equation types that can be used for calibration coefficients
/// on Wireless Nodes.
pub const CalCoefEquationType = enum(mscl.mscl_cal_coef_equation_type) {
    none = mscl.MSCL_CAL_COEF_EQUATION_TYPE_NONE,
    standard = mscl.MSCL_CAL_COEF_EQUATION_TYPE_STANDARD,
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

/// Represents the thermocouple types supported by some Wireless Nodes.
pub const ThermocoupleType = enum(mscl.mscl_thermocouple_type) {
    uncompensated = mscl.MSCL_THERMOCOUPLE_TYPE_UNCOMPENSATED,
    k = mscl.MSCL_THERMOCOUPLE_TYPE_K,
    j = mscl.MSCL_THERMOCOUPLE_TYPE_J,
    r = mscl.MSCL_THERMOCOUPLE_TYPE_R,
    s = mscl.MSCL_THERMOCOUPLE_TYPE_S,
    t = mscl.MSCL_THERMOCOUPLE_TYPE_T,
    e = mscl.MSCL_THERMOCOUPLE_TYPE_E,
    b = mscl.MSCL_THERMOCOUPLE_TYPE_B,
    n = mscl.MSCL_THERMOCOUPLE_TYPE_N,
    custom_polynomial = mscl.MSCL_THERMOCOUPLE_TYPE_CUSTOM_POLYNOMIAL,
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
