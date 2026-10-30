// Implementation of mscl_c.h. MSCL is C++, so these C functions are written
// in C++ and exported with C linkage. No exception leaves this file: every
// call goes through `call`, which turns MSCL's exceptions into an
// mscl_status and keeps the message for mscl_last_error().

#include "mscl/stdafx.h"

#include "mscl_c.h"

#include "mscl/Communication/Connection.h"
#include "mscl/Communication/Devices.h"
#include "mscl/Exceptions.h"
#include "mscl/MicroStrain/SampleUtils.h"
#include "mscl/MicroStrain/Wireless/BaseStation.h"
#include "mscl/MicroStrain/Wireless/Commands/AutoCalInfo.h"
#include "mscl/MicroStrain/Wireless/Configuration/BaseStationConfig.h"
#include "mscl/MicroStrain/Wireless/Configuration/ConfigIssue.h"
#include "mscl/MicroStrain/Wireless/Configuration/WirelessNodeConfig.h"
#include "mscl/MicroStrain/Wireless/DatalogDownloader.h"
#include "mscl/MicroStrain/Wireless/Features/BaseStationFeatures.h"
#include "mscl/MicroStrain/Wireless/Features/NodeFeatures.h"
#include "mscl/MicroStrain/Wireless/SyncSamplingNetwork.h"
#include "mscl/MicroStrain/Wireless/WirelessNode.h"

#include <algorithm>
#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <limits>
#include <new>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

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

struct mscl_base_station_config {
    mscl::BaseStationConfig config;
};

struct mscl_set_to_idle_status {
    explicit mscl_set_to_idle_status(const mscl::SetToIdleStatus &status)
        : status(status)
    {
    }

    mscl::SetToIdleStatus status;
};

// The C enums reuse MSCL's values, so converting is a cast. These checks
// catch MSCL changing a value.
#define MSCL_C_SAME(c_value, mscl_value)                                    \
    static_assert(                                                         \
        static_cast<long>(c_value) == static_cast<long>(mscl_value),       \
        #c_value " differs from " #mscl_value                              \
    )

using mscl::WirelessTypes;

MSCL_C_SAME(MSCL_TRANSMIT_POWER_0DBM, WirelessTypes::power_0dBm);
MSCL_C_SAME(MSCL_TRANSMIT_POWER_1DBM, WirelessTypes::power_1dBm);
MSCL_C_SAME(MSCL_TRANSMIT_POWER_5DBM, WirelessTypes::power_5dBm);
MSCL_C_SAME(MSCL_TRANSMIT_POWER_10DBM, WirelessTypes::power_10dBm);
MSCL_C_SAME(MSCL_TRANSMIT_POWER_11DBM, WirelessTypes::power_11dBm);
MSCL_C_SAME(MSCL_TRANSMIT_POWER_12DBM, WirelessTypes::power_12dBm);
MSCL_C_SAME(MSCL_TRANSMIT_POWER_15DBM, WirelessTypes::power_15dBm);
MSCL_C_SAME(MSCL_TRANSMIT_POWER_16DBM, WirelessTypes::power_16dBm);
MSCL_C_SAME(MSCL_TRANSMIT_POWER_20DBM, WirelessTypes::power_20dBm);

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

MSCL_C_SAME(
    MSCL_CONNECTION_TYPE_SERIAL,
    mscl::DeviceInfo::connectionType_serial
);
MSCL_C_SAME(MSCL_CONNECTION_TYPE_TCP, mscl::DeviceInfo::connectionType_tcp);

MSCL_C_SAME(MSCL_FREQUENCY_UNKNOWN, WirelessTypes::freq_unknown);
MSCL_C_SAME(MSCL_FREQUENCY_11, WirelessTypes::freq_11);
MSCL_C_SAME(MSCL_FREQUENCY_12, WirelessTypes::freq_12);
MSCL_C_SAME(MSCL_FREQUENCY_13, WirelessTypes::freq_13);
MSCL_C_SAME(MSCL_FREQUENCY_14, WirelessTypes::freq_14);
MSCL_C_SAME(MSCL_FREQUENCY_15, WirelessTypes::freq_15);
MSCL_C_SAME(MSCL_FREQUENCY_16, WirelessTypes::freq_16);
MSCL_C_SAME(MSCL_FREQUENCY_17, WirelessTypes::freq_17);
MSCL_C_SAME(MSCL_FREQUENCY_18, WirelessTypes::freq_18);
MSCL_C_SAME(MSCL_FREQUENCY_19, WirelessTypes::freq_19);
MSCL_C_SAME(MSCL_FREQUENCY_20, WirelessTypes::freq_20);
MSCL_C_SAME(MSCL_FREQUENCY_21, WirelessTypes::freq_21);
MSCL_C_SAME(MSCL_FREQUENCY_22, WirelessTypes::freq_22);
MSCL_C_SAME(MSCL_FREQUENCY_23, WirelessTypes::freq_23);
MSCL_C_SAME(MSCL_FREQUENCY_24, WirelessTypes::freq_24);
MSCL_C_SAME(MSCL_FREQUENCY_25, WirelessTypes::freq_25);
MSCL_C_SAME(MSCL_FREQUENCY_26, WirelessTypes::freq_26);

MSCL_C_SAME(MSCL_COMM_PROTOCOL_LXRS, WirelessTypes::commProtocol_lxrs);
MSCL_C_SAME(
    MSCL_COMM_PROTOCOL_LXRS_PLUS,
    WirelessTypes::commProtocol_lxrsPlus
);

MSCL_C_SAME(MSCL_REGION_CODE_USA, WirelessTypes::region_usa);
MSCL_C_SAME(
    MSCL_REGION_CODE_EUROPEAN_UNION,
    WirelessTypes::region_europeanUnion
);
MSCL_C_SAME(MSCL_REGION_CODE_JAPAN, WirelessTypes::region_japan);
MSCL_C_SAME(MSCL_REGION_CODE_OTHER, WirelessTypes::region_other);
MSCL_C_SAME(MSCL_REGION_CODE_BRAZIL, WirelessTypes::region_brazil);
MSCL_C_SAME(MSCL_REGION_CODE_CHINA, WirelessTypes::region_china);
MSCL_C_SAME(
    MSCL_REGION_CODE_AUSTRALIA_NEW_ZEALAND,
    WirelessTypes::region_australia_newzealand
);
MSCL_C_SAME(MSCL_REGION_CODE_SINGAPORE, WirelessTypes::region_singapore);
MSCL_C_SAME(MSCL_REGION_CODE_CANADA, WirelessTypes::region_canada);
MSCL_C_SAME(MSCL_REGION_CODE_SOUTH_AFRICA, WirelessTypes::region_southAfrica);
MSCL_C_SAME(MSCL_REGION_CODE_INDONESIA, WirelessTypes::region_indonesia);
MSCL_C_SAME(MSCL_REGION_CODE_TAIWAN, WirelessTypes::region_taiwan);

MSCL_C_SAME(
    MSCL_MICROCONTROLLER_18F452,
    WirelessTypes::microcontroller_18F452
);
MSCL_C_SAME(
    MSCL_MICROCONTROLLER_18F4620,
    WirelessTypes::microcontroller_18F4620
);
MSCL_C_SAME(
    MSCL_MICROCONTROLLER_18F46K20,
    WirelessTypes::microcontroller_18F46K20
);
MSCL_C_SAME(
    MSCL_MICROCONTROLLER_18F67K90,
    WirelessTypes::microcontroller_18F67K90
);
MSCL_C_SAME(
    MSCL_MICROCONTROLLER_EFM32WG990F256,
    WirelessTypes::microcontroller_EFM32WG990F256
);
MSCL_C_SAME(
    MSCL_MICROCONTROLLER_EFR32FG1P132F256GM48,
    WirelessTypes::microcontroller_EFR32FG1P132F256GM48
);
MSCL_C_SAME(
    MSCL_MICROCONTROLLER_EFR32MG1P232F256GM48,
    WirelessTypes::microcontroller_EFR32MG1P232F256GM48
);

MSCL_C_SAME(MSCL_BASE_MODEL_WSDA_1000, mscl::WirelessModels::base_wsda_1000);
MSCL_C_SAME(MSCL_BASE_MODEL_WSDA_1500, mscl::WirelessModels::base_wsda_1500);
MSCL_C_SAME(MSCL_BASE_MODEL_WSDA_2000, mscl::WirelessModels::base_wsda_2000);
MSCL_C_SAME(MSCL_BASE_MODEL_WSDA_PRO, mscl::WirelessModels::base_wsdaPro);
MSCL_C_SAME(
    MSCL_BASE_MODEL_WSDA_BASE_200_LEGACY,
    mscl::WirelessModels::base_wsdaBase_200_legacy
);
MSCL_C_SAME(
    MSCL_BASE_MODEL_WSDA_BASE_200,
    mscl::WirelessModels::base_wsdaBase_200
);
MSCL_C_SAME(
    MSCL_BASE_MODEL_WSDA_BASE_200_EXT_ANTENNA,
    mscl::WirelessModels::base_wsdaBase_200_extAntenna
);
MSCL_C_SAME(
    MSCL_BASE_MODEL_WSDA_BASE_101_ANALOG,
    mscl::WirelessModels::base_wsdaBase_101_analog
);
MSCL_C_SAME(
    MSCL_BASE_MODEL_WSDA_BASE_102_RS232,
    mscl::WirelessModels::base_wsdaBase_102_rs232
);
MSCL_C_SAME(
    MSCL_BASE_MODEL_WSDA_BASE_104_USB,
    mscl::WirelessModels::base_wsdaBase_104_usb
);
MSCL_C_SAME(MSCL_BASE_MODEL_WSI_104, mscl::WirelessModels::base_wsi_104);
MSCL_C_SAME(
    MSCL_BASE_MODEL_WSDA_BASE_MINI,
    mscl::WirelessModels::base_wsdaBase_mini
);

MSCL_C_SAME(
    MSCL_BUTTON_COMMAND_NODE_SLEEP,
    mscl::BaseStationButton::btn_nodeSleep
);
MSCL_C_SAME(
    MSCL_BUTTON_COMMAND_NODE_STOP,
    mscl::BaseStationButton::btn_nodeStop
);
MSCL_C_SAME(
    MSCL_BUTTON_COMMAND_ENABLE_BEACON,
    mscl::BaseStationButton::btn_enableBeacon
);
MSCL_C_SAME(
    MSCL_BUTTON_COMMAND_DISABLE_BEACON,
    mscl::BaseStationButton::btn_disableBeacon
);
MSCL_C_SAME(
    MSCL_BUTTON_COMMAND_NODE_NON_SYNC_SAMPLING,
    mscl::BaseStationButton::btn_nodeNonSyncSampling
);
MSCL_C_SAME(
    MSCL_BUTTON_COMMAND_NODE_SYNC_SAMPLING,
    mscl::BaseStationButton::btn_nodeSyncSampling
);
MSCL_C_SAME(
    MSCL_BUTTON_COMMAND_NODE_ARMED_DATALOGGING,
    mscl::BaseStationButton::btn_nodeArmedDatalogging
);
MSCL_C_SAME(
    MSCL_BUTTON_COMMAND_CYCLE_POWER,
    mscl::BaseStationButton::btn_cyclePower
);
MSCL_C_SAME(
    MSCL_BUTTON_COMMAND_DISABLED,
    mscl::BaseStationButton::btn_disabled
);

MSCL_C_SAME(MSCL_DEFAULT_MODE_IDLE, WirelessTypes::defaultMode_idle);
MSCL_C_SAME(MSCL_DEFAULT_MODE_LDC, WirelessTypes::defaultMode_ldc);
MSCL_C_SAME(MSCL_DEFAULT_MODE_DATALOG, WirelessTypes::defaultMode_datalog);
MSCL_C_SAME(MSCL_DEFAULT_MODE_SLEEP, WirelessTypes::defaultMode_sleep);
MSCL_C_SAME(MSCL_DEFAULT_MODE_SYNC, WirelessTypes::defaultMode_sync);

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

MSCL_C_SAME(MSCL_SAMPLE_RATE_104170HZ, WirelessTypes::sampleRate_104170Hz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_78125HZ, WirelessTypes::sampleRate_78125Hz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_62500HZ, WirelessTypes::sampleRate_62500Hz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_25000HZ, WirelessTypes::sampleRate_25000Hz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_12500HZ, WirelessTypes::sampleRate_12500Hz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_3200HZ, WirelessTypes::sampleRate_3200Hz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_1600HZ, WirelessTypes::sampleRate_1600Hz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_800HZ, WirelessTypes::sampleRate_800Hz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_300HZ, WirelessTypes::sampleRate_300Hz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_1K_HZ, WirelessTypes::sampleRate_1kHz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_2K_HZ, WirelessTypes::sampleRate_2kHz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_3K_HZ, WirelessTypes::sampleRate_3kHz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_4K_HZ, WirelessTypes::sampleRate_4kHz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_5K_HZ, WirelessTypes::sampleRate_5kHz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_6K_HZ, WirelessTypes::sampleRate_6kHz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_7K_HZ, WirelessTypes::sampleRate_7kHz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_8K_HZ, WirelessTypes::sampleRate_8kHz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_9K_HZ, WirelessTypes::sampleRate_9kHz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_10K_HZ, WirelessTypes::sampleRate_10kHz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_20K_HZ, WirelessTypes::sampleRate_20kHz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_30K_HZ, WirelessTypes::sampleRate_30kHz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_40K_HZ, WirelessTypes::sampleRate_40kHz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_50K_HZ, WirelessTypes::sampleRate_50kHz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_60K_HZ, WirelessTypes::sampleRate_60kHz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_70K_HZ, WirelessTypes::sampleRate_70kHz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_80K_HZ, WirelessTypes::sampleRate_80kHz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_90K_HZ, WirelessTypes::sampleRate_90kHz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_100K_HZ, WirelessTypes::sampleRate_100kHz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_887HZ, WirelessTypes::sampleRate_887Hz);
MSCL_C_SAME(MSCL_SAMPLE_RATE_8192HZ, WirelessTypes::sampleRate_8192Hz);
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
MSCL_C_SAME(MSCL_SAMPLE_RATE_24HOURS, WirelessTypes::sampleRate_24Hours);

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
    MSCL_DATA_COLLECTION_METHOD_LOG_ONLY,
    WirelessTypes::collectionMethod_logOnly
);
MSCL_C_SAME(
    MSCL_DATA_COLLECTION_METHOD_TRANSMIT_ONLY,
    WirelessTypes::collectionMethod_transmitOnly
);
MSCL_C_SAME(
    MSCL_DATA_COLLECTION_METHOD_LOG_AND_TRANSMIT,
    WirelessTypes::collectionMethod_logAndTransmit
);

MSCL_C_SAME(MSCL_DATA_MODE_NONE, WirelessTypes::dataMode_none);
MSCL_C_SAME(MSCL_DATA_MODE_RAW, WirelessTypes::dataMode_raw);
MSCL_C_SAME(MSCL_DATA_MODE_DERIVED, WirelessTypes::dataMode_derived);
MSCL_C_SAME(MSCL_DATA_MODE_RAW_DERIVED, WirelessTypes::dataMode_raw_derived);

MSCL_C_SAME(MSCL_DERIVED_CATEGORY_RMS, WirelessTypes::derivedCategory_rms);
MSCL_C_SAME(
    MSCL_DERIVED_CATEGORY_PEAK_TO_PEAK,
    WirelessTypes::derivedCategory_peakToPeak
);
MSCL_C_SAME(
    MSCL_DERIVED_CATEGORY_VELOCITY,
    WirelessTypes::derivedCategory_velocity
);
MSCL_C_SAME(
    MSCL_DERIVED_CATEGORY_CREST_FACTOR,
    WirelessTypes::derivedCategory_crestFactor
);
MSCL_C_SAME(MSCL_DERIVED_CATEGORY_MEAN, WirelessTypes::derivedCategory_mean);

MSCL_C_SAME(MSCL_DERIVED_VELOCITY_UNIT_IPS, WirelessTypes::derivedVelocity_ips);
MSCL_C_SAME(
    MSCL_DERIVED_VELOCITY_UNIT_MMPS,
    WirelessTypes::derivedVelocity_mmps
);

MSCL_C_SAME(MSCL_INPUT_RANGE_14_545M_V, WirelessTypes::range_14_545mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_10_236M_V, WirelessTypes::range_10_236mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_7_608M_V, WirelessTypes::range_7_608mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_4_046M_V, WirelessTypes::range_4_046mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_2_008M_V, WirelessTypes::range_2_008mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_1_511M_V, WirelessTypes::range_1_511mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_1_001M_V, WirelessTypes::range_1_001mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_0_812M_V, WirelessTypes::range_0_812mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_75M_V, WirelessTypes::range_75mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_37_5M_V, WirelessTypes::range_37_5mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_18_75M_V, WirelessTypes::range_18_75mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_9_38M_V, WirelessTypes::range_9_38mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_4_69M_V, WirelessTypes::range_4_69mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_2_34M_V, WirelessTypes::range_2_34mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_1_17M_V, WirelessTypes::range_1_17mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_0_586M_V, WirelessTypes::range_0_586mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_70M_V, WirelessTypes::range_70mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_35M_V, WirelessTypes::range_35mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_17_5M_V, WirelessTypes::range_17_5mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_8_75M_V, WirelessTypes::range_8_75mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_4_38M_V, WirelessTypes::range_4_38mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_2_19M_V, WirelessTypes::range_2_19mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_1_09M_V, WirelessTypes::range_1_09mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_0_547M_V, WirelessTypes::range_0_547mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_44M_V, WirelessTypes::range_44mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_30M_V, WirelessTypes::range_30mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_20M_V, WirelessTypes::range_20mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_15M_V, WirelessTypes::range_15mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_10M_V, WirelessTypes::range_10mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_5M_V, WirelessTypes::range_5mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_3M_V, WirelessTypes::range_3mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_2M_V, WirelessTypes::range_2mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_6M_V, WirelessTypes::range_6mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_1M_V, WirelessTypes::range_1mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_50M_V, WirelessTypes::range_50mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_2_5M_V, WirelessTypes::range_2_5mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_0_6M_V, WirelessTypes::range_0_6mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_0_35M_V, WirelessTypes::range_0_35mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_0_1M_V, WirelessTypes::range_0_1mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_156M_V, WirelessTypes::range_156mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_78_1M_V, WirelessTypes::range_78_1mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_39M_V, WirelessTypes::range_39mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_19_5M_V, WirelessTypes::range_19_5mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_9_76M_V, WirelessTypes::range_9_76mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_4_88M_V, WirelessTypes::range_4_88mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_2_44M_V, WirelessTypes::range_2_44mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_1_22M_V, WirelessTypes::range_1_22mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_10_24V, WirelessTypes::range_10_24V);
MSCL_C_SAME(MSCL_INPUT_RANGE_5_12V, WirelessTypes::range_5_12V);
MSCL_C_SAME(MSCL_INPUT_RANGE_2_56V, WirelessTypes::range_2_56V);
MSCL_C_SAME(MSCL_INPUT_RANGE_0TO10_24V, WirelessTypes::range_0to10_24V);
MSCL_C_SAME(MSCL_INPUT_RANGE_0TO5_12V, WirelessTypes::range_0to5_12V);
MSCL_C_SAME(MSCL_INPUT_RANGE_1_147V, WirelessTypes::range_1_147V);
MSCL_C_SAME(MSCL_INPUT_RANGE_585M_V, WirelessTypes::range_585mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_292_5M_V, WirelessTypes::range_292_5mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_146_25M_V, WirelessTypes::range_146_25mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_73_13M_V, WirelessTypes::range_73_13mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_36_56M_V, WirelessTypes::range_36_56mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_18_23M_V, WirelessTypes::range_18_23mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_9_14M_V, WirelessTypes::range_9_14mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_5_74V, WirelessTypes::range_5_74V);
MSCL_C_SAME(MSCL_INPUT_RANGE_2_93V, WirelessTypes::range_2_93V);
MSCL_C_SAME(MSCL_INPUT_RANGE_1_46V, WirelessTypes::range_1_46V);
MSCL_C_SAME(MSCL_INPUT_RANGE_731_3M_V, WirelessTypes::range_731_3mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_365_6M_V, WirelessTypes::range_365_6mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_182_8M_V, WirelessTypes::range_182_8mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_91_4M_V, WirelessTypes::range_91_4mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_45_7M_V, WirelessTypes::range_45_7mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_62_5M_V, WirelessTypes::range_62_5mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_31_25M_V, WirelessTypes::range_31_25mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_15_63M_V, WirelessTypes::range_15_63mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_7_81M_V, WirelessTypes::range_7_81mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_3_91M_V, WirelessTypes::range_3_91mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_1_95M_V, WirelessTypes::range_1_95mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_0_976M_V, WirelessTypes::range_0_976mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_0_488M_V, WirelessTypes::range_0_488mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_2G, WirelessTypes::range_2G);
MSCL_C_SAME(MSCL_INPUT_RANGE_4G, WirelessTypes::range_4G);
MSCL_C_SAME(MSCL_INPUT_RANGE_8G, WirelessTypes::range_8G);
MSCL_C_SAME(MSCL_INPUT_RANGE_10G, WirelessTypes::range_10G);
MSCL_C_SAME(MSCL_INPUT_RANGE_20G, WirelessTypes::range_20G);
MSCL_C_SAME(MSCL_INPUT_RANGE_40G, WirelessTypes::range_40G);
MSCL_C_SAME(MSCL_INPUT_RANGE_2_5V, WirelessTypes::range_2_5V);
MSCL_C_SAME(MSCL_INPUT_RANGE_1_25V, WirelessTypes::range_1_25V);
MSCL_C_SAME(MSCL_INPUT_RANGE_625M_V, WirelessTypes::range_625mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_312_5M_V, WirelessTypes::range_312_5mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_156_25M_V, WirelessTypes::range_156_25mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_78_125M_V, WirelessTypes::range_78_125mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_39_063M_V, WirelessTypes::range_39_063mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_19_532M_V, WirelessTypes::range_19_532mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_0TO2_5V, WirelessTypes::range_0to2_5V);
MSCL_C_SAME(MSCL_INPUT_RANGE_0TO1_25V, WirelessTypes::range_0to1_25V);
MSCL_C_SAME(MSCL_INPUT_RANGE_0TO625M_V, WirelessTypes::range_0to625mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_0TO312_5M_V, WirelessTypes::range_0to312_5mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_0TO156_25M_V, WirelessTypes::range_0to156_25mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_0TO78_125M_V, WirelessTypes::range_0to78_125mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_0TO39_063M_V, WirelessTypes::range_0to39_063mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_0TO19_532M_V, WirelessTypes::range_0to19_532mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_9_766M_V, WirelessTypes::range_9_766mV);
MSCL_C_SAME(
    MSCL_INPUT_RANGE_1_35V_OR_0TO1000000OHM,
    WirelessTypes::range_1_35V_or_0to1000000ohm
);
MSCL_C_SAME(
    MSCL_INPUT_RANGE_1_25V_OR_0TO10000OHM,
    WirelessTypes::range_1_25V_or_0to10000ohm
);
MSCL_C_SAME(
    MSCL_INPUT_RANGE_625M_V_OR_0TO3333_3OHM,
    WirelessTypes::range_625mV_or_0to3333_3ohm
);
MSCL_C_SAME(
    MSCL_INPUT_RANGE_312_5M_V_OR_0TO1428_6OHM,
    WirelessTypes::range_312_5mV_or_0to1428_6ohm
);
MSCL_C_SAME(
    MSCL_INPUT_RANGE_156_25M_V_OR_0TO666_67OHM,
    WirelessTypes::range_156_25mV_or_0to666_67ohm
);
MSCL_C_SAME(
    MSCL_INPUT_RANGE_78_125M_V_OR_0TO322_58OHM,
    WirelessTypes::range_78_125mV_or_0to322_58ohm
);
MSCL_C_SAME(
    MSCL_INPUT_RANGE_39_0625M_V_OR_0TO158_73OHM,
    WirelessTypes::range_39_0625mV_or_0to158_73ohm
);
MSCL_C_SAME(
    MSCL_INPUT_RANGE_19_5313M_V_OR_0TO78_74OHM,
    WirelessTypes::range_19_5313mV_or_0to78_74ohm
);
MSCL_C_SAME(MSCL_INPUT_RANGE_750M_V, WirelessTypes::range_750mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_375M_V, WirelessTypes::range_375mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_187_5M_V, WirelessTypes::range_187_5mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_93_75M_V, WirelessTypes::range_93_75mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_46_875M_V, WirelessTypes::range_46_875mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_23_438M_V, WirelessTypes::range_23_438mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_11_719M_V, WirelessTypes::range_11_719mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_5_859M_V, WirelessTypes::range_5_859mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_0TO1_5V, WirelessTypes::range_0to1_5V);
MSCL_C_SAME(MSCL_INPUT_RANGE_0TO750M_V, WirelessTypes::range_0to750mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_0TO375M_V, WirelessTypes::range_0to375mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_0TO187_5M_V, WirelessTypes::range_0to187_5mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_0TO93_75M_V, WirelessTypes::range_0to93_75mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_0TO46_875M_V, WirelessTypes::range_0to46_875mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_0TO23_438M_V, WirelessTypes::range_0to23_438mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_0TO11_719M_V, WirelessTypes::range_0to11_719mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_1_5V, WirelessTypes::range_1_5V);
MSCL_C_SAME(MSCL_INPUT_RANGE_1_35V, WirelessTypes::range_1_35V);
MSCL_C_SAME(MSCL_INPUT_RANGE_0TO1000000OHM, WirelessTypes::range_0to1000000ohm);
MSCL_C_SAME(MSCL_INPUT_RANGE_0TO10000OHM, WirelessTypes::range_0to10000ohm);
MSCL_C_SAME(MSCL_INPUT_RANGE_0TO3333_3OHM, WirelessTypes::range_0to3333_3ohm);
MSCL_C_SAME(MSCL_INPUT_RANGE_0TO1428_6OHM, WirelessTypes::range_0to1428_6ohm);
MSCL_C_SAME(MSCL_INPUT_RANGE_0TO666_67OHM, WirelessTypes::range_0to666_67ohm);
MSCL_C_SAME(MSCL_INPUT_RANGE_0TO322_58OHM, WirelessTypes::range_0to322_58ohm);
MSCL_C_SAME(MSCL_INPUT_RANGE_0TO158_73OHM, WirelessTypes::range_0to158_73ohm);
MSCL_C_SAME(MSCL_INPUT_RANGE_0TO78_74OHM, WirelessTypes::range_0to78_74ohm);
MSCL_C_SAME(MSCL_INPUT_RANGE_39_0625M_V, WirelessTypes::range_39_0625mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_19_5313M_V, WirelessTypes::range_19_5313mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_125M_V, WirelessTypes::range_125mV);
MSCL_C_SAME(MSCL_INPUT_RANGE_INVALID, WirelessTypes::range_invalid);

MSCL_C_SAME(MSCL_FILTER_33000HZ, WirelessTypes::filter_33000hz);
MSCL_C_SAME(MSCL_FILTER_20000HZ, WirelessTypes::filter_20000hz);
MSCL_C_SAME(MSCL_FILTER_10000HZ, WirelessTypes::filter_10000hz);
MSCL_C_SAME(MSCL_FILTER_5222HZ, WirelessTypes::filter_5222hz);
MSCL_C_SAME(MSCL_FILTER_5000HZ, WirelessTypes::filter_5000hz);
MSCL_C_SAME(MSCL_FILTER_4416HZ, WirelessTypes::filter_4416hz);
MSCL_C_SAME(MSCL_FILTER_4096HZ, WirelessTypes::filter_4096hz);
MSCL_C_SAME(MSCL_FILTER_4000HZ, WirelessTypes::filter_4000hz);
MSCL_C_SAME(MSCL_FILTER_2208HZ, WirelessTypes::filter_2208hz);
MSCL_C_SAME(MSCL_FILTER_2048HZ, WirelessTypes::filter_2048hz);
MSCL_C_SAME(MSCL_FILTER_2000HZ, WirelessTypes::filter_2000hz);
MSCL_C_SAME(MSCL_FILTER_1104HZ, WirelessTypes::filter_1104hz);
MSCL_C_SAME(MSCL_FILTER_1024HZ, WirelessTypes::filter_1024hz);
MSCL_C_SAME(MSCL_FILTER_1000HZ, WirelessTypes::filter_1000hz);
MSCL_C_SAME(MSCL_FILTER_800HZ, WirelessTypes::filter_800hz);
MSCL_C_SAME(MSCL_FILTER_552HZ, WirelessTypes::filter_552hz);
MSCL_C_SAME(MSCL_FILTER_512HZ, WirelessTypes::filter_512hz);
MSCL_C_SAME(MSCL_FILTER_500HZ, WirelessTypes::filter_500hz);
MSCL_C_SAME(MSCL_FILTER_418HZ, WirelessTypes::filter_418hz);
MSCL_C_SAME(MSCL_FILTER_294HZ, WirelessTypes::filter_294hz);
MSCL_C_SAME(MSCL_FILTER_256HZ, WirelessTypes::filter_256hz);
MSCL_C_SAME(MSCL_FILTER_250HZ, WirelessTypes::filter_250hz);
MSCL_C_SAME(MSCL_FILTER_209HZ, WirelessTypes::filter_209hz);
MSCL_C_SAME(MSCL_FILTER_200HZ, WirelessTypes::filter_200hz);
MSCL_C_SAME(MSCL_FILTER_147HZ, WirelessTypes::filter_147hz);
MSCL_C_SAME(MSCL_FILTER_128HZ, WirelessTypes::filter_128hz);
MSCL_C_SAME(MSCL_FILTER_125HZ, WirelessTypes::filter_125hz);
MSCL_C_SAME(MSCL_FILTER_104HZ, WirelessTypes::filter_104hz);
MSCL_C_SAME(MSCL_FILTER_100HZ, WirelessTypes::filter_100hz);
MSCL_C_SAME(MSCL_FILTER_62HZ, WirelessTypes::filter_62hz);
MSCL_C_SAME(MSCL_FILTER_52HZ, WirelessTypes::filter_52hz);
MSCL_C_SAME(MSCL_FILTER_50HZ, WirelessTypes::filter_50hz);
MSCL_C_SAME(MSCL_FILTER_31HZ, WirelessTypes::filter_31hz);
MSCL_C_SAME(MSCL_FILTER_26HZ, WirelessTypes::filter_26hz);
MSCL_C_SAME(MSCL_FILTER_12_66HZ, WirelessTypes::filter_12_66hz);
MSCL_C_SAME(MSCL_FILTER_2_6HZ, WirelessTypes::filter_2_6hz);

MSCL_C_SAME(MSCL_HIGH_PASS_FILTER_OFF, WirelessTypes::highPass_off);
MSCL_C_SAME(MSCL_HIGH_PASS_FILTER_AUTO, WirelessTypes::highPass_auto);

MSCL_C_SAME(MSCL_CHANNEL_FREQUENCY_CLASS_10, WirelessTypes::cfc_10);
MSCL_C_SAME(MSCL_CHANNEL_FREQUENCY_CLASS_21, WirelessTypes::cfc_21);
MSCL_C_SAME(MSCL_CHANNEL_FREQUENCY_CLASS_60, WirelessTypes::cfc_60);

MSCL_C_SAME(
    MSCL_SENSOR_OUTPUT_MODE_ACCEL,
    WirelessTypes::sensorOutputMode_accel
);
MSCL_C_SAME(MSCL_SENSOR_OUTPUT_MODE_TILT, WirelessTypes::sensorOutputMode_tilt);

MSCL_C_SAME(MSCL_VOLTAGE_5120M_V, WirelessTypes::voltage_5120mV);
MSCL_C_SAME(MSCL_VOLTAGE_5000M_V, WirelessTypes::voltage_5000mV);
MSCL_C_SAME(MSCL_VOLTAGE_4096M_V, WirelessTypes::voltage_4096mV);
MSCL_C_SAME(MSCL_VOLTAGE_3000M_V, WirelessTypes::voltage_3000mV);
MSCL_C_SAME(MSCL_VOLTAGE_2800M_V, WirelessTypes::voltage_2800mV);
MSCL_C_SAME(MSCL_VOLTAGE_2750M_V, WirelessTypes::voltage_2750mV);
MSCL_C_SAME(MSCL_VOLTAGE_2700M_V, WirelessTypes::voltage_2700mV);
MSCL_C_SAME(MSCL_VOLTAGE_2500M_V, WirelessTypes::voltage_2500mV);
MSCL_C_SAME(MSCL_VOLTAGE_1500M_V, WirelessTypes::voltage_1500mV);

MSCL_C_SAME(
    MSCL_VOLTAGE_TYPE_SINGLE_ENDED,
    WirelessTypes::voltageType_singleEnded
);
MSCL_C_SAME(
    MSCL_VOLTAGE_TYPE_DIFFERENTIAL,
    WirelessTypes::voltageType_differential
);

MSCL_C_SAME(MSCL_CAL_COEF_UNIT_NONE, WirelessTypes::unit_none);
MSCL_C_SAME(MSCL_CAL_COEF_UNIT_OTHER_BITS, WirelessTypes::unit_other_bits);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_STRAIN_STRAIN,
    WirelessTypes::unit_strain_strain
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_STRAIN_MICRO_STRAIN,
    WirelessTypes::unit_strain_microStrain
);
MSCL_C_SAME(MSCL_CAL_COEF_UNIT_ACCEL_G, WirelessTypes::unit_accel_g);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_ACCEL_M_PER_SEC2,
    WirelessTypes::unit_accel_mPerSec2
);
MSCL_C_SAME(MSCL_CAL_COEF_UNIT_VOLTS_VOLTS, WirelessTypes::unit_volts_volts);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_VOLTS_MILLIVOLTS,
    WirelessTypes::unit_volts_millivolts
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_VOLTS_MICROVOLTS,
    WirelessTypes::unit_volts_microvolts
);
MSCL_C_SAME(MSCL_CAL_COEF_UNIT_TEMP_CELSIUS, WirelessTypes::unit_temp_celsius);
MSCL_C_SAME(MSCL_CAL_COEF_UNIT_TEMP_KELVIN, WirelessTypes::unit_temp_kelvin);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_TEMP_FAHRENHEIT,
    WirelessTypes::unit_temp_fahrenheit
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_DISPLACEMENT_METERS,
    WirelessTypes::unit_displacement_meters
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_DISPLACEMENT_MILLIMETERS,
    WirelessTypes::unit_displacement_millimeters
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_DISPLACEMENT_MICROMETERS,
    WirelessTypes::unit_displacement_micrometers
);
MSCL_C_SAME(MSCL_CAL_COEF_UNIT_FORCE_LBF, WirelessTypes::unit_force_lbf);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_FORCE_NEWTONS,
    WirelessTypes::unit_force_newtons
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_FORCE_KILO_NEWTONS,
    WirelessTypes::unit_force_kiloNewtons
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_MASS_KILOGRAMS,
    WirelessTypes::unit_mass_kilograms
);
MSCL_C_SAME(MSCL_CAL_COEF_UNIT_PRESSURE_BAR, WirelessTypes::unit_pressure_bar);
MSCL_C_SAME(MSCL_CAL_COEF_UNIT_PRESSURE_PSI, WirelessTypes::unit_pressure_psi);
MSCL_C_SAME(MSCL_CAL_COEF_UNIT_PRESSURE_ATM, WirelessTypes::unit_pressure_atm);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_PRESSURE_MM_HG,
    WirelessTypes::unit_pressure_mmHg
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_PRESSURE_PASCAL,
    WirelessTypes::unit_pressure_pascal
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_PRESSURE_MEGA_PASCAL,
    WirelessTypes::unit_pressure_megaPascal
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_PRESSURE_KILO_PASCAL,
    WirelessTypes::unit_pressure_kiloPascal
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_ANG_DISPLACEMENT_DEGREES,
    WirelessTypes::unit_angDisplacement_degrees
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_ANG_VELOCITY_DEGREES_PER_SEC,
    WirelessTypes::unit_angVelocity_degreesPerSec
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_ANG_VELOCITY_RADIANS_PER_SEC,
    WirelessTypes::unit_angVelocity_radiansPerSec
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_OTHER_PERCENT,
    WirelessTypes::unit_other_percent
);
MSCL_C_SAME(MSCL_CAL_COEF_UNIT_FREQ_RPM, WirelessTypes::unit_freq_rpm);
MSCL_C_SAME(MSCL_CAL_COEF_UNIT_FREQ_HERTZ, WirelessTypes::unit_freq_hertz);
MSCL_C_SAME(MSCL_CAL_COEF_UNIT_RH_PERCENT_RH, WirelessTypes::unit_rh_percentRh);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_OTHER_M_VPER_V,
    WirelessTypes::unit_other_mVperV
);
MSCL_C_SAME(MSCL_CAL_COEF_UNIT_ACCEL_MILLI_G, WirelessTypes::unit_accel_milliG);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_ACCEL_FT_PER_SEC2,
    WirelessTypes::unit_accel_ftPerSec2
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_OTHER_PERCENT_LIFE,
    WirelessTypes::unit_other_percentLife
);
MSCL_C_SAME(MSCL_CAL_COEF_UNIT_OTHER_COUNT, WirelessTypes::unit_other_count);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_DISPLACEMENT_FEET,
    WirelessTypes::unit_displacement_feet
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_DISPLACEMENT_INCHES,
    WirelessTypes::unit_displacement_inches
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_DISPLACEMENT_YARDS,
    WirelessTypes::unit_displacement_yards
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_DISPLACEMENT_MILES,
    WirelessTypes::unit_displacement_miles
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_DISPLACEMENT_NAUT_MILES,
    WirelessTypes::unit_displacement_nautMiles
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_DISPLACEMENT_THOU_INCH,
    WirelessTypes::unit_displacement_thouInch
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_DISPLACEMENT_HUND_INCH,
    WirelessTypes::unit_displacement_hundInch
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_DISPLACEMENT_KILOMETERS,
    WirelessTypes::unit_displacement_kilometers
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_DISPLACEMENT_CENTIMETERS,
    WirelessTypes::unit_displacement_centimeters
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_IRRADIANCE_WATTS_PER_SQ_METER,
    WirelessTypes::unit_irradiance_wattsPerSqMeter
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_PAR_MICRO_EINSTEIN,
    WirelessTypes::unit_par_microEinstein
);
MSCL_C_SAME(MSCL_CAL_COEF_UNIT_MASS_POUND, WirelessTypes::unit_mass_pound);
MSCL_C_SAME(MSCL_CAL_COEF_UNIT_POWER_WATT, WirelessTypes::unit_power_watt);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_POWER_MILLIWATT,
    WirelessTypes::unit_power_milliwatt
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_POWER_HORSEPOWER,
    WirelessTypes::unit_power_horsepower
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_REACTIVE_POWER_VAR,
    WirelessTypes::unit_reactivePower_var
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_ENERGY_WATT_HOUR,
    WirelessTypes::unit_energy_wattHour
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_ENERGY_KILO_WATT_HOUR,
    WirelessTypes::unit_energy_kiloWattHour
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_REACTIVE_ENERGY_VARH,
    WirelessTypes::unit_reactiveEnergy_VARh
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_REACTIVE_ENERGY_K_VARH,
    WirelessTypes::unit_reactiveEnergy_kVARh
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_CURRENT_AMPERE,
    WirelessTypes::unit_current_ampere
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_CURRENT_MILLIAMPERE,
    WirelessTypes::unit_current_milliampere
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_CURRENT_MICROAMPERE,
    WirelessTypes::unit_current_microampere
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_PRESSURE_MILLIBAR,
    WirelessTypes::unit_pressure_millibar
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_PRESSURE_IN_HG,
    WirelessTypes::unit_pressure_inHg
);
MSCL_C_SAME(MSCL_CAL_COEF_UNIT_RSSI_D_BM, WirelessTypes::unit_rssi_dBm);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_FREQ_KILO_HERTZ,
    WirelessTypes::unit_freq_kiloHertz
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_ANG_DISPLACEMENT_RADIANS,
    WirelessTypes::unit_angDisplacement_radians
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_VELOCITY_METERS_PER_SEC,
    WirelessTypes::unit_velocity_metersPerSec
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_VELOCITY_KILOMETERS_PER_SEC,
    WirelessTypes::unit_velocity_kilometersPerSec
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_VELOCITY_KILOMETERS_PER_HR,
    WirelessTypes::unit_velocity_kilometersPerHr
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_VELOCITY_MILES_PER_HR,
    WirelessTypes::unit_velocity_milesPerHr
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_VELOCITY_KNOTS,
    WirelessTypes::unit_velocity_knots
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_VOLUME_CUBIC_METER,
    WirelessTypes::unit_volume_cubicMeter
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_VOLUME_CUBIC_FT,
    WirelessTypes::unit_volume_cubicFt
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_VOLUME_LITERS,
    WirelessTypes::unit_volume_liters
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_VOLUME_GALLON,
    WirelessTypes::unit_volume_gallon
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_FLOW_RATE_CUBIC_METERS_PER_SEC,
    WirelessTypes::unit_flowRate_cubicMetersPerSec
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_FLOW_RATE_CUBIC_FT_PER_SEC,
    WirelessTypes::unit_flowRate_cubicFtPerSec
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_TORQUE_NEWTON_METER,
    WirelessTypes::unit_torque_newtonMeter
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_TORQUE_FOOT_POUNDS,
    WirelessTypes::unit_torque_footPounds
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_TORQUE_INCH_POUNDS,
    WirelessTypes::unit_torque_inchPounds
);
MSCL_C_SAME(MSCL_CAL_COEF_UNIT_TIME_SECS, WirelessTypes::unit_time_secs);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_TIME_NANOSECS,
    WirelessTypes::unit_time_nanosecs
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_TIME_MICROSECS,
    WirelessTypes::unit_time_microsecs
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_TIME_MILLISECS,
    WirelessTypes::unit_time_millisecs
);
MSCL_C_SAME(MSCL_CAL_COEF_UNIT_TIME_MINUTES, WirelessTypes::unit_time_minutes);
MSCL_C_SAME(MSCL_CAL_COEF_UNIT_TIME_HOURS, WirelessTypes::unit_time_hours);
MSCL_C_SAME(MSCL_CAL_COEF_UNIT_TIME_DAYS, WirelessTypes::unit_time_days);
MSCL_C_SAME(MSCL_CAL_COEF_UNIT_TIME_WEEKS, WirelessTypes::unit_time_weeks);
MSCL_C_SAME(MSCL_CAL_COEF_UNIT_OTHER_VALUE, WirelessTypes::unit_other_value);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_MAGNETIC_FLUX_GAUSS,
    WirelessTypes::unit_magneticFlux_gauss
);
MSCL_C_SAME(MSCL_CAL_COEF_UNIT_OTHER_G_SEC, WirelessTypes::unit_other_gSec);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_OTHER_SECS_PER_SEC,
    WirelessTypes::unit_other_secsPerSec
);
MSCL_C_SAME(MSCL_CAL_COEF_UNIT_RSSI_D_BHZ, WirelessTypes::unit_rssi_dBHz);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_DENSITY_KG_PER_METER3,
    WirelessTypes::unit_density_kgPerMeter3
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_OTHER_UNITLESS,
    WirelessTypes::unit_other_unitless
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_VELOCITY_INCHES_PER_SEC,
    WirelessTypes::unit_velocity_inchesPerSec
);
MSCL_C_SAME(MSCL_CAL_COEF_UNIT_FORCE_KG, WirelessTypes::unit_force_kg);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_RAW_VOLTAGE_VOLTS,
    WirelessTypes::unit_rawVoltage_volts
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_RAW_VOLTAGE_MILLIVOLTS,
    WirelessTypes::unit_rawVoltage_millivolts
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_RAW_VOLTAGE_MICROVOLTS,
    WirelessTypes::unit_rawVoltage_microvolts
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_RESISTANCE_OHM,
    WirelessTypes::unit_resistance_ohm
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_RESISTANCE_MILLIOHM,
    WirelessTypes::unit_resistance_milliohm
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_RESISTANCE_KILOOHM,
    WirelessTypes::unit_resistance_kiloohm
);
MSCL_C_SAME(
    MSCL_CAL_COEF_UNIT_VELOCITY_MM_PER_SEC,
    WirelessTypes::unit_velocity_mmPerSec
);
MSCL_C_SAME(MSCL_CAL_COEF_UNIT_MASS_GRAMS, WirelessTypes::unit_mass_grams);
MSCL_C_SAME(MSCL_CAL_COEF_UNIT_MASS_TON, WirelessTypes::unit_mass_ton);
MSCL_C_SAME(MSCL_CAL_COEF_UNIT_MASS_TONNE, WirelessTypes::unit_mass_tonne);

MSCL_C_SAME(MSCL_CAL_COEF_EQUATION_TYPE_NONE, WirelessTypes::equation_none);
MSCL_C_SAME(
    MSCL_CAL_COEF_EQUATION_TYPE_STANDARD,
    WirelessTypes::equation_standard
);

MSCL_C_SAME(MSCL_SETTLING_TIME_4MS, WirelessTypes::settling_4ms);
MSCL_C_SAME(MSCL_SETTLING_TIME_8MS, WirelessTypes::settling_8ms);
MSCL_C_SAME(MSCL_SETTLING_TIME_16MS, WirelessTypes::settling_16ms);
MSCL_C_SAME(MSCL_SETTLING_TIME_32MS, WirelessTypes::settling_32ms);
MSCL_C_SAME(MSCL_SETTLING_TIME_40MS, WirelessTypes::settling_40ms);
MSCL_C_SAME(MSCL_SETTLING_TIME_48MS, WirelessTypes::settling_48ms);
MSCL_C_SAME(MSCL_SETTLING_TIME_60MS, WirelessTypes::settling_60ms);
MSCL_C_SAME(MSCL_SETTLING_TIME_101MS_90DB, WirelessTypes::settling_101ms_90db);
MSCL_C_SAME(MSCL_SETTLING_TIME_120MS_80DB, WirelessTypes::settling_120ms_80db);
MSCL_C_SAME(MSCL_SETTLING_TIME_120MS_65DB, WirelessTypes::settling_120ms_65db);
MSCL_C_SAME(MSCL_SETTLING_TIME_160MS_69DB, WirelessTypes::settling_160ms_69db);
MSCL_C_SAME(MSCL_SETTLING_TIME_200MS, WirelessTypes::settling_200ms);

MSCL_C_SAME(
    MSCL_TRANSDUCER_TYPE_THERMOCOUPLE,
    WirelessTypes::transducer_thermocouple
);
MSCL_C_SAME(MSCL_TRANSDUCER_TYPE_RTD, WirelessTypes::transducer_rtd);
MSCL_C_SAME(
    MSCL_TRANSDUCER_TYPE_THERMISTOR,
    WirelessTypes::transducer_thermistor
);

MSCL_C_SAME(
    MSCL_THERMOCOUPLE_TYPE_UNCOMPENSATED,
    WirelessTypes::tc_uncompensated
);
MSCL_C_SAME(MSCL_THERMOCOUPLE_TYPE_K, WirelessTypes::tc_K);
MSCL_C_SAME(MSCL_THERMOCOUPLE_TYPE_J, WirelessTypes::tc_J);
MSCL_C_SAME(MSCL_THERMOCOUPLE_TYPE_R, WirelessTypes::tc_R);
MSCL_C_SAME(MSCL_THERMOCOUPLE_TYPE_S, WirelessTypes::tc_S);
MSCL_C_SAME(MSCL_THERMOCOUPLE_TYPE_T, WirelessTypes::tc_T);
MSCL_C_SAME(MSCL_THERMOCOUPLE_TYPE_E, WirelessTypes::tc_E);
MSCL_C_SAME(MSCL_THERMOCOUPLE_TYPE_B, WirelessTypes::tc_B);
MSCL_C_SAME(MSCL_THERMOCOUPLE_TYPE_N, WirelessTypes::tc_N);
MSCL_C_SAME(
    MSCL_THERMOCOUPLE_TYPE_CUSTOM_POLYNOMIAL,
    WirelessTypes::tc_customPolynomial
);

MSCL_C_SAME(MSCL_RTD_TYPE_UNCOMPENSATED, WirelessTypes::rtd_uncompensated);
MSCL_C_SAME(MSCL_RTD_TYPE_PT10, WirelessTypes::rtd_pt10);
MSCL_C_SAME(MSCL_RTD_TYPE_PT50, WirelessTypes::rtd_pt50);
MSCL_C_SAME(MSCL_RTD_TYPE_PT100, WirelessTypes::rtd_pt100);
MSCL_C_SAME(MSCL_RTD_TYPE_PT200, WirelessTypes::rtd_pt200);
MSCL_C_SAME(MSCL_RTD_TYPE_PT500, WirelessTypes::rtd_pt500);
MSCL_C_SAME(MSCL_RTD_TYPE_PT1000, WirelessTypes::rtd_pt1000);

MSCL_C_SAME(MSCL_RTD_WIRE_TYPE_2WIRE, WirelessTypes::rtd_2wire);
MSCL_C_SAME(MSCL_RTD_WIRE_TYPE_3WIRE, WirelessTypes::rtd_3wire);
MSCL_C_SAME(MSCL_RTD_WIRE_TYPE_4WIRE, WirelessTypes::rtd_4wire);

MSCL_C_SAME(
    MSCL_THERMISTOR_TYPE_UNCOMPENSATED,
    WirelessTypes::thermistor_uncompensated
);
MSCL_C_SAME(
    MSCL_THERMISTOR_TYPE_44004_44033,
    WirelessTypes::thermistor_44004_44033
);
MSCL_C_SAME(
    MSCL_THERMISTOR_TYPE_44005_44030,
    WirelessTypes::thermistor_44005_44030
);
MSCL_C_SAME(
    MSCL_THERMISTOR_TYPE_44007_44034,
    WirelessTypes::thermistor_44007_44034
);
MSCL_C_SAME(
    MSCL_THERMISTOR_TYPE_44006_44031,
    WirelessTypes::thermistor_44006_44031
);
MSCL_C_SAME(
    MSCL_THERMISTOR_TYPE_44008_44032,
    WirelessTypes::thermistor_44008_44032
);
MSCL_C_SAME(MSCL_THERMISTOR_TYPE_YSI_400, WirelessTypes::thermistor_ysi_400);

MSCL_C_SAME(
    MSCL_STORAGE_LIMIT_MODE_OVERWRITE,
    WirelessTypes::storageLimit_overwrite
);
MSCL_C_SAME(MSCL_STORAGE_LIMIT_MODE_STOP, WirelessTypes::storageLimit_stop);

MSCL_C_SAME(MSCL_CHANNEL_TYPE_NONE, WirelessTypes::chType_none);
MSCL_C_SAME(
    MSCL_CHANNEL_TYPE_FULL_DIFFERENTIAL,
    WirelessTypes::chType_fullDifferential
);
MSCL_C_SAME(MSCL_CHANNEL_TYPE_SINGLE_ENDED, WirelessTypes::chType_singleEnded);
MSCL_C_SAME(MSCL_CHANNEL_TYPE_BATTERY, WirelessTypes::chType_battery);
MSCL_C_SAME(MSCL_CHANNEL_TYPE_TEMPERATURE, WirelessTypes::chType_temperature);
MSCL_C_SAME(MSCL_CHANNEL_TYPE_RH, WirelessTypes::chType_rh);
MSCL_C_SAME(MSCL_CHANNEL_TYPE_ACCELERATION, WirelessTypes::chType_acceleration);
MSCL_C_SAME(MSCL_CHANNEL_TYPE_DISPLACEMENT, WirelessTypes::chType_displacement);
MSCL_C_SAME(MSCL_CHANNEL_TYPE_VOLTAGE, WirelessTypes::chType_voltage);
MSCL_C_SAME(
    MSCL_CHANNEL_TYPE_DIFF_TEMPERATURE,
    WirelessTypes::chType_diffTemperature
);
MSCL_C_SAME(MSCL_CHANNEL_TYPE_DIGITAL, WirelessTypes::chType_digital);
MSCL_C_SAME(MSCL_CHANNEL_TYPE_TILT, WirelessTypes::chType_tilt);

MSCL_C_SAME(
    MSCL_CHANNEL_GROUP_SETTING_INPUT_RANGE,
    WirelessTypes::chSetting_inputRange
);
MSCL_C_SAME(
    MSCL_CHANNEL_GROUP_SETTING_FILTER_SETTLING_TIME,
    WirelessTypes::chSetting_filterSettlingTime
);
MSCL_C_SAME(
    MSCL_CHANNEL_GROUP_SETTING_THERMOCOUPLE_TYPE,
    WirelessTypes::chSetting_thermocoupleType
);
MSCL_C_SAME(
    MSCL_CHANNEL_GROUP_SETTING_LINEAR_EQUATION,
    WirelessTypes::chSetting_linearEquation
);
MSCL_C_SAME(MSCL_CHANNEL_GROUP_SETTING_UNIT, WirelessTypes::chSetting_unit);
MSCL_C_SAME(
    MSCL_CHANNEL_GROUP_SETTING_EQUATION_TYPE,
    WirelessTypes::chSetting_equationType
);
MSCL_C_SAME(
    MSCL_CHANNEL_GROUP_SETTING_HARDWARE_OFFSET,
    WirelessTypes::chSetting_hardwareOffset
);
MSCL_C_SAME(
    MSCL_CHANNEL_GROUP_SETTING_AUTO_BALANCE,
    WirelessTypes::chSetting_autoBalance
);
MSCL_C_SAME(
    MSCL_CHANNEL_GROUP_SETTING_GAUGE_FACTOR,
    WirelessTypes::chSetting_gaugeFactor
);
MSCL_C_SAME(
    MSCL_CHANNEL_GROUP_SETTING_ANTI_ALIASING_FILTER,
    WirelessTypes::chSetting_antiAliasingFilter
);
MSCL_C_SAME(
    MSCL_CHANNEL_GROUP_SETTING_LEGACY_SHUNT_CAL,
    WirelessTypes::chSetting_legacyShuntCal
);
MSCL_C_SAME(
    MSCL_CHANNEL_GROUP_SETTING_AUTO_SHUNT_CAL,
    WirelessTypes::chSetting_autoShuntCal
);
MSCL_C_SAME(
    MSCL_CHANNEL_GROUP_SETTING_LOW_PASS_FILTER,
    WirelessTypes::chSetting_lowPassFilter
);
MSCL_C_SAME(
    MSCL_CHANNEL_GROUP_SETTING_HIGH_PASS_FILTER,
    WirelessTypes::chSetting_highPassFilter
);
MSCL_C_SAME(
    MSCL_CHANNEL_GROUP_SETTING_TEMP_SENSOR_OPTIONS,
    WirelessTypes::chSetting_tempSensorOptions
);
MSCL_C_SAME(
    MSCL_CHANNEL_GROUP_SETTING_DEBOUNCE_FILTER,
    WirelessTypes::chSetting_debounceFilter
);
MSCL_C_SAME(
    MSCL_CHANNEL_GROUP_SETTING_PULL_UP_RESISTOR,
    WirelessTypes::chSetting_pullUpResistor
);
MSCL_C_SAME(
    MSCL_CHANNEL_GROUP_SETTING_FACTORY_LINEAR_EQ,
    WirelessTypes::chSetting_factoryLinearEq
);
MSCL_C_SAME(
    MSCL_CHANNEL_GROUP_SETTING_FACTORY_UNIT,
    WirelessTypes::chSetting_factoryUnit
);
MSCL_C_SAME(
    MSCL_CHANNEL_GROUP_SETTING_FACTORY_EQ_TYPE,
    WirelessTypes::chSetting_factoryEqType
);

MSCL_C_SAME(
    MSCL_FATIGUE_MODE_ANGLE_STRAIN,
    WirelessTypes::fatigueMode_angleStrain
);
MSCL_C_SAME(
    MSCL_FATIGUE_MODE_DISTRIBUTED_ANGLE,
    WirelessTypes::fatigueMode_distributedAngle
);
MSCL_C_SAME(
    MSCL_FATIGUE_MODE_RAW_GAUGE_STRAIN,
    WirelessTypes::fatigueMode_rawGaugeStrain
);

MSCL_C_SAME(
    MSCL_EVENT_TRIGGER_TYPE_CEILING,
    WirelessTypes::eventTrigger_ceiling
);
MSCL_C_SAME(MSCL_EVENT_TRIGGER_TYPE_FLOOR, WirelessTypes::eventTrigger_floor);

MSCL_C_SAME(
    MSCL_AUTO_BALANCE_ERROR_FLAG_SUCCESS,
    WirelessTypes::autobalance_success
);
MSCL_C_SAME(
    MSCL_AUTO_BALANCE_ERROR_FLAG_MAYBE_INVALID,
    WirelessTypes::autobalance_maybeInvalid
);
MSCL_C_SAME(
    MSCL_AUTO_BALANCE_ERROR_FLAG_NOT_SUPPORTED_BY_NODE,
    WirelessTypes::autobalance_notSupportedByNode
);
MSCL_C_SAME(
    MSCL_AUTO_BALANCE_ERROR_FLAG_NOT_SUPPORTED_BY_CH,
    WirelessTypes::autobalance_notSupportedByCh
);
MSCL_C_SAME(
    MSCL_AUTO_BALANCE_ERROR_FLAG_TARGET_OUT_OF_RANGE,
    WirelessTypes::autobalance_targetOutOfRange
);
MSCL_C_SAME(
    MSCL_AUTO_BALANCE_ERROR_FLAG_FAILED,
    WirelessTypes::autobalance_failed
);
MSCL_C_SAME(
    MSCL_AUTO_BALANCE_ERROR_FLAG_LEGACY_NONE,
    WirelessTypes::autobalance_legacyNone
);
MSCL_C_SAME(
    MSCL_AUTO_BALANCE_ERROR_FLAG_NOT_COMPLETE,
    WirelessTypes::autobalance_notComplete
);

MSCL_C_SAME(
    MSCL_AUTO_CAL_COMPLETION_FLAG_SUCCESS,
    WirelessTypes::autocal_success
);
MSCL_C_SAME(
    MSCL_AUTO_CAL_COMPLETION_FLAG_MAYBE_INVALID_APPLIED,
    WirelessTypes::autocal_maybeInvalid_applied
);
MSCL_C_SAME(
    MSCL_AUTO_CAL_COMPLETION_FLAG_MAYBE_INVALID_NOT_APPLIED,
    WirelessTypes::autocal_maybeInvalid_notApplied
);
MSCL_C_SAME(
    MSCL_AUTO_CAL_COMPLETION_FLAG_NOT_COMPLETE,
    WirelessTypes::autocal_notComplete
);

MSCL_C_SAME(MSCL_AUTO_CAL_ERROR_FLAG_NONE, WirelessTypes::autocalError_none);
MSCL_C_SAME(
    MSCL_AUTO_CAL_ERROR_FLAG_SENSOR_DETACHED,
    WirelessTypes::autocalError_sensorDetached
);
MSCL_C_SAME(
    MSCL_AUTO_CAL_ERROR_FLAG_SENSOR_SHORTED,
    WirelessTypes::autocalError_sensorShorted
);
MSCL_C_SAME(
    MSCL_AUTO_CAL_ERROR_FLAG_UNSUPPORTED_CHANNEL,
    WirelessTypes::autocalError_unsupportedChannel
);
MSCL_C_SAME(
    MSCL_AUTO_CAL_ERROR_FLAG_BASE_HIGH_RAIL,
    WirelessTypes::autocalError_baseHighRail
);
MSCL_C_SAME(
    MSCL_AUTO_CAL_ERROR_FLAG_BASE_LOW_RAIL,
    WirelessTypes::autocalError_baseLowRail
);
MSCL_C_SAME(
    MSCL_AUTO_CAL_ERROR_FLAG_SHUNT_HIGH_RAIL,
    WirelessTypes::autocalError_shuntHighRail
);
MSCL_C_SAME(
    MSCL_AUTO_CAL_ERROR_FLAG_SHUNT_LOW_RAIL,
    WirelessTypes::autocalError_shuntLowRail
);
MSCL_C_SAME(MSCL_AUTO_CAL_ERROR_FLAG_RAMP, WirelessTypes::autocalError_ramp);
MSCL_C_SAME(
    MSCL_AUTO_CAL_ERROR_FLAG_NO_SHUNT,
    WirelessTypes::autocalError_noShunt
);
MSCL_C_SAME(
    MSCL_AUTO_CAL_ERROR_FLAG_TIMEOUT,
    WirelessTypes::autocalError_timeout
);

MSCL_C_SAME(
    MSCL_NODE_MODEL_V_LINK_LEGACY,
    mscl::WirelessModels::node_vLink_legacy
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_CF_BEARING_TEMP_LINK,
    mscl::WirelessModels::node_cfBearingTempLink
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_ENV_LINK_PRO,
    mscl::WirelessModels::node_envLink_pro
);
MSCL_C_SAME(MSCL_NODE_MODEL_G_LINK_2G, mscl::WirelessModels::node_gLink_2g);
MSCL_C_SAME(MSCL_NODE_MODEL_G_LINK_10G, mscl::WirelessModels::node_gLink_10g);
MSCL_C_SAME(
    MSCL_NODE_MODEL_G_LINK_II_CUST_IN,
    mscl::WirelessModels::node_gLinkII_cust_in
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_G_LINK_II_2G_IN,
    mscl::WirelessModels::node_gLinkII_2g_in
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_G_LINK_II_10G_IN,
    mscl::WirelessModels::node_gLinkII_10g_in
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_G_LINK_II_CUST_EX,
    mscl::WirelessModels::node_gLinkII_cust_ex
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_G_LINK_II_2G_EX,
    mscl::WirelessModels::node_gLinkII_2g_ex
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_G_LINK_II_10G_EX,
    mscl::WirelessModels::node_gLinkII_10g_ex
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_G_LINK_RGD_10G,
    mscl::WirelessModels::node_gLink_rgd_10g
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_G_LINK_200_8G,
    mscl::WirelessModels::node_gLink_200_8g
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_G_LINK_200_40G,
    mscl::WirelessModels::node_gLink_200_40g
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_G_LINK_200_8G_OEM,
    mscl::WirelessModels::node_gLink_200_8g_oem
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_G_LINK_200_40G_OEM,
    mscl::WirelessModels::node_gLink_200_40g_oem
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_G_LINK_200_8G_OEM_MMCX,
    mscl::WirelessModels::node_gLink_200_8g_oem_mmcx
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_G_LINK_200_40G_OEM_MMCX,
    mscl::WirelessModels::node_gLink_200_40g_oem_mmcx
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_G_LINK_200_8G_OEM_U_FL,
    mscl::WirelessModels::node_gLink_200_8g_oem_u_fl
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_G_LINK_200_40G_OEM_U_FL,
    mscl::WirelessModels::node_gLink_200_40g_oem_u_fl
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_G_LINK_200_R,
    mscl::WirelessModels::node_gLink_200_r
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SG_LINK_OEM_S,
    mscl::WirelessModels::node_sgLink_oem_S
);
MSCL_C_SAME(MSCL_NODE_MODEL_SG_LINK, mscl::WirelessModels::node_sgLink);
MSCL_C_SAME(MSCL_NODE_MODEL_SG_LINK200, mscl::WirelessModels::node_sgLink200);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SG_LINK200_HBRIDGE_1K,
    mscl::WirelessModels::node_sgLink200_hbridge_1K
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SG_LINK200_HBRIDGE_350,
    mscl::WirelessModels::node_sgLink200_hbridge_350
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SG_LINK200_HBRIDGE_120,
    mscl::WirelessModels::node_sgLink200_hbridge_120
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SG_LINK200_QBRIDGE_1K,
    mscl::WirelessModels::node_sgLink200_qbridge_1K
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SG_LINK200_QBRIDGE_350,
    mscl::WirelessModels::node_sgLink200_qbridge_350
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SG_LINK200_QBRIDGE_120,
    mscl::WirelessModels::node_sgLink200_qbridge_120
);
MSCL_C_SAME(MSCL_NODE_MODEL_SG_LINK_OEM, mscl::WirelessModels::node_sgLink_oem);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SG_LINK_MICRO,
    mscl::WirelessModels::node_sgLink_micro
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SG_LINK200_OEM,
    mscl::WirelessModels::node_sgLink200_oem
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SG_LINK200_OEM_UFL,
    mscl::WirelessModels::node_sgLink200_oem_ufl
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SG_LINK200_OEM_HBRIDGE_1K,
    mscl::WirelessModels::node_sgLink200_oem_hbridge_1K
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SG_LINK200_OEM_HBRIDGE_1K_UFL,
    mscl::WirelessModels::node_sgLink200_oem_hbridge_1K_ufl
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SG_LINK200_OEM_HBRIDGE_120,
    mscl::WirelessModels::node_sgLink200_oem_hbridge_120
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SG_LINK200_OEM_HBRIDGE_120_UFL,
    mscl::WirelessModels::node_sgLink200_oem_hbridge_120_ufl
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SG_LINK200_OEM_HBRIDGE_350,
    mscl::WirelessModels::node_sgLink200_oem_hbridge_350
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SG_LINK200_OEM_HBRIDGE_350_UFL,
    mscl::WirelessModels::node_sgLink200_oem_hbridge_350_ufl
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SG_LINK200_OEM_QBRIDGE_1K,
    mscl::WirelessModels::node_sgLink200_oem_qbridge_1K
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SG_LINK200_OEM_QBRIDGE_1K_UFL,
    mscl::WirelessModels::node_sgLink200_oem_qbridge_1K_ufl
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SG_LINK200_OEM_QBRIDGE_120,
    mscl::WirelessModels::node_sgLink200_oem_qbridge_120
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SG_LINK200_OEM_QBRIDGE_120_UFL,
    mscl::WirelessModels::node_sgLink200_oem_qbridge_120_ufl
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SG_LINK200_OEM_QBRIDGE_350,
    mscl::WirelessModels::node_sgLink200_oem_qbridge_350
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SG_LINK200_OEM_QBRIDGE_350_UFL,
    mscl::WirelessModels::node_sgLink200_oem_qbridge_350_ufl
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SG_LINK200_OEM_128HZ,
    mscl::WirelessModels::node_sgLink200_oem_128hz
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SG_LINK200_OEM_256HZ,
    mscl::WirelessModels::node_sgLink200_oem_256hz
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SG_LINK200_OEM_QBRIDGE_350_128HZ,
    mscl::WirelessModels::node_sgLink200_oem_qbridge_350_128hz
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SG_LINK200_OEM_QBRIDGE_350_256HZ,
    mscl::WirelessModels::node_sgLink200_oem_qbridge_350_256hz
);
MSCL_C_SAME(MSCL_NODE_MODEL_SG_LINK_RGD, mscl::WirelessModels::node_sgLink_rgd);
MSCL_C_SAME(MSCL_NODE_MODEL_SHM_LINK, mscl::WirelessModels::node_shmLink);
MSCL_C_SAME(MSCL_NODE_MODEL_TC_LINK_1CH, mscl::WirelessModels::node_tcLink_1ch);
MSCL_C_SAME(MSCL_NODE_MODEL_TC_LINK_6CH, mscl::WirelessModels::node_tcLink_6ch);
MSCL_C_SAME(MSCL_NODE_MODEL_TC_LINK_3CH, mscl::WirelessModels::node_tcLink_3ch);
MSCL_C_SAME(
    MSCL_NODE_MODEL_TC_LINK_6CH_IP67,
    mscl::WirelessModels::node_tcLink_6ch_ip67
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_TC_LINK200_OEM,
    mscl::WirelessModels::node_tcLink200_oem
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_TC_LINK200_OEM_UFL,
    mscl::WirelessModels::node_tcLink200_oem_ufl
);
MSCL_C_SAME(MSCL_NODE_MODEL_TC_LINK200, mscl::WirelessModels::node_tcLink200);
MSCL_C_SAME(MSCL_NODE_MODEL_RTD_LINK200, mscl::WirelessModels::node_rtdLink200);
MSCL_C_SAME(
    MSCL_NODE_MODEL_TC_LINK_6CH_IP67_RHT,
    mscl::WirelessModels::node_tcLink_6ch_ip67_rht
);
MSCL_C_SAME(MSCL_NODE_MODEL_V_LINK, mscl::WirelessModels::node_vLink);
MSCL_C_SAME(MSCL_NODE_MODEL_V_LINK200, mscl::WirelessModels::node_vLink200);
MSCL_C_SAME(
    MSCL_NODE_MODEL_V_LINK200_QBRIDGE_1K,
    mscl::WirelessModels::node_vLink200_qbridge_1K
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_V_LINK200_QBRIDGE_120,
    mscl::WirelessModels::node_vLink200_qbridge_120
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_V_LINK200_QBRIDGE_350,
    mscl::WirelessModels::node_vLink200_qbridge_350
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_V_LINK200_HBRIDGE_1K,
    mscl::WirelessModels::node_vLink200_hbridge_1K
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_V_LINK200_HBRIDGE_120,
    mscl::WirelessModels::node_vLink200_hbridge_120
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_V_LINK200_HBRIDGE_350,
    mscl::WirelessModels::node_vLink200_hbridge_350
);
MSCL_C_SAME(MSCL_NODE_MODEL_IEPE_LINK, mscl::WirelessModels::node_iepeLink);
MSCL_C_SAME(MSCL_NODE_MODEL_DVRT_LINK, mscl::WirelessModels::node_dvrtLink);
MSCL_C_SAME(
    MSCL_NODE_MODEL_ENV_LINK_MINI,
    mscl::WirelessModels::node_envLink_mini
);
MSCL_C_SAME(MSCL_NODE_MODEL_WATT_LINK, mscl::WirelessModels::node_wattLink);
MSCL_C_SAME(
    MSCL_NODE_MODEL_WATT_LINK_3Y208,
    mscl::WirelessModels::node_wattLink_3Y208
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_WATT_LINK_3D240,
    mscl::WirelessModels::node_wattLink_3D240
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_WATT_LINK_3Y400,
    mscl::WirelessModels::node_wattLink_3Y400
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_WATT_LINK_3D400,
    mscl::WirelessModels::node_wattLink_3D400
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_WATT_LINK_3Y480,
    mscl::WirelessModels::node_wattLink_3Y480
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_WATT_LINK_3D480,
    mscl::WirelessModels::node_wattLink_3D480
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_WATT_LINK_3Y600,
    mscl::WirelessModels::node_wattLink_3Y600
);
MSCL_C_SAME(MSCL_NODE_MODEL_PT_LINK200, mscl::WirelessModels::node_ptLink200);
MSCL_C_SAME(MSCL_NODE_MODEL_RTD_LINK, mscl::WirelessModels::node_rtdLink);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SHM_LINK2_CUST1_OLD_NUMBER,
    mscl::WirelessModels::node_shmLink2_cust1_oldNumber
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SHM_LINK2_CUST1,
    mscl::WirelessModels::node_shmLink2_cust1
);
MSCL_C_SAME(MSCL_NODE_MODEL_SHM_LINK200, mscl::WirelessModels::node_shmLink200);
MSCL_C_SAME(MSCL_NODE_MODEL_SHM_LINK201, mscl::WirelessModels::node_shmLink201);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SHM_LINK201_QBRIDGE_1K,
    mscl::WirelessModels::node_shmLink201_qbridge_1K
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SHM_LINK201_QBRIDGE_348,
    mscl::WirelessModels::node_shmLink201_qbridge_348
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SHM_LINK201_HBRIDGE_1K,
    mscl::WirelessModels::node_shmLink201_hbridge_1K
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SHM_LINK201_HBRIDGE_348,
    mscl::WirelessModels::node_shmLink201_hbridge_348
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SHM_LINK201_FULLBRIDGE,
    mscl::WirelessModels::node_shmLink201_fullbridge
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SHM_LINK210_FULLBRIDGE,
    mscl::WirelessModels::node_shmLink210_fullbridge
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SHM_LINK210_QBRIDGE_3K,
    mscl::WirelessModels::node_shmLink210_qbridge_3K
);
MSCL_C_SAME(MSCL_NODE_MODEL_TORQUE_LINK, mscl::WirelessModels::node_torqueLink);
MSCL_C_SAME(
    MSCL_NODE_MODEL_TORQUE_LINK200_3CH,
    mscl::WirelessModels::node_torqueLink200_3ch
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_TORQUE_LINK200,
    mscl::WirelessModels::node_torqueLink200
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_TORQUE_LINK200_3CH_S,
    mscl::WirelessModels::node_torqueLink200_3ch_s
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SG_LINK_HERM,
    mscl::WirelessModels::node_sgLink_herm
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SG_LINK_HERM_2600,
    mscl::WirelessModels::node_sgLink_herm_2600
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SG_LINK_HERM_2700,
    mscl::WirelessModels::node_sgLink_herm_2700
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SG_LINK_HERM_2800,
    mscl::WirelessModels::node_sgLink_herm_2800
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_SG_LINK_HERM_2900,
    mscl::WirelessModels::node_sgLink_herm_2900
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_WIRELESS_IMPACT_SENSOR,
    mscl::WirelessModels::node_wirelessImpactSensor
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_G_LINK_200_40G_S,
    mscl::WirelessModels::node_gLink_200_40g_s
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_G_LINK_200_P,
    mscl::WirelessModels::node_gLink_200_p
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_G_LINK_200_PX8,
    mscl::WirelessModels::node_gLink_200_px8
);
MSCL_C_SAME(
    MSCL_NODE_MODEL_G_LINK_200_PX40,
    mscl::WirelessModels::node_gLink_200_px40
);

MSCL_C_SAME(MSCL_CHANNEL_ID_UNKNOWN, mscl::WirelessChannel::channel_unknown);
MSCL_C_SAME(MSCL_CHANNEL_ID_1, mscl::WirelessChannel::channel_1);
MSCL_C_SAME(MSCL_CHANNEL_ID_2, mscl::WirelessChannel::channel_2);
MSCL_C_SAME(MSCL_CHANNEL_ID_3, mscl::WirelessChannel::channel_3);
MSCL_C_SAME(MSCL_CHANNEL_ID_4, mscl::WirelessChannel::channel_4);
MSCL_C_SAME(MSCL_CHANNEL_ID_5, mscl::WirelessChannel::channel_5);
MSCL_C_SAME(MSCL_CHANNEL_ID_6, mscl::WirelessChannel::channel_6);
MSCL_C_SAME(MSCL_CHANNEL_ID_7, mscl::WirelessChannel::channel_7);
MSCL_C_SAME(MSCL_CHANNEL_ID_8, mscl::WirelessChannel::channel_8);
MSCL_C_SAME(MSCL_CHANNEL_ID_9, mscl::WirelessChannel::channel_9);
MSCL_C_SAME(MSCL_CHANNEL_ID_10, mscl::WirelessChannel::channel_10);
MSCL_C_SAME(MSCL_CHANNEL_ID_11, mscl::WirelessChannel::channel_11);
MSCL_C_SAME(MSCL_CHANNEL_ID_12, mscl::WirelessChannel::channel_12);
MSCL_C_SAME(MSCL_CHANNEL_ID_13, mscl::WirelessChannel::channel_13);
MSCL_C_SAME(MSCL_CHANNEL_ID_14, mscl::WirelessChannel::channel_14);
MSCL_C_SAME(MSCL_CHANNEL_ID_15, mscl::WirelessChannel::channel_15);
MSCL_C_SAME(MSCL_CHANNEL_ID_16, mscl::WirelessChannel::channel_16);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIGITAL_1,
    mscl::WirelessChannel::channel_digital_1
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIGITAL_2,
    mscl::WirelessChannel::channel_digital_2
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIGITAL_3,
    mscl::WirelessChannel::channel_digital_3
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIGITAL_4,
    mscl::WirelessChannel::channel_digital_4
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIGITAL_5,
    mscl::WirelessChannel::channel_digital_5
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIGITAL_6,
    mscl::WirelessChannel::channel_digital_6
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIGITAL_7,
    mscl::WirelessChannel::channel_digital_7
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIGITAL_8,
    mscl::WirelessChannel::channel_digital_8
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIGITAL_9,
    mscl::WirelessChannel::channel_digital_9
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIGITAL_10,
    mscl::WirelessChannel::channel_digital_10
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIGITAL_11,
    mscl::WirelessChannel::channel_digital_11
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIGITAL_12,
    mscl::WirelessChannel::channel_digital_12
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIGITAL_13,
    mscl::WirelessChannel::channel_digital_13
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIGITAL_14,
    mscl::WirelessChannel::channel_digital_14
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIGITAL_15,
    mscl::WirelessChannel::channel_digital_15
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIGITAL_16,
    mscl::WirelessChannel::channel_digital_16
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_STRUCTURAL_HEALTH,
    mscl::WirelessChannel::channel_structuralHealth
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_BASE_MAG1_X,
    mscl::WirelessChannel::channel_hcl_rawBase_mag1_x
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_BASE_MAG1_Y,
    mscl::WirelessChannel::channel_hcl_rawBase_mag1_y
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_BASE_MAG1_Z,
    mscl::WirelessChannel::channel_hcl_rawBase_mag1_z
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_BASE_MAG2_X,
    mscl::WirelessChannel::channel_hcl_rawBase_mag2_x
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_BASE_MAG2_Y,
    mscl::WirelessChannel::channel_hcl_rawBase_mag2_y
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_BASE_MAG2_Z,
    mscl::WirelessChannel::channel_hcl_rawBase_mag2_z
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_BASE_MAG3_X,
    mscl::WirelessChannel::channel_hcl_rawBase_mag3_x
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_BASE_MAG3_Y,
    mscl::WirelessChannel::channel_hcl_rawBase_mag3_y
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_BASE_MAG3_Z,
    mscl::WirelessChannel::channel_hcl_rawBase_mag3_z
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_BASE_MAG4_X,
    mscl::WirelessChannel::channel_hcl_rawBase_mag4_x
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_BASE_MAG4_Y,
    mscl::WirelessChannel::channel_hcl_rawBase_mag4_y
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_BASE_MAG4_Z,
    mscl::WirelessChannel::channel_hcl_rawBase_mag4_z
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_BASE_MAG5_X,
    mscl::WirelessChannel::channel_hcl_rawBase_mag5_x
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_BASE_MAG5_Y,
    mscl::WirelessChannel::channel_hcl_rawBase_mag5_y
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_BASE_MAG5_Z,
    mscl::WirelessChannel::channel_hcl_rawBase_mag5_z
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_BASE_MAG6_X,
    mscl::WirelessChannel::channel_hcl_rawBase_mag6_x
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_BASE_MAG6_Y,
    mscl::WirelessChannel::channel_hcl_rawBase_mag6_y
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_BASE_MAG6_Z,
    mscl::WirelessChannel::channel_hcl_rawBase_mag6_z
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_BASE_MAG7_X,
    mscl::WirelessChannel::channel_hcl_rawBase_mag7_x
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_BASE_MAG7_Y,
    mscl::WirelessChannel::channel_hcl_rawBase_mag7_y
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_BASE_MAG7_Z,
    mscl::WirelessChannel::channel_hcl_rawBase_mag7_z
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_BASE_MAG8_X,
    mscl::WirelessChannel::channel_hcl_rawBase_mag8_x
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_BASE_MAG8_Y,
    mscl::WirelessChannel::channel_hcl_rawBase_mag8_y
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_BASE_MAG8_Z,
    mscl::WirelessChannel::channel_hcl_rawBase_mag8_z
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_BASE_GYRO_X,
    mscl::WirelessChannel::channel_hcl_rawBase_gyro_x
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_BASE_GYRO_Y,
    mscl::WirelessChannel::channel_hcl_rawBase_gyro_y
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_BASE_GYRO_Z,
    mscl::WirelessChannel::channel_hcl_rawBase_gyro_z
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_ERROR_CODE,
    mscl::WirelessChannel::channel_error_code
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_BL30,
    mscl::WirelessChannel::channel_hcl_rawStrain_BL30
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_BL120,
    mscl::WirelessChannel::channel_hcl_rawStrain_BL120
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_A60,
    mscl::WirelessChannel::channel_hcl_rawStrain_A60
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_A150,
    mscl::WirelessChannel::channel_hcl_rawStrain_A150
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_AL30,
    mscl::WirelessChannel::channel_hcl_rawStrain_AL30
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_AL120,
    mscl::WirelessChannel::channel_hcl_rawStrain_AL120
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_BR60,
    mscl::WirelessChannel::channel_hcl_rawStrain_BR60
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_BR150,
    mscl::WirelessChannel::channel_hcl_rawStrain_BR150
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_B30,
    mscl::WirelessChannel::channel_hcl_rawStrain_B30
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_T120,
    mscl::WirelessChannel::channel_hcl_rawStrain_T120
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_AR60,
    mscl::WirelessChannel::channel_hcl_rawStrain_AR60
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_AR150,
    mscl::WirelessChannel::channel_hcl_rawStrain_AR150
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_A30,
    mscl::WirelessChannel::channel_hcl_rawStrain_A30
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_A120,
    mscl::WirelessChannel::channel_hcl_rawStrain_A120
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_BL90,
    mscl::WirelessChannel::channel_hcl_rawStrain_BL90
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_BL180,
    mscl::WirelessChannel::channel_hcl_rawStrain_BL180
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_BR30,
    mscl::WirelessChannel::channel_hcl_rawStrain_BR30
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_BR120,
    mscl::WirelessChannel::channel_hcl_rawStrain_BR120
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_AL90,
    mscl::WirelessChannel::channel_hcl_rawStrain_AL90
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_AL180,
    mscl::WirelessChannel::channel_hcl_rawStrain_AL180
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_AR30,
    mscl::WirelessChannel::channel_hcl_rawStrain_AR30
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_AR120,
    mscl::WirelessChannel::channel_hcl_rawStrain_AR120
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_B90,
    mscl::WirelessChannel::channel_hcl_rawStrain_B90
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_T0,
    mscl::WirelessChannel::channel_hcl_rawStrain_T0
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_BL60,
    mscl::WirelessChannel::channel_hcl_rawStrain_BL60
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_BL150,
    mscl::WirelessChannel::channel_hcl_rawStrain_BL150
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_A90,
    mscl::WirelessChannel::channel_hcl_rawStrain_A90
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_A0,
    mscl::WirelessChannel::channel_hcl_rawStrain_A0
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_AL60,
    mscl::WirelessChannel::channel_hcl_rawStrain_AL60
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_AL150,
    mscl::WirelessChannel::channel_hcl_rawStrain_AL150
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_BR90,
    mscl::WirelessChannel::channel_hcl_rawStrain_BR90
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_BR0,
    mscl::WirelessChannel::channel_hcl_rawStrain_BR0
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_T60,
    mscl::WirelessChannel::channel_hcl_rawStrain_T60
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_B150,
    mscl::WirelessChannel::channel_hcl_rawStrain_B150
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_AR90,
    mscl::WirelessChannel::channel_hcl_rawStrain_AR90
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_STRAIN_AR0,
    mscl::WirelessChannel::channel_hcl_rawStrain_AR0
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_INERTIAL_ACCEL1,
    mscl::WirelessChannel::channel_hcl_rawInertial_accel1
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_INERTIAL_ACCEL2,
    mscl::WirelessChannel::channel_hcl_rawInertial_accel2
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_INERTIAL_ACCEL3,
    mscl::WirelessChannel::channel_hcl_rawInertial_accel3
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_INERTIAL_ACCEL4,
    mscl::WirelessChannel::channel_hcl_rawInertial_accel4
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_INERTIAL_ACCEL5,
    mscl::WirelessChannel::channel_hcl_rawInertial_accel5
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_INERTIAL_ACCEL6,
    mscl::WirelessChannel::channel_hcl_rawInertial_accel6
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_INERTIAL_ACCEL7,
    mscl::WirelessChannel::channel_hcl_rawInertial_accel7
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_INERTIAL_ACCEL8,
    mscl::WirelessChannel::channel_hcl_rawInertial_accel8
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_INERTIAL_GYRO_X,
    mscl::WirelessChannel::channel_hcl_rawInertial_gyroX
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_INERTIAL_GYRO_Y,
    mscl::WirelessChannel::channel_hcl_rawInertial_gyroY
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_RAW_INERTIAL_GYRO_Z,
    mscl::WirelessChannel::channel_hcl_rawInertial_gyroZ
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_RAW_ANGLE_STRAIN,
    mscl::WirelessChannel::channel_rawAngleStrain
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_BEACON_ECHO,
    mscl::WirelessChannel::channel_beaconEcho
);
MSCL_C_SAME(MSCL_CHANNEL_ID_RF_SWEEP, mscl::WirelessChannel::channel_rfSweep);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIAG_STATE,
    mscl::WirelessChannel::channel_diag_state
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIAG_RUNTIME_IDLE,
    mscl::WirelessChannel::channel_diag_runtime_idle
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIAG_RUNTIME_SLEEP,
    mscl::WirelessChannel::channel_diag_runtime_sleep
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIAG_RUNTIME_ACTIVE_RUN,
    mscl::WirelessChannel::channel_diag_runtime_activeRun
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIAG_RUNTIME_INACTIVE_RUN,
    mscl::WirelessChannel::channel_diag_runtime_inactiveRun
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIAG_RESET_COUNTER,
    mscl::WirelessChannel::channel_diag_resetCounter
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIAG_LOW_BATTERY_FLAG,
    mscl::WirelessChannel::channel_diag_lowBatteryFlag
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIAG_SWEEP_INDEX,
    mscl::WirelessChannel::channel_diag_sweepIndex
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIAG_BAD_SWEEP_COUNT,
    mscl::WirelessChannel::channel_diag_badSweepCount
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIAG_TOTAL_TX,
    mscl::WirelessChannel::channel_diag_totalTx
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIAG_TOTAL_RE_TX,
    mscl::WirelessChannel::channel_diag_totalReTx
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIAG_TOTAL_DROPPED_PACKETS,
    mscl::WirelessChannel::channel_diag_totalDroppedPackets
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIAG_BUILT_IN_TEST_RESULT,
    mscl::WirelessChannel::channel_diag_builtInTestResult
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIAG_EVENT_INDEX,
    mscl::WirelessChannel::channel_diag_eventIndex
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_AXIAL_LOAD_X,
    mscl::WirelessChannel::channel_hcl_axialLoadX
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_AXIAL_LOAD_Y,
    mscl::WirelessChannel::channel_hcl_axialLoadY
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_AXIAL_LOAD_Z,
    mscl::WirelessChannel::channel_hcl_axialLoadZ
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_BENDING_MOMENT_FLAP,
    mscl::WirelessChannel::channel_hcl_bendingMomentFlap
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_BENDING_MOMENT_LAG,
    mscl::WirelessChannel::channel_hcl_bendingMomentLag
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_BENDING_MOMENT_PITCH,
    mscl::WirelessChannel::channel_hcl_bendingMomentPitch
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_MOTION_FLAP_MAG,
    mscl::WirelessChannel::channel_hcl_motionFlap_mag
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_MOTION_LAG_MAG,
    mscl::WirelessChannel::channel_hcl_motionLag_mag
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_MOTION_PITCH_MAG,
    mscl::WirelessChannel::channel_hcl_motionPitch_mag
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_MOTION_FLAP_INERTIAL,
    mscl::WirelessChannel::channel_hcl_motionFlap_inertial
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_MOTION_LAG_INERTIAL,
    mscl::WirelessChannel::channel_hcl_motionLag_inertial
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_MOTION_PITCH_INERTIAL,
    mscl::WirelessChannel::channel_hcl_motionPitch_inertial
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_COCKING_STIFFNESS_MAG,
    mscl::WirelessChannel::channel_hcl_cockingStiffness_mag
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_COCKING_STIFFNESS_INERTIAL,
    mscl::WirelessChannel::channel_hcl_cockingStiffness_inertial
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_HCL_TEMPERATURE,
    mscl::WirelessChannel::channel_hcl_temperature
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIAG_EXTERNAL_POWER,
    mscl::WirelessChannel::channel_diag_externalPower
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIAG_INTERNAL_TEMP,
    mscl::WirelessChannel::channel_diag_internalTemp
);
MSCL_C_SAME(MSCL_CHANNEL_ID_1_RMS, mscl::WirelessChannel::channel_1_rms);
MSCL_C_SAME(MSCL_CHANNEL_ID_2_RMS, mscl::WirelessChannel::channel_2_rms);
MSCL_C_SAME(MSCL_CHANNEL_ID_3_RMS, mscl::WirelessChannel::channel_3_rms);
MSCL_C_SAME(MSCL_CHANNEL_ID_4_RMS, mscl::WirelessChannel::channel_4_rms);
MSCL_C_SAME(MSCL_CHANNEL_ID_5_RMS, mscl::WirelessChannel::channel_5_rms);
MSCL_C_SAME(MSCL_CHANNEL_ID_6_RMS, mscl::WirelessChannel::channel_6_rms);
MSCL_C_SAME(MSCL_CHANNEL_ID_7_RMS, mscl::WirelessChannel::channel_7_rms);
MSCL_C_SAME(MSCL_CHANNEL_ID_8_RMS, mscl::WirelessChannel::channel_8_rms);
MSCL_C_SAME(MSCL_CHANNEL_ID_9_RMS, mscl::WirelessChannel::channel_9_rms);
MSCL_C_SAME(MSCL_CHANNEL_ID_10_RMS, mscl::WirelessChannel::channel_10_rms);
MSCL_C_SAME(MSCL_CHANNEL_ID_11_RMS, mscl::WirelessChannel::channel_11_rms);
MSCL_C_SAME(MSCL_CHANNEL_ID_12_RMS, mscl::WirelessChannel::channel_12_rms);
MSCL_C_SAME(MSCL_CHANNEL_ID_13_RMS, mscl::WirelessChannel::channel_13_rms);
MSCL_C_SAME(MSCL_CHANNEL_ID_14_RMS, mscl::WirelessChannel::channel_14_rms);
MSCL_C_SAME(MSCL_CHANNEL_ID_15_RMS, mscl::WirelessChannel::channel_15_rms);
MSCL_C_SAME(MSCL_CHANNEL_ID_16_RMS, mscl::WirelessChannel::channel_16_rms);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_1_PEAK_TO_PEAK,
    mscl::WirelessChannel::channel_1_peakToPeak
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_2_PEAK_TO_PEAK,
    mscl::WirelessChannel::channel_2_peakToPeak
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_3_PEAK_TO_PEAK,
    mscl::WirelessChannel::channel_3_peakToPeak
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_4_PEAK_TO_PEAK,
    mscl::WirelessChannel::channel_4_peakToPeak
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_5_PEAK_TO_PEAK,
    mscl::WirelessChannel::channel_5_peakToPeak
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_6_PEAK_TO_PEAK,
    mscl::WirelessChannel::channel_6_peakToPeak
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_7_PEAK_TO_PEAK,
    mscl::WirelessChannel::channel_7_peakToPeak
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_8_PEAK_TO_PEAK,
    mscl::WirelessChannel::channel_8_peakToPeak
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_9_PEAK_TO_PEAK,
    mscl::WirelessChannel::channel_9_peakToPeak
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_10_PEAK_TO_PEAK,
    mscl::WirelessChannel::channel_10_peakToPeak
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_11_PEAK_TO_PEAK,
    mscl::WirelessChannel::channel_11_peakToPeak
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_12_PEAK_TO_PEAK,
    mscl::WirelessChannel::channel_12_peakToPeak
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_13_PEAK_TO_PEAK,
    mscl::WirelessChannel::channel_13_peakToPeak
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_14_PEAK_TO_PEAK,
    mscl::WirelessChannel::channel_14_peakToPeak
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_15_PEAK_TO_PEAK,
    mscl::WirelessChannel::channel_15_peakToPeak
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_16_PEAK_TO_PEAK,
    mscl::WirelessChannel::channel_16_peakToPeak
);
MSCL_C_SAME(MSCL_CHANNEL_ID_1_IPS, mscl::WirelessChannel::channel_1_ips);
MSCL_C_SAME(MSCL_CHANNEL_ID_2_IPS, mscl::WirelessChannel::channel_2_ips);
MSCL_C_SAME(MSCL_CHANNEL_ID_3_IPS, mscl::WirelessChannel::channel_3_ips);
MSCL_C_SAME(MSCL_CHANNEL_ID_4_IPS, mscl::WirelessChannel::channel_4_ips);
MSCL_C_SAME(MSCL_CHANNEL_ID_5_IPS, mscl::WirelessChannel::channel_5_ips);
MSCL_C_SAME(MSCL_CHANNEL_ID_6_IPS, mscl::WirelessChannel::channel_6_ips);
MSCL_C_SAME(MSCL_CHANNEL_ID_7_IPS, mscl::WirelessChannel::channel_7_ips);
MSCL_C_SAME(MSCL_CHANNEL_ID_8_IPS, mscl::WirelessChannel::channel_8_ips);
MSCL_C_SAME(MSCL_CHANNEL_ID_9_IPS, mscl::WirelessChannel::channel_9_ips);
MSCL_C_SAME(MSCL_CHANNEL_ID_10_IPS, mscl::WirelessChannel::channel_10_ips);
MSCL_C_SAME(MSCL_CHANNEL_ID_11_IPS, mscl::WirelessChannel::channel_11_ips);
MSCL_C_SAME(MSCL_CHANNEL_ID_12_IPS, mscl::WirelessChannel::channel_12_ips);
MSCL_C_SAME(MSCL_CHANNEL_ID_13_IPS, mscl::WirelessChannel::channel_13_ips);
MSCL_C_SAME(MSCL_CHANNEL_ID_14_IPS, mscl::WirelessChannel::channel_14_ips);
MSCL_C_SAME(MSCL_CHANNEL_ID_15_IPS, mscl::WirelessChannel::channel_15_ips);
MSCL_C_SAME(MSCL_CHANNEL_ID_16_IPS, mscl::WirelessChannel::channel_16_ips);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_1_CREST_FACTOR,
    mscl::WirelessChannel::channel_1_crestFactor
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_2_CREST_FACTOR,
    mscl::WirelessChannel::channel_2_crestFactor
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_3_CREST_FACTOR,
    mscl::WirelessChannel::channel_3_crestFactor
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_4_CREST_FACTOR,
    mscl::WirelessChannel::channel_4_crestFactor
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_5_CREST_FACTOR,
    mscl::WirelessChannel::channel_5_crestFactor
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_6_CREST_FACTOR,
    mscl::WirelessChannel::channel_6_crestFactor
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_7_CREST_FACTOR,
    mscl::WirelessChannel::channel_7_crestFactor
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_8_CREST_FACTOR,
    mscl::WirelessChannel::channel_8_crestFactor
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_9_CREST_FACTOR,
    mscl::WirelessChannel::channel_9_crestFactor
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_10_CREST_FACTOR,
    mscl::WirelessChannel::channel_10_crestFactor
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_11_CREST_FACTOR,
    mscl::WirelessChannel::channel_11_crestFactor
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_12_CREST_FACTOR,
    mscl::WirelessChannel::channel_12_crestFactor
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_13_CREST_FACTOR,
    mscl::WirelessChannel::channel_13_crestFactor
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_14_CREST_FACTOR,
    mscl::WirelessChannel::channel_14_crestFactor
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_15_CREST_FACTOR,
    mscl::WirelessChannel::channel_15_crestFactor
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_16_CREST_FACTOR,
    mscl::WirelessChannel::channel_16_crestFactor
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIAG_SYNC_ATTEMPTS,
    mscl::WirelessChannel::channel_diag_syncAttempts
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIAG_SYNC_FAILURES,
    mscl::WirelessChannel::channel_diag_syncFailures
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIAG_SECS_SINCE_LAST_SYNC,
    mscl::WirelessChannel::channel_diag_secsSinceLastSync
);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_BEACON_CONFLICT,
    mscl::WirelessChannel::channel_beaconConflict
);
MSCL_C_SAME(MSCL_CHANNEL_ID_1_MEAN, mscl::WirelessChannel::channel_1_mean);
MSCL_C_SAME(MSCL_CHANNEL_ID_2_MEAN, mscl::WirelessChannel::channel_2_mean);
MSCL_C_SAME(MSCL_CHANNEL_ID_3_MEAN, mscl::WirelessChannel::channel_3_mean);
MSCL_C_SAME(MSCL_CHANNEL_ID_4_MEAN, mscl::WirelessChannel::channel_4_mean);
MSCL_C_SAME(MSCL_CHANNEL_ID_5_MEAN, mscl::WirelessChannel::channel_5_mean);
MSCL_C_SAME(MSCL_CHANNEL_ID_6_MEAN, mscl::WirelessChannel::channel_6_mean);
MSCL_C_SAME(MSCL_CHANNEL_ID_7_MEAN, mscl::WirelessChannel::channel_7_mean);
MSCL_C_SAME(MSCL_CHANNEL_ID_8_MEAN, mscl::WirelessChannel::channel_8_mean);
MSCL_C_SAME(MSCL_CHANNEL_ID_9_MEAN, mscl::WirelessChannel::channel_9_mean);
MSCL_C_SAME(MSCL_CHANNEL_ID_10_MEAN, mscl::WirelessChannel::channel_10_mean);
MSCL_C_SAME(MSCL_CHANNEL_ID_11_MEAN, mscl::WirelessChannel::channel_11_mean);
MSCL_C_SAME(MSCL_CHANNEL_ID_12_MEAN, mscl::WirelessChannel::channel_12_mean);
MSCL_C_SAME(MSCL_CHANNEL_ID_13_MEAN, mscl::WirelessChannel::channel_13_mean);
MSCL_C_SAME(MSCL_CHANNEL_ID_14_MEAN, mscl::WirelessChannel::channel_14_mean);
MSCL_C_SAME(MSCL_CHANNEL_ID_15_MEAN, mscl::WirelessChannel::channel_15_mean);
MSCL_C_SAME(MSCL_CHANNEL_ID_16_MEAN, mscl::WirelessChannel::channel_16_mean);
MSCL_C_SAME(MSCL_CHANNEL_ID_1_MMPS, mscl::WirelessChannel::channel_1_mmps);
MSCL_C_SAME(MSCL_CHANNEL_ID_2_MMPS, mscl::WirelessChannel::channel_2_mmps);
MSCL_C_SAME(MSCL_CHANNEL_ID_3_MMPS, mscl::WirelessChannel::channel_3_mmps);
MSCL_C_SAME(MSCL_CHANNEL_ID_4_MMPS, mscl::WirelessChannel::channel_4_mmps);
MSCL_C_SAME(MSCL_CHANNEL_ID_5_MMPS, mscl::WirelessChannel::channel_5_mmps);
MSCL_C_SAME(MSCL_CHANNEL_ID_6_MMPS, mscl::WirelessChannel::channel_6_mmps);
MSCL_C_SAME(MSCL_CHANNEL_ID_7_MMPS, mscl::WirelessChannel::channel_7_mmps);
MSCL_C_SAME(MSCL_CHANNEL_ID_8_MMPS, mscl::WirelessChannel::channel_8_mmps);
MSCL_C_SAME(MSCL_CHANNEL_ID_9_MMPS, mscl::WirelessChannel::channel_9_mmps);
MSCL_C_SAME(MSCL_CHANNEL_ID_10_MMPS, mscl::WirelessChannel::channel_10_mmps);
MSCL_C_SAME(MSCL_CHANNEL_ID_11_MMPS, mscl::WirelessChannel::channel_11_mmps);
MSCL_C_SAME(MSCL_CHANNEL_ID_12_MMPS, mscl::WirelessChannel::channel_12_mmps);
MSCL_C_SAME(MSCL_CHANNEL_ID_13_MMPS, mscl::WirelessChannel::channel_13_mmps);
MSCL_C_SAME(MSCL_CHANNEL_ID_14_MMPS, mscl::WirelessChannel::channel_14_mmps);
MSCL_C_SAME(MSCL_CHANNEL_ID_15_MMPS, mscl::WirelessChannel::channel_15_mmps);
MSCL_C_SAME(MSCL_CHANNEL_ID_16_MMPS, mscl::WirelessChannel::channel_16_mmps);
MSCL_C_SAME(
    MSCL_CHANNEL_ID_DIAG_MEMORY_FULL,
    mscl::WirelessChannel::channel_diag_memoryFull
);

MSCL_C_SAME(MSCL_DEVICE_STATE_IDLE, mscl::deviceState_idle);
MSCL_C_SAME(MSCL_DEVICE_STATE_SLEEP, mscl::deviceState_sleep);
MSCL_C_SAME(MSCL_DEVICE_STATE_SAMPLING, mscl::deviceState_sampling);
MSCL_C_SAME(
    MSCL_DEVICE_STATE_SAMPLING_LOST_BEACON,
    mscl::deviceState_sampling_lostBeacon
);
MSCL_C_SAME(
    MSCL_DEVICE_STATE_SAMPLING_INACTIVE,
    mscl::deviceState_sampling_inactive
);
MSCL_C_SAME(MSCL_DEVICE_STATE_UNKNOWN, mscl::deviceState_unknown);
MSCL_C_SAME(MSCL_CHANNEL_MASK_MAX_CHANNELS, mscl::ChannelMask::MAX_CHANNELS);

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
    } catch (const std::invalid_argument &e) {
        return fail(MSCL_ERROR_INVALID_ARGUMENT, e.what());
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

void fill_version(const mscl::Version &data, mscl_version &version)
{
    version.major = data.majorPart();
    version.minor = data.minorPart();
    version.patch = data.patchPart();
}

void fill_node_discovery(
    const mscl::NodeDiscovery &data,
    mscl_node_discovery &discovery
)
{
    discovery.node_address = data.nodeAddress();
    discovery.frequency = static_cast<mscl_frequency>(data.frequency());
    discovery.pan_id = data.panId();
    discovery.model = static_cast<uint32_t>(data.model());
    discovery.serial_number = data.serialNumber();
    fill_version(data.firmwareVersion(), discovery.firmware_version);
    discovery.default_mode = static_cast<uint32_t>(data.defaultMode());
    discovery.built_in_test_result = data.builtInTestResult();
    discovery.comm_protocol =
        static_cast<mscl_comm_protocol>(data.communicationProtocol());
    fill_version(data.asppVersion_lxrs(), discovery.aspp_version_lxrs);
    fill_version(
        data.asppVersion_lxrsPlus(),
        discovery.aspp_version_lxrs_plus
    );
    discovery.base_rssi = data.baseRssi();
    discovery.timestamp_ns = data.timestamp().nanoseconds();
}

// mscl_base_station_features is never defined: a handle points at the
// BaseStationFeatures that the base station owns.
const mscl::BaseStationFeatures &features_of(
    const mscl_base_station_features *features
)
{
    return *reinterpret_cast<const mscl::BaseStationFeatures *>(features);
}

// Copies as many of `values` as fit into `destination` and returns how many
// it copied.
template <typename C, typename T>
size_t copy_values(C *destination, size_t size, const std::vector<T> &values)
{
    const size_t count = std::min(values.size(), size);
    for (size_t i = 0; i < count; i++) {
        destination[i] = static_cast<C>(values[i]);
    }
    return count;
}

// mscl_node_features is never defined either: a handle points at the
// NodeFeatures that the node owns.
const mscl::NodeFeatures &node_features_of(
    const mscl_node_features *features
)
{
    return *reinterpret_cast<const mscl::NodeFeatures *>(features);
}

mscl::SampleRate to_sample_rate(mscl_sample_rate rate)
{
    return mscl::SampleUtils::convertToSampleRate(
        static_cast<WirelessTypes::WirelessSampleRate>(rate)
    );
}

mscl_version to_c(const mscl::Version &data)
{
    mscl_version version{};
    fill_version(data, version);
    return version;
}

mscl_ping_result to_c(const mscl::PingResponse &data)
{
    mscl_ping_result result{};
    result.success = data.success();
    result.base_rssi = data.baseRssi();
    result.node_rssi = data.nodeRssi();
    return result;
}

// RadioFeatures::extendedRange is not const, so this takes a copy.
mscl_radio_features to_c(mscl::RadioFeatures data)
{
    mscl_radio_features features{};
    features.extended_range = data.extendedRange();
    return features;
}

mscl_linear_equation to_c(const mscl::LinearEquation &data)
{
    mscl_linear_equation equation{};
    equation.slope = data.slope();
    equation.offset = data.offset();
    return equation;
}

mscl::LinearEquation to_mscl(const mscl_linear_equation &equation)
{
    return mscl::LinearEquation(equation.slope, equation.offset);
}

mscl_temp_sensor_options to_c(const mscl::TempSensorOptions &data)
{
    mscl_temp_sensor_options options{};
    options.transducer_type =
        static_cast<mscl_transducer_type>(data.transducerType());
    options.thermocouple_type =
        static_cast<mscl_thermocouple_type>(data.thermocoupleType());
    options.rtd_type = static_cast<mscl_rtd_type>(data.rtdType());
    options.rtd_wire_type = static_cast<mscl_rtd_wire_type>(data.rtdWireType());
    options.thermistor_type =
        static_cast<mscl_thermistor_type>(data.thermistorType());
    return options;
}

mscl::TempSensorOptions to_mscl(const mscl_temp_sensor_options &options)
{
    switch (options.transducer_type) {
    case MSCL_TRANSDUCER_TYPE_THERMOCOUPLE:
        return mscl::TempSensorOptions::Thermocouple(
            static_cast<WirelessTypes::ThermocoupleType>(
                options.thermocouple_type
            )
        );
    case MSCL_TRANSDUCER_TYPE_RTD:
        return mscl::TempSensorOptions::RTD(
            static_cast<WirelessTypes::RtdWireType>(options.rtd_wire_type),
            static_cast<WirelessTypes::RtdType>(options.rtd_type)
        );
    case MSCL_TRANSDUCER_TYPE_THERMISTOR:
        return mscl::TempSensorOptions::Thermistor(
            static_cast<WirelessTypes::ThermistorType>(options.thermistor_type)
        );
    }
    throw std::invalid_argument("unknown transducer_type");
}

mscl_histogram_options to_c(const mscl::HistogramOptions &data)
{
    mscl_histogram_options options{};
    options.transmit_rate = static_cast<mscl_sample_rate>(data.transmitRate());
    options.bins_start = data.binsStart();
    options.bins_size = data.binsSize();
    return options;
}

mscl::HistogramOptions to_mscl(const mscl_histogram_options &options)
{
    mscl::HistogramOptions result;
    result.transmitRate(
        static_cast<WirelessTypes::WirelessSampleRate>(options.transmit_rate)
    );
    result.binsStart(options.bins_start);
    result.binsSize(options.bins_size);
    return result;
}

mscl_activity_sense to_c(const mscl::ActivitySense &data)
{
    mscl_activity_sense activity_sense{};
    activity_sense.enabled = data.enabled();
    activity_sense.activity_threshold = data.activityThreshold();
    activity_sense.inactivity_threshold = data.inactivityThreshold();
    activity_sense.activity_time = data.activityTime();
    activity_sense.inactivity_timeout = data.inactivityTimeout();
    return activity_sense;
}

mscl::ActivitySense to_mscl(const mscl_activity_sense &activity_sense)
{
    mscl::ActivitySense result;
    result.enabled(activity_sense.enabled);
    result.activityThreshold(activity_sense.activity_threshold);
    result.inactivityThreshold(activity_sense.inactivity_threshold);
    result.activityTime(activity_sense.activity_time);
    result.inactivityTimeout(activity_sense.inactivity_timeout);
    return result;
}

mscl_event_trigger_options to_c(const mscl::EventTriggerOptions &data)
{
    mscl_event_trigger_options options{};
    options.trigger_mask = data.triggerMask().toMask();
    options.pre_duration = data.preDuration();
    options.post_duration = data.postDuration();
    const size_t capacity =
        sizeof(options.triggers) / sizeof(options.triggers[0]);
    for (const auto &[index, trigger] : data.triggers()) {
        if (options.trigger_count == capacity) {
            break;
        }
        mscl_event_trigger &result = options.triggers[options.trigger_count];
        result.index = index;
        result.channel_number = trigger.channelNumber();
        result.type =
            static_cast<mscl_event_trigger_type>(trigger.triggerType());
        result.value = trigger.triggerValue();
        options.trigger_count++;
    }
    return options;
}

mscl::EventTriggerOptions to_mscl(const mscl_event_trigger_options &options)
{
    const size_t capacity =
        sizeof(options.triggers) / sizeof(options.triggers[0]);
    if (options.trigger_count > capacity) {
        throw std::invalid_argument("trigger_count is larger than triggers");
    }
    mscl::EventTriggerOptions result;
    result.triggerMask(mscl::BitMask(options.trigger_mask));
    result.preDuration(options.pre_duration);
    result.postDuration(options.post_duration);
    for (size_t i = 0; i < options.trigger_count; i++) {
        const mscl_event_trigger &trigger = options.triggers[i];
        result.trigger(
            trigger.index,
            mscl::Trigger(
                trigger.channel_number,
                static_cast<WirelessTypes::EventTriggerType>(trigger.type),
                trigger.value
            )
        );
    }
    return result;
}

mscl_fatigue_options to_c(const mscl::FatigueOptions &data)
{
    mscl_fatigue_options options{};
    options.youngs_modulus = data.youngsModulus();
    options.poissons_ratio = data.poissonsRatio();
    options.peak_valley_threshold = data.peakValleyThreshold();
    options.debug_mode = data.debugMode();
    options.fatigue_mode = static_cast<mscl_fatigue_mode>(data.fatigueMode());
    options.distributed_angle_mode_num_angles =
        data.distributedAngleMode_numAngles();
    options.distributed_angle_mode_lower_bound =
        data.distributedAngleMode_lowerBound();
    options.distributed_angle_mode_upper_bound =
        data.distributedAngleMode_upperBound();
    options.histogram_enable = data.histogramEnable();
    const size_t angle_capacity =
        sizeof(options.damage_angles) / sizeof(options.damage_angles[0]);
    for (const auto &[id, angle] : data.damageAngles()) {
        if (options.damage_angle_count == angle_capacity) {
            break;
        }
        mscl_damage_angle &result =
            options.damage_angles[options.damage_angle_count];
        result.id = id;
        result.angle = angle;
        options.damage_angle_count++;
    }
    const size_t segment_capacity = sizeof(options.sn_curve_segments) /
        sizeof(options.sn_curve_segments[0]);
    for (const auto &[id, segment] : data.snCurveSegments()) {
        if (options.sn_curve_segment_count == segment_capacity) {
            break;
        }
        mscl_sn_curve_segment &result =
            options.sn_curve_segments[options.sn_curve_segment_count];
        result.id = id;
        result.m = segment.m();
        result.log_a = segment.logA();
        options.sn_curve_segment_count++;
    }
    return options;
}

mscl::FatigueOptions to_mscl(const mscl_fatigue_options &options)
{
    const size_t angle_capacity =
        sizeof(options.damage_angles) / sizeof(options.damage_angles[0]);
    const size_t segment_capacity = sizeof(options.sn_curve_segments) /
        sizeof(options.sn_curve_segments[0]);
    if (
        options.damage_angle_count > angle_capacity ||
        options.sn_curve_segment_count > segment_capacity
    ) {
        throw std::invalid_argument("a count is larger than its array");
    }
    mscl::FatigueOptions result;
    result.youngsModulus(options.youngs_modulus);
    result.poissonsRatio(options.poissons_ratio);
    result.peakValleyThreshold(options.peak_valley_threshold);
    result.debugMode(options.debug_mode);
    result.fatigueMode(
        static_cast<WirelessTypes::FatigueMode>(options.fatigue_mode)
    );
    result.distributedAngleMode_numAngles(
        options.distributed_angle_mode_num_angles
    );
    result.distributedAngleMode_lowerBound(
        options.distributed_angle_mode_lower_bound
    );
    result.distributedAngleMode_upperBound(
        options.distributed_angle_mode_upper_bound
    );
    result.histogramEnable(options.histogram_enable);
    for (size_t i = 0; i < options.damage_angle_count; i++) {
        const mscl_damage_angle &angle = options.damage_angles[i];
        result.damageAngle(angle.id, angle.angle);
    }
    for (size_t i = 0; i < options.sn_curve_segment_count; i++) {
        const mscl_sn_curve_segment &segment = options.sn_curve_segments[i];
        result.snCurveSegment(
            segment.id,
            mscl::SnCurveSegment(segment.m, segment.log_a)
        );
    }
    return result;
}

mscl_auto_balance_result to_c(const mscl::AutoBalanceResult &data)
{
    mscl_auto_balance_result result{};
    result.error_code =
        static_cast<mscl_auto_balance_error_flag>(data.errorCode());
    result.percent_achieved = data.percentAchieved();
    result.hardware_offset = data.hardwareOffset();
    return result;
}

mscl_auto_cal_result_shm_link to_c(const mscl::AutoCalResult_shmLink &data)
{
    mscl_auto_cal_result_shm_link result{};
    result.completion_flag =
        static_cast<mscl_auto_cal_completion_flag>(data.completionFlag());
    result.error_flag_ch1 =
        static_cast<mscl_auto_cal_error_flag>(data.errorFlagCh1());
    result.error_flag_ch2 =
        static_cast<mscl_auto_cal_error_flag>(data.errorFlagCh2());
    result.error_flag_ch3 =
        static_cast<mscl_auto_cal_error_flag>(data.errorFlagCh3());
    result.offset_ch1 = data.offsetCh1();
    result.offset_ch2 = data.offsetCh2();
    result.offset_ch3 = data.offsetCh3();
    result.temperature = data.temperature();
    return result;
}

mscl_auto_cal_result_shm_link_201 to_c(
    const mscl::AutoCalResult_shmLink201 &data
)
{
    mscl_auto_cal_result_shm_link_201 result{};
    result.completion_flag =
        static_cast<mscl_auto_cal_completion_flag>(data.completionFlag());
    result.error_flag_ch1 =
        static_cast<mscl_auto_cal_error_flag>(data.errorFlagCh1());
    result.error_flag_ch2 =
        static_cast<mscl_auto_cal_error_flag>(data.errorFlagCh2());
    result.error_flag_ch3 =
        static_cast<mscl_auto_cal_error_flag>(data.errorFlagCh3());
    result.slope_ch1 = data.slopeCh1();
    result.offset_ch1 = data.offsetCh1();
    result.slope_ch2 = data.slopeCh2();
    result.offset_ch2 = data.offsetCh2();
    result.slope_ch3 = data.slopeCh3();
    result.offset_ch3 = data.offsetCh3();
    result.temperature = data.temperature();
    return result;
}

mscl::ShuntCalCmdInfo to_mscl(const mscl_shunt_cal_cmd_info &info)
{
    mscl::ShuntCalCmdInfo result;
    result.useInternalShunt = info.use_internal_shunt;
    result.numActiveGauges = info.num_active_gauges;
    result.gaugeResistance = info.gauge_resistance;
    result.shuntResistance = info.shunt_resistance;
    result.gaugeFactor = info.gauge_factor;
    result.inputRange =
        static_cast<WirelessTypes::InputRange>(info.input_range);
    result.hardwareOffset = info.hardware_offset;
    result.excitationVoltage =
        static_cast<WirelessTypes::Voltage>(info.excitation_voltage);
    return result;
}

mscl_auto_shunt_cal_result to_c(const mscl::AutoShuntCalResult &data)
{
    mscl_auto_shunt_cal_result result{};
    result.completion_flag =
        static_cast<mscl_auto_cal_completion_flag>(data.completionFlag());
    result.error_flag = static_cast<mscl_auto_cal_error_flag>(data.errorFlag());
    result.slope = data.slope();
    result.offset = data.offset();
    result.base_median = data.baseMedian();
    result.base_min = data.baseMin();
    result.base_max = data.baseMax();
    result.shunt_median = data.shuntMedian();
    result.shunt_min = data.shuntMin();
    result.shunt_max = data.shuntMax();
    return result;
}

mscl_wireless_channel to_c(const mscl::WirelessChannel &data)
{
    mscl_wireless_channel channel{};
    channel.channel_number = data.channelNumber();
    channel.id = static_cast<mscl_channel_id>(data.id());
    channel.type = static_cast<mscl_channel_type>(data.type());
    copy_string(
        channel.description,
        sizeof(channel.description),
        data.description()
    );
    channel.adc_resolution = data.adcResolution();
    channel.adc_max_value = data.adcMaxValue();
    copy_string(channel.name, sizeof(channel.name), data.name());
    return channel;
}

mscl_channel_group to_c(const mscl::ChannelGroup &data)
{
    mscl_channel_group group{};
    group.channels = data.channels().toMask();
    copy_string(group.name, sizeof(group.name), data.name());
    const size_t capacity = sizeof(group.settings) / sizeof(group.settings[0]);
    for (const WirelessTypes::ChannelGroupSetting setting : data.settings()) {
        if (group.setting_count == capacity) {
            break;
        }
        group.settings[group.setting_count] =
            static_cast<mscl_channel_group_setting>(setting);
        group.eeprom_locations[group.setting_count] =
            data.eepromLocation(setting);
        group.setting_count++;
    }
    return group;
}

mscl_input_range_entry to_c(const mscl::InputRangeEntry &data)
{
    mscl_input_range_entry entry{};
    entry.input_range = static_cast<mscl_input_range>(data.inputRange);
    entry.has_gain = data.hasGain;
    entry.gain = data.gain;
    return entry;
}

mscl_derived_channel_mask to_c(
    const std::pair<const WirelessTypes::DerivedCategory, mscl::ChannelMask>
        &data
)
{
    mscl_derived_channel_mask mask{};
    mask.category = static_cast<mscl_derived_category>(data.first);
    mask.mask = data.second.toMask();
    return mask;
}

WirelessTypes::DerivedChannelMasks to_mscl(
    const mscl_derived_channel_mask *masks,
    size_t count
)
{
    WirelessTypes::DerivedChannelMasks result;
    for (size_t i = 0; i < count; i++) {
        result.emplace(
            static_cast<WirelessTypes::DerivedCategory>(masks[i].category),
            mscl::ChannelMask(masks[i].mask)
        );
    }
    return result;
}

// Converts as many of `values` as fit into `destination` with to_c and
// returns how many it converted.
template <typename C, typename Values>
size_t convert_values(C *destination, size_t size, const Values &values)
{
    size_t count = 0;
    for (const auto &value : values) {
        if (count == size) {
            break;
        }
        destination[count] = to_c(value);
        count++;
    }
    return count;
}

} // namespace

extern "C" {

const char *mscl_last_error(void)
{
    return last_error;
}

mscl_status mscl_list_base_stations(mscl_device_info **devices, size_t *count)
{
    if (devices == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *devices = nullptr;
    *count = 0;
    return call([&] {
        const mscl::Devices::DeviceList list =
            mscl::Devices::listBaseStations();
        if (list.empty()) {
            return;
        }
        mscl_device_info *result =
            allocate_zeroed<mscl_device_info>(list.size());
        size_t i = 0;
        for (const auto &[port, info] : list) {
            copy_string(result[i].port, sizeof(result[i].port), port);
            copy_string(
                result[i].description,
                sizeof(result[i].description),
                info.description()
            );
            copy_string(
                result[i].serial,
                sizeof(result[i].serial),
                info.serial()
            );
            result[i].baud_rate = info.baudRate();
            result[i].connection_type = static_cast<mscl_connection_type>(
                info.connectionType()
            );
            i++;
        }
        *devices = result;
        *count = list.size();
    });
}

void mscl_device_infos_free(mscl_device_info *devices)
{
    std::free(devices);
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

mscl_status mscl_base_station_get_retries(
    mscl_base_station *base_station,
    uint8_t *retries
)
{
    if (base_station == nullptr || retries == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *retries = base_station->base.readWriteRetries(); });
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

mscl_status mscl_base_station_get_last_communication_time(
    mscl_base_station *base_station,
    uint64_t *time_ns
)
{
    if (base_station == nullptr || time_ns == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *time_ns = base_station->base.lastCommunicationTime().nanoseconds();
    });
}

mscl_status mscl_base_station_use_eeprom_cache(
    mscl_base_station *base_station,
    bool use_cache
)
{
    if (base_station == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { base_station->base.useEepromCache(use_cache); });
}

mscl_status mscl_base_station_clear_eeprom_cache(
    mscl_base_station *base_station
)
{
    if (base_station == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { base_station->base.clearEepromCache(); });
}

mscl_status mscl_base_station_get_frequency(
    mscl_base_station *base_station,
    mscl_frequency *frequency
)
{
    if (base_station == nullptr || frequency == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *frequency =
            static_cast<mscl_frequency>(base_station->base.frequency());
    });
}

mscl_status mscl_base_station_get_communication_protocol(
    mscl_base_station *base_station,
    mscl_comm_protocol *protocol
)
{
    if (base_station == nullptr || protocol == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *protocol = static_cast<mscl_comm_protocol>(
            base_station->base.communicationProtocol()
        );
    });
}

mscl_status mscl_base_station_get_firmware_version(
    mscl_base_station *base_station,
    mscl_version *version
)
{
    if (base_station == nullptr || version == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        const mscl::Version firmware = base_station->base.firmwareVersion();
        version->major = firmware.majorPart();
        version->minor = firmware.minorPart();
        version->patch = firmware.patchPart();
    });
}

mscl_status mscl_base_station_get_model(
    mscl_base_station *base_station,
    mscl_base_model *model
)
{
    if (base_station == nullptr || model == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *model = static_cast<mscl_base_model>(base_station->base.model());
    });
}

mscl_status mscl_base_station_get_serial(
    mscl_base_station *base_station,
    char *serial,
    size_t serial_len
)
{
    if (base_station == nullptr || serial == nullptr) {
        return fail_null(__func__);
    }
    copy_string(serial, serial_len, "");
    return call([&] {
        copy_string(serial, serial_len, base_station->base.serial());
    });
}

mscl_status mscl_base_station_get_name(
    mscl_base_station *base_station,
    char *name,
    size_t name_len
)
{
    if (base_station == nullptr || name == nullptr) {
        return fail_null(__func__);
    }
    copy_string(name, name_len, "");
    return call([&] {
        copy_string(name, name_len, base_station->base.name());
    });
}

mscl_status mscl_base_station_get_microcontroller(
    mscl_base_station *base_station,
    mscl_microcontroller *microcontroller
)
{
    if (base_station == nullptr || microcontroller == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *microcontroller = static_cast<mscl_microcontroller>(
            base_station->base.microcontroller()
        );
    });
}

mscl_status mscl_base_station_get_region_code(
    mscl_base_station *base_station,
    mscl_region_code *region_code
)
{
    if (base_station == nullptr || region_code == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *region_code =
            static_cast<mscl_region_code>(base_station->base.regionCode());
    });
}

mscl_status mscl_base_station_get_total_data(
    mscl_base_station *base_station,
    uint32_t *count
)
{
    if (base_station == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *count = base_station->base.totalData(); });
}

mscl_status mscl_base_station_set_timeout(
    mscl_base_station *base_station,
    uint64_t timeout_ms
)
{
    if (base_station == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { base_station->base.timeout(timeout_ms); });
}

mscl_status mscl_base_station_get_timeout(
    mscl_base_station *base_station,
    uint64_t *timeout_ms
)
{
    if (base_station == nullptr || timeout_ms == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *timeout_ms = base_station->base.timeout(); });
}

mscl_status mscl_base_station_read_eeprom(
    mscl_base_station *base_station,
    uint16_t address,
    uint16_t *value
)
{
    if (base_station == nullptr || value == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *value = base_station->base.readEeprom(address); });
}

mscl_status mscl_base_station_write_eeprom(
    mscl_base_station *base_station,
    uint16_t address,
    uint16_t value
)
{
    if (base_station == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { base_station->base.writeEeprom(address, value); });
}

mscl_status mscl_base_station_enable_beacon_at(
    mscl_base_station *base_station,
    uint32_t utc_time_s,
    uint64_t *beacon_time_ns
)
{
    if (base_station == nullptr || beacon_time_ns == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *beacon_time_ns =
            base_station->base.enableBeacon(utc_time_s).nanoseconds();
    });
}

mscl_status mscl_base_station_get_beacon_status(
    mscl_base_station *base_station,
    mscl_beacon_status *status
)
{
    if (base_station == nullptr || status == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        mscl::BeaconStatus result = base_station->base.beaconStatus();
        status->enabled = result.enabled();
        status->timestamp_ns = result.timestamp().nanoseconds();
    });
}

mscl_status mscl_base_station_start_rf_sweep_mode(
    mscl_base_station *base_station
)
{
    if (base_station == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { base_station->base.startRfSweepMode(); });
}

mscl_status mscl_base_station_start_custom_rf_sweep_mode(
    mscl_base_station *base_station,
    uint32_t min_freq_khz,
    uint32_t max_freq_khz,
    uint32_t interval,
    uint16_t options
)
{
    if (base_station == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        base_station->base.startRfSweepMode(
            min_freq_khz,
            max_freq_khz,
            interval,
            options
        );
    });
}

mscl_status mscl_base_station_cycle_power(
    mscl_base_station *base_station,
    bool check_comm
)
{
    if (base_station == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { base_station->base.cyclePower(check_comm); });
}

mscl_status mscl_base_station_reset_radio(mscl_base_station *base_station)
{
    if (base_station == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { base_station->base.resetRadio(); });
}

mscl_status mscl_base_station_change_frequency(
    mscl_base_station *base_station,
    mscl_frequency frequency
)
{
    if (base_station == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        base_station->base.changeFrequency(
            static_cast<WirelessTypes::Frequency>(frequency)
        );
    });
}

mscl_status mscl_base_station_get_transmit_power(
    mscl_base_station *base_station,
    mscl_transmit_power *power
)
{
    if (base_station == nullptr || power == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *power = static_cast<mscl_transmit_power>(
            base_station->base.getTransmitPower()
        );
    });
}

mscl_status mscl_base_station_get_button_long_press(
    mscl_base_station *base_station,
    uint8_t button_number,
    mscl_base_station_button *button
)
{
    if (base_station == nullptr || button == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        const mscl::BaseStationButton result =
            base_station->base.getButtonLongPress(button_number);
        button->command = static_cast<mscl_button_command>(result.command());
        button->node_address = result.nodeAddress();
    });
}

mscl_status mscl_base_station_get_button_short_press(
    mscl_base_station *base_station,
    uint8_t button_number,
    mscl_base_station_button *button
)
{
    if (base_station == nullptr || button == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        const mscl::BaseStationButton result =
            base_station->base.getButtonShortPress(button_number);
        button->command = static_cast<mscl_button_command>(result.command());
        button->node_address = result.nodeAddress();
    });
}

mscl_status mscl_base_station_get_analog_pairing_enabled(
    mscl_base_station *base_station,
    bool *enabled
)
{
    if (base_station == nullptr || enabled == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *enabled = base_station->base.getAnalogPairingEnabled();
    });
}

mscl_status mscl_base_station_get_analog_timeout_time(
    mscl_base_station *base_station,
    uint16_t *seconds
)
{
    if (base_station == nullptr || seconds == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *seconds = base_station->base.getAnalogTimeoutTime();
    });
}

mscl_status mscl_base_station_get_analog_timeout_voltage(
    mscl_base_station *base_station,
    float *voltage
)
{
    if (base_station == nullptr || voltage == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *voltage = base_station->base.getAnalogTimeoutVoltage();
    });
}

mscl_status mscl_base_station_get_analog_exceedance_enabled(
    mscl_base_station *base_station,
    bool *enabled
)
{
    if (base_station == nullptr || enabled == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *enabled = base_station->base.getAnalogExceedanceEnabled();
    });
}

mscl_status mscl_base_station_get_analog_pair(
    mscl_base_station *base_station,
    uint8_t port_number,
    mscl_base_station_analog_pair *pair
)
{
    if (base_station == nullptr || pair == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        const mscl::BaseStationAnalogPair result =
            base_station->base.getAnalogPair(port_number);
        pair->node_address = result.nodeAddress();
        pair->node_channel = result.nodeChannel();
        pair->expect_float_data = result.expectFloatData();
        pair->output_0v = result.outputVal_0V();
        pair->output_3v = result.outputVal_3V();
    });
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

mscl_status mscl_base_station_get_node_discoveries(
    mscl_base_station *base_station,
    mscl_node_discovery **discoveries,
    size_t *count
)
{
    if (
        base_station == nullptr ||
        discoveries == nullptr ||
        count == nullptr
    ) {
        return fail_null(__func__);
    }
    *discoveries = nullptr;
    *count = 0;
    return call([&] {
        const mscl::NodeDiscoveries data =
            base_station->base.getNodeDiscoveries();
        if (data.empty()) {
            return;
        }
        mscl_node_discovery *result =
            allocate_zeroed<mscl_node_discovery>(data.size());
        for (size_t i = 0; i < data.size(); i++) {
            fill_node_discovery(data[i], result[i]);
        }
        *discoveries = result;
        *count = data.size();
    });
}

void mscl_node_discoveries_free(mscl_node_discovery *discoveries)
{
    std::free(discoveries);
}

mscl_status mscl_base_station_broadcast_set_to_idle(
    mscl_base_station *base_station,
    mscl_set_to_idle_status **status
)
{
    if (base_station == nullptr || status == nullptr) {
        return fail_null(__func__);
    }
    *status = nullptr;
    return call([&] {
        *status = new mscl_set_to_idle_status(
            base_station->base.broadcastSetToIdle()
        );
    });
}

mscl_status mscl_base_station_verify_config(
    mscl_base_station *base_station,
    const mscl_base_station_config *config,
    bool *ok,
    char *issues,
    size_t issues_len
)
{
    if (base_station == nullptr || config == nullptr || ok == nullptr) {
        return fail_null(__func__);
    }
    if (issues != nullptr && issues_len > 0) {
        issues[0] = '\0';
    }
    return call([&] {
        mscl::ConfigIssues found;
        *ok = base_station->base.verifyConfig(config->config, found);
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

mscl_status mscl_base_station_apply_config(
    mscl_base_station *base_station,
    const mscl_base_station_config *config
)
{
    if (base_station == nullptr || config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { base_station->base.applyConfig(config->config); });
}

mscl_status mscl_base_station_get_features(
    mscl_base_station *base_station,
    const mscl_base_station_features **features
)
{
    if (base_station == nullptr || features == nullptr) {
        return fail_null(__func__);
    }
    *features = nullptr;
    return call([&] {
        *features = reinterpret_cast<const mscl_base_station_features *>(
            &base_station->base.features()
        );
    });
}

mscl_status mscl_base_station_features_supports_transmit_power(
    const mscl_base_station_features *features,
    mscl_transmit_power power,
    mscl_comm_protocol comm_protocol,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = features_of(features).supportsTransmitPower(
            static_cast<WirelessTypes::TransmitPower>(power),
            static_cast<WirelessTypes::CommProtocol>(comm_protocol)
        );
    });
}

mscl_status mscl_base_station_features_supports_communication_protocol(
    const mscl_base_station_features *features,
    mscl_comm_protocol protocol,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = features_of(features).supportsCommunicationProtocol(
            static_cast<WirelessTypes::CommProtocol>(protocol)
        );
    });
}

mscl_status mscl_base_station_features_supports_buttons(
    const mscl_base_station_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = features_of(features).supportsButtons();
    });
}

mscl_status mscl_base_station_features_supports_analog_pairing(
    const mscl_base_station_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = features_of(features).supportsAnalogPairing();
    });
}

mscl_status mscl_base_station_features_supports_beacon_status(
    const mscl_base_station_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = features_of(features).supportsBeaconStatus();
    });
}

mscl_status mscl_base_station_features_supports_rf_sweep_mode(
    const mscl_base_station_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = features_of(features).supportsRfSweepMode();
    });
}

mscl_status mscl_base_station_features_supports_custom_rf_sweep_mode(
    const mscl_base_station_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = features_of(features).supportsCustomRfSweepMode();
    });
}

mscl_status mscl_base_station_features_get_button_count(
    const mscl_base_station_features *features,
    uint8_t *count
)
{
    if (features == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *count = features_of(features).buttonCount(); });
}

mscl_status mscl_base_station_features_get_analog_port_count(
    const mscl_base_station_features *features,
    uint8_t *count
)
{
    if (features == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *count = features_of(features).analogPortCount(); });
}

mscl_status mscl_base_station_features_get_transmit_powers(
    const mscl_base_station_features *features,
    mscl_comm_protocol comm_protocol,
    mscl_transmit_power *powers,
    size_t powers_len,
    size_t *count
)
{
    if (features == nullptr || powers == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *count = 0;
    return call([&] {
        *count = copy_values(
            powers,
            powers_len,
            features_of(features).transmitPowers(
                static_cast<WirelessTypes::CommProtocol>(comm_protocol)
            )
        );
    });
}

mscl_status mscl_base_station_features_get_region_transmit_powers(
    const mscl_base_station_features *features,
    mscl_region_code region,
    mscl_comm_protocol comm_protocol,
    mscl_transmit_power *powers,
    size_t powers_len,
    size_t *count
)
{
    if (features == nullptr || powers == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *count = 0;
    return call([&] {
        *count = copy_values(
            powers,
            powers_len,
            features_of(features).transmitPowers(
                static_cast<WirelessTypes::RegionCode>(region),
                static_cast<WirelessTypes::CommProtocol>(comm_protocol)
            )
        );
    });
}

mscl_status mscl_base_station_features_get_comm_protocols(
    const mscl_base_station_features *features,
    mscl_comm_protocol *protocols,
    size_t protocols_len,
    size_t *count
)
{
    if (features == nullptr || protocols == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *count = 0;
    return call([&] {
        *count = copy_values(
            protocols,
            protocols_len,
            features_of(features).commProtocols()
        );
    });
}

mscl_status mscl_base_station_features_get_max_transmit_power(
    const mscl_base_station_features *features,
    mscl_region_code region,
    mscl_comm_protocol comm_protocol,
    mscl_transmit_power *power
)
{
    if (features == nullptr || power == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *power = static_cast<mscl_transmit_power>(
            features_of(features).maxTransmitPower(
                static_cast<WirelessTypes::RegionCode>(region),
                static_cast<WirelessTypes::CommProtocol>(comm_protocol)
            )
        );
    });
}

mscl_status mscl_base_station_features_get_min_transmit_power(
    const mscl_base_station_features *features,
    mscl_region_code region,
    mscl_comm_protocol comm_protocol,
    mscl_transmit_power *power
)
{
    if (features == nullptr || power == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *power = static_cast<mscl_transmit_power>(
            features_of(features).minTransmitPower(
                static_cast<WirelessTypes::RegionCode>(region),
                static_cast<WirelessTypes::CommProtocol>(comm_protocol)
            )
        );
    });
}

void mscl_set_to_idle_status_destroy(mscl_set_to_idle_status *status)
{
    delete status;
}

mscl_status mscl_set_to_idle_status_get_result(
    mscl_set_to_idle_status *status,
    mscl_set_to_idle_result *result
)
{
    if (status == nullptr || result == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *result = static_cast<mscl_set_to_idle_result>(
            status->status.result()
        );
    });
}

mscl_status mscl_set_to_idle_status_complete(
    mscl_set_to_idle_status *status,
    uint64_t timeout_ms,
    bool *complete
)
{
    if (status == nullptr || complete == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *complete = status->status.complete(timeout_ms); });
}

mscl_status mscl_set_to_idle_status_cancel(mscl_set_to_idle_status *status)
{
    if (status == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { status->status.cancel(); });
}

mscl_status mscl_base_station_config_create(mscl_base_station_config **config)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    *config = nullptr;
    return call([&] { *config = new mscl_base_station_config(); });
}

void mscl_base_station_config_destroy(mscl_base_station_config *config)
{
    delete config;
}

mscl_status mscl_base_station_config_get_transmit_power(
    const mscl_base_station_config *config,
    mscl_transmit_power *power
)
{
    if (config == nullptr || power == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *power =
            static_cast<mscl_transmit_power>(config->config.transmitPower());
    });
}

mscl_status mscl_base_station_config_set_transmit_power(
    mscl_base_station_config *config,
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

mscl_status mscl_base_station_config_get_communication_protocol(
    const mscl_base_station_config *config,
    mscl_comm_protocol *protocol
)
{
    if (config == nullptr || protocol == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *protocol = static_cast<mscl_comm_protocol>(
            config->config.communicationProtocol()
        );
    });
}

mscl_status mscl_base_station_config_set_communication_protocol(
    mscl_base_station_config *config,
    mscl_comm_protocol protocol
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.communicationProtocol(
            static_cast<WirelessTypes::CommProtocol>(protocol)
        );
    });
}

mscl_status mscl_base_station_config_get_button_long_press(
    const mscl_base_station_config *config,
    uint8_t button_number,
    mscl_base_station_button *button
)
{
    if (config == nullptr || button == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        const mscl::BaseStationButton result =
            config->config.buttonLongPress(button_number);
        button->command = static_cast<mscl_button_command>(result.command());
        button->node_address = result.nodeAddress();
    });
}

mscl_status mscl_base_station_config_set_button_long_press(
    mscl_base_station_config *config,
    uint8_t button_number,
    mscl_base_station_button button
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.buttonLongPress(
            button_number,
            mscl::BaseStationButton(
                static_cast<mscl::BaseStationButton::Command>(button.command),
                button.node_address
            )
        );
    });
}

mscl_status mscl_base_station_config_get_button_short_press(
    const mscl_base_station_config *config,
    uint8_t button_number,
    mscl_base_station_button *button
)
{
    if (config == nullptr || button == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        const mscl::BaseStationButton result =
            config->config.buttonShortPress(button_number);
        button->command = static_cast<mscl_button_command>(result.command());
        button->node_address = result.nodeAddress();
    });
}

mscl_status mscl_base_station_config_set_button_short_press(
    mscl_base_station_config *config,
    uint8_t button_number,
    mscl_base_station_button button
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.buttonShortPress(
            button_number,
            mscl::BaseStationButton(
                static_cast<mscl::BaseStationButton::Command>(button.command),
                button.node_address
            )
        );
    });
}

mscl_status mscl_base_station_config_get_analog_pairing_enable(
    const mscl_base_station_config *config,
    bool *enable
)
{
    if (config == nullptr || enable == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *enable = config->config.analogPairingEnable(); });
}

mscl_status mscl_base_station_config_set_analog_pairing_enable(
    mscl_base_station_config *config,
    bool enable
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { config->config.analogPairingEnable(enable); });
}

mscl_status mscl_base_station_config_get_analog_timeout_time(
    const mscl_base_station_config *config,
    uint16_t *seconds
)
{
    if (config == nullptr || seconds == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *seconds = config->config.analogTimeoutTime(); });
}

mscl_status mscl_base_station_config_set_analog_timeout_time(
    mscl_base_station_config *config,
    uint16_t seconds
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { config->config.analogTimeoutTime(seconds); });
}

mscl_status mscl_base_station_config_get_analog_timeout_voltage(
    const mscl_base_station_config *config,
    float *voltage
)
{
    if (config == nullptr || voltage == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *voltage = config->config.analogTimeoutVoltage(); });
}

mscl_status mscl_base_station_config_set_analog_timeout_voltage(
    mscl_base_station_config *config,
    float voltage
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { config->config.analogTimeoutVoltage(voltage); });
}

mscl_status mscl_base_station_config_get_analog_exceedance_enable(
    const mscl_base_station_config *config,
    bool *enable
)
{
    if (config == nullptr || enable == nullptr) {
        return fail_null(__func__);
    }
    // MSCL's getter is not const, although it only reads.
    return call([&] {
        *enable = const_cast<mscl::BaseStationConfig &>(config->config)
                      .analogExceedanceEnable();
    });
}

mscl_status mscl_base_station_config_set_analog_exceedance_enable(
    mscl_base_station_config *config,
    bool enable
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { config->config.analogExceedanceEnable(enable); });
}

mscl_status mscl_base_station_config_get_analog_pairing(
    const mscl_base_station_config *config,
    uint8_t port_number,
    mscl_base_station_analog_pair *pair
)
{
    if (config == nullptr || pair == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        const mscl::BaseStationAnalogPair result =
            config->config.analogPairing(port_number);
        pair->node_address = result.nodeAddress();
        pair->node_channel = result.nodeChannel();
        pair->expect_float_data = result.expectFloatData();
        pair->output_0v = result.outputVal_0V();
        pair->output_3v = result.outputVal_3V();
    });
}

mscl_status mscl_base_station_config_set_analog_pairing(
    mscl_base_station_config *config,
    uint8_t port_number,
    mscl_base_station_analog_pair pair
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.analogPairing(
            port_number,
            pair.expect_float_data
                ? mscl::BaseStationAnalogPair::Float(
                      pair.node_address,
                      pair.node_channel,
                      pair.output_0v,
                      pair.output_3v
                  )
                : mscl::BaseStationAnalogPair::NonFloat(
                      pair.node_address,
                      pair.node_channel
                  )
        );
    });
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

mscl_status mscl_node_device_name(
    uint32_t node_address,
    char *name,
    size_t name_len
)
{
    if (name == nullptr) {
        return fail_null(__func__);
    }
    copy_string(name, name_len, "");
    return call([&] {
        copy_string(
            name,
            name_len,
            mscl::WirelessNode::deviceName(node_address)
        );
    });
}

mscl_status mscl_node_get_serial(
    mscl_node *node,
    char *serial,
    size_t serial_len
)
{
    if (node == nullptr || serial == nullptr) {
        return fail_null(__func__);
    }
    copy_string(serial, serial_len, "");
    return call([&] {
        copy_string(serial, serial_len, node->node.serial());
    });
}

mscl_status mscl_node_get_name(mscl_node *node, char *name, size_t name_len)
{
    if (node == nullptr || name == nullptr) {
        return fail_null(__func__);
    }
    copy_string(name, name_len, "");
    return call([&] { copy_string(name, name_len, node->node.name()); });
}

mscl_status mscl_node_get_features(
    mscl_node *node,
    const mscl_node_features **features
)
{
    if (node == nullptr || features == nullptr) {
        return fail_null(__func__);
    }
    *features = nullptr;
    return call([&] {
        *features = reinterpret_cast<const mscl_node_features *>(
            &node->node.features()
        );
    });
}

mscl_status mscl_node_set_base_station(
    mscl_node *node,
    mscl_base_station *base_station
)
{
    if (node == nullptr || base_station == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { node->node.setBaseStation(base_station->base); });
}

mscl_status mscl_node_has_base_station(
    mscl_node *node,
    mscl_base_station *base_station,
    bool *has
)
{
    if (node == nullptr || base_station == nullptr || has == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *has = node->node.hasBaseStation(base_station->base);
    });
}

mscl_status mscl_node_get_eeprom_cache(
    mscl_node *node,
    mscl_eeprom_entry **entries,
    size_t *count
)
{
    if (node == nullptr || entries == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *entries = nullptr;
    *count = 0;
    return call([&] {
        const WirelessTypes::EepromMap cache = node->node.getEepromCache();
        if (cache.empty()) {
            return;
        }
        mscl_eeprom_entry *result =
            allocate_zeroed<mscl_eeprom_entry>(cache.size());
        size_t i = 0;
        for (const auto &[location, value] : cache) {
            result[i].location = location;
            result[i].value = value;
            i++;
        }
        *entries = result;
        *count = cache.size();
    });
}

void mscl_eeprom_entries_free(mscl_eeprom_entry *entries)
{
    std::free(entries);
}

mscl_status mscl_node_set_to_idle(
    mscl_node *node,
    mscl_set_to_idle_status **status
)
{
    if (node == nullptr || status == nullptr) {
        return fail_null(__func__);
    }
    *status = nullptr;
    return call([&] {
        *status = new mscl_set_to_idle_status(node->node.setToIdle());
    });
}

mscl_status mscl_node_poll(
    mscl_node *node,
    uint16_t channel_mask,
    mscl_poll_value **values,
    size_t *count
)
{
    if (node == nullptr || values == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *values = nullptr;
    *count = 0;
    return call([&] {
        const mscl::WirelessPollData data =
            node->node.poll(mscl::ChannelMask(channel_mask));
        if (data.empty()) {
            return;
        }
        mscl_poll_value *result = allocate_zeroed<mscl_poll_value>(data.size());
        size_t i = 0;
        for (const auto &[channel, value] : data) {
            result[i].channel = static_cast<mscl_channel_id>(channel);
            result[i].value = value;
            i++;
        }
        *values = result;
        *count = data.size();
    });
}

void mscl_poll_values_free(mscl_poll_value *values)
{
    std::free(values);
}

mscl_status mscl_node_get_diagnostic_info(
    mscl_node *node,
    mscl_data_point **points,
    size_t *count
)
{
    if (node == nullptr || points == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *points = nullptr;
    *count = 0;
    return call([&] {
        // fill_points fills the points of a sweep; only those are kept.
        mscl_sweep sweep{};
        fill_points(node->node.getDiagnosticInfo(), sweep);
        *points = sweep.points;
        *count = sweep.point_count;
    });
}

void mscl_data_points_free(mscl_data_point *points)
{
    std::free(points);
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

mscl_status mscl_node_get_last_communication_time(
    mscl_node *node,
    uint64_t *time_ns
)
{
    if (node == nullptr || time_ns == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *time_ns = node->node.lastCommunicationTime().nanoseconds();
    });
}

mscl_status mscl_node_get_last_device_state(
    mscl_node *node,
    mscl_device_state *state
)
{
    if (node == nullptr || state == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *state = static_cast<mscl_device_state>(node->node.lastDeviceState());
    });
}

mscl_status mscl_node_use_group_read(
    mscl_node *node,
    bool use_group
)
{
    if (node == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { node->node.useGroupRead(use_group); });
}

mscl_status mscl_node_set_retries(
    mscl_node *node,
    uint8_t retries
)
{
    if (node == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { node->node.readWriteRetries(retries); });
}

mscl_status mscl_node_get_retries(
    mscl_node *node,
    uint8_t *retries
)
{
    if (node == nullptr || retries == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *retries = node->node.readWriteRetries(); });
}

mscl_status mscl_node_use_eeprom_cache(
    mscl_node *node,
    bool use_cache
)
{
    if (node == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { node->node.useEepromCache(use_cache); });
}

mscl_status mscl_node_clear_eeprom_cache(
    mscl_node *node
)
{
    if (node == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { node->node.clearEepromCache(); });
}

mscl_status mscl_node_get_node_address(
    mscl_node *node,
    uint32_t *address
)
{
    if (node == nullptr || address == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *address = node->node.nodeAddress(); });
}

mscl_status mscl_node_get_frequency(
    mscl_node *node,
    mscl_frequency *frequency
)
{
    if (node == nullptr || frequency == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *frequency = static_cast<mscl_frequency>(node->node.frequency());
    });
}

mscl_status mscl_node_get_communication_protocol(
    mscl_node *node,
    mscl_comm_protocol *protocol
)
{
    if (node == nullptr || protocol == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *protocol =
            static_cast<mscl_comm_protocol>(node->node.communicationProtocol());
    });
}

mscl_status mscl_node_get_firmware_version(
    mscl_node *node,
    mscl_version *version
)
{
    if (node == nullptr || version == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *version = to_c(node->node.firmwareVersion()); });
}

mscl_status mscl_node_get_model(
    mscl_node *node,
    mscl_node_model *model
)
{
    if (node == nullptr || model == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *model = static_cast<mscl_node_model>(node->node.model());
    });
}

mscl_status mscl_node_get_microcontroller(
    mscl_node *node,
    mscl_microcontroller *microcontroller
)
{
    if (node == nullptr || microcontroller == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *microcontroller =
            static_cast<mscl_microcontroller>(node->node.microcontroller());
    });
}

mscl_status mscl_node_get_radio_features(
    mscl_node *node,
    mscl_radio_features *radio_features
)
{
    if (node == nullptr || radio_features == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *radio_features = to_c(node->node.radioFeatures()); });
}

mscl_status mscl_node_get_data_storage_size(
    mscl_node *node,
    uint64_t *size
)
{
    if (node == nullptr || size == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *size = node->node.dataStorageSize(); });
}

mscl_status mscl_node_get_region_code(
    mscl_node *node,
    mscl_region_code *region_code
)
{
    if (node == nullptr || region_code == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *region_code = static_cast<mscl_region_code>(node->node.regionCode());
    });
}

mscl_status mscl_node_ping(
    mscl_node *node,
    mscl_ping_result *result
)
{
    if (node == nullptr || result == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *result = to_c(node->node.ping()); });
}

mscl_status mscl_node_sleep(
    mscl_node *node,
    bool *success
)
{
    if (node == nullptr || success == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *success = node->node.sleep(); });
}

mscl_status mscl_node_cycle_power(
    mscl_node *node
)
{
    if (node == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { node->node.cyclePower(); });
}

mscl_status mscl_node_reset_radio(
    mscl_node *node
)
{
    if (node == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { node->node.resetRadio(); });
}

mscl_status mscl_node_change_frequency(
    mscl_node *node,
    mscl_frequency frequency
)
{
    if (node == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        node->node.changeFrequency(
            static_cast<WirelessTypes::Frequency>(frequency)
        );
    });
}

mscl_status mscl_node_erase(
    mscl_node *node
)
{
    if (node == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { node->node.erase(); });
}

mscl_status mscl_node_start_non_sync_sampling(
    mscl_node *node,
    bool *success
)
{
    if (node == nullptr || success == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *success = node->node.startNonSyncSampling(); });
}

mscl_status mscl_node_resend_start_sync_sampling(
    mscl_node *node,
    bool *success
)
{
    if (node == nullptr || success == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *success = node->node.resendStartSyncSampling(); });
}

mscl_status mscl_node_clear_histogram(
    mscl_node *node
)
{
    if (node == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { node->node.clearHistogram(); });
}

mscl_status mscl_node_auto_balance(
    mscl_node *node,
    uint16_t channel_mask,
    float target_percent,
    mscl_auto_balance_result *result
)
{
    if (node == nullptr || result == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *result = to_c(
            node->node.autoBalance(
                mscl::ChannelMask(channel_mask),
                target_percent
            )
        );
    });
}

mscl_status mscl_node_auto_cal_shm_link(
    mscl_node *node,
    mscl_auto_cal_result_shm_link *result
)
{
    if (node == nullptr || result == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *result = to_c(node->node.autoCal_shmLink()); });
}

mscl_status mscl_node_auto_cal_shm_link_201(
    mscl_node *node,
    mscl_auto_cal_result_shm_link_201 *result
)
{
    if (node == nullptr || result == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *result = to_c(node->node.autoCal_shmLink201()); });
}

mscl_status mscl_node_auto_shunt_cal(
    mscl_node *node,
    uint16_t channel_mask,
    const mscl_shunt_cal_cmd_info *command_info,
    mscl_auto_shunt_cal_result *result
)
{
    if (node == nullptr || command_info == nullptr || result == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *result = to_c(
            node->node.autoShuntCal(
                mscl::ChannelMask(channel_mask),
                to_mscl(*command_info)
            )
        );
    });
}

mscl_status mscl_node_read_eeprom(
    mscl_node *node,
    uint16_t location,
    uint16_t *value
)
{
    if (node == nullptr || value == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *value = node->node.readEeprom(location); });
}

mscl_status mscl_node_write_eeprom(
    mscl_node *node,
    uint16_t location,
    uint16_t value
)
{
    if (node == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { node->node.writeEeprom(location, value); });
}

mscl_status mscl_node_test_communication_protocol(
    mscl_node *node,
    mscl_comm_protocol protocol,
    bool *success
)
{
    if (node == nullptr || success == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *success = node->node.testCommunicationProtocol(
            static_cast<WirelessTypes::CommProtocol>(protocol)
        );
    });
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

mscl_status mscl_node_get_percent_full(
    mscl_node *node,
    float *percent
)
{
    if (node == nullptr || percent == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *percent = node->node.percentFull(); });
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

mscl_status mscl_node_get_active_channels(
    mscl_node *node,
    uint16_t *mask
)
{
    if (node == nullptr || mask == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *mask = node->node.getActiveChannels().toMask(); });
}

mscl_status mscl_node_get_sample_rate(
    mscl_node *node,
    mscl_sample_rate *rate
)
{
    if (node == nullptr || rate == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *rate = static_cast<mscl_sample_rate>(node->node.getSampleRate());
    });
}

mscl_status mscl_node_get_num_sweeps(
    mscl_node *node,
    uint32_t *sweeps
)
{
    if (node == nullptr || sweeps == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *sweeps = node->node.getNumSweeps(); });
}

mscl_status mscl_node_get_unlimited_duration(
    mscl_node *node,
    bool *enabled
)
{
    if (node == nullptr || enabled == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *enabled = node->node.getUnlimitedDuration(); });
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
    uint64_t *time_ns
)
{
    if (node == nullptr || time_ns == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *time_ns = node->node.getTimeBetweenBursts().getNanoseconds();
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

mscl_status mscl_node_get_hardware_offset(
    mscl_node *node,
    uint16_t channel_mask,
    uint16_t *offset
)
{
    if (node == nullptr || offset == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *offset = node->node.getHardwareOffset(mscl::ChannelMask(channel_mask));
    });
}

mscl_status mscl_node_get_anti_aliasing_filter(
    mscl_node *node,
    uint16_t channel_mask,
    mscl_filter *filter
)
{
    if (node == nullptr || filter == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *filter = static_cast<mscl_filter>(
            node->node.getAntiAliasingFilter(mscl::ChannelMask(channel_mask))
        );
    });
}

mscl_status mscl_node_get_cfc_filter_configuration(
    mscl_node *node,
    mscl_channel_frequency_class *cfc
)
{
    if (node == nullptr || cfc == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *cfc = static_cast<mscl_channel_frequency_class>(
            node->node.getCfcFilterConfiguration()
        );
    });
}

mscl_status mscl_node_get_low_pass_filter(
    mscl_node *node,
    uint16_t channel_mask,
    mscl_filter *filter
)
{
    if (node == nullptr || filter == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *filter = static_cast<mscl_filter>(
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

mscl_status mscl_node_get_debounce_filter(
    mscl_node *node,
    uint16_t channel_mask,
    uint16_t *milliseconds
)
{
    if (node == nullptr || milliseconds == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *milliseconds =
            node->node.getDebounceFilter(mscl::ChannelMask(channel_mask));
    });
}

mscl_status mscl_node_get_pull_up_resistor(
    mscl_node *node,
    uint16_t channel_mask,
    bool *enabled
)
{
    if (node == nullptr || enabled == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *enabled =
            node->node.getPullUpResistor(mscl::ChannelMask(channel_mask));
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

mscl_status mscl_node_get_gauge_factor(
    mscl_node *node,
    uint16_t channel_mask,
    float *factor
)
{
    if (node == nullptr || factor == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *factor = node->node.getGaugeFactor(mscl::ChannelMask(channel_mask));
    });
}

mscl_status mscl_node_get_excitation_voltage(
    mscl_node *node,
    mscl_voltage *voltage
)
{
    if (node == nullptr || voltage == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *voltage = static_cast<mscl_voltage>(node->node.getExcitationVoltage());
    });
}

mscl_status mscl_node_get_adc_voltage_ref(
    mscl_node *node,
    mscl_voltage *voltage
)
{
    if (node == nullptr || voltage == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *voltage = static_cast<mscl_voltage>(node->node.getAdcVoltageRef());
    });
}

mscl_status mscl_node_get_gain_amplifier_voltage_ref(
    mscl_node *node,
    mscl_voltage *voltage
)
{
    if (node == nullptr || voltage == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *voltage =
            static_cast<mscl_voltage>(node->node.getGainAmplifierVoltageRef());
    });
}

mscl_status mscl_node_get_gauge_resistance(
    mscl_node *node,
    uint16_t *resistance
)
{
    if (node == nullptr || resistance == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *resistance = node->node.getGaugeResistance(); });
}

mscl_status mscl_node_get_num_active_gauges(
    mscl_node *node,
    uint16_t *count
)
{
    if (node == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *count = node->node.getNumActiveGauges(); });
}

mscl_status mscl_node_get_low_battery_threshold(
    mscl_node *node,
    float *voltage
)
{
    if (node == nullptr || voltage == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *voltage = node->node.getLowBatteryThreshold(); });
}

mscl_status mscl_node_get_linear_equation(
    mscl_node *node,
    uint16_t channel_mask,
    mscl_linear_equation *equation
)
{
    if (node == nullptr || equation == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *equation =
            to_c(node->node.getLinearEquation(mscl::ChannelMask(channel_mask)));
    });
}

mscl_status mscl_node_get_unit(
    mscl_node *node,
    uint16_t channel_mask,
    mscl_cal_coef_unit *unit
)
{
    if (node == nullptr || unit == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *unit = static_cast<mscl_cal_coef_unit>(
            node->node.getUnit(mscl::ChannelMask(channel_mask))
        );
    });
}

mscl_status mscl_node_get_factory_calibration_linear_eq(
    mscl_node *node,
    uint16_t channel_mask,
    mscl_linear_equation *equation
)
{
    if (node == nullptr || equation == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *equation = to_c(
            node->node.getFactoryCalibrationLinearEq(
                mscl::ChannelMask(channel_mask)
            )
        );
    });
}

mscl_status mscl_node_get_factory_calibration_unit(
    mscl_node *node,
    uint16_t channel_mask,
    mscl_cal_coef_unit *unit
)
{
    if (node == nullptr || unit == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *unit = static_cast<mscl_cal_coef_unit>(
            node->node.getFactoryCalibrationUnit(
                mscl::ChannelMask(channel_mask)
            )
        );
    });
}

mscl_status mscl_node_get_filter_settling_time(
    mscl_node *node,
    uint16_t channel_mask,
    mscl_settling_time *settling_time
)
{
    if (node == nullptr || settling_time == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *settling_time = static_cast<mscl_settling_time>(
            node->node.getFilterSettlingTime(mscl::ChannelMask(channel_mask))
        );
    });
}

mscl_status mscl_node_get_thermocouple_type(
    mscl_node *node,
    uint16_t channel_mask,
    mscl_thermocouple_type *type
)
{
    if (node == nullptr || type == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *type = static_cast<mscl_thermocouple_type>(
            node->node.getThermocoupleType(mscl::ChannelMask(channel_mask))
        );
    });
}

mscl_status mscl_node_get_temp_sensor_options(
    mscl_node *node,
    uint16_t channel_mask,
    mscl_temp_sensor_options *options
)
{
    if (node == nullptr || options == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *options = to_c(
            node->node.getTempSensorOptions(mscl::ChannelMask(channel_mask))
        );
    });
}

mscl_status mscl_node_get_fatigue_options(
    mscl_node *node,
    mscl_fatigue_options *options
)
{
    if (node == nullptr || options == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *options = to_c(node->node.getFatigueOptions()); });
}

mscl_status mscl_node_get_histogram_options(
    mscl_node *node,
    mscl_histogram_options *options
)
{
    if (node == nullptr || options == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *options = to_c(node->node.getHistogramOptions()); });
}

mscl_status mscl_node_get_activity_sense(
    mscl_node *node,
    mscl_activity_sense *activity_sense
)
{
    if (node == nullptr || activity_sense == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *activity_sense = to_c(node->node.getActivitySense()); });
}

mscl_status mscl_node_get_event_trigger_options(
    mscl_node *node,
    mscl_event_trigger_options *options
)
{
    if (node == nullptr || options == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *options = to_c(node->node.getEventTriggerOptions()); });
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

mscl_status mscl_node_get_storage_limit_mode(
    mscl_node *node,
    mscl_storage_limit_mode *mode
)
{
    if (node == nullptr || mode == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *mode = static_cast<mscl_storage_limit_mode>(
            node->node.getStorageLimitMode()
        );
    });
}

mscl_status mscl_node_get_sensor_delay(
    mscl_node *node,
    uint32_t *delay
)
{
    if (node == nullptr || delay == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *delay = node->node.getSensorDelay(); });
}

mscl_status mscl_node_get_data_mode(
    mscl_node *node,
    mscl_data_mode *mode
)
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
        *mask = node->node.getDerivedChannelMask(
            static_cast<WirelessTypes::DerivedCategory>(category)
        ).toMask();
    });
}

mscl_status mscl_node_get_derived_velocity_unit(
    mscl_node *node,
    mscl_derived_velocity_unit *unit
)
{
    if (node == nullptr || unit == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *unit = static_cast<mscl_derived_velocity_unit>(
            node->node.getDerivedVelocityUnit()
        );
    });
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

mscl_status mscl_node_config_get_default_mode(
    const mscl_node_config *config,
    mscl_default_mode *mode
)
{
    if (config == nullptr || mode == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *mode = static_cast<mscl_default_mode>(config->config.defaultMode());
    });
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

mscl_status mscl_node_config_get_inactivity_timeout(
    const mscl_node_config *config,
    uint16_t *seconds
)
{
    if (config == nullptr || seconds == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *seconds = config->config.inactivityTimeout(); });
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

mscl_status mscl_node_config_get_check_radio_interval(
    const mscl_node_config *config,
    uint8_t *seconds
)
{
    if (config == nullptr || seconds == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *seconds = config->config.checkRadioInterval(); });
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

mscl_status mscl_node_config_get_transmit_power(
    const mscl_node_config *config,
    mscl_transmit_power *power
)
{
    if (config == nullptr || power == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *power =
            static_cast<mscl_transmit_power>(config->config.transmitPower());
    });
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

mscl_status mscl_node_config_get_sampling_mode(
    const mscl_node_config *config,
    mscl_sampling_mode *mode
)
{
    if (config == nullptr || mode == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *mode = static_cast<mscl_sampling_mode>(config->config.samplingMode());
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

mscl_status mscl_node_config_get_sample_rate(
    const mscl_node_config *config,
    mscl_sample_rate *rate
)
{
    if (config == nullptr || rate == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *rate = static_cast<mscl_sample_rate>(config->config.sampleRate());
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

mscl_status mscl_node_config_get_active_channels(
    const mscl_node_config *config,
    uint16_t *mask
)
{
    if (config == nullptr || mask == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *mask = config->config.activeChannels().toMask(); });
}

mscl_status mscl_node_config_set_active_channels(
    mscl_node_config *config,
    uint16_t mask
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.activeChannels(mscl::ChannelMask(mask));
    });
}

mscl_status mscl_node_config_get_num_sweeps(
    const mscl_node_config *config,
    uint32_t *sweeps
)
{
    if (config == nullptr || sweeps == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *sweeps = config->config.numSweeps(); });
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

mscl_status mscl_node_config_get_unlimited_duration(
    const mscl_node_config *config,
    bool *enabled
)
{
    if (config == nullptr || enabled == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *enabled = config->config.unlimitedDuration(); });
}

mscl_status mscl_node_config_set_unlimited_duration(
    mscl_node_config *config,
    bool enabled
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { config->config.unlimitedDuration(enabled); });
}

mscl_status mscl_node_config_get_data_format(
    const mscl_node_config *config,
    mscl_data_format *format
)
{
    if (config == nullptr || format == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *format = static_cast<mscl_data_format>(config->config.dataFormat());
    });
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

mscl_status mscl_node_config_get_data_collection_method(
    const mscl_node_config *config,
    mscl_data_collection_method *method
)
{
    if (config == nullptr || method == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *method = static_cast<mscl_data_collection_method>(
            config->config.dataCollectionMethod()
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

mscl_status mscl_node_config_get_time_between_bursts(
    const mscl_node_config *config,
    uint64_t *time_ns
)
{
    if (config == nullptr || time_ns == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *time_ns = config->config.timeBetweenBursts().getNanoseconds();
    });
}

mscl_status mscl_node_config_set_time_between_bursts(
    mscl_node_config *config,
    uint64_t time_ns
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.timeBetweenBursts(mscl::TimeSpan::NanoSeconds(time_ns));
    });
}

mscl_status mscl_node_config_get_lost_beacon_timeout(
    const mscl_node_config *config,
    uint16_t *minutes
)
{
    if (config == nullptr || minutes == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *minutes = config->config.lostBeaconTimeout(); });
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

mscl_status mscl_node_config_get_pull_up_resistor(
    const mscl_node_config *config,
    uint16_t channel_mask,
    bool *enabled
)
{
    if (config == nullptr || enabled == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *enabled =
            config->config.pullUpResistor(mscl::ChannelMask(channel_mask));
    });
}

mscl_status mscl_node_config_set_pull_up_resistor(
    mscl_node_config *config,
    uint16_t channel_mask,
    bool enabled
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.pullUpResistor(mscl::ChannelMask(channel_mask), enabled);
    });
}

mscl_status mscl_node_config_get_input_range(
    const mscl_node_config *config,
    uint16_t channel_mask,
    mscl_input_range *range
)
{
    if (config == nullptr || range == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *range = static_cast<mscl_input_range>(
            config->config.inputRange(mscl::ChannelMask(channel_mask))
        );
    });
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

mscl_status mscl_node_config_get_hardware_offset(
    const mscl_node_config *config,
    uint16_t channel_mask,
    uint16_t *offset
)
{
    if (config == nullptr || offset == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *offset =
            config->config.hardwareOffset(mscl::ChannelMask(channel_mask));
    });
}

mscl_status mscl_node_config_set_hardware_offset(
    mscl_node_config *config,
    uint16_t channel_mask,
    uint16_t offset
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.hardwareOffset(mscl::ChannelMask(channel_mask), offset);
    });
}

mscl_status mscl_node_config_get_anti_aliasing_filter(
    const mscl_node_config *config,
    uint16_t channel_mask,
    mscl_filter *filter
)
{
    if (config == nullptr || filter == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *filter = static_cast<mscl_filter>(
            config->config.antiAliasingFilter(mscl::ChannelMask(channel_mask))
        );
    });
}

mscl_status mscl_node_config_set_anti_aliasing_filter(
    mscl_node_config *config,
    uint16_t channel_mask,
    mscl_filter filter
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.antiAliasingFilter(
            mscl::ChannelMask(channel_mask),
            static_cast<WirelessTypes::Filter>(filter)
        );
    });
}

mscl_status mscl_node_config_get_cfc_filter_config(
    const mscl_node_config *config,
    mscl_channel_frequency_class *cfc
)
{
    if (config == nullptr || cfc == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *cfc = static_cast<mscl_channel_frequency_class>(
            config->config.cfcFilterConfig()
        );
    });
}

mscl_status mscl_node_config_set_cfc_filter_config(
    mscl_node_config *config,
    mscl_channel_frequency_class cfc
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.cfcFilterConfig(
            static_cast<WirelessTypes::ChannelFrequencyClass>(cfc)
        );
    });
}

mscl_status mscl_node_config_get_low_pass_filter(
    const mscl_node_config *config,
    uint16_t channel_mask,
    mscl_filter *filter
)
{
    if (config == nullptr || filter == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *filter = static_cast<mscl_filter>(
            config->config.lowPassFilter(mscl::ChannelMask(channel_mask))
        );
    });
}

mscl_status mscl_node_config_set_low_pass_filter(
    mscl_node_config *config,
    uint16_t channel_mask,
    mscl_filter filter
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

mscl_status mscl_node_config_get_high_pass_filter(
    const mscl_node_config *config,
    uint16_t channel_mask,
    mscl_high_pass_filter *filter
)
{
    if (config == nullptr || filter == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *filter = static_cast<mscl_high_pass_filter>(
            config->config.highPassFilter(mscl::ChannelMask(channel_mask))
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

mscl_status mscl_node_config_get_gauge_factor(
    const mscl_node_config *config,
    uint16_t channel_mask,
    float *factor
)
{
    if (config == nullptr || factor == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *factor = config->config.gaugeFactor(mscl::ChannelMask(channel_mask));
    });
}

mscl_status mscl_node_config_set_gauge_factor(
    mscl_node_config *config,
    uint16_t channel_mask,
    float factor
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.gaugeFactor(mscl::ChannelMask(channel_mask), factor);
    });
}

mscl_status mscl_node_config_get_gauge_resistance(
    const mscl_node_config *config,
    uint16_t *resistance
)
{
    if (config == nullptr || resistance == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *resistance = config->config.gaugeResistance(); });
}

mscl_status mscl_node_config_set_gauge_resistance(
    mscl_node_config *config,
    uint16_t resistance
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { config->config.gaugeResistance(resistance); });
}

mscl_status mscl_node_config_get_excitation_voltage(
    const mscl_node_config *config,
    mscl_voltage *voltage
)
{
    if (config == nullptr || voltage == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *voltage =
            static_cast<mscl_voltage>(config->config.excitationVoltage());
    });
}

mscl_status mscl_node_config_set_excitation_voltage(
    mscl_node_config *config,
    mscl_voltage voltage
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.excitationVoltage(
            static_cast<WirelessTypes::Voltage>(voltage)
        );
    });
}

mscl_status mscl_node_config_get_num_active_gauges(
    const mscl_node_config *config,
    uint16_t *count
)
{
    if (config == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *count = config->config.numActiveGauges(); });
}

mscl_status mscl_node_config_set_num_active_gauges(
    mscl_node_config *config,
    uint16_t count
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { config->config.numActiveGauges(count); });
}

mscl_status mscl_node_config_get_low_battery_threshold(
    const mscl_node_config *config,
    float *voltage
)
{
    if (config == nullptr || voltage == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *voltage = config->config.lowBatteryThreshold(); });
}

mscl_status mscl_node_config_set_low_battery_threshold(
    mscl_node_config *config,
    float voltage
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { config->config.lowBatteryThreshold(voltage); });
}

mscl_status mscl_node_config_get_linear_equation(
    const mscl_node_config *config,
    uint16_t channel_mask,
    mscl_linear_equation *equation
)
{
    if (config == nullptr || equation == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *equation = to_c(
            config->config.linearEquation(mscl::ChannelMask(channel_mask))
        );
    });
}

mscl_status mscl_node_config_set_linear_equation(
    mscl_node_config *config,
    uint16_t channel_mask,
    const mscl_linear_equation *equation
)
{
    if (config == nullptr || equation == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.linearEquation(
            mscl::ChannelMask(channel_mask),
            to_mscl(*equation)
        );
    });
}

mscl_status mscl_node_config_get_unit(
    const mscl_node_config *config,
    uint16_t channel_mask,
    mscl_cal_coef_unit *unit
)
{
    if (config == nullptr || unit == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *unit = static_cast<mscl_cal_coef_unit>(
            config->config.unit(mscl::ChannelMask(channel_mask))
        );
    });
}

mscl_status mscl_node_config_set_unit(
    mscl_node_config *config,
    uint16_t channel_mask,
    mscl_cal_coef_unit unit
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.unit(
            mscl::ChannelMask(channel_mask),
            static_cast<WirelessTypes::CalCoef_Unit>(unit)
        );
    });
}

mscl_status mscl_node_config_get_equation_type(
    const mscl_node_config *config,
    uint16_t channel_mask,
    mscl_cal_coef_equation_type *equation
)
{
    if (config == nullptr || equation == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *equation = static_cast<mscl_cal_coef_equation_type>(
            config->config.equationType(mscl::ChannelMask(channel_mask))
        );
    });
}

mscl_status mscl_node_config_set_equation_type(
    mscl_node_config *config,
    uint16_t channel_mask,
    mscl_cal_coef_equation_type equation
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.equationType(
            mscl::ChannelMask(channel_mask),
            static_cast<WirelessTypes::CalCoef_EquationType>(equation)
        );
    });
}

mscl_status mscl_node_config_get_filter_settling_time(
    const mscl_node_config *config,
    uint16_t channel_mask,
    mscl_settling_time *settling_time
)
{
    if (config == nullptr || settling_time == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *settling_time = static_cast<mscl_settling_time>(
            config->config.filterSettlingTime(mscl::ChannelMask(channel_mask))
        );
    });
}

mscl_status mscl_node_config_set_filter_settling_time(
    mscl_node_config *config,
    uint16_t channel_mask,
    mscl_settling_time settling_time
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.filterSettlingTime(
            mscl::ChannelMask(channel_mask),
            static_cast<WirelessTypes::SettlingTime>(settling_time)
        );
    });
}

mscl_status mscl_node_config_get_thermocouple_type(
    const mscl_node_config *config,
    uint16_t channel_mask,
    mscl_thermocouple_type *type
)
{
    if (config == nullptr || type == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *type = static_cast<mscl_thermocouple_type>(
            config->config.thermocoupleType(mscl::ChannelMask(channel_mask))
        );
    });
}

mscl_status mscl_node_config_set_thermocouple_type(
    mscl_node_config *config,
    uint16_t channel_mask,
    mscl_thermocouple_type type
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.thermocoupleType(
            mscl::ChannelMask(channel_mask),
            static_cast<WirelessTypes::ThermocoupleType>(type)
        );
    });
}

mscl_status mscl_node_config_get_temp_sensor_options(
    const mscl_node_config *config,
    uint16_t channel_mask,
    mscl_temp_sensor_options *options
)
{
    if (config == nullptr || options == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *options = to_c(
            config->config.tempSensorOptions(mscl::ChannelMask(channel_mask))
        );
    });
}

mscl_status mscl_node_config_set_temp_sensor_options(
    mscl_node_config *config,
    uint16_t channel_mask,
    const mscl_temp_sensor_options *options
)
{
    if (config == nullptr || options == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.tempSensorOptions(
            mscl::ChannelMask(channel_mask),
            to_mscl(*options)
        );
    });
}

mscl_status mscl_node_config_get_debounce_filter(
    const mscl_node_config *config,
    uint16_t channel_mask,
    uint16_t *milliseconds
)
{
    if (config == nullptr || milliseconds == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *milliseconds =
            config->config.debounceFilter(mscl::ChannelMask(channel_mask));
    });
}

mscl_status mscl_node_config_set_debounce_filter(
    mscl_node_config *config,
    uint16_t channel_mask,
    uint16_t milliseconds
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.debounceFilter(
            mscl::ChannelMask(channel_mask),
            milliseconds
        );
    });
}

mscl_status mscl_node_config_get_fatigue_options(
    const mscl_node_config *config,
    mscl_fatigue_options *options
)
{
    if (config == nullptr || options == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *options = to_c(config->config.fatigueOptions()); });
}

mscl_status mscl_node_config_set_fatigue_options(
    mscl_node_config *config,
    const mscl_fatigue_options *options
)
{
    if (config == nullptr || options == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { config->config.fatigueOptions(to_mscl(*options)); });
}

mscl_status mscl_node_config_get_histogram_options(
    const mscl_node_config *config,
    mscl_histogram_options *options
)
{
    if (config == nullptr || options == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *options = to_c(config->config.histogramOptions()); });
}

mscl_status mscl_node_config_set_histogram_options(
    mscl_node_config *config,
    const mscl_histogram_options *options
)
{
    if (config == nullptr || options == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { config->config.histogramOptions(to_mscl(*options)); });
}

mscl_status mscl_node_config_get_activity_sense(
    const mscl_node_config *config,
    mscl_activity_sense *activity_sense
)
{
    if (config == nullptr || activity_sense == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *activity_sense = to_c(config->config.activitySense());
    });
}

mscl_status mscl_node_config_set_activity_sense(
    mscl_node_config *config,
    const mscl_activity_sense *activity_sense
)
{
    if (config == nullptr || activity_sense == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.activitySense(to_mscl(*activity_sense));
    });
}

mscl_status mscl_node_config_get_event_trigger_options(
    const mscl_node_config *config,
    mscl_event_trigger_options *options
)
{
    if (config == nullptr || options == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *options = to_c(config->config.eventTriggerOptions()); });
}

mscl_status mscl_node_config_set_event_trigger_options(
    mscl_node_config *config,
    const mscl_event_trigger_options *options
)
{
    if (config == nullptr || options == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { config->config.eventTriggerOptions(to_mscl(*options)); });
}

mscl_status mscl_node_config_get_diagnostic_interval(
    const mscl_node_config *config,
    uint16_t *seconds
)
{
    if (config == nullptr || seconds == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *seconds = config->config.diagnosticInterval(); });
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

mscl_status mscl_node_config_get_storage_limit_mode(
    const mscl_node_config *config,
    mscl_storage_limit_mode *mode
)
{
    if (config == nullptr || mode == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *mode = static_cast<mscl_storage_limit_mode>(
            config->config.storageLimitMode()
        );
    });
}

mscl_status mscl_node_config_set_storage_limit_mode(
    mscl_node_config *config,
    mscl_storage_limit_mode mode
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.storageLimitMode(
            static_cast<WirelessTypes::StorageLimitMode>(mode)
        );
    });
}

mscl_status mscl_node_config_get_sensor_delay(
    const mscl_node_config *config,
    uint32_t *delay
)
{
    if (config == nullptr || delay == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *delay = config->config.sensorDelay(); });
}

mscl_status mscl_node_config_set_sensor_delay(
    mscl_node_config *config,
    uint32_t delay
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { config->config.sensorDelay(delay); });
}

mscl_status mscl_node_config_get_data_mode(
    const mscl_node_config *config,
    mscl_data_mode *mode
)
{
    if (config == nullptr || mode == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *mode = static_cast<mscl_data_mode>(config->config.dataMode());
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

mscl_status mscl_node_config_get_derived_data_rate(
    const mscl_node_config *config,
    mscl_sample_rate *rate
)
{
    if (config == nullptr || rate == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *rate = static_cast<mscl_sample_rate>(config->config.derivedDataRate());
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

mscl_status mscl_node_config_get_derived_channel_mask(
    const mscl_node_config *config,
    mscl_derived_category category,
    uint16_t *mask
)
{
    if (config == nullptr || mask == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *mask = config->config.derivedChannelMask(
            static_cast<WirelessTypes::DerivedCategory>(category)
        ).toMask();
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

mscl_status mscl_node_config_get_derived_velocity_unit(
    const mscl_node_config *config,
    mscl_derived_velocity_unit *unit
)
{
    if (config == nullptr || unit == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *unit = static_cast<mscl_derived_velocity_unit>(
            config->config.derivedVelocityUnit()
        );
    });
}

mscl_status mscl_node_config_set_derived_velocity_unit(
    mscl_node_config *config,
    mscl_derived_velocity_unit unit
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.derivedVelocityUnit(
            static_cast<WirelessTypes::DerivedVelocityUnit>(unit)
        );
    });
}

mscl_status mscl_node_config_get_communication_protocol(
    const mscl_node_config *config,
    mscl_comm_protocol *protocol
)
{
    if (config == nullptr || protocol == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *protocol = static_cast<mscl_comm_protocol>(
            config->config.communicationProtocol()
        );
    });
}

mscl_status mscl_node_config_set_communication_protocol(
    mscl_node_config *config,
    mscl_comm_protocol protocol
)
{
    if (config == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        config->config.communicationProtocol(
            static_cast<WirelessTypes::CommProtocol>(protocol)
        );
    });
}

mscl_status mscl_node_config_get_sensor_output_mode(
    const mscl_node_config *config,
    mscl_sensor_output_mode *mode
)
{
    if (config == nullptr || mode == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *mode = static_cast<mscl_sensor_output_mode>(
            config->config.sensorOutputMode()
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

mscl_status mscl_node_features_get_min_time_between_bursts(
    const mscl_node_features *features,
    mscl_data_mode data_mode,
    mscl_data_format data_format,
    uint16_t raw_channels,
    const mscl_derived_channel_mask *derived_masks,
    size_t derived_mask_count,
    mscl_sample_rate raw_sample_rate,
    uint32_t sweeps_per_burst,
    mscl_comm_protocol protocol,
    uint64_t *time_ns
)
{
    if (
        features == nullptr ||
        (derived_masks == nullptr && derived_mask_count > 0) ||
        time_ns == nullptr
    ) {
        return fail_null(__func__);
    }
    return call([&] {
        const mscl::TimeSpan time =
            node_features_of(features).minTimeBetweenBursts(
                static_cast<WirelessTypes::DataMode>(data_mode),
                static_cast<WirelessTypes::DataFormat>(data_format),
                mscl::ChannelMask(raw_channels),
                to_mscl(derived_masks, derived_mask_count),
                to_sample_rate(raw_sample_rate),
                sweeps_per_burst,
                static_cast<WirelessTypes::CommProtocol>(protocol)
            );
        *time_ns = time.getNanoseconds();
    });
}

mscl_status mscl_node_features_get_max_event_trigger_total_duration(
    const mscl_node_features *features,
    mscl_data_mode data_mode,
    mscl_data_format data_format,
    uint16_t raw_channels,
    const mscl_derived_channel_mask *derived_masks,
    size_t derived_mask_count,
    mscl_sample_rate raw_sample_rate,
    mscl_sample_rate derived_data_rate,
    uint32_t *duration
)
{
    if (
        features == nullptr ||
        (derived_masks == nullptr && derived_mask_count > 0) ||
        duration == nullptr
    ) {
        return fail_null(__func__);
    }
    return call([&] {
        *duration = node_features_of(features).maxEventTriggerTotalDuration(
            static_cast<WirelessTypes::DataMode>(data_mode),
            static_cast<WirelessTypes::DataFormat>(data_format),
            mscl::ChannelMask(raw_channels),
            to_mscl(derived_masks, derived_mask_count),
            to_sample_rate(raw_sample_rate),
            to_sample_rate(derived_data_rate)
        );
    });
}

mscl_status mscl_node_features_supports_input_range(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsInputRange();
    });
}

mscl_status mscl_node_features_supports_input_range_per_excitation_voltage(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported =
            node_features_of(features).supportsInputRangePerExcitationVoltage();
    });
}

mscl_status mscl_node_features_supports_hardware_offset(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsHardwareOffset();
    });
}

mscl_status mscl_node_features_supports_anti_aliasing_filter(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsAntiAliasingFilter();
    });
}

mscl_status mscl_node_features_supports_low_pass_filter(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsLowPassFilter();
    });
}

mscl_status mscl_node_features_supports_high_pass_filter(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsHighPassFilter();
    });
}

mscl_status mscl_node_features_supports_gauge_factor(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsGaugeFactor();
    });
}

mscl_status mscl_node_features_supports_gauge_resistance(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsGaugeResistance();
    });
}

mscl_status mscl_node_features_supports_num_active_gauges(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsNumActiveGauges();
    });
}

mscl_status mscl_node_features_supports_lost_beacon_timeout(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsLostBeaconTimeout();
    });
}

mscl_status mscl_node_features_supports_pull_up_resistor(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsPullUpResistor();
    });
}

mscl_status mscl_node_features_supports_filter_settling_time(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsFilterSettlingTime();
    });
}

mscl_status mscl_node_features_supports_thermocouple_type(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsThermocoupleType();
    });
}

mscl_status mscl_node_features_supports_temp_sensor_options(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsTempSensorOptions();
    });
}

mscl_status mscl_node_features_supports_debounce_filter(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsDebounceFilter();
    });
}

mscl_status mscl_node_features_supports_fatigue_config(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsFatigueConfig();
    });
}

mscl_status mscl_node_features_supports_youngs_mod_config(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsYoungsModConfig();
    });
}

mscl_status mscl_node_features_supports_poissons_ratio_config(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsPoissonsRatioConfig();
    });
}

mscl_status mscl_node_features_supports_fatigue_debug_mode_config(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported =
            node_features_of(features).supportsFatigueDebugModeConfig();
    });
}

mscl_status mscl_node_features_supports_fatigue_mode_config(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsFatigueModeConfig();
    });
}

mscl_status mscl_node_features_supports_histogram_config(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsHistogramConfig();
    });
}

mscl_status mscl_node_features_supports_histogram_rate_config(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsHistogramRateConfig();
    });
}

mscl_status mscl_node_features_supports_histogram_enable_config(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsHistogramEnableConfig();
    });
}

mscl_status mscl_node_features_supports_activity_sense(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsActivitySense();
    });
}

mscl_status mscl_node_features_supports_auto_balance(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsAutoBalance();
    });
}

mscl_status mscl_node_features_supports_legacy_shunt_cal(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsLegacyShuntCal();
    });
}

mscl_status mscl_node_features_supports_auto_calshm(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsAutoCal_shm();
    });
}

mscl_status mscl_node_features_supports_auto_calshm201(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsAutoCal_shm201();
    });
}

mscl_status mscl_node_features_supports_auto_shunt_cal(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsAutoShuntCal();
    });
}

mscl_status mscl_node_features_supports_get_factory_cal(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsGetFactoryCal();
    });
}

mscl_status mscl_node_features_supports_limited_duration(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsLimitedDuration();
    });
}

mscl_status mscl_node_features_supports_event_trigger(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsEventTrigger();
    });
}

mscl_status mscl_node_features_supports_diagnostic_info(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsDiagnosticInfo();
    });
}

mscl_status mscl_node_features_supports_logged_data(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsLoggedData();
    });
}

mscl_status mscl_node_features_supports_poll(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsPoll();
    });
}

mscl_status mscl_node_features_supports_sensor_delay_config(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsSensorDelayConfig();
    });
}

mscl_status mscl_node_features_supports_sensor_delay_always_on(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsSensorDelayAlwaysOn();
    });
}

mscl_status mscl_node_features_supports_sensor_output_mode(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsSensorOutputMode();
    });
}

mscl_status mscl_node_features_supports_cfc_filter_configuration(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported =
            node_features_of(features).supportsCfcFilterConfiguration();
    });
}

mscl_status mscl_node_features_supports_centisecond_event_duration(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported =
            node_features_of(features).supportsCentisecondEventDuration();
    });
}

mscl_status mscl_node_features_supports_get_diagnostic_info(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsGetDiagnosticInfo();
    });
}

mscl_status mscl_node_features_supports_non_sync_log_with_timestamps(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported =
            node_features_of(features).supportsNonSyncLogWithTimestamps();
    });
}

mscl_status mscl_node_features_supports_raw_data_mode(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsRawDataMode();
    });
}

mscl_status mscl_node_features_supports_derived_data_mode(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsDerivedDataMode();
    });
}

mscl_status mscl_node_features_supports_derived_velocity_unit_config(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported =
            node_features_of(features).supportsDerivedVelocityUnitConfig();
    });
}

mscl_status mscl_node_features_supports_excitation_voltage_config(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported =
            node_features_of(features).supportsExcitationVoltageConfig();
    });
}

mscl_status mscl_node_features_supports_low_battery_threshold_config(
    const mscl_node_features *features,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported =
            node_features_of(features).supportsLowBatteryThresholdConfig();
    });
}

mscl_status mscl_node_features_supports_channel_setting(
    const mscl_node_features *features,
    mscl_channel_group_setting setting,
    uint16_t channel_mask,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsChannelSetting(
            static_cast<WirelessTypes::ChannelGroupSetting>(setting),
            mscl::ChannelMask(channel_mask)
        );
    });
}

mscl_status mscl_node_features_supports_channel(
    const mscl_node_features *features,
    uint8_t channel_number,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsChannel(channel_number);
    });
}

mscl_status mscl_node_features_supports_sampling_mode(
    const mscl_node_features *features,
    mscl_sampling_mode mode,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsSamplingMode(
            static_cast<WirelessTypes::SamplingMode>(mode)
        );
    });
}

mscl_status mscl_node_features_supports_sample_rate(
    const mscl_node_features *features,
    mscl_sample_rate rate,
    mscl_sampling_mode sampling_mode,
    mscl_data_collection_method collection_method,
    mscl_data_mode data_mode,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsSampleRate(
            static_cast<WirelessTypes::WirelessSampleRate>(rate),
            static_cast<WirelessTypes::SamplingMode>(sampling_mode),
            static_cast<WirelessTypes::DataCollectionMethod>(collection_method),
            static_cast<WirelessTypes::DataMode>(data_mode)
        );
    });
}

mscl_status mscl_node_features_supports_communication_protocol(
    const mscl_node_features *features,
    mscl_comm_protocol protocol,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsCommunicationProtocol(
            static_cast<WirelessTypes::CommProtocol>(protocol)
        );
    });
}

mscl_status mscl_node_features_supports_data_format(
    const mscl_node_features *features,
    mscl_data_format format,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsDataFormat(
            static_cast<WirelessTypes::DataFormat>(format)
        );
    });
}

mscl_status mscl_node_features_supports_default_mode(
    const mscl_node_features *features,
    mscl_default_mode mode,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsDefaultMode(
            static_cast<WirelessTypes::DefaultMode>(mode)
        );
    });
}

mscl_status mscl_node_features_supports_data_collection_method(
    const mscl_node_features *features,
    mscl_data_collection_method method,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsDataCollectionMethod(
            static_cast<WirelessTypes::DataCollectionMethod>(method)
        );
    });
}

mscl_status mscl_node_features_supports_transmit_power(
    const mscl_node_features *features,
    mscl_transmit_power power,
    mscl_comm_protocol protocol,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsTransmitPower(
            static_cast<WirelessTypes::TransmitPower>(power),
            static_cast<WirelessTypes::CommProtocol>(protocol)
        );
    });
}

mscl_status mscl_node_features_supports_data_mode(
    const mscl_node_features *features,
    mscl_data_mode mode,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsDataMode(
            static_cast<WirelessTypes::DataMode>(mode)
        );
    });
}

mscl_status mscl_node_features_supports_transducer_type(
    const mscl_node_features *features,
    mscl_transducer_type type,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsTransducerType(
            static_cast<WirelessTypes::TransducerType>(type)
        );
    });
}

mscl_status mscl_node_features_supports_fatigue_mode(
    const mscl_node_features *features,
    mscl_fatigue_mode mode,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsFatigueMode(
            static_cast<WirelessTypes::FatigueMode>(mode)
        );
    });
}

mscl_status mscl_node_features_supports_derived_category(
    const mscl_node_features *features,
    mscl_derived_category category,
    bool *supported
)
{
    if (features == nullptr || supported == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *supported = node_features_of(features).supportsDerivedCategory(
            static_cast<WirelessTypes::DerivedCategory>(category)
        );
    });
}

mscl_status mscl_node_features_normalize_num_sweeps(
    const mscl_node_features *features,
    uint32_t sweeps,
    uint32_t *normalized
)
{
    if (features == nullptr || normalized == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *normalized = node_features_of(features).normalizeNumSweeps(sweeps);
    });
}

mscl_status mscl_node_features_normalize_time_between_bursts(
    const mscl_node_features *features,
    uint64_t time_ns,
    uint64_t *normalized_ns
)
{
    if (features == nullptr || normalized_ns == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *normalized_ns = node_features_of(features).normalizeTimeBetweenBursts(
            mscl::TimeSpan::NanoSeconds(time_ns)
        ).getNanoseconds();
    });
}

mscl_status mscl_node_features_normalize_event_duration(
    const mscl_node_features *features,
    uint32_t duration,
    uint32_t *normalized
)
{
    if (features == nullptr || normalized == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *normalized =
            node_features_of(features).normalizeEventDuration(duration);
    });
}

mscl_status mscl_node_features_normalize_sensor_delay(
    const mscl_node_features *features,
    uint32_t delay,
    uint32_t *normalized
)
{
    if (features == nullptr || normalized == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *normalized = node_features_of(features).normalizeSensorDelay(delay);
    });
}

mscl_status mscl_node_features_get_channel_type(
    const mscl_node_features *features,
    uint8_t channel_number,
    mscl_channel_type *type
)
{
    if (features == nullptr || type == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *type = static_cast<mscl_channel_type>(
            node_features_of(features).channelType(channel_number)
        );
    });
}

mscl_status mscl_node_features_get_max_sample_rate(
    const mscl_node_features *features,
    mscl_sampling_mode sampling_mode,
    uint16_t channels,
    mscl_data_collection_method collection_method,
    mscl_data_mode data_mode,
    mscl_sample_rate *rate
)
{
    if (features == nullptr || rate == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *rate = static_cast<mscl_sample_rate>(
            node_features_of(features).maxSampleRate(
                static_cast<WirelessTypes::SamplingMode>(sampling_mode),
                mscl::ChannelMask(channels),
                static_cast<WirelessTypes::DataCollectionMethod>(
                    collection_method
                ),
                static_cast<WirelessTypes::DataMode>(data_mode)
            )
        );
    });
}

mscl_status mscl_node_features_get_max_sample_rate_for_settling_time(
    const mscl_node_features *features,
    mscl_settling_time settling_time,
    mscl_sampling_mode sampling_mode,
    mscl_data_collection_method collection_method,
    mscl_data_mode data_mode,
    mscl_sample_rate *rate
)
{
    if (features == nullptr || rate == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *rate = static_cast<mscl_sample_rate>(
            node_features_of(features).maxSampleRateForSettlingTime(
                static_cast<WirelessTypes::SettlingTime>(settling_time),
                static_cast<WirelessTypes::SamplingMode>(sampling_mode),
                static_cast<WirelessTypes::DataCollectionMethod>(
                    collection_method
                ),
                static_cast<WirelessTypes::DataMode>(data_mode)
            )
        );
    });
}

mscl_status mscl_node_features_get_max_sample_rate_for_low_pass_filter(
    const mscl_node_features *features,
    mscl_filter filter,
    mscl_sampling_mode sampling_mode,
    mscl_data_collection_method collection_method,
    mscl_data_mode data_mode,
    uint16_t channels,
    mscl_sample_rate *rate
)
{
    if (features == nullptr || rate == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *rate = static_cast<mscl_sample_rate>(
            node_features_of(features).maxSampleRateForLowPassFilter(
                static_cast<WirelessTypes::Filter>(filter),
                static_cast<WirelessTypes::SamplingMode>(sampling_mode),
                static_cast<WirelessTypes::DataCollectionMethod>(
                    collection_method
                ),
                static_cast<WirelessTypes::DataMode>(data_mode),
                mscl::ChannelMask(channels)
            )
        );
    });
}

mscl_status mscl_node_features_get_max_filter_settling_time(
    const mscl_node_features *features,
    mscl_sample_rate rate,
    mscl_settling_time *settling_time
)
{
    if (features == nullptr || settling_time == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *settling_time = static_cast<mscl_settling_time>(
            node_features_of(features).maxFilterSettlingTime(
                mscl::SampleUtils::convertToSampleRate(
                    static_cast<WirelessTypes::WirelessSampleRate>(rate)
                )
            )
        );
    });
}

mscl_status mscl_node_features_get_min_inactivity_timeout(
    const mscl_node_features *features,
    uint16_t *value
)
{
    if (features == nullptr || value == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *value = node_features_of(features).minInactivityTimeout();
    });
}

mscl_status mscl_node_features_get_min_lost_beacon_timeout(
    const mscl_node_features *features,
    uint16_t *value
)
{
    if (features == nullptr || value == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *value = node_features_of(features).minLostBeaconTimeout();
    });
}

mscl_status mscl_node_features_get_max_lost_beacon_timeout(
    const mscl_node_features *features,
    uint16_t *value
)
{
    if (features == nullptr || value == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *value = node_features_of(features).maxLostBeaconTimeout();
    });
}

mscl_status mscl_node_features_get_min_check_radio_interval(
    const mscl_node_features *features,
    uint8_t *value
)
{
    if (features == nullptr || value == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *value = node_features_of(features).minCheckRadioInterval();
    });
}

mscl_status mscl_node_features_get_max_check_radio_interval(
    const mscl_node_features *features,
    uint8_t *value
)
{
    if (features == nullptr || value == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *value = node_features_of(features).maxCheckRadioInterval();
    });
}

mscl_status mscl_node_features_get_min_sweeps(
    const mscl_node_features *features,
    uint32_t *value
)
{
    if (features == nullptr || value == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *value = node_features_of(features).minSweeps(); });
}

mscl_status mscl_node_features_get_min_sensor_delay(
    const mscl_node_features *features,
    uint32_t *value
)
{
    if (features == nullptr || value == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *value = node_features_of(features).minSensorDelay(); });
}

mscl_status mscl_node_features_get_max_sensor_delay(
    const mscl_node_features *features,
    uint32_t *value
)
{
    if (features == nullptr || value == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *value = node_features_of(features).maxSensorDelay(); });
}

mscl_status mscl_node_features_get_default_sensor_delay(
    const mscl_node_features *features,
    uint32_t *value
)
{
    if (features == nullptr || value == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *value = node_features_of(features).defaultSensorDelay();
    });
}

mscl_status mscl_node_features_get_num_damage_angles(
    const mscl_node_features *features,
    uint8_t *value
)
{
    if (features == nullptr || value == nullptr) {
        return fail_null(__func__);
    }
    return call([&] { *value = node_features_of(features).numDamageAngles(); });
}

mscl_status mscl_node_features_get_num_sn_curve_segments(
    const mscl_node_features *features,
    uint8_t *value
)
{
    if (features == nullptr || value == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *value = node_features_of(features).numSnCurveSegments();
    });
}

mscl_status mscl_node_features_get_num_event_triggers(
    const mscl_node_features *features,
    uint8_t *value
)
{
    if (features == nullptr || value == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *value = node_features_of(features).numEventTriggers();
    });
}

mscl_status mscl_node_features_get_max_sweeps(
    const mscl_node_features *features,
    mscl_sampling_mode sampling_mode,
    mscl_data_mode data_mode,
    mscl_data_format data_format,
    uint16_t channels,
    uint32_t *sweeps
)
{
    if (features == nullptr || sweeps == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *sweeps = node_features_of(features).maxSweeps(
            static_cast<WirelessTypes::SamplingMode>(sampling_mode),
            static_cast<WirelessTypes::DataMode>(data_mode),
            static_cast<WirelessTypes::DataFormat>(data_format),
            mscl::ChannelMask(channels)
        );
    });
}

mscl_status mscl_node_features_get_max_sweeps_per_burst(
    const mscl_node_features *features,
    mscl_data_mode data_mode,
    mscl_data_format data_format,
    uint16_t channels,
    uint32_t *sweeps
)
{
    if (features == nullptr || sweeps == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *sweeps = node_features_of(features).maxSweepsPerBurst(
            static_cast<WirelessTypes::DataMode>(data_mode),
            static_cast<WirelessTypes::DataFormat>(data_format),
            mscl::ChannelMask(channels)
        );
    });
}

mscl_status mscl_node_features_get_adc_voltage_input_type(
    const mscl_node_features *features,
    mscl_voltage_type *type
)
{
    if (features == nullptr || type == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *type = static_cast<mscl_voltage_type>(
            node_features_of(features).adcVoltageInputType()
        );
    });
}

mscl_status mscl_node_features_get_max_transmit_power(
    const mscl_node_features *features,
    mscl_comm_protocol protocol,
    mscl_transmit_power *power
)
{
    if (features == nullptr || power == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *power = static_cast<mscl_transmit_power>(
            node_features_of(features).maxTransmitPower(
                static_cast<WirelessTypes::CommProtocol>(protocol)
            )
        );
    });
}

mscl_status mscl_node_features_get_region_max_transmit_power(
    const mscl_node_features *features,
    mscl_region_code region,
    mscl_comm_protocol protocol,
    mscl_transmit_power *power
)
{
    if (features == nullptr || power == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *power = static_cast<mscl_transmit_power>(
            node_features_of(features).maxTransmitPower(
                static_cast<WirelessTypes::RegionCode>(region),
                static_cast<WirelessTypes::CommProtocol>(protocol)
            )
        );
    });
}

mscl_status mscl_node_features_get_min_transmit_power(
    const mscl_node_features *features,
    mscl_comm_protocol protocol,
    mscl_transmit_power *power
)
{
    if (features == nullptr || power == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *power = static_cast<mscl_transmit_power>(
            node_features_of(features).minTransmitPower(
                static_cast<WirelessTypes::CommProtocol>(protocol)
            )
        );
    });
}

mscl_status mscl_node_features_get_region_min_transmit_power(
    const mscl_node_features *features,
    mscl_region_code region,
    mscl_comm_protocol protocol,
    mscl_transmit_power *power
)
{
    if (features == nullptr || power == nullptr) {
        return fail_null(__func__);
    }
    return call([&] {
        *power = static_cast<mscl_transmit_power>(
            node_features_of(features).minTransmitPower(
                static_cast<WirelessTypes::RegionCode>(region),
                static_cast<WirelessTypes::CommProtocol>(protocol)
            )
        );
    });
}

mscl_status mscl_node_features_get_channels(
    const mscl_node_features *features,
    mscl_wireless_channel *channels,
    size_t channels_len,
    size_t *count
)
{
    if (features == nullptr || channels == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *count = 0;
    return call([&] {
        *count = convert_values(
            channels,
            channels_len,
            node_features_of(features).channels()
        );
    });
}

mscl_status mscl_node_features_get_channel_groups(
    const mscl_node_features *features,
    mscl_channel_group *groups,
    size_t groups_len,
    size_t *count
)
{
    if (features == nullptr || groups == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *count = 0;
    return call([&] {
        *count = convert_values(
            groups,
            groups_len,
            node_features_of(features).channelGroups()
        );
    });
}

mscl_status mscl_node_features_get_default_modes(
    const mscl_node_features *features,
    mscl_default_mode *modes,
    size_t modes_len,
    size_t *count
)
{
    if (features == nullptr || modes == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *count = 0;
    return call([&] {
        *count = copy_values(
            modes,
            modes_len,
            node_features_of(features).defaultModes()
        );
    });
}

mscl_status mscl_node_features_get_data_collection_methods(
    const mscl_node_features *features,
    mscl_data_collection_method *methods,
    size_t methods_len,
    size_t *count
)
{
    if (features == nullptr || methods == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *count = 0;
    return call([&] {
        *count = copy_values(
            methods,
            methods_len,
            node_features_of(features).dataCollectionMethods()
        );
    });
}

mscl_status mscl_node_features_get_data_formats(
    const mscl_node_features *features,
    mscl_data_format *formats,
    size_t formats_len,
    size_t *count
)
{
    if (features == nullptr || formats == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *count = 0;
    return call([&] {
        *count = copy_values(
            formats,
            formats_len,
            node_features_of(features).dataFormats()
        );
    });
}

mscl_status mscl_node_features_get_sampling_modes(
    const mscl_node_features *features,
    mscl_sampling_mode *modes,
    size_t modes_len,
    size_t *count
)
{
    if (features == nullptr || modes == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *count = 0;
    return call([&] {
        *count = copy_values(
            modes,
            modes_len,
            node_features_of(features).samplingModes()
        );
    });
}

mscl_status mscl_node_features_get_sample_rates(
    const mscl_node_features *features,
    mscl_sampling_mode sampling_mode,
    mscl_data_collection_method collection_method,
    mscl_data_mode data_mode,
    mscl_sample_rate *rates,
    size_t rates_len,
    size_t *count
)
{
    if (features == nullptr || rates == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *count = 0;
    return call([&] {
        *count = copy_values(
            rates,
            rates_len,
            node_features_of(features).sampleRates(
                static_cast<WirelessTypes::SamplingMode>(sampling_mode),
                static_cast<WirelessTypes::DataCollectionMethod>(
                    collection_method
                ),
                static_cast<WirelessTypes::DataMode>(data_mode)
            )
        );
    });
}

mscl_status mscl_node_features_get_derived_data_rates(
    const mscl_node_features *features,
    mscl_sample_rate *rates,
    size_t rates_len,
    size_t *count
)
{
    if (features == nullptr || rates == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *count = 0;
    return call([&] {
        *count = copy_values(
            rates,
            rates_len,
            node_features_of(features).derivedDataRates()
        );
    });
}

mscl_status mscl_node_features_get_transmit_powers(
    const mscl_node_features *features,
    mscl_comm_protocol protocol,
    mscl_transmit_power *powers,
    size_t powers_len,
    size_t *count
)
{
    if (features == nullptr || powers == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *count = 0;
    return call([&] {
        *count = copy_values(
            powers,
            powers_len,
            node_features_of(features).transmitPowers(
                static_cast<WirelessTypes::CommProtocol>(protocol)
            )
        );
    });
}

mscl_status mscl_node_features_get_region_transmit_powers(
    const mscl_node_features *features,
    mscl_region_code region,
    mscl_comm_protocol protocol,
    mscl_transmit_power *powers,
    size_t powers_len,
    size_t *count
)
{
    if (features == nullptr || powers == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *count = 0;
    return call([&] {
        *count = copy_values(
            powers,
            powers_len,
            node_features_of(features).transmitPowers(
                static_cast<WirelessTypes::RegionCode>(region),
                static_cast<WirelessTypes::CommProtocol>(protocol)
            )
        );
    });
}

mscl_status mscl_node_features_get_comm_protocols(
    const mscl_node_features *features,
    mscl_comm_protocol *protocols,
    size_t protocols_len,
    size_t *count
)
{
    if (features == nullptr || protocols == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *count = 0;
    return call([&] {
        *count = copy_values(
            protocols,
            protocols_len,
            node_features_of(features).commProtocols()
        );
    });
}

mscl_status mscl_node_features_get_sensor_output_modes(
    const mscl_node_features *features,
    mscl_sensor_output_mode *modes,
    size_t modes_len,
    size_t *count
)
{
    if (features == nullptr || modes == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *count = 0;
    return call([&] {
        *count = copy_values(
            modes,
            modes_len,
            node_features_of(features).sensorOutputModes()
        );
    });
}

mscl_status mscl_node_features_get_cfc_filters(
    const mscl_node_features *features,
    mscl_channel_frequency_class *filters,
    size_t filters_len,
    size_t *count
)
{
    if (features == nullptr || filters == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *count = 0;
    return call([&] {
        *count = copy_values(
            filters,
            filters_len,
            node_features_of(features).cfcFilters()
        );
    });
}

mscl_status mscl_node_features_get_histogram_transmit_rates(
    const mscl_node_features *features,
    mscl_sample_rate *rates,
    size_t rates_len,
    size_t *count
)
{
    if (features == nullptr || rates == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *count = 0;
    return call([&] {
        *count = copy_values(
            rates,
            rates_len,
            node_features_of(features).histogramTransmitRates()
        );
    });
}

mscl_status mscl_node_features_get_fatigue_modes(
    const mscl_node_features *features,
    mscl_fatigue_mode *modes,
    size_t modes_len,
    size_t *count
)
{
    if (features == nullptr || modes == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *count = 0;
    return call([&] {
        *count = copy_values(
            modes,
            modes_len,
            node_features_of(features).fatigueModes()
        );
    });
}

mscl_status mscl_node_features_get_anti_aliasing_filters(
    const mscl_node_features *features,
    mscl_filter *filters,
    size_t filters_len,
    size_t *count
)
{
    if (features == nullptr || filters == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *count = 0;
    return call([&] {
        *count = copy_values(
            filters,
            filters_len,
            node_features_of(features).antiAliasingFilters()
        );
    });
}

mscl_status mscl_node_features_get_low_pass_filters(
    const mscl_node_features *features,
    mscl_filter *filters,
    size_t filters_len,
    size_t *count
)
{
    if (features == nullptr || filters == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *count = 0;
    return call([&] {
        *count = copy_values(
            filters,
            filters_len,
            node_features_of(features).lowPassFilters()
        );
    });
}

mscl_status mscl_node_features_get_high_pass_filters(
    const mscl_node_features *features,
    mscl_high_pass_filter *filters,
    size_t filters_len,
    size_t *count
)
{
    if (features == nullptr || filters == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *count = 0;
    return call([&] {
        *count = copy_values(
            filters,
            filters_len,
            node_features_of(features).highPassFilters()
        );
    });
}

mscl_status mscl_node_features_get_storage_limit_modes(
    const mscl_node_features *features,
    mscl_storage_limit_mode *modes,
    size_t modes_len,
    size_t *count
)
{
    if (features == nullptr || modes == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *count = 0;
    return call([&] {
        *count = copy_values(
            modes,
            modes_len,
            node_features_of(features).storageLimitModes()
        );
    });
}

mscl_status mscl_node_features_get_input_ranges(
    const mscl_node_features *features,
    uint16_t channels,
    mscl_input_range_entry *ranges,
    size_t ranges_len,
    size_t *count
)
{
    if (features == nullptr || ranges == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *count = 0;
    return call([&] {
        *count = convert_values(
            ranges,
            ranges_len,
            node_features_of(features).inputRanges(mscl::ChannelMask(channels))
        );
    });
}

mscl_status mscl_node_features_get_input_ranges_for_excitation_voltage(
    const mscl_node_features *features,
    uint16_t channels,
    mscl_voltage excitation_voltage,
    mscl_input_range_entry *ranges,
    size_t ranges_len,
    size_t *count
)
{
    if (features == nullptr || ranges == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *count = 0;
    return call([&] {
        *count = convert_values(
            ranges,
            ranges_len,
            node_features_of(features).inputRanges(
                mscl::ChannelMask(channels),
                static_cast<WirelessTypes::Voltage>(excitation_voltage)
            )
        );
    });
}

mscl_status mscl_node_features_get_data_modes(
    const mscl_node_features *features,
    mscl_data_mode *modes,
    size_t modes_len,
    size_t *count
)
{
    if (features == nullptr || modes == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *count = 0;
    return call([&] {
        *count = copy_values(
            modes,
            modes_len,
            node_features_of(features).dataModes()
        );
    });
}

mscl_status mscl_node_features_get_transducer_types(
    const mscl_node_features *features,
    mscl_transducer_type *types,
    size_t types_len,
    size_t *count
)
{
    if (features == nullptr || types == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *count = 0;
    return call([&] {
        *count = copy_values(
            types,
            types_len,
            node_features_of(features).transducerTypes()
        );
    });
}

mscl_status mscl_node_features_get_channels_per_derived_category(
    const mscl_node_features *features,
    mscl_derived_channel_mask *masks,
    size_t masks_len,
    size_t *count
)
{
    if (features == nullptr || masks == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *count = 0;
    return call([&] {
        *count = convert_values(
            masks,
            masks_len,
            node_features_of(features).channelsPerDerivedCategory()
        );
    });
}

mscl_status mscl_node_features_get_excitation_voltages(
    const mscl_node_features *features,
    mscl_voltage *voltages,
    size_t voltages_len,
    size_t *count
)
{
    if (features == nullptr || voltages == nullptr || count == nullptr) {
        return fail_null(__func__);
    }
    *count = 0;
    return call([&] {
        *count = copy_values(
            voltages,
            voltages_len,
            node_features_of(features).excitationVoltages()
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
