const std = @import("std");
const root = @import("root.zig");
const mscl = root.mscl;
const BaseStation = @import("BaseStation.zig");

const Node = @This();
pub const Features = @import("Node/Features.zig");

handle: *mscl.mscl_node,
features: Features,

pub const Error = error{
    Connection,
    NodeCommunication,
    NotSupported,
    /// Any other failure; `root.mscl.mscl_last_error()` describes it.
    MsclFailure,
};

/// Creates a WirelessNode object with the given node address and parent
/// BaseStation.
pub fn init(
    gpa: std.mem.Allocator,
    base_station: BaseStation,
    address: u32,
) (Error || std.mem.Allocator.Error)!Node {
    var handle: ?*mscl.mscl_node = null;
    const status =
        mscl.mscl_node_create(base_station.handle, address, &handle);
    switch (status) {
        mscl.MSCL_OK => {},
        else => {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            return Error.MsclFailure;
        },
    }
    const node = handle.?;
    errdefer mscl.mscl_node_destroy(node);
    return .{ .handle = node, .features = try Features.init(gpa, node) };
}

/// Destroys the node. Deinitialize everything using this node first.
pub fn deinit(self: Node, gpa: std.mem.Allocator) void {
    self.features.deinit(gpa);
    mscl.mscl_node_destroy(self.handle);
}
