//! Information read from the BaseStation when it is initialized. A value that
//! the BaseStation does not support is null.

const std = @import("std");
const root = @import("../root.zig");
const BaseStation = @import("../BaseStation.zig");

const State = @This();

/// The model of the BaseStation.
model: ?BaseStation.Model,
/// The serial number of the BaseStation.
serial: ?[]const u8,
/// The name of the BaseStation. This is the universal basestation name that
/// should be used for SensorCloud.
name: ?[]const u8,
/// The firmware version of the BaseStation.
firmware_version: ?std.SemanticVersion,
/// The microcontroller of the BaseStation.
microcontroller: ?root.Microcontroller,
/// The region code currently set on the BaseStation.
region_code: ?root.RegionCode,
/// The WirelessTypes::Frequency representing the radio frequency of this
/// BaseStation. `BaseStation.changeFrequency` updates it.
frequency: ?root.Frequency,
/// The BeaconStatus of the beacon on the base station.
/// `BaseStation.enableBeacon`, `BaseStation.enableBeaconAt` and
/// `BaseStation.disableBeacon` update it.
beacon_status: ?BaseStation.BeaconStatus,

pub fn deinit(self: State, gpa: std.mem.Allocator) void {
    if (self.serial) |serial| {
        gpa.free(serial);
    }
    if (self.name) |name| {
        gpa.free(name);
    }
}
