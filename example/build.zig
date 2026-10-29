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
            .root_source_file = b.path("src/list_base_stations.zig"),
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
            .root_source_file = b.path("src/print_features.zig"),
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

    const config_exe = b.addExecutable(.{
        .name = "print_config",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/print_config.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "mscl_zig", .module = mscl_zig.module("mscl_zig") },
            },
        }),
    });
    b.installArtifact(config_exe);
    const config_step = b.step(
        "print_config",
        "Print the config currently set on the first attached base station",
    );
    config_step.dependOn(&b.addRunArtifact(config_exe).step);

    const state_exe = b.addExecutable(.{
        .name = "print_state",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/print_state.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "mscl_zig", .module = mscl_zig.module("mscl_zig") },
            },
        }),
    });
    b.installArtifact(state_exe);
    const state_step = b.step(
        "print_state",
        "Print the state of the first attached base station",
    );
    state_step.dependOn(&b.addRunArtifact(state_exe).step);

    const base_station_exe = b.addExecutable(.{
        .name = "print_base_station",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/print_base_station.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "mscl_zig", .module = mscl_zig.module("mscl_zig") },
            },
        }),
    });
    b.installArtifact(base_station_exe);
    const base_station_step = b.step(
        "print_base_station",
        "Print everything about the first attached base station",
    );
    base_station_step.dependOn(&b.addRunArtifact(base_station_exe).step);
}
