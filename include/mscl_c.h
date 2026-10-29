/*
 * C bindings for the wireless part of MSCL: a G-Link-200 node reached
 * through a USB base station.
 *
 * Every function that can fail returns an mscl_status and passes its
 * results back through pointer arguments. On failure, mscl_last_error()
 * describes the error. Memory that the library allocates is released with
 * the matching library function.
 *
 * Channel masks: bit n - 1 selects channel n (0x07 selects channels 1-3).
 */
#ifndef MSCL_C_H
#define MSCL_C_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#if defined(__cplusplus)
    #define EXTERN_C extern "C"
#else
    #define EXTERN_C extern
#endif

typedef enum mscl_status {
    MSCL_OK = 0,
    MSCL_ERROR_INVALID_ARGUMENT = 1,
    MSCL_ERROR_OUT_OF_MEMORY = 2,
    MSCL_ERROR_INVALID_SERIAL_PORT = 3,
    MSCL_ERROR_CONNECTION = 4,
    MSCL_ERROR_COMMUNICATION = 5,
    MSCL_ERROR_NODE_COMMUNICATION = 6,
    MSCL_ERROR_INVALID_CONFIG = 7,
    MSCL_ERROR_NOT_SUPPORTED = 8,
    MSCL_ERROR_NO_DATA = 9,
    MSCL_ERROR_BAD_DATA_TYPE = 10,
    MSCL_ERROR_UNKNOWN_SAMPLE_RATE = 11,
    /* Any other error raised by MSCL. */
    MSCL_ERROR_OTHER = 12,
    /* An error that did not come from MSCL. */
    MSCL_ERROR_UNKNOWN = 13
} mscl_status;

/* The values of the enums below are MSCL's own. */

typedef enum mscl_default_mode {
    MSCL_DEFAULT_MODE_IDLE = 0,
    MSCL_DEFAULT_MODE_LDC = 1,
    MSCL_DEFAULT_MODE_DATALOG = 4,
    MSCL_DEFAULT_MODE_SLEEP = 5,
    MSCL_DEFAULT_MODE_SYNC = 6
} mscl_default_mode;

typedef enum mscl_transmit_power {
    MSCL_TRANSMIT_POWER_0DBM = 0,
    MSCL_TRANSMIT_POWER_1DBM = 1,
    MSCL_TRANSMIT_POWER_5DBM = 5,
    MSCL_TRANSMIT_POWER_10DBM = 10,
    MSCL_TRANSMIT_POWER_11DBM = 11,
    MSCL_TRANSMIT_POWER_12DBM = 12,
    MSCL_TRANSMIT_POWER_15DBM = 15,
    MSCL_TRANSMIT_POWER_16DBM = 16,
    MSCL_TRANSMIT_POWER_20DBM = 20
} mscl_transmit_power;

typedef enum mscl_sampling_mode {
    MSCL_SAMPLING_MODE_SYNC = 1,
    MSCL_SAMPLING_MODE_SYNC_BURST = 2,
    MSCL_SAMPLING_MODE_NON_SYNC = 3,
    MSCL_SAMPLING_MODE_ARMED_DATALOG = 4,
    MSCL_SAMPLING_MODE_SYNC_EVENT = 5,
    MSCL_SAMPLING_MODE_NON_SYNC_EVENT = 6
} mscl_sampling_mode;

typedef enum mscl_sample_rate {
    MSCL_SAMPLE_RATE_4096HZ = 101,
    MSCL_SAMPLE_RATE_2048HZ = 102,
    MSCL_SAMPLE_RATE_1024HZ = 103,
    MSCL_SAMPLE_RATE_512HZ = 104,
    MSCL_SAMPLE_RATE_256HZ = 105,
    MSCL_SAMPLE_RATE_128HZ = 106,
    MSCL_SAMPLE_RATE_64HZ = 107,
    MSCL_SAMPLE_RATE_32HZ = 108,
    MSCL_SAMPLE_RATE_16HZ = 109,
    MSCL_SAMPLE_RATE_8HZ = 110,
    MSCL_SAMPLE_RATE_4HZ = 111,
    MSCL_SAMPLE_RATE_2HZ = 112,
    MSCL_SAMPLE_RATE_1HZ = 113,
    MSCL_SAMPLE_RATE_2SEC = 114,
    MSCL_SAMPLE_RATE_5SEC = 115,
    MSCL_SAMPLE_RATE_10SEC = 116,
    MSCL_SAMPLE_RATE_30SEC = 117,
    MSCL_SAMPLE_RATE_1MIN = 118,
    MSCL_SAMPLE_RATE_2MIN = 119,
    MSCL_SAMPLE_RATE_5MIN = 120,
    MSCL_SAMPLE_RATE_10MIN = 121,
    MSCL_SAMPLE_RATE_30MIN = 122,
    MSCL_SAMPLE_RATE_60MIN = 123
} mscl_sample_rate;

typedef enum mscl_data_format {
    MSCL_DATA_FORMAT_RAW_UINT16 = 1,
    MSCL_DATA_FORMAT_CAL_FLOAT = 2,
    MSCL_DATA_FORMAT_RAW_UINT24 = 3,
    MSCL_DATA_FORMAT_RAW_INT24 = 4,
    MSCL_DATA_FORMAT_RAW_INT16 = 5,
    MSCL_DATA_FORMAT_CAL_INT16_X10 = 6
} mscl_data_format;

typedef enum mscl_data_collection_method {
    MSCL_DATA_COLLECTION_LOG_ONLY = 1,
    MSCL_DATA_COLLECTION_TRANSMIT_ONLY = 2,
    MSCL_DATA_COLLECTION_LOG_AND_TRANSMIT = 3
} mscl_data_collection_method;

typedef enum mscl_data_mode {
    MSCL_DATA_MODE_NONE = 0,
    MSCL_DATA_MODE_RAW = 1,
    MSCL_DATA_MODE_DERIVED = 2,
    MSCL_DATA_MODE_RAW_DERIVED = 3
} mscl_data_mode;

typedef enum mscl_derived_category {
    MSCL_DERIVED_RMS = 0,
    MSCL_DERIVED_PEAK_TO_PEAK = 1,
    MSCL_DERIVED_VELOCITY = 2,
    MSCL_DERIVED_CREST_FACTOR = 3,
    MSCL_DERIVED_MEAN = 4
} mscl_derived_category;

typedef enum mscl_input_range {
    MSCL_INPUT_RANGE_2G = 76,
    MSCL_INPUT_RANGE_4G = 77,
    MSCL_INPUT_RANGE_8G = 78
} mscl_input_range;

typedef enum mscl_low_pass_filter {
    MSCL_LOW_PASS_26HZ = 26,
    MSCL_LOW_PASS_52HZ = 52,
    MSCL_LOW_PASS_104HZ = 104,
    MSCL_LOW_PASS_209HZ = 209,
    MSCL_LOW_PASS_418HZ = 418,
    MSCL_LOW_PASS_800HZ = 800
} mscl_low_pass_filter;

typedef enum mscl_high_pass_filter {
    MSCL_HIGH_PASS_OFF = 0,
    MSCL_HIGH_PASS_AUTO = 65535
} mscl_high_pass_filter;

typedef enum mscl_sensor_output_mode {
    MSCL_SENSOR_OUTPUT_ACCEL = 0,
    MSCL_SENSOR_OUTPUT_TILT = 1
} mscl_sensor_output_mode;

typedef enum mscl_set_to_idle_result {
    MSCL_SET_TO_IDLE_SUCCESS = 0,
    MSCL_SET_TO_IDLE_CANCELED = 1,
    MSCL_SET_TO_IDLE_FAILED = 2,
    MSCL_SET_TO_IDLE_NOT_COMPLETED = 3
} mscl_set_to_idle_result;

typedef enum mscl_connection_type {
    MSCL_CONNECTION_TYPE_SERIAL = 0,
    MSCL_CONNECTION_TYPE_TCP = 1
} mscl_connection_type;

typedef enum mscl_frequency {
    MSCL_FREQUENCY_UNKNOWN = 0,
    MSCL_FREQUENCY_11 = 11,
    MSCL_FREQUENCY_12 = 12,
    MSCL_FREQUENCY_13 = 13,
    MSCL_FREQUENCY_14 = 14,
    MSCL_FREQUENCY_15 = 15,
    MSCL_FREQUENCY_16 = 16,
    MSCL_FREQUENCY_17 = 17,
    MSCL_FREQUENCY_18 = 18,
    MSCL_FREQUENCY_19 = 19,
    MSCL_FREQUENCY_20 = 20,
    MSCL_FREQUENCY_21 = 21,
    MSCL_FREQUENCY_22 = 22,
    MSCL_FREQUENCY_23 = 23,
    MSCL_FREQUENCY_24 = 24,
    MSCL_FREQUENCY_25 = 25,
    MSCL_FREQUENCY_26 = 26
} mscl_frequency;

typedef enum mscl_comm_protocol {
    MSCL_COMM_PROTOCOL_LXRS = 0,
    MSCL_COMM_PROTOCOL_LXRS_PLUS = 1
} mscl_comm_protocol;

typedef enum mscl_region_code {
    MSCL_REGION_CODE_USA = 0,
    MSCL_REGION_CODE_EUROPEAN_UNION = 1,
    MSCL_REGION_CODE_JAPAN = 2,
    MSCL_REGION_CODE_OTHER = 3,
    MSCL_REGION_CODE_BRAZIL = 4,
    MSCL_REGION_CODE_CHINA = 5,
    MSCL_REGION_CODE_AUSTRALIA_NEW_ZEALAND = 6,
    MSCL_REGION_CODE_SINGAPORE = 7,
    MSCL_REGION_CODE_CANADA = 8,
    MSCL_REGION_CODE_SOUTH_AFRICA = 9,
    MSCL_REGION_CODE_INDONESIA = 10,
    MSCL_REGION_CODE_TAIWAN = 11
} mscl_region_code;

typedef enum mscl_microcontroller {
    MSCL_MICROCONTROLLER_18F452 = 31,
    MSCL_MICROCONTROLLER_18F4620 = 32,
    MSCL_MICROCONTROLLER_18F46K20 = 33,
    MSCL_MICROCONTROLLER_18F67K90 = 34,
    MSCL_MICROCONTROLLER_EFM32WG990F256 = 35,
    MSCL_MICROCONTROLLER_EFR32FG1P132F256GM48 = 36,
    MSCL_MICROCONTROLLER_EFR32MG1P232F256GM48 = 37
} mscl_microcontroller;

typedef enum mscl_base_model {
    MSCL_BASE_MODEL_WSDA_1000 = 63140050,
    MSCL_BASE_MODEL_WSDA_1500 = 63141500,
    MSCL_BASE_MODEL_WSDA_2000 = 63142000,
    MSCL_BASE_MODEL_WSDA_PRO = 63143000,
    MSCL_BASE_MODEL_WSDA_BASE_200_LEGACY = 63070200,
    MSCL_BASE_MODEL_WSDA_BASE_200 = 63072040,
    MSCL_BASE_MODEL_WSDA_BASE_200_EXT_ANTENNA = 63072140,
    MSCL_BASE_MODEL_WSDA_BASE_101_ANALOG = 63071010,
    MSCL_BASE_MODEL_WSDA_BASE_102_RS232 = 63071020,
    MSCL_BASE_MODEL_WSDA_BASE_104_USB = 63071040,
    MSCL_BASE_MODEL_WSI_104 = 63072000,
    MSCL_BASE_MODEL_WSDA_BASE_MINI = 63079999
} mscl_base_model;

typedef enum mscl_button_command {
    MSCL_BUTTON_COMMAND_NODE_SLEEP = 0,
    MSCL_BUTTON_COMMAND_NODE_STOP = 1,
    MSCL_BUTTON_COMMAND_ENABLE_BEACON = 2,
    MSCL_BUTTON_COMMAND_DISABLE_BEACON = 3,
    MSCL_BUTTON_COMMAND_NODE_NON_SYNC_SAMPLING = 4,
    MSCL_BUTTON_COMMAND_NODE_SYNC_SAMPLING = 5,
    MSCL_BUTTON_COMMAND_NODE_ARMED_DATALOGGING = 6,
    MSCL_BUTTON_COMMAND_CYCLE_POWER = 7,
    MSCL_BUTTON_COMMAND_DISABLED = 65535
} mscl_button_command;

typedef struct mscl_base_station mscl_base_station;
typedef struct mscl_node mscl_node;
typedef struct mscl_node_config mscl_node_config;
typedef struct mscl_sync_network mscl_sync_network;
typedef struct mscl_datalog_downloader mscl_datalog_downloader;
typedef struct mscl_base_station_features mscl_base_station_features;
typedef struct mscl_base_station_config mscl_base_station_config;

typedef struct mscl_device_info {
    /* The key MSCL lists the device under. */
    char port[256];
    char description[256];
    char serial[256];
    uint32_t baud_rate;
    mscl_connection_type connection_type;
} mscl_device_info;

typedef struct mscl_version {
    uint32_t major;
    uint32_t minor;
    uint32_t patch;
} mscl_version;

typedef struct mscl_beacon_status {
    bool enabled;
    /* Nanoseconds since the Unix epoch. */
    uint64_t timestamp_ns;
} mscl_beacon_status;

typedef struct mscl_base_station_button {
    mscl_button_command command;
    uint16_t node_address;
} mscl_base_station_button;

typedef struct mscl_base_station_analog_pair {
    uint16_t node_address;
    uint8_t node_channel;
    bool expect_float_data;
    float output_0v;
    float output_3v;
} mscl_base_station_analog_pair;

typedef struct mscl_ping_result {
    bool success;
    int16_t base_rssi;
    int16_t node_rssi;
} mscl_ping_result;

typedef struct mscl_node_info {
    uint32_t address;
    uint32_t model;
    char serial[32];
    uint32_t firmware_major;
    uint32_t firmware_minor;
    uint32_t firmware_patch;
} mscl_node_info;

typedef struct mscl_sync_network_info {
    bool ok;
    bool lossless;
    float percent_bandwidth;
} mscl_sync_network_info;

typedef struct mscl_data_point {
    uint32_t channel_id;
    char channel_name[64];
    /* NaN when MSCL stores the value as a non-numeric type. */
    double value;
} mscl_data_point;

typedef struct mscl_sweep {
    uint32_t node_address;
    /* Nanoseconds since the Unix epoch. */
    uint64_t timestamp_ns;
    uint64_t tick;
    double sample_rate_hz;
    /* Live data only; 0 for logged data. */
    int16_t base_rssi;
    int16_t node_rssi;
    bool cal_applied;
    size_t point_count;
    mscl_data_point *points;
} mscl_sweep;

/*
 * Message of the last failed call on this thread. It stays valid until the
 * next failed call on the same thread.
 */
EXTERN_C const char *mscl_last_error(void);

/*
 * Base stations attached to this computer; free with
 * mscl_device_infos_free.
 */
EXTERN_C mscl_status mscl_list_base_stations(
    mscl_device_info **devices,
    size_t *count
);
EXTERN_C void mscl_device_infos_free(mscl_device_info *devices);

/* USB base stations use a baud rate of 3000000. */
EXTERN_C mscl_status mscl_base_station_open(
    const char *port,
    uint32_t baud_rate,
    mscl_base_station **base_station
);
/* Disconnects the port. Destroy every object using it first. */
EXTERN_C void mscl_base_station_close(mscl_base_station *base_station);
EXTERN_C mscl_status mscl_base_station_ping(
    mscl_base_station *base_station,
    bool *success
);
EXTERN_C mscl_status mscl_base_station_set_retries(
    mscl_base_station *base_station,
    uint8_t retries
);
EXTERN_C mscl_status mscl_base_station_get_retries(
    mscl_base_station *base_station,
    uint8_t *retries
);
EXTERN_C mscl_status mscl_base_station_enable_beacon(
    mscl_base_station *base_station,
    uint64_t *beacon_time_ns
);
EXTERN_C mscl_status mscl_base_station_disable_beacon(
    mscl_base_station *base_station
);
/* utc_time_s is in seconds since the Unix epoch. */
EXTERN_C mscl_status mscl_base_station_enable_beacon_at(
    mscl_base_station *base_station,
    uint32_t utc_time_s,
    uint64_t *beacon_time_ns
);
EXTERN_C mscl_status mscl_base_station_get_beacon_status(
    mscl_base_station *base_station,
    mscl_beacon_status *status
);
EXTERN_C mscl_status mscl_base_station_get_communication_protocol(
    mscl_base_station *base_station,
    mscl_comm_protocol *protocol
);
EXTERN_C mscl_status mscl_base_station_get_transmit_power(
    mscl_base_station *base_station,
    mscl_transmit_power *power
);
EXTERN_C mscl_status mscl_base_station_get_button_long_press(
    mscl_base_station *base_station,
    uint8_t button_number,
    mscl_base_station_button *button
);
EXTERN_C mscl_status mscl_base_station_get_button_short_press(
    mscl_base_station *base_station,
    uint8_t button_number,
    mscl_base_station_button *button
);
EXTERN_C mscl_status mscl_base_station_get_analog_pairing_enabled(
    mscl_base_station *base_station,
    bool *enabled
);
EXTERN_C mscl_status mscl_base_station_get_analog_timeout_time(
    mscl_base_station *base_station,
    uint16_t *seconds
);
EXTERN_C mscl_status mscl_base_station_get_analog_timeout_voltage(
    mscl_base_station *base_station,
    float *voltage
);
EXTERN_C mscl_status mscl_base_station_get_analog_exceedance_enabled(
    mscl_base_station *base_station,
    bool *enabled
);
EXTERN_C mscl_status mscl_base_station_get_analog_pair(
    mscl_base_station *base_station,
    uint8_t port_number,
    mscl_base_station_analog_pair *pair
);
EXTERN_C mscl_status mscl_base_station_get_frequency(
    mscl_base_station *base_station,
    mscl_frequency *frequency
);
EXTERN_C mscl_status mscl_base_station_get_firmware_version(
    mscl_base_station *base_station,
    mscl_version *version
);
EXTERN_C mscl_status mscl_base_station_get_model(
    mscl_base_station *base_station,
    mscl_base_model *model
);
/* Strings are truncated to fit their buffer, whose length is given. */
EXTERN_C mscl_status mscl_base_station_get_serial(
    mscl_base_station *base_station,
    char *serial,
    size_t serial_len
);
EXTERN_C mscl_status mscl_base_station_get_name(
    mscl_base_station *base_station,
    char *name,
    size_t name_len
);
EXTERN_C mscl_status mscl_base_station_get_microcontroller(
    mscl_base_station *base_station,
    mscl_microcontroller *microcontroller
);
EXTERN_C mscl_status mscl_base_station_get_region_code(
    mscl_base_station *base_station,
    mscl_region_code *region_code
);
EXTERN_C mscl_status mscl_base_station_change_frequency(
    mscl_base_station *base_station,
    mscl_frequency frequency
);
/*
 * Sweeps collected since the last call, waiting up to timeout_ms for the
 * first one. max_sweeps of 0 returns all of them. Free with mscl_sweeps_free.
 */
EXTERN_C mscl_status mscl_base_station_get_data(
    mscl_base_station *base_station,
    uint32_t timeout_ms,
    uint32_t max_sweeps,
    mscl_sweep **sweeps,
    size_t *count
);
EXTERN_C void mscl_sweeps_free(mscl_sweep *sweeps, size_t count);
/*
 * Checks config against the base station. When it is not valid, *ok is false
 * and issues receives one line per problem, truncated to issues_len.
 */
EXTERN_C mscl_status mscl_base_station_verify_config(
    mscl_base_station *base_station,
    const mscl_base_station_config *config,
    bool *ok,
    char *issues,
    size_t issues_len
);
EXTERN_C mscl_status mscl_base_station_apply_config(
    mscl_base_station *base_station,
    const mscl_base_station_config *config
);
/* Owned by the base station; valid until it is closed. */
EXTERN_C mscl_status mscl_base_station_get_features(
    mscl_base_station *base_station,
    const mscl_base_station_features **features
);

/*
 * Lists are truncated to fit their buffer, whose length is given; *count is
 * the number written.
 */
EXTERN_C mscl_status mscl_base_station_features_supports_transmit_power(
    const mscl_base_station_features *features,
    mscl_transmit_power power,
    mscl_comm_protocol comm_protocol,
    bool *supported
);
EXTERN_C mscl_status
mscl_base_station_features_supports_communication_protocol(
    const mscl_base_station_features *features,
    mscl_comm_protocol protocol,
    bool *supported
);
EXTERN_C mscl_status mscl_base_station_features_supports_buttons(
    const mscl_base_station_features *features,
    bool *supported
);
EXTERN_C mscl_status mscl_base_station_features_supports_analog_pairing(
    const mscl_base_station_features *features,
    bool *supported
);
EXTERN_C mscl_status mscl_base_station_features_supports_beacon_status(
    const mscl_base_station_features *features,
    bool *supported
);
EXTERN_C mscl_status mscl_base_station_features_supports_rf_sweep_mode(
    const mscl_base_station_features *features,
    bool *supported
);
EXTERN_C mscl_status mscl_base_station_features_supports_custom_rf_sweep_mode(
    const mscl_base_station_features *features,
    bool *supported
);
EXTERN_C mscl_status mscl_base_station_features_get_button_count(
    const mscl_base_station_features *features,
    uint8_t *count
);
EXTERN_C mscl_status mscl_base_station_features_get_analog_port_count(
    const mscl_base_station_features *features,
    uint8_t *count
);
EXTERN_C mscl_status mscl_base_station_features_get_transmit_powers(
    const mscl_base_station_features *features,
    mscl_comm_protocol comm_protocol,
    mscl_transmit_power *powers,
    size_t powers_len,
    size_t *count
);
EXTERN_C mscl_status mscl_base_station_features_get_region_transmit_powers(
    const mscl_base_station_features *features,
    mscl_region_code region,
    mscl_comm_protocol comm_protocol,
    mscl_transmit_power *powers,
    size_t powers_len,
    size_t *count
);
EXTERN_C mscl_status mscl_base_station_features_get_comm_protocols(
    const mscl_base_station_features *features,
    mscl_comm_protocol *protocols,
    size_t protocols_len,
    size_t *count
);
EXTERN_C mscl_status mscl_base_station_features_get_max_transmit_power(
    const mscl_base_station_features *features,
    mscl_region_code region,
    mscl_comm_protocol comm_protocol,
    mscl_transmit_power *power
);
EXTERN_C mscl_status mscl_base_station_features_get_min_transmit_power(
    const mscl_base_station_features *features,
    mscl_region_code region,
    mscl_comm_protocol comm_protocol,
    mscl_transmit_power *power
);

/* Settings to write to a base station. Settings left unset are not changed. */
EXTERN_C mscl_status mscl_base_station_config_create(
    mscl_base_station_config **config
);
EXTERN_C void mscl_base_station_config_destroy(
    mscl_base_station_config *config
);
EXTERN_C mscl_status mscl_base_station_config_get_transmit_power(
    const mscl_base_station_config *config,
    mscl_transmit_power *power
);
EXTERN_C mscl_status mscl_base_station_config_set_transmit_power(
    mscl_base_station_config *config,
    mscl_transmit_power power
);
EXTERN_C mscl_status mscl_base_station_config_get_communication_protocol(
    const mscl_base_station_config *config,
    mscl_comm_protocol *protocol
);
EXTERN_C mscl_status mscl_base_station_config_set_communication_protocol(
    mscl_base_station_config *config,
    mscl_comm_protocol protocol
);
EXTERN_C mscl_status mscl_base_station_config_get_button_long_press(
    const mscl_base_station_config *config,
    uint8_t button_number,
    mscl_base_station_button *button
);
EXTERN_C mscl_status mscl_base_station_config_set_button_long_press(
    mscl_base_station_config *config,
    uint8_t button_number,
    mscl_base_station_button button
);
EXTERN_C mscl_status mscl_base_station_config_get_button_short_press(
    const mscl_base_station_config *config,
    uint8_t button_number,
    mscl_base_station_button *button
);
EXTERN_C mscl_status mscl_base_station_config_set_button_short_press(
    mscl_base_station_config *config,
    uint8_t button_number,
    mscl_base_station_button button
);
EXTERN_C mscl_status mscl_base_station_config_get_analog_pairing_enable(
    const mscl_base_station_config *config,
    bool *enable
);
EXTERN_C mscl_status mscl_base_station_config_set_analog_pairing_enable(
    mscl_base_station_config *config,
    bool enable
);
EXTERN_C mscl_status mscl_base_station_config_get_analog_timeout_time(
    const mscl_base_station_config *config,
    uint16_t *seconds
);
EXTERN_C mscl_status mscl_base_station_config_set_analog_timeout_time(
    mscl_base_station_config *config,
    uint16_t seconds
);
EXTERN_C mscl_status mscl_base_station_config_get_analog_timeout_voltage(
    const mscl_base_station_config *config,
    float *voltage
);
EXTERN_C mscl_status mscl_base_station_config_set_analog_timeout_voltage(
    mscl_base_station_config *config,
    float voltage
);
EXTERN_C mscl_status mscl_base_station_config_get_analog_exceedance_enable(
    const mscl_base_station_config *config,
    bool *enable
);
EXTERN_C mscl_status mscl_base_station_config_set_analog_exceedance_enable(
    mscl_base_station_config *config,
    bool enable
);
EXTERN_C mscl_status mscl_base_station_config_get_analog_pairing(
    const mscl_base_station_config *config,
    uint8_t port_number,
    mscl_base_station_analog_pair *pair
);
/* output_0v and output_3v are used only when expect_float_data is true. */
EXTERN_C mscl_status mscl_base_station_config_set_analog_pairing(
    mscl_base_station_config *config,
    uint8_t port_number,
    mscl_base_station_analog_pair pair
);

EXTERN_C mscl_status mscl_node_create(
    mscl_base_station *base_station,
    uint32_t address,
    mscl_node **node
);
EXTERN_C void mscl_node_destroy(mscl_node *node);
EXTERN_C mscl_status mscl_node_set_retries(mscl_node *node, uint8_t retries);
EXTERN_C mscl_status mscl_node_ping(mscl_node *node, mscl_ping_result *result);
/* Waits up to timeout_ms, then cancels if the node has not gone idle. */
EXTERN_C mscl_status mscl_node_set_to_idle(
    mscl_node *node,
    uint32_t timeout_ms,
    mscl_set_to_idle_result *result
);
EXTERN_C mscl_status mscl_node_sleep(mscl_node *node, bool *success);
EXTERN_C mscl_status mscl_node_cycle_power(mscl_node *node);
EXTERN_C mscl_status mscl_node_get_info(mscl_node *node, mscl_node_info *info);
EXTERN_C mscl_status mscl_node_start_non_sync_sampling(
    mscl_node *node,
    bool *success
);
EXTERN_C mscl_status mscl_node_get_num_datalog_sessions(
    mscl_node *node,
    uint16_t *count
);
/* Erases all logged data on the node. */
EXTERN_C mscl_status mscl_node_erase(mscl_node *node);

/* Settings currently on the node. */
EXTERN_C mscl_status mscl_node_get_default_mode(
    mscl_node *node,
    mscl_default_mode *mode
);
EXTERN_C mscl_status mscl_node_get_inactivity_timeout(
    mscl_node *node,
    uint16_t *seconds
);
EXTERN_C mscl_status mscl_node_get_check_radio_interval(
    mscl_node *node,
    uint8_t *seconds
);
EXTERN_C mscl_status mscl_node_get_transmit_power(
    mscl_node *node,
    mscl_transmit_power *power
);
EXTERN_C mscl_status mscl_node_get_sampling_mode(
    mscl_node *node,
    mscl_sampling_mode *mode
);
EXTERN_C mscl_status mscl_node_get_sample_rate(
    mscl_node *node,
    mscl_sample_rate *rate
);
EXTERN_C mscl_status mscl_node_get_active_channels(
    mscl_node *node,
    uint16_t *mask
);
EXTERN_C mscl_status mscl_node_get_num_sweeps(
    mscl_node *node,
    uint32_t *sweeps
);
EXTERN_C mscl_status mscl_node_get_unlimited_duration(
    mscl_node *node,
    bool *unlimited
);
EXTERN_C mscl_status mscl_node_get_data_format(
    mscl_node *node,
    mscl_data_format *format
);
EXTERN_C mscl_status mscl_node_get_data_collection_method(
    mscl_node *node,
    mscl_data_collection_method *method
);
EXTERN_C mscl_status mscl_node_get_time_between_bursts(
    mscl_node *node,
    uint32_t *seconds
);
EXTERN_C mscl_status mscl_node_get_lost_beacon_timeout(
    mscl_node *node,
    uint16_t *minutes
);
EXTERN_C mscl_status mscl_node_get_diagnostic_interval(
    mscl_node *node,
    uint16_t *seconds
);
EXTERN_C mscl_status mscl_node_get_input_range(
    mscl_node *node,
    uint16_t channel_mask,
    mscl_input_range *range
);
EXTERN_C mscl_status mscl_node_get_low_pass_filter(
    mscl_node *node,
    uint16_t channel_mask,
    mscl_low_pass_filter *filter
);
EXTERN_C mscl_status mscl_node_get_high_pass_filter(
    mscl_node *node,
    uint16_t channel_mask,
    mscl_high_pass_filter *filter
);
EXTERN_C mscl_status mscl_node_get_sensor_output_mode(
    mscl_node *node,
    mscl_sensor_output_mode *mode
);
EXTERN_C mscl_status mscl_node_get_data_mode(
    mscl_node *node,
    mscl_data_mode *mode
);
EXTERN_C mscl_status mscl_node_get_derived_data_rate(
    mscl_node *node,
    mscl_sample_rate *rate
);
EXTERN_C mscl_status mscl_node_get_derived_channel_mask(
    mscl_node *node,
    mscl_derived_category category,
    uint16_t *mask
);

/*
 * Checks config against the node. When it is not valid, *ok is false and
 * issues receives one line per problem, truncated to issues_len.
 */
EXTERN_C mscl_status mscl_node_verify_config(
    mscl_node *node,
    const mscl_node_config *config,
    bool *ok,
    char *issues,
    size_t issues_len
);
EXTERN_C mscl_status mscl_node_apply_config(
    mscl_node *node,
    const mscl_node_config *config
);

/* Settings to write to a node. Settings left unset are not changed. */
EXTERN_C mscl_status mscl_node_config_create(mscl_node_config **config);
EXTERN_C void mscl_node_config_destroy(mscl_node_config *config);
EXTERN_C mscl_status mscl_node_config_set_default_mode(
    mscl_node_config *config,
    mscl_default_mode mode
);
EXTERN_C mscl_status mscl_node_config_set_inactivity_timeout(
    mscl_node_config *config,
    uint16_t seconds
);
EXTERN_C mscl_status mscl_node_config_set_check_radio_interval(
    mscl_node_config *config,
    uint8_t seconds
);
EXTERN_C mscl_status mscl_node_config_set_transmit_power(
    mscl_node_config *config,
    mscl_transmit_power power
);
EXTERN_C mscl_status mscl_node_config_set_sampling_mode(
    mscl_node_config *config,
    mscl_sampling_mode mode
);
EXTERN_C mscl_status mscl_node_config_set_sample_rate(
    mscl_node_config *config,
    mscl_sample_rate rate
);
EXTERN_C mscl_status mscl_node_config_set_active_channels(
    mscl_node_config *config,
    uint16_t mask
);
EXTERN_C mscl_status mscl_node_config_set_num_sweeps(
    mscl_node_config *config,
    uint32_t sweeps
);
EXTERN_C mscl_status mscl_node_config_set_unlimited_duration(
    mscl_node_config *config,
    bool unlimited
);
EXTERN_C mscl_status mscl_node_config_set_data_format(
    mscl_node_config *config,
    mscl_data_format format
);
EXTERN_C mscl_status mscl_node_config_set_data_collection_method(
    mscl_node_config *config,
    mscl_data_collection_method method
);
EXTERN_C mscl_status mscl_node_config_set_time_between_bursts(
    mscl_node_config *config,
    uint32_t seconds
);
EXTERN_C mscl_status mscl_node_config_set_lost_beacon_timeout(
    mscl_node_config *config,
    uint16_t minutes
);
EXTERN_C mscl_status mscl_node_config_set_diagnostic_interval(
    mscl_node_config *config,
    uint16_t seconds
);
EXTERN_C mscl_status mscl_node_config_set_input_range(
    mscl_node_config *config,
    uint16_t channel_mask,
    mscl_input_range range
);
EXTERN_C mscl_status mscl_node_config_set_low_pass_filter(
    mscl_node_config *config,
    uint16_t channel_mask,
    mscl_low_pass_filter filter
);
EXTERN_C mscl_status mscl_node_config_set_high_pass_filter(
    mscl_node_config *config,
    uint16_t channel_mask,
    mscl_high_pass_filter filter
);
EXTERN_C mscl_status mscl_node_config_set_sensor_output_mode(
    mscl_node_config *config,
    mscl_sensor_output_mode mode
);
EXTERN_C mscl_status mscl_node_config_set_data_mode(
    mscl_node_config *config,
    mscl_data_mode mode
);
EXTERN_C mscl_status mscl_node_config_set_derived_data_rate(
    mscl_node_config *config,
    mscl_sample_rate rate
);
EXTERN_C mscl_status mscl_node_config_set_derived_channel_mask(
    mscl_node_config *config,
    mscl_derived_category category,
    uint16_t mask
);

/* Synchronized sampling of the nodes added to the network. */
EXTERN_C mscl_status mscl_sync_network_create(
    mscl_base_station *base_station,
    mscl_sync_network **network
);
EXTERN_C void mscl_sync_network_destroy(mscl_sync_network *network);
EXTERN_C mscl_status mscl_sync_network_add_node(
    mscl_sync_network *network,
    mscl_node *node
);
EXTERN_C mscl_status mscl_sync_network_get_info(
    mscl_sync_network *network,
    mscl_sync_network_info *info
);
EXTERN_C mscl_status mscl_sync_network_apply_configuration(
    mscl_sync_network *network
);
/* Starts sampling and enables the beacon with the computer's time. */
EXTERN_C mscl_status mscl_sync_network_start_sampling(
    mscl_sync_network *network
);

/* Downloads the data logged on an idle node. */
EXTERN_C mscl_status mscl_datalog_downloader_create(
    mscl_node *node,
    mscl_datalog_downloader **downloader
);
EXTERN_C void mscl_datalog_downloader_destroy(
    mscl_datalog_downloader *downloader
);
EXTERN_C mscl_status mscl_datalog_downloader_complete(
    mscl_datalog_downloader *downloader,
    bool *complete
);
/* Next logged sweep; free with mscl_sweeps_free(sweep, 1). */
EXTERN_C mscl_status mscl_datalog_downloader_next(
    mscl_datalog_downloader *downloader,
    mscl_sweep **sweep
);
/* Session of the sweep returned last by mscl_datalog_downloader_next. */
EXTERN_C mscl_status mscl_datalog_downloader_get_session(
    mscl_datalog_downloader *downloader,
    bool *start_of_session,
    uint16_t *session_index
);
EXTERN_C mscl_status mscl_datalog_downloader_get_percent_complete(
    mscl_datalog_downloader *downloader,
    float *percent
);

#endif /* MSCL_C_H */
