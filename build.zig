const std = @import("std");

const Translator = @import("translate_c").Translator;

pub fn build(b: *std.Build) std.mem.Allocator.Error!void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    // Prepare the `translate-c` dependency.
    const translate_c = b.dependency("translate_c", .{});
    const libmscl = buildLibMscl(b, target, optimize);
    const libmscl_wrapper = buildLibMsclWrapper(b, target, optimize, libmscl);
    const trans_libmscl_wrapper: Translator = .init(
        translate_c,
        .{
            .c_source_file = b.addWriteFiles().add("c.h",
                \\#include <mscl_c.h>
            ),
            .target = target,
            .optimize = optimize,
        },
    );
    trans_libmscl_wrapper.linkLibrary(libmscl_wrapper);
    const mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .link_libcpp = true,
    });
    mod.addImport("mscl", trans_libmscl_wrapper.mod);
    const lib = b.addLibrary(.{ .name = "mscl_zig", .root_module = mod });

    b.installArtifact(libmscl);
    b.installArtifact(libmscl_wrapper);
    b.installArtifact(lib);

    const tests = b.addTest(.{ .root_module = mod });
    const test_step = b.step("test", "Run the tests");
    test_step.dependOn(&b.addRunArtifact(tests).step);
}

fn buildLibMsclWrapper(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    libmscl: *std.Build.Step.Compile,
) *std.Build.Step.Compile {
    const mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .link_libcpp = true,
    });
    mod.addIncludePath(b.path("include"));
    mod.linkLibrary(libmscl);
    // MSCL's headers include Boost's, which linking MSCL does not pass on.
    const boost = b.dependency("boost", .{
        .target = target,
        .optimize = optimize,
    });
    mod.addIncludePath(boost.artifact("boost").getEmittedIncludeTree());
    mod.addCSourceFile(.{ .file = b.path("include/mscl_c.cpp"), .language = .cpp });
    const lib = b.addLibrary(.{ .name = "mscl_c", .root_module = mod });
    lib.installHeader(b.path("include/mscl_c.h"), "mscl_c.h");
    return lib;
}

/// MSCL built from source. Its options are the ones of MSCL's CMake build
/// that change the library; the others build bindings, examples, tests,
/// documentation or packages, or drive vcpkg.
fn buildLibMscl(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) *std.Build.Step.Compile {
    // BUILD_SHARED_LIBS
    const shared = b.option(
        bool,
        "shared",
        "Build MSCL as a shared library (default: false)",
    ) orelse false;
    // MSCL_LINK_STATIC_DEPS
    const link_static_deps = b.option(
        bool,
        "link_static_deps",
        "Link MSCL's dependencies statically; always on when MSCL is " ++
            "static (default: true)",
    ) orelse true;
    // MSCL_WITH_SSL
    const with_ssl = b.option(
        bool,
        "with_ssl",
        "Compile MSCL with SSL support, using the system's OpenSSL " ++
            "(default: false)",
    ) orelse false;
    // MSCL_WITH_WEBSOCKETS
    const with_websockets = b.option(
        bool,
        "with_websockets",
        "Compile MSCL with WebSocket support (default: false)",
    ) orelse false;

    // As in CMake, a static MSCL always links its dependencies statically.
    const static_deps = link_static_deps or !shared;

    const mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .link_libcpp = true,
    });
    // Boost.Filesystem is compiled; Asio, Beast, Circular Buffer, CRC, Lambda
    // and Math are header-only.
    const boost = b.dependency("boost", .{
        .target = target,
        .optimize = optimize,
        .filesystem = true,
        .shared = !static_deps,
    });
    mod.linkLibrary(boost.artifact("boost"));
    mod.addCMacro("BOOST_ASIO_NO_DEPRECATED", "1");
    mod.addCMacro("BOOST_FILESYSTEM_NO_DEPRECATED", "1");
    mod.addCMacro("BOOST_PROCESS_NO_DEPRECATED", "1");
    mod.addCMacro("BOOST_SYSTEM_NO_DEPRECATED", "1");
    if (with_ssl) {
        mod.addCMacro("MSCL_WITH_SSL", "1");
        const link_mode: std.builtin.LinkMode =
            if (static_deps) .static else .dynamic;
        mod.linkSystemLibrary("ssl", .{ .preferred_link_mode = link_mode });
        mod.linkSystemLibrary("crypto", .{ .preferred_link_mode = link_mode });
    }
    if (with_websockets) {
        mod.addCMacro("MSCL_WITH_WEBSOCKETS", "1");
    }

    const mscl = b.dependency("mscl", .{});
    // MSCL's sources include its headers as `mscl/...`.
    mod.addIncludePath(mscl.path("src"));

    // As CMake's precompiled header, `stdafx.h` comes first in every source.
    // Not `-include mscl/stdafx.h`: Zig opens that file from the build root
    // instead of searching the include paths as clang does.
    const flags: []const []const u8 = &.{"--include=mscl/stdafx.h"};

    mod.addCSourceFiles(.{
        .root = mscl.path("src/mscl"),
        .files = &.{
            "Bin.cpp",
            "BitMask.cpp",
            "HighResClock.cpp",
            "Histogram.cpp",
            "ScopeHelper.cpp",
            "TimedCondition.cpp",
            "TimeSpan.cpp",
            "Timestamp.cpp",
            "TimestampCounter.cpp",
            "Utils.cpp",
            "Value.cpp",
            "Version.cpp",
            "WMI_Helper.cpp",
        },
        .flags = flags,
    });
    mod.addCSourceFiles(.{
        .root = mscl.path("src/mscl/Communication"),
        .files = &.{
            "Connection.cpp",
            "ConnectionDebugData.cpp",
            "Devices.cpp",
            "RawBytePacket.cpp",
            "RawBytePacketCollector.cpp",
            "SerialConnection.cpp",
            "TcpIpConnection.cpp",
            "WebSocketConnection.cpp",
            "WebSocketSecureConnection.cpp",
        },
        .flags = flags,
    });
    switch (target.result.os.tag) {
        .windows => {},
        .linux => {
            mod.addCSourceFiles(.{
                .root = mscl.path("src/mscl/Communication"),
                .files = &.{"UnixSocketConnection.cpp"},
                .flags = flags,
            });
        },
        else => std.debug.panic("Unsupported OS.", .{}),
    }
    mod.addCSourceFiles(.{
        .root = mscl.path("src/mscl/MicroStrain"),
        .files = &.{
            "ByteStream.cpp",
            "ChecksumBuilder.cpp",
            "DataBuffer.cpp",
            "DataPoint.cpp",
            "LinearEquation.cpp",
            "Matrix.cpp",
            "ResponseCollector.cpp",
            "ResponsePattern.cpp",
            "SampleRate.cpp",
            "SampleUtils.cpp",
            "Vector.cpp",
        },
        .flags = flags,
    });
    mod.addCSourceFiles(.{
        .root = mscl.path("src/mscl/MicroStrain/Wireless"),
        .files = &.{
            "ArmedDataloggingNetwork.cpp",
            "BaseStation.cpp",
            "BaseStationAnalogPair.cpp",
            "BaseStationButton.cpp",
            "BaseStationInfo.cpp",
            "BaseStation_Impl.cpp",
            "CalCoefficients.cpp",
            "ChannelMask.cpp",
            "DatalogDownloader.cpp",
            "DataSweep.cpp",
            "DeliveryStopFlags.cpp",
            "LoggedDataSweep.cpp",
            "MockBaseStation_Impl.cpp",
            "MockWirelessNode_Impl.cpp",
            "NodeCommTimes.cpp",
            "NodeDiscovery.cpp",
            "NodeMemory.cpp",
            "NodeMemory_v1.cpp",
            "NodeMemory_v2.cpp",
            "RadioFeatures.cpp",
            "StructuralHealth.cpp",
            "SyncNetworkInfo.cpp",
            "SyncSamplingFormulas.cpp",
            "SyncSamplingNetwork.cpp",
            "WirelessChannel.cpp",
            "WirelessDataPoint.cpp",
            "WirelessModels.cpp",
            "WirelessNode.cpp",
            "WirelessNode_Impl.cpp",
            "WirelessParser.cpp",
            "WirelessTypes.cpp",
        },
        .flags = flags,
    });
    mod.addCSourceFiles(.{
        .root = mscl.path("src/mscl/MicroStrain/Wireless/Commands"),
        .files = &.{
            "ArmForDatalogging.cpp",
            "AutoBalance.cpp",
            "AutoBalanceResult.cpp",
            "AutoBalance_v2.cpp",
            "AutoCal.cpp",
            "AutoCalResult.cpp",
            "BaseStation_BeaconStatus.cpp",
            "BaseStation_Ping.cpp",
            "BaseStation_Ping_v2.cpp",
            "BaseStation_ReadEeprom.cpp",
            "BaseStation_ReadEeprom_v2.cpp",
            "BaseStation_Reset_v2.cpp",
            "BaseStation_RfSweepStart.cpp",
            "BaseStation_SetBeacon.cpp",
            "BaseStation_SetBeacon_v2.cpp",
            "BaseStation_WriteEeprom.cpp",
            "BaseStation_WriteEeprom_v2.cpp",
            "BatchEepromRead.cpp",
            "BeaconStatus.cpp",
            "Erase.cpp",
            "Erase_v2.cpp",
            "GetDatalogSessionInfo.cpp",
            "GetDiagnosticInfo.cpp",
            "GetLoggedData.cpp",
            "LongPing.cpp",
            "PageDownload.cpp",
            "PingResponse.cpp",
            "Poll.cpp",
            "ReadEeprom.cpp",
            "ReadEeprom_v2.cpp",
            "ReadSingleSensor.cpp",
            "Reset_v2.cpp",
            "SetToIdle.cpp",
            "SetToIdleStatus.cpp",
            "SetToIdle_v2.cpp",
            "Sleep.cpp",
            "Sleep_v2.cpp",
            "StartNonSyncSampling.cpp",
            "StartNonSyncSampling_v2.cpp",
            "StartSyncSampling.cpp",
            "TestNodeCommProtocol.cpp",
            "TriggerArmedDatalogging.cpp",
            "WirelessProtocol.cpp",
            "WirelessResponsePattern.cpp",
            "WriteEeprom.cpp",
            "WriteEeprom_v2.cpp",
        },
        .flags = flags,
    });
    mod.addCSourceFiles(.{
        .root = mscl.path("src/mscl/MicroStrain/Wireless/Configuration"),
        .files = &.{
            "ActivitySense.cpp",
            "BaseStationConfig.cpp",
            "BaseStationEeprom.cpp",
            "BaseStationEepromHelper.cpp",
            "BaseStationEepromMap.cpp",
            "ConfigIssue.cpp",
            "DataModeMask.cpp",
            "Eeprom.cpp",
            "EepromLocation.cpp",
            "EventTriggerOptions.cpp",
            "FatigueOptions.cpp",
            "HistogramOptions.cpp",
            "InputRange.cpp",
            "MockNodeEeprom.cpp",
            "NodeEeprom.cpp",
            "NodeEepromHelper.cpp",
            "NodeEepromMap.cpp",
            "SyncNodeConfig.cpp",
            "TempSensorOptions.cpp",
            "WirelessNodeConfig.cpp",
        },
        .flags = flags,
    });
    mod.addCSourceFiles(.{
        .root = mscl.path("src/mscl/MicroStrain/Wireless/Features"),
        .files = &.{
            "AvailableSampleRates.cpp",
            "AvailableTransmitPowers.cpp",
            "BaseStationFeatures.cpp",
            "BaseStationFeatures_analog.cpp",
            "BaseStationFeatures_rs232.cpp",
            "BaseStationFeatures_usb.cpp",
            "BaseStationFeatures_usb200.cpp",
            "BaseStationFeatures_wsda.cpp",
            "BaseStationFeatures_wsda2000.cpp",
            "BaseStationFeatures_wsdaPro.cpp",
            "ChannelGroup.cpp",
            "FlashInfo.cpp",
            "NodeFeatures.cpp",
            "NodeFeatures_200series.cpp",
            "NodeFeatures_cfBearingTempLink.cpp",
            "NodeFeatures_dvrtlink.cpp",
            "NodeFeatures_envlinkMini.cpp",
            "NodeFeatures_envlinkPro.cpp",
            "NodeFeatures_glink.cpp",
            "NodeFeatures_glink200.cpp",
            "NodeFeatures_glink200r.cpp",
            "NodeFeatures_glink2External.cpp",
            "NodeFeatures_glink2Internal.cpp",
            "NodeFeatures_iepeLink.cpp",
            "NodeFeatures_ptlink200.cpp",
            "NodeFeatures_rtdlink.cpp",
            "NodeFeatures_rtdlink200.cpp",
            "NodeFeatures_sglink.cpp",
            "NodeFeatures_sglink200.cpp",
            "NodeFeatures_sglink200oem.cpp",
            "NodeFeatures_sglinkMicro.cpp",
            "NodeFeatures_sglinkoem.cpp",
            "NodeFeatures_sglinkoemHermetic.cpp",
            "NodeFeatures_sglinkoemNoXR.cpp",
            "NodeFeatures_sglinkrgd.cpp",
            "NodeFeatures_shmlink.cpp",
            "NodeFeatures_shmlink2.cpp",
            "NodeFeatures_shmlink200.cpp",
            "NodeFeatures_shmlink201.cpp",
            "NodeFeatures_shmlink201FullBridge.cpp",
            "NodeFeatures_shmlink210.cpp",
            "NodeFeatures_tclink1ch.cpp",
            "NodeFeatures_tclink200.cpp",
            "NodeFeatures_tclink200oem.cpp",
            "NodeFeatures_tclink3ch.cpp",
            "NodeFeatures_tclink6ch.cpp",
            "NodeFeatures_torqueLink.cpp",
            "NodeFeatures_torqueLink200.cpp",
            "NodeFeatures_torqueLink200_3ch.cpp",
            "NodeFeatures_torqueLink200_3ch_s.cpp",
            "NodeFeatures_vlink.cpp",
            "NodeFeatures_vlink200.cpp",
            "NodeFeatures_vlink_legacy.cpp",
            "NodeFeatures_wirelessImpactSensor.cpp",
            "NodeInfo.cpp",
        },
        .flags = flags,
    });
    mod.addCSourceFiles(.{
        .root = mscl.path("src/mscl/MicroStrain/Wireless/Packets"),
        .files = &.{
            "AsyncDigitalAnalogPacket.cpp",
            "AsyncDigitalPacket.cpp",
            "BeaconEchoPacket.cpp",
            "BufferedLdcPacket.cpp",
            "BufferedLdcPacket_v2.cpp",
            "DiagnosticPacket.cpp",
            "HclSmartBearing_CalPacket.cpp",
            "HclSmartBearing_RawPacket.cpp",
            "LdcMathPacket.cpp",
            "LdcMathPacket_aspp3.cpp",
            "LdcPacket.cpp",
            "LdcPacket_v2.cpp",
            "LdcPacket_v2_aspp3.cpp",
            "NodeDiscoveryPacket.cpp",
            "NodeDiscoveryPacket_v2.cpp",
            "NodeDiscoveryPacket_v3.cpp",
            "NodeDiscoveryPacket_v4.cpp",
            "NodeDiscoveryPacket_v5.cpp",
            "RawAngleStrainPacket.cpp",
            "RfSweepPacket.cpp",
            "RollerPacket.cpp",
            "ShmPacket.cpp",
            "ShmPacket_v2_aspp3.cpp",
            "SyncSamplingMathPacket.cpp",
            "SyncSamplingMathPacket_aspp3.cpp",
            "SyncSamplingPacket.cpp",
            "SyncSamplingPacket_v2.cpp",
            "SyncSamplingPacket_v2_aspp3.cpp",
            "WirelessDataPacket.cpp",
            "WirelessPacket.cpp",
            "WirelessPacketCollector.cpp",
            "WirelessPacketUtils.cpp",
        },
        .flags = flags,
    });

    const lib = b.addLibrary(.{
        .name = "MSCL",
        .linkage = if (shared) .dynamic else .static,
        .root_module = mod,
    });
    // As in CMake, whatever links MSCL includes its headers from `src` too,
    // but only the headers that the sources above include.
    const headers: []const []const u8 = &.{
        "mscl/Bin.h",
        "mscl/BitMask.h",
        "mscl/Endianness.h",
        "mscl/Exceptions.h",
        "mscl/HighResClock.h",
        "mscl/Histogram.h",
        "mscl/ScopeHelper.h",
        "mscl/simple_any.h",
        "mscl/stdafx.h",
        "mscl/TimedCondition.h",
        "mscl/TimeSpan.h",
        "mscl/Timestamp.h",
        "mscl/TimestampCounter.h",
        "mscl/Types.h",
        "mscl/Utils.h",
        "mscl/Utils_Win32.h",
        "mscl/Value.h",
        "mscl/Version.h",
        "mscl/WMI_Helper.h",
        "mscl/Communication/BoostCommunication.h",
        "mscl/Communication/Connection.h",
        "mscl/Communication/ConnectionDebugData.h",
        "mscl/Communication/Connection_Impl.h",
        "mscl/Communication/Devices.h",
        "mscl/Communication/MockConnection.h",
        "mscl/Communication/NativeSerialPort.h",
        "mscl/Communication/NativeSerialPort_linux.h",
        "mscl/Communication/NativeSerialPort_Win32.h",
        "mscl/Communication/OperatingSystemErrorCodes.h",
        "mscl/Communication/RawBytePacket.h",
        "mscl/Communication/RawBytePacketCollector.h",
        "mscl/Communication/SerialConnection.h",
        "mscl/Communication/TcpIpConnection.h",
        "mscl/Communication/UnixSocketConnection.h",
        "mscl/Communication/WebSocketConnection.h",
        "mscl/Communication/WebSocketSecureConnection.h",
        "mscl/MicroStrain/ByteStream.h",
        "mscl/MicroStrain/ChecksumBuilder.h",
        "mscl/MicroStrain/DataBuffer.h",
        "mscl/MicroStrain/DataPoint.h",
        "mscl/MicroStrain/LinearEquation.h",
        "mscl/MicroStrain/Matrix.h",
        "mscl/MicroStrain/ResponseCollector.h",
        "mscl/MicroStrain/ResponsePattern.h",
        "mscl/MicroStrain/SampleRate.h",
        "mscl/MicroStrain/SampleUtils.h",
        "mscl/MicroStrain/Vector.h",
    };
    for (headers) |header| {
        lib.installHeader(mscl.path("src").path(b, header), header);
    }
    // The sources above include every header under it.
    lib.installHeadersDirectory(
        mscl.path("src/mscl/MicroStrain/Wireless"),
        "mscl/MicroStrain/Wireless",
        .{},
    );
    return lib;
}
