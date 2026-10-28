const std = @import("std");
const mscl_zig = @import("mscl_zig");

pub fn main(init: std.process.Init) !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer: std.Io.File.Writer =
        .init(.stdout(), init.io, &stdout_buffer);
    const stdout = &stdout_writer.interface;

    const base_stations = mscl_zig.BaseStations.list() catch |err| {
        std.log.err("{t}: {s}", .{ err, mscl_zig.mscl.mscl_last_error() });
        return err;
    };
    defer base_stations.deinit();

    if (base_stations.devices.len == 0) {
        try stdout.writeAll("No base stations found.\n");
    }
    for (base_stations.devices) |device| {
        const connection_type: mscl_zig.ConnectionType =
            @enumFromInt(device.connection_type);
        try stdout.print(
            \\{s}
            \\  description: {s}
            \\  serial: {s}
            \\  baud rate: {d}
            \\  connection type: {t}
            \\
        , .{
            std.mem.sliceTo(&device.port, 0),
            std.mem.sliceTo(&device.description, 0),
            std.mem.sliceTo(&device.serial, 0),
            device.baud_rate,
            connection_type,
        });
    }
    try stdout.flush();
}
