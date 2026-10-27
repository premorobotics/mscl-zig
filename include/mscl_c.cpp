// Implementation of mscl_c.h. MSCL is C++, so these C functions are written
// in C++ and exported with C linkage. No exception leaves this file: every
// call goes through `call`, which turns MSCL's exceptions into an
// mscl_status and keeps the message for mscl_last_error().

#include "mscl/stdafx.h"

#include "mscl_c.h"

#include "mscl/Communication/Connection.h"
#include "mscl/Communication/Devices.h"
#include "mscl/Exceptions.h"
#include "mscl/LibVersion.h"
#include "mscl/MicroStrain/Wireless/BaseStation.h"
#include "mscl/MicroStrain/Wireless/Configuration/ConfigIssue.h"
#include "mscl/MicroStrain/Wireless/Configuration/WirelessNodeConfig.h"
#include "mscl/MicroStrain/Wireless/DatalogDownloader.h"
#include "mscl/MicroStrain/Wireless/SyncSamplingNetwork.h"
#include "mscl/MicroStrain/Wireless/WirelessNode.h"

#include <algorithm>
#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <limits>
#include <new>
#include <string>

struct mscl_base_station {
    explicit mscl_base_station(mscl::Connection& connection)
        : base(connection)
    {
    }

    mscl::BaseStation base;
};

struct mscl_node {
    mscl_node(uint32_t address, const mscl::BaseStation& base)
        : node(address, base)
    {
    }

    mscl::WirelessNode node;
};

struct mscl_node_config {
    mscl::WirelessNodeConfig config;
};

struct mscl_sync_network {
    explicit mscl_sync_network(const mscl::BaseStation& base)
        : network(base)
    {
    }

    mscl::SyncSamplingNetwork network;
};

struct mscl_datalog_downloader {
    explicit mscl_datalog_downloader(const mscl::WirelessNode& node)
        : node_address(node.nodeAddress()), downloader(node)
    {
    }

    uint32_t node_address;
    mscl::DatalogDownloader downloader;
};

// The C enums reuse MSCL's values, so converting is a cast. These checks
// catch MSCL changing a value.
#define MSCL_C_SAME(c_value, mscl_value)                                    \
    static_assert(                                                         \
        static_cast<long>(c_value) == static_cast<long>(mscl_value),       \
        #c_value " differs from " #mscl_value                              \
    )

using mscl::WirelessTypes;

MSCL_C_SAME(MSCL_DEFAULT_MODE_IDLE, WirelessTypes::defaultMode_idle);
MSCL_C_SAME(MSCL_DEFAULT_MODE_LDC, WirelessTypes::defaultMode_ldc);
MSCL_C_SAME(MSCL_DEFAULT_MODE_DATALOG, WirelessTypes::defaultMode_datalog);
MSCL_C_SAME(MSCL_DEFAULT_MODE_SLEEP, WirelessTypes::defaultMode_sleep);
MSCL_C_SAME(MSCL_DEFAULT_MODE_SYNC, WirelessTypes::defaultMode_sync);

MSCL_C_SAME(MSCL_TRANSMIT_POWER_0DBM, WirelessTypes::power_0dBm);
MSCL_C_SAME(MSCL_TRANSMIT_POWER_1DBM, WirelessTypes::power_1dBm);
MSCL_C_SAME(MSCL_TRANSMIT_POWER_5DBM, WirelessTypes::power_5dBm);
MSCL_C_SAME(MSCL_TRANSMIT_POWER_10DBM, WirelessTypes::power_10dBm);
MSCL_C_SAME(MSCL_TRANSMIT_POWER_11DBM, WirelessTypes::power_11dBm);
MSCL_C_SAME(MSCL_TRANSMIT_POWER_12DBM, WirelessTypes::power_12dBm);
MSCL_C_SAME(MSCL_TRANSMIT_POWER_15DBM, WirelessTypes::power_15dBm);
MSCL_C_SAME(MSCL_TRANSMIT_POWER_16DBM, WirelessTypes::power_16dBm);
MSCL_C_SAME(MSCL_TRANSMIT_POWER_20DBM, WirelessTypes::power_20dBm);

MSCL_C_SAME(MSCL_SAMPLING_MODE_SYNC, WirelessTypes::samplingMode_sync);
MSCL_C_SAME(
    MSCL_SAMPLING_MODE_SYNC_BURST,
    WirelessTypes::samplingMode_syncBurst
);
MSCL_C_SAME(MSCL_SAMPLING_MODE_NON_SYNC, WirelessTypes::samplingMode_nonSync);
MSCL_C_SAME(
    MSCL_SAMPLING_MODE_ARMED_DATALOG,
    WirelessTypes::samplingMode_armedDatalog
);
MSCL_C_SAME(
    MSCL_SAMPLING_MODE_SYNC_EVENT,
    WirelessTypes::samplingMode_syncEvent
);
MSCL_C_SAME(
    MSCL_SAMPLING_MODE_NON_SYNC_EVENT,
    WirelessTypes::samplingMode_nonSyncEvent
);

MSCL_C_SAME(MSCL_SAMPLE_RATE_4096HZ, WirelessTypes::sampleRate_4096Hz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_2048HZ, WirelessTypes::sampleRate_2048Hz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_1024HZ, WirelessTypes::sampleRate_1024Hz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_512HZ, WirelessTypes::sampleRate_512Hz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_256HZ, WirelessTypes::sampleRate_256Hz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_128HZ, WirelessTypes::sampleRate_128Hz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_64HZ, WirelessTypes::sampleRate_64Hz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_32HZ, WirelessTypes::sampleRate_32Hz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_16HZ, WirelessTypes::sampleRate_16Hz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_8HZ, WirelessTypes::sampleRate_8Hz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_4HZ, WirelessTypes::sampleRate_4Hz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_2HZ, WirelessTypes::sampleRate_2Hz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_1HZ, WirelessTypes::sampleRate_1Hz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_2SEC, WirelessTypes::sampleRate_2Sec);
MSCL_C_SAME(MSCL_SAMPLE_RATE_5SEC, WirelessTypes::sampleRate_5Sec);
MSCL_C_SAME(MSCL_SAMPLE_RATE_10SEC, WirelessTypes::sampleRate_10Sec);
MSCL_C_SAME(MSCL_SAMPLE_RATE_30SEC, WirelessTypes::sampleRate_30Sec);
MSCL_C_SAME(MSCL_SAMPLE_RATE_1MIN, WirelessTypes::sampleRate_1Min);
MSCL_C_SAME(MSCL_SAMPLE_RATE_2MIN, WirelessTypes::sampleRate_2Min);
MSCL_C_SAME(MSCL_SAMPLE_RATE_5MIN, WirelessTypes::sampleRate_5Min);
MSCL_C_SAME(MSCL_SAMPLE_RATE_10MIN, WirelessTypes::sampleRate_10Min);
MSCL_C_SAME(MSCL_SAMPLE_RATE_30MIN, WirelessTypes::sampleRate_30Min);
MSCL_C_SAME(MSCL_SAMPLE_RATE_60MIN, WirelessTypes::sampleRate_60Min);

MSCL_C_SAME(MSCL_DATA_FORMAT_RAW_UINT16, WirelessTypes::dataFormat_raw_uint16);
MSCL_C_SAME(MSCL_DATA_FORMAT_CAL_FLOAT, WirelessTypes::dataFormat_cal_float);
MSCL_C_SAME(MSCL_DATA_FORMAT_RAW_UINT24, WirelessTypes::dataFormat_raw_uint24);
MSCL_C_SAME(MSCL_DATA_FORMAT_RAW_INT24, WirelessTypes::dataFormat_raw_int24);
MSCL_C_SAME(MSCL_DATA_FORMAT_RAW_INT16, WirelessTypes::dataFormat_raw_int16);
MSCL_C_SAME(
    MSCL_DATA_FORMAT_CAL_INT16_X10,
    WirelessTypes::dataFormat_cal_int16_x10
);

MSCL_C_SAME(
    MSCL_DATA_COLLECTION_LOG_ONLY,
    WirelessTypes::collectionMethod_logOnly
);
MSCL_C_SAME(
    MSCL_DATA_COLLECTION_TRANSMIT_ONLY,
    WirelessTypes::collectionMethod_transmitOnly
);
MSCL_C_SAME(
    MSCL_DATA_COLLECTION_LOG_AND_TRANSMIT,
    WirelessTypes::collectionMethod_logAndTransmit
);

MSCL_C_SAME(MSCL_DATA_MODE_NONE, WirelessTypes::dataMode_none);
MSCL_C_SAME(MSCL_DATA_MODE_RAW, WirelessTypes::dataMode_raw);
MSCL_C_SAME(MSCL_DATA_MODE_DERIVED, WirelessTypes::dataMode_derived);
MSCL_C_SAME(MSCL_DATA_MODE_RAW_DERIVED, WirelessTypes::dataMode_raw_derived);

MSCL_C_SAME(MSCL_DERIVED_RMS, WirelessTypes::derivedCategory_rms);
MSCL_C_SAME(
    MSCL_DERIVED_PEAK_TO_PEAK,
    WirelessTypes::derivedCategory_peakToPeak
);
MSCL_C_SAME(MSCL_DERIVED_VELOCITY, WirelessTypes::derivedCategory_velocity);
MSCL_C_SAME(
    MSCL_DERIVED_CREST_FACTOR,
    WirelessTypes::derivedCategory_crestFactor
);
MSCL_C_SAME(MSCL_DERIVED_MEAN, WirelessTypes::derivedCategory_mean);

MSCL_C_SAME(MSCL_INPUT_RANGE_2G, WirelessTypes::range_2G);
MSCL_C_SAME(MSCL_INPUT_RANGE_4G, WirelessTypes::range_4G);
MSCL_C_SAME(MSCL_INPUT_RANGE_8G, WirelessTypes::range_8G);

MSCL_C_SAME(MSCL_LOW_PASS_26HZ, WirelessTypes::filter_26hz);
MSCL_C_SAME(MSCL_LOW_PASS_52HZ, WirelessTypes::filter_52hz);
MSCL_C_SAME(MSCL_LOW_PASS_104HZ, WirelessTypes::filter_104hz);
MSCL_C_SAME(MSCL_LOW_PASS_209HZ, WirelessTypes::filter_209hz);
MSCL_C_SAME(MSCL_LOW_PASS_418HZ, WirelessTypes::filter_418hz);
MSCL_C_SAME(MSCL_LOW_PASS_800HZ, WirelessTypes::filter_800hz);

MSCL_C_SAME(MSCL_HIGH_PASS_OFF, WirelessTypes::highPass_off);
MSCL_C_SAME(MSCL_HIGH_PASS_AUTO, WirelessTypes::highPass_auto);

MSCL_C_SAME(MSCL_SENSOR_OUTPUT_ACCEL, WirelessTypes::sensorOutputMode_accel);
MSCL_C_SAME(MSCL_SENSOR_OUTPUT_TILT, WirelessTypes::sensorOutputMode_tilt);

MSCL_C_SAME(
    MSCL_SET_TO_IDLE_SUCCESS,
    mscl::SetToIdleStatus::setToIdleResult_success
);
MSCL_C_SAME(
    MSCL_SET_TO_IDLE_CANCELED,
    mscl::SetToIdleStatus::setToIdleResult_canceled
);
MSCL_C_SAME(
    MSCL_SET_TO_IDLE_FAILED,
    mscl::SetToIdleStatus::setToIdleResult_failed
);
MSCL_C_SAME(
    MSCL_SET_TO_IDLE_NOT_COMPLETED,
    mscl::SetToIdleStatus::setToIdleResult_notCompleted
);

#undef MSCL_C_SAME

namespace {

// A fixed buffer, so that recording an error never allocates or throws.
thread_local char last_error[512] = "";

mscl_status fail(mscl_status status, const char *message)
{
    std::snprintf(last_error, sizeof(last_error), "%s", message);
    return status;
}

mscl_status fail_null(const char *function)
{
    std::snprintf(
        last_error,
        sizeof(last_error),
        "%s: a required pointer argument is NULL",
        function
    );
    return MSCL_ERROR_INVALID_ARGUMENT;
}

// Runs `function` and maps any exception it throws to an mscl_status.
// Derived MSCL errors come before their bases.
template <typename Function>
mscl_status call(Function &&function)
{
    try {
        function();
        return MSCL_OK;
    } catch (const mscl::Error_InvalidSerialPort &e) {
        return fail(MSCL_ERROR_INVALID_SERIAL_PORT, e.what());
    } catch (const mscl::Error_Connection &e) {
        return fail(MSCL_ERROR_CONNECTION, e.what());
    } catch (const mscl::Error_NodeCommunication &e) {
        return fail(MSCL_ERROR_NODE_COMMUNICATION, e.what());
    } catch (const mscl::Error_Communication &e) {
        return fail(MSCL_ERROR_COMMUNICATION, e.what());
    } catch (const mscl::Error_InvalidConfig &e) {
        return fail(MSCL_ERROR_INVALID_CONFIG, e.what());
    } catch (const mscl::Error_NotSupported &e) {
        return fail(MSCL_ERROR_NOT_SUPPORTED, e.what());
    } catch (const mscl::Error_NoData &e) {
        return fail(MSCL_ERROR_NO_DATA, e.what());
    } catch (const mscl::Error_BadDataType &e) {
        return fail(MSCL_ERROR_BAD_DATA_TYPE, e.what());
    } catch (const mscl::Error_UnknownSampleRate &e) {
        return fail(MSCL_ERROR_UNKNOWN_SAMPLE_RATE, e.what());
    } catch (const mscl::Error &e) {
        return fail(MSCL_ERROR_OTHER, e.what());
    } catch (const std::bad_alloc &) {
        return fail(MSCL_ERROR_OUT_OF_MEMORY, "out of memory");
    } catch (const std::exception &e) {
        return fail(MSCL_ERROR_UNKNOWN, e.what());
    } catch (...) {
        return fail(MSCL_ERROR_UNKNOWN, "unknown error");
    }
}

// Copies `source` into `destination`, truncating to fit, always terminated.
void copy_string(char *destination, size_t size, const std::string &source)
{
    if (size == 0) {
        return;
    }
    const size_t length = std::min(source.size(), size - 1);
    std::memcpy(destination, source.data(), length);
    destination[length] = '\0';
}

template <typename T>
T *allocate_zeroed(size_t count)
{
    void *memory = std::calloc(count, sizeof(T));
    if (memory == nullptr) {
        throw std::bad_alloc();
    }
    return static_cast<T *>(memory);
}

double value_of(const mscl::WirelessDataPoint &point)
{
    try {
        return point.as_double();
    } catch (const mscl::Error_BadDataType &) {
        return std::numeric_limits<double>::quiet_NaN();
    }
}

std::string name_of(const mscl::WirelessDataPoint &point)
{
    try {
        return point.channelName();
    } catch (const mscl::Error &) {
        return "unknown";
    }
}

// Fills sweep.points; on failure the caller frees them with
// mscl_sweeps_free.
void fill_points(const mscl::ChannelData &data, mscl_sweep &sweep)
{
    sweep.point_count = 0;
    sweep.points = nullptr;
    if (data.empty()) {
        return;
    }
    sweep.points = allocate_zeroed<mscl_data_point>(data.size());
    sweep.point_count = data.size();
    for (size_t i = 0; i < data.size(); i++) {
        mscl_data_point &point = sweep.points[i];
        point.channel_id = static_cast<uint32_t>(data[i].channelId());
        copy_string(
            point.channel_name,
            sizeof(point.channel_name),
            name_of(data[i])
        );
        point.value = value_of(data[i]);
    }
}

void fill_sweep(const mscl::DataSweep &data, mscl_sweep &sweep)
{
    sweep.node_address = data.nodeAddress();
    sweep.timestamp_ns = data.timestamp().nanoseconds();
    sweep.tick = data.tick();
    sweep.sample_rate_hz = data.sampleRate().samplesPerSecond();
    sweep.base_rssi = data.baseRssi();
    sweep.node_rssi = data.nodeRssi();
    sweep.cal_applied = data.calApplied();
    fill_points(data.data(), sweep);
}

} // namespace

extern "C" {

const char *mscl_last_error(void)
{
    return last_error;
}

mscl_version mscl_get_version(void)
{
    return {MSCL_MAJOR, MSCL_MINOR, MSCL_PATCH, MSCL_GIT_COMMIT};
}

mscl_status mscl_list_base_stations(mscl_port_info **ports, size_t *count)
{
    if (ports == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *ports = nullptr;
    *count = 0;
    return call([&] {
        const mscl::Devices::DeviceList devices =
            mscl::Devices::listBaseStations();
        if (devices.empty()) {
            return;
        }
        mscl_port_info *result =
            allocate_zeroed<mscl_port_info>(devices.size());
        size_t i = 0;
        for (const auto &device : devices) {
            copy_string(result[i].port, sizeof(result[i].port), device.first);
            copy_string(
                result[i].description,
                sizeof(result[i].description),
                device.second.description()
            );
            result[i].baud_rate = device.second.baudRate();
            i++;
        }
        *ports = result;
        *count = devices.size();
    });
}

void mscl_port_infos_free(mscl_port_info *ports)
{
    std::free(ports);
}

mscl_status mscl_base_station_open(
    const char *port,
    uint32_t baud_rate,
    mscl_base_station **base_station
)
{
    if (port == nullptr || base_station == nullptr) {
        return fail_null(__func__);
    }
    *base_station = nullptr;
    return call([&] {
        mscl::Connection connection =
            mscl::Connection::Serial(port, baud_rate);
        *base_station = new mscl_base_station(connection);
    });
}

void mscl_base_station_close(mscl_base_station *base_station)
{
    if (base_station == nullptr) {
        return;
    }
    try {
        base_station->base.connection().disconnect();
    } catch (...) {
        // Closing must not fail; the port is released with the object.
    }
    delete base_station;
}

mscl_status mscl_base_station_ping(
    mscl_base_station *base_station,
    bool *success
)
{
    if (base_station == nullptr || success == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *success = base_station->base.ping(); });
}

mscl_status mscl_base_station_set_retries(
    mscl_base_station *base_station,
    uint8_t retries
)
{
    if (base_station == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { base_station->base.readWriteRetries(retries); });
}

mscl_status mscl_base_station_enable_beacon(
    mscl_base_station *base_station,
    uint64_t *beacon_time_ns
)
{
    if (base_station == nullptr || beacon_time_ns == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *beacon_time_ns = base_station->base.enableBeacon().nanoseconds();
    });
}

mscl_status mscl_base_station_disable_beacon(mscl_base_station *base_station)
{
    if (base_station == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { base_station->base.disableBeacon(); });
}

mscl_status mscl_base_station_get_data(
    mscl_base_station *base_station,
    uint32_t timeout_ms,
    uint32_t max_sweeps,
    mscl_sweep **sweeps,
    size_t *count
)
{
    if (base_station == nullptr || sweeps == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *sweeps = nullptr;
    *count = 0;
    return call([&] {
        const mscl::DataSweeps data =
            base_station->base.getData(timeout_ms, max_sweeps);
        if (data.empty()) {
            return;
        }
        mscl_sweep *result = allocate_zeroed<mscl_sweep>(data.size());
        try {
            for (size_t i = 0; i < data.size(); i++) {
                fill_sweep(data[i], result[i]);
            }
        } catch (...) {
            mscl_sweeps_free(result, data.size());
            throw;
        }
        *sweeps = result;
        *count = data.size();
    });
}

void mscl_sweeps_free(mscl_sweep *sweeps, size_t count)
{
    if (sweeps == nullptr) {
        return;
    }
    for (size_t i = 0; i < count; i++) {
        std::free(sweeps[i].points);
    }
    std::free(sweeps);
}

mscl_status mscl_node_create(
    mscl_base_station *base_station,
    uint32_t address,
    mscl_node **node
)
{
    if (base_station == nullptr || node == nullptr) {
        return fail_null(__func__);
    }
    *node = nullptr;
    return call([&] { *node = new mscl_node(address, base_station->base); });
}

void mscl_node_destroy(mscl_node *node)
{
    delete node;
}

mscl_status mscl_node_set_retries(mscl_node *node, uint8_t retries)
{
    if (node == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { node->node.readWriteRetries(retries); });
}

mscl_status mscl_node_ping(mscl_node *node, mscl_ping_result *result)
{
    if (node == nullptr || result == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        const mscl::PingResponse response = node->node.ping();
        result->success = response.success();
        result->base_rssi = response.baseRssi();
        result->node_rssi = response.nodeRssi();
    });
}

mscl_status mscl_node_set_to_idle(
    mscl_node *node,
    uint32_t timeout_ms,
    mscl_set_to_idle_result *result
)
{
    if (node == nullptr || result == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        mscl::SetToIdleStatus status = node->node.setToIdle();
        const auto deadline = std::chrono::steady_clock::now() +
            std::chrono::milliseconds(timeout_ms);
        // complete() waits up to 10 ms; cancel() marks the status complete.
        while (!status.complete(10)) {
            if (std::chrono::steady_clock::now() >= deadline) {
                status.cancel();
            }
        }
        *result = static_cast<mscl_set_to_idle_result>(status.result());
    });
}

mscl_status mscl_node_sleep(mscl_node *node, bool *success)
{
    if (node == nullptr || success == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *success = node->node.sleep(); });
}

mscl_status mscl_node_cycle_power(mscl_node *node)
{
    if (node == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { node->node.cyclePower(); });
}

mscl_status mscl_node_get_info(mscl_node *node, mscl_node_info *info)
{
    if (node == nullptr || info == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        info->address = node->node.nodeAddress();
        info->model = static_cast<uint32_t>(node->node.model());
        copy_string(info->serial, sizeof(info->serial), node->node.serial());
        const mscl::Version firmware = node->node.firmwareVersion();
        info->firmware_major = firmware.majorPart();
        info->firmware_minor = firmware.minorPart();
        info->firmware_patch = firmware.patchPart();
    });
}

mscl_status mscl_node_start_non_sync_sampling(mscl_node *node, bool *success)
{
    if (node == nullptr || success == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *success = node->node.startNonSyncSampling(); });
}

mscl_status mscl_node_get_num_datalog_sessions(
    mscl_node *node,
    uint16_t *count
)
{
    if (node == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *count = node->node.getNumDatalogSessions(); });
}

mscl_status mscl_node_erase(mscl_node *node)
{
    if (node == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { node->node.erase(); });
}

mscl_status mscl_node_get_default_mode(
    mscl_node *node,
    mscl_default_mode *mode
)
{
    if (node == nullptr || mode == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *mode = static_cast<mscl_default_mode>(node->node.getDefaultMode());
    });
}

mscl_status mscl_node_get_inactivity_timeout(
    mscl_node *node,
    uint16_t *seconds
)
{
    if (node == nullptr || seconds == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *seconds = node->node.getInactivityTimeout(); });
}

mscl_status mscl_node_get_check_radio_interval(
    mscl_node *node,
    uint8_t *seconds
)
{
    if (node == nullptr || seconds == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *seconds = node->node.getCheckRadioInterval(); });
}

mscl_status mscl_node_get_transmit_power(
    mscl_node *node,
    mscl_transmit_power *power
)
{
    if (node == nullptr || power == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *power =
            static_cast<mscl_transmit_power>(node->node.getTransmitPower());
    });
}

mscl_status mscl_node_get_sampling_mode(
    mscl_node *node,
    mscl_sampling_mode *mode
)
{
    if (node == nullptr || mode == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *mode = static_cast<mscl_sampling_mode>(node->node.getSamplingMode());
    });
}

mscl_status mscl_node_get_sample_rate(mscl_node *node, mscl_sample_rate *rate)
{
    if (node == nullptr || rate == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *rate = static_cast<mscl_sample_rate>(node->node.getSampleRate());
    });
}

mscl_status mscl_node_get_active_channels(mscl_node *node, uint16_t *mask)
{
    if (node == nullptr || mask == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *mask = node->node.getActiveChannels().toMask(); });
}

mscl_status mscl_node_get_num_sweeps(mscl_node *node, uint32_t *sweeps)
{
    if (node == nullptr || sweeps == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *sweeps = node->node.getNumSweeps(); });
}

mscl_status mscl_node_get_unlimited_duration(mscl_node *node, bool *unlimited)
{
    if (node == nullptr || unlimited == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *unlimited = node->node.getUnlimitedDuration(); });
}

mscl_status mscl_node_get_data_format(
    mscl_node *node,
    mscl_data_format *format
)
{
    if (node == nullptr || format == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *format = static_cast<mscl_data_format>(node->node.getDataFormat());
    });
}

mscl_status mscl_node_get_data_collection_method(
    mscl_node *node,
    mscl_data_collection_method *method
)
{
    if (node == nullptr || method == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *method = static_cast<mscl_data_collection_method>(
            node->node.getDataCollectionMethod()
        );
    });
}

mscl_status mscl_node_get_time_between_bursts(
    mscl_node *node,
    uint32_t *seconds
)
{
    if (node == nullptr || seconds == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *seconds = static_cast<uint32_t>(
            node->node.getTimeBetweenBursts().getSeconds()
        );
    });
}

mscl_status mscl_node_get_lost_beacon_timeout(
    mscl_node *node,
    uint16_t *minutes
)
{
    if (node == nullptr || minutes == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *minutes = node->node.getLostBeaconTimeout(); });
}

mscl_status mscl_node_get_diagnostic_interval(
    mscl_node *node,
    uint16_t *seconds
)
{
    if (node == nullptr || seconds == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *seconds = node->node.getDiagnosticInterval(); });
}

mscl_status mscl_node_get_input_range(
    mscl_node *node,
    uint16_t channel_mask,
    mscl_input_range *range
)
{
    if (node == nullptr || range == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *range = static_cast<mscl_input_range>(
            node->node.getInputRange(mscl::ChannelMask(channel_mask))
        );
    });
}

mscl_status mscl_node_get_low_pass_filter(
    mscl_node *node,
    uint16_t channel_mask,
    mscl_low_pass_filter *filter
)
{
    if (node == nullptr || filter == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *filter = static_cast<mscl_low_pass_filter>(
            node->node.getLowPassFilter(mscl::ChannelMask(channel_mask))
        );
    });
}

mscl_status mscl_node_get_high_pass_filter(
    mscl_node *node,
    uint16_t channel_mask,
    mscl_high_pass_filter *filter
)
{
    if (node == nullptr || filter == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *filter = static_cast<mscl_high_pass_filter>(
            node->node.getHighPassFilter(mscl::ChannelMask(channel_mask))
        );
    });
}

mscl_status mscl_node_get_sensor_output_mode(
    mscl_node *node,
    mscl_sensor_output_mode *mode
)
{
    if (node == nullptr || mode == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *mode = static_cast<mscl_sensor_output_mode>(
            node->node.getSensorOutputMode()
        );
    });
}

mscl_status mscl_node_get_data_mode(mscl_node *node, mscl_data_mode *mode)
{
    if (node == nullptr || mode == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *mode = static_cast<mscl_data_mode>(node->node.getDataMode());
    });
}

mscl_status mscl_node_get_derived_data_rate(
    mscl_node *node,
    mscl_sample_rate *rate
)
{
    if (node == nullptr || rate == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *rate = static_cast<mscl_sample_rate>(node->node.getDerivedDataRate());
    });
}

mscl_status mscl_node_get_derived_channel_mask(
    mscl_node *node,
    mscl_derived_category category,
    uint16_t *mask
)
{
    if (node == nullptr || mask == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *mask = node->node
                    .getDerivedChannelMask(
                        static_cast<WirelessTypes::DerivedCategory>(category)
                    )
                    .toMask();
    });
}

mscl_status mscl_node_verify_config(
    mscl_node *node,
    const mscl_node_config *config,
    bool *ok,
    char *issues,
    size_t issues_len
)
{
    if (node == nullptr || config == nullptr || ok == nullptr) {
        return fail_null(__func__);
    }
    if (issues != nullptr && issues_len > 0) {
        issues[0] = '\0';
    }
    return call([&] {
        mscl::ConfigIssues found;
        *ok = node->node.verifyConfig(config->config, found);
        if (issues == nullptr || issues_len == 0) {
            return;
        }
        std::string text;
        for (const mscl::ConfigIssue &issue : found) {
            text += issue.description();
            text += '\n';
        }
        copy_string(issues, issues_len, text);
    });
}

mscl_status mscl_node_apply_config(
    mscl_node *node,
    const mscl_node_config *config
)
{
    if (node == nullptr || config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { node->node.applyConfig(config->config); });
}

mscl_status mscl_node_config_create(mscl_node_config **config)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    *config = nullptr;
    return call([&] { *config = new mscl_node_config(); });
}

void mscl_node_config_destroy(mscl_node_config *config)
{
    delete config;
}

mscl_status mscl_node_config_set_default_mode(
    mscl_node_config *config,
    mscl_default_mode mode
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.defaultMode(
            static_cast<WirelessTypes::DefaultMode>(mode)
        );
    });
}

mscl_status mscl_node_config_set_inactivity_timeout(
    mscl_node_config *config,
    uint16_t seconds
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { config->config.inactivityTimeout(seconds); });
}

mscl_status mscl_node_config_set_check_radio_interval(
    mscl_node_config *config,
    uint8_t seconds
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { config->config.checkRadioInterval(seconds); });
}

mscl_status mscl_node_config_set_transmit_power(
    mscl_node_config *config,
    mscl_transmit_power power
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.transmitPower(
            static_cast<WirelessTypes::TransmitPower>(power)
        );
    });
}

mscl_status mscl_node_config_set_sampling_mode(
    mscl_node_config *config,
    mscl_sampling_mode mode
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.samplingMode(
            static_cast<WirelessTypes::SamplingMode>(mode)
        );
    });
}

mscl_status mscl_node_config_set_sample_rate(
    mscl_node_config *config,
    mscl_sample_rate rate
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.sampleRate(
            static_cast<WirelessTypes::WirelessSampleRate>(rate)
        );
    });
}

mscl_status mscl_node_config_set_active_channels(
    mscl_node_config *config,
    uint16_t mask
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { config->config.activeChannels(mscl::ChannelMask(mask)); });
}

mscl_status mscl_node_config_set_num_sweeps(
    mscl_node_config *config,
    uint32_t sweeps
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { config->config.numSweeps(sweeps); });
}

mscl_status mscl_node_config_set_unlimited_duration(
    mscl_node_config *config,
    bool unlimited
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { config->config.unlimitedDuration(unlimited); });
}

mscl_status mscl_node_config_set_data_format(
    mscl_node_config *config,
    mscl_data_format format
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.dataFormat(
            static_cast<WirelessTypes::DataFormat>(format)
        );
    });
}

mscl_status mscl_node_config_set_data_collection_method(
    mscl_node_config *config,
    mscl_data_collection_method method
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.dataCollectionMethod(
            static_cast<WirelessTypes::DataCollectionMethod>(method)
        );
    });
}

mscl_status mscl_node_config_set_time_between_bursts(
    mscl_node_config *config,
    uint32_t seconds
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.timeBetweenBursts(mscl::TimeSpan::Seconds(seconds));
    });
}

mscl_status mscl_node_config_set_lost_beacon_timeout(
    mscl_node_config *config,
    uint16_t minutes
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { config->config.lostBeaconTimeout(minutes); });
}

mscl_status mscl_node_config_set_diagnostic_interval(
    mscl_node_config *config,
    uint16_t seconds
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { config->config.diagnosticInterval(seconds); });
}

mscl_status mscl_node_config_set_input_range(
    mscl_node_config *config,
    uint16_t channel_mask,
    mscl_input_range range
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.inputRange(
            mscl::ChannelMask(channel_mask),
            static_cast<WirelessTypes::InputRange>(range)
        );
    });
}

mscl_status mscl_node_config_set_low_pass_filter(
    mscl_node_config *config,
    uint16_t channel_mask,
    mscl_low_pass_filter filter
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.lowPassFilter(
            mscl::ChannelMask(channel_mask),
            static_cast<WirelessTypes::Filter>(filter)
        );
    });
}

mscl_status mscl_node_config_set_high_pass_filter(
    mscl_node_config *config,
    uint16_t channel_mask,
    mscl_high_pass_filter filter
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.highPassFilter(
            mscl::ChannelMask(channel_mask),
            static_cast<WirelessTypes::HighPassFilter>(filter)
        );
    });
}

mscl_status mscl_node_config_set_sensor_output_mode(
    mscl_node_config *config,
    mscl_sensor_output_mode mode
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.sensorOutputMode(
            static_cast<WirelessTypes::SensorOutputMode>(mode)
        );
    });
}

mscl_status mscl_node_config_set_data_mode(
    mscl_node_config *config,
    mscl_data_mode mode
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.dataMode(static_cast<WirelessTypes::DataMode>(mode));
    });
}

mscl_status mscl_node_config_set_derived_data_rate(
    mscl_node_config *config,
    mscl_sample_rate rate
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.derivedDataRate(
            static_cast<WirelessTypes::WirelessSampleRate>(rate)
        );
    });
}

mscl_status mscl_node_config_set_derived_channel_mask(
    mscl_node_config *config,
    mscl_derived_category category,
    uint16_t mask
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.derivedChannelMask(
            static_cast<WirelessTypes::DerivedCategory>(category),
            mscl::ChannelMask(mask)
        );
    });
}

mscl_status mscl_sync_network_create(
    mscl_base_station *base_station,
    mscl_sync_network **network
)
{
    if (base_station == nullptr || network == nullptr) {
        return fail_null(__func__);
    }
    *network = nullptr;
    return call([&] {
        *network = new mscl_sync_network(base_station->base);
    });
}

void mscl_sync_network_destroy(mscl_sync_network *network)
{
    delete network;
}

mscl_status mscl_sync_network_add_node(
    mscl_sync_network *network,
    mscl_node *node
)
{
    if (network == nullptr || node == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { network->network.addNode(node->node); });
}

mscl_status mscl_sync_network_get_info(
    mscl_sync_network *network,
    mscl_sync_network_info *info
)
{
    if (network == nullptr || info == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        info->ok = network->network.ok();
        info->lossless = network->network.lossless();
        info->percent_bandwidth = network->network.percentBandwidth();
    });
}

mscl_status mscl_sync_network_apply_configuration(mscl_sync_network *network)
{
    if (network == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { network->network.applyConfiguration(); });
}

mscl_status mscl_sync_network_start_sampling(mscl_sync_network *network)
{
    if (network == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { network->network.startSampling(); });
}

mscl_status mscl_datalog_downloader_create(
    mscl_node *node,
    mscl_datalog_downloader **downloader
)
{
    if (node == nullptr || downloader == nullptr) {
        return fail_null(__func__);
    }
    *downloader = nullptr;
    return call([&] {
        *downloader = new mscl_datalog_downloader(node->node);
    });
}

void mscl_datalog_downloader_destroy(mscl_datalog_downloader *downloader)
{
    delete downloader;
}

mscl_status mscl_datalog_downloader_complete(
    mscl_datalog_downloader *downloader,
    bool *complete
)
{
    if (downloader == nullptr || complete == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *complete = downloader->downloader.complete(); });
}

mscl_status mscl_datalog_downloader_next(
    mscl_datalog_downloader *downloader,
    mscl_sweep **sweep
)
{
    if (downloader == nullptr || sweep == nullptr) {
        return fail_null(__func__);
    }
    *sweep = nullptr;
    return call([&] {
        const mscl::LoggedDataSweep data =
            downloader->downloader.getNextData();
        mscl_sweep *result = allocate_zeroed<mscl_sweep>(1);
        try {
            result->node_address = downloader->node_address;
            result->timestamp_ns = data.timestamp().nanoseconds();
            result->tick = data.tick();
            result->sample_rate_hz =
                downloader->downloader.sampleRate().samplesPerSecond();
            result->cal_applied = data.calApplied();
            fill_points(data.data(), *result);
        } catch (...) {
            mscl_sweeps_free(result, 1);
            throw;
        }
        *sweep = result;
    });
}

mscl_status mscl_datalog_downloader_get_session(
    mscl_datalog_downloader *downloader,
    bool *start_of_session,
    uint16_t *session_index
)
{
    if (
        downloader == nullptr ||
        start_of_session == nullptr ||
        session_index == nullptr
    ) {
        return fail_null(__func__);
    }
    return call([&] {
        *start_of_session = downloader->downloader.startOfSession();
        *session_index = downloader->downloader.sessionIndex();
    });
}

mscl_status mscl_datalog_downloader_get_percent_complete(
    mscl_datalog_downloader *downloader,
    float *percent
)
{
    if (downloader == nullptr || percent == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *percent = downloader->downloader.percentComplete();
    });
}

} // extern "C"
