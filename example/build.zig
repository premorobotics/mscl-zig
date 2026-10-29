const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const mscl_zig = b.dependency("mscl_zig", .{
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "list_base_stations",
        .root_module = b.createModule(.{
            .root_source_file = b.path("list_base_stations.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "mscl_zig", .module = mscl_zig.module("mscl_zig") },
            },
        }),
    });
    b.installArtifact(exe);
    const run_step = b.step("run", "List the attached base stations");
    run_step.dependOn(&b.addRunArtifact(exe).step);

    const features_exe = b.addExecutable(.{
        .name = "print_features",
        .root_module = b.createModule(.{
            .root_source_file = b.path("print_features.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "mscl_zig", .module = mscl_zig.module("mscl_zig") },
            },
        }),
    });
    b.installArtifact(features_exe);
    const features_step = b.step(
        "print_features",
        "Print the features of the first attached base station",
    );
    features_step.dependOn(&b.addRunArtifact(features_exe).step);
}
