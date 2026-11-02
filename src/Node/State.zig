//! Information read from the Node when it is initialized.

const std = @import("std");
const root = @import("../root.zig");
const Node = @import("../Node.zig");

const State = @This();

/// The node address of the Node.
node_address: u32,
/// The name of the Node. This is the universal sensor name that should be used
/// for uploading to SensorCloud.
name: []const u8,
/// The serial number of the Node.
serial: []const u8,
/// The model of the Node.
model: Node.Model,
/// The microcontroller of the Node.
microcontroller: root.Microcontroller,
/// The region code currently set on the Node.
region_code: root.RegionCode,
/// The firmware version of the Node.
firmware_version: std.SemanticVersion,

pub fn deinit(self: State, gpa: std.mem.Allocator) void {
    gpa.free(self.name);
    gpa.free(self.serial);
}
