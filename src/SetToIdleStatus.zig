const std = @import("std");
const root = @import("root.zig");

const SetToIdleStatus = @This();

handle: *root.mscl.mscl_set_to_idle_status,

pub const Error = error{
    Connection,
    /// Any other failure; `root.mscl.mscl_last_error()` describes it.
    MsclFailure,
};

/// The result of the Set To Idle command once the operation has ceased.
pub const Result = enum(root.mscl.mscl_set_to_idle_result) {
    /// The Node has been successfully set to idle.
    success = root.mscl.MSCL_SET_TO_IDLE_SUCCESS,
    /// The Set to Idle operation has been canceled by the user.
    canceled = root.mscl.MSCL_SET_TO_IDLE_CANCELED,
    /// The Set to Idle operation has failed. The state of the Node is unknown.
    failed = root.mscl.MSCL_SET_TO_IDLE_FAILED,
    /// The Set to Idle operation has not yet completed.
    not_completed = root.mscl.MSCL_SET_TO_IDLE_NOT_COMPLETED,
    _,
};

/// Releases the status. MSCL cancels the operation if it has not completed.
pub fn deinit(self: SetToIdleStatus) void {
    root.mscl.mscl_set_to_idle_status_destroy(self.handle);
}

/// Gets the SetToIdleResult representing the result of the Stop Node command
/// (success, fail, canceled, etc.).
/// After complete is true, this should be called to discover how the command
/// completed.
pub fn getResult(self: SetToIdleStatus) Result {
    var result: root.mscl.mscl_set_to_idle_result =
        root.mscl.MSCL_SET_TO_IDLE_NOT_COMPLETED;
    _ = root.mscl.mscl_set_to_idle_status_get_result(self.handle, &result);
    return @fromBackingInt(result);
}

/// Gets whether the Stop Node command has completed or not, waiting for the
/// specified amount of time before returning.
pub fn isComplete(self: SetToIdleStatus, timeout_ms: u64) bool {
    var complete = false;
    _ = root.mscl.mscl_set_to_idle_status_complete(
        self.handle,
        timeout_ms,
        &complete,
    );
    return complete;
}

/// Cancels the Stop Node operation that this SetToIdleResult belongs to.
/// If the Stop Node operation has already been completed/canceled, this will
/// have no effect.
pub fn cancel(self: SetToIdleStatus) Error!void {
    const status = root.mscl.mscl_set_to_idle_status_cancel(self.handle);
    return switch (status) {
        root.mscl.MSCL_OK => {},
        // A connection error has occurred with the BaseStation.
        root.mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{root.mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}
