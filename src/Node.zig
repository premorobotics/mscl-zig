const std = @import("std");
const root = @import("root.zig");
const mscl = root.mscl;
const BaseStation = @import("BaseStation.zig");

const Node = @This();
pub const Config = @import("Node/Config.zig");
pub const Features = @import("Node/Features.zig");
pub const State = @import("Node/State.zig");

handle: *mscl.mscl_node,
features: Features,
/// Information read from this Node when it is initialized.
state: State,
/// The frequency that the Node is on. `changeFrequency` updates it.
frequency: root.Frequency,
/// The number of retry attempts for reading and writing config options with
/// the Node. By default, the number of retries is 0. Note:   The timeout that
/// is set per command will be per read and write attempt, meaning this retry
/// number is multiplied by the timeout for your overall timeout.
/// `setRetries` updates it.
retries: u8,
/// The ChannelMask currently set on the Node, representing which channels are
/// enabled and disabled. `setActiveChannels` updates it.
active_channels: root.ChannelMask,

pub const Error = error{
    Connection,
    Communication,
    NodeCommunication,
    NotSupported,
    NoData,
    InvalidConfig,
    /// Any other failure; `root.mscl.mscl_last_error()` describes it.
    MsclFailure,
};

/// The model numbers for each of the Wireless Nodes.
pub const Model = enum(mscl.mscl_node_model) {
    v_link_legacy = mscl.MSCL_NODE_MODEL_V_LINK_LEGACY,
    cf_bearing_temp_link = mscl.MSCL_NODE_MODEL_CF_BEARING_TEMP_LINK,
    env_link_pro = mscl.MSCL_NODE_MODEL_ENV_LINK_PRO,
    g_link_2g = mscl.MSCL_NODE_MODEL_G_LINK_2G,
    g_link_10g = mscl.MSCL_NODE_MODEL_G_LINK_10G,
    g_link_ii_cust_in = mscl.MSCL_NODE_MODEL_G_LINK_II_CUST_IN,
    g_link_ii_2g_in = mscl.MSCL_NODE_MODEL_G_LINK_II_2G_IN,
    g_link_ii_10g_in = mscl.MSCL_NODE_MODEL_G_LINK_II_10G_IN,
    g_link_ii_cust_ex = mscl.MSCL_NODE_MODEL_G_LINK_II_CUST_EX,
    g_link_ii_2g_ex = mscl.MSCL_NODE_MODEL_G_LINK_II_2G_EX,
    g_link_ii_10g_ex = mscl.MSCL_NODE_MODEL_G_LINK_II_10G_EX,
    g_link_rgd_10g = mscl.MSCL_NODE_MODEL_G_LINK_RGD_10G,
    g_link_200_8g = mscl.MSCL_NODE_MODEL_G_LINK_200_8G,
    g_link_200_40g = mscl.MSCL_NODE_MODEL_G_LINK_200_40G,
    g_link_200_8g_oem = mscl.MSCL_NODE_MODEL_G_LINK_200_8G_OEM,
    g_link_200_40g_oem = mscl.MSCL_NODE_MODEL_G_LINK_200_40G_OEM,
    g_link_200_8g_oem_mmcx = mscl.MSCL_NODE_MODEL_G_LINK_200_8G_OEM_MMCX,
    g_link_200_40g_oem_mmcx = mscl.MSCL_NODE_MODEL_G_LINK_200_40G_OEM_MMCX,
    g_link_200_8g_oem_u_fl = mscl.MSCL_NODE_MODEL_G_LINK_200_8G_OEM_U_FL,
    g_link_200_40g_oem_u_fl = mscl.MSCL_NODE_MODEL_G_LINK_200_40G_OEM_U_FL,
    g_link_200_r = mscl.MSCL_NODE_MODEL_G_LINK_200_R,
    sg_link_oem_s = mscl.MSCL_NODE_MODEL_SG_LINK_OEM_S,
    sg_link = mscl.MSCL_NODE_MODEL_SG_LINK,
    sg_link200 = mscl.MSCL_NODE_MODEL_SG_LINK200,
    sg_link200_hbridge_1k = mscl.MSCL_NODE_MODEL_SG_LINK200_HBRIDGE_1K,
    sg_link200_hbridge_350 = mscl.MSCL_NODE_MODEL_SG_LINK200_HBRIDGE_350,
    sg_link200_hbridge_120 = mscl.MSCL_NODE_MODEL_SG_LINK200_HBRIDGE_120,
    sg_link200_qbridge_1k = mscl.MSCL_NODE_MODEL_SG_LINK200_QBRIDGE_1K,
    sg_link200_qbridge_350 = mscl.MSCL_NODE_MODEL_SG_LINK200_QBRIDGE_350,
    sg_link200_qbridge_120 = mscl.MSCL_NODE_MODEL_SG_LINK200_QBRIDGE_120,
    sg_link_oem = mscl.MSCL_NODE_MODEL_SG_LINK_OEM,
    sg_link_micro = mscl.MSCL_NODE_MODEL_SG_LINK_MICRO,
    sg_link200_oem = mscl.MSCL_NODE_MODEL_SG_LINK200_OEM,
    sg_link200_oem_ufl = mscl.MSCL_NODE_MODEL_SG_LINK200_OEM_UFL,
    sg_link200_oem_hbridge_1k = mscl.MSCL_NODE_MODEL_SG_LINK200_OEM_HBRIDGE_1K,
    sg_link200_oem_hbridge_1k_ufl =
        mscl.MSCL_NODE_MODEL_SG_LINK200_OEM_HBRIDGE_1K_UFL,
    sg_link200_oem_hbridge_120 =
        mscl.MSCL_NODE_MODEL_SG_LINK200_OEM_HBRIDGE_120,
    sg_link200_oem_hbridge_120_ufl =
        mscl.MSCL_NODE_MODEL_SG_LINK200_OEM_HBRIDGE_120_UFL,
    sg_link200_oem_hbridge_350 =
        mscl.MSCL_NODE_MODEL_SG_LINK200_OEM_HBRIDGE_350,
    sg_link200_oem_hbridge_350_ufl =
        mscl.MSCL_NODE_MODEL_SG_LINK200_OEM_HBRIDGE_350_UFL,
    sg_link200_oem_qbridge_1k = mscl.MSCL_NODE_MODEL_SG_LINK200_OEM_QBRIDGE_1K,
    sg_link200_oem_qbridge_1k_ufl =
        mscl.MSCL_NODE_MODEL_SG_LINK200_OEM_QBRIDGE_1K_UFL,
    sg_link200_oem_qbridge_120 =
        mscl.MSCL_NODE_MODEL_SG_LINK200_OEM_QBRIDGE_120,
    sg_link200_oem_qbridge_120_ufl =
        mscl.MSCL_NODE_MODEL_SG_LINK200_OEM_QBRIDGE_120_UFL,
    sg_link200_oem_qbridge_350 =
        mscl.MSCL_NODE_MODEL_SG_LINK200_OEM_QBRIDGE_350,
    sg_link200_oem_qbridge_350_ufl =
        mscl.MSCL_NODE_MODEL_SG_LINK200_OEM_QBRIDGE_350_UFL,
    sg_link200_oem_128hz = mscl.MSCL_NODE_MODEL_SG_LINK200_OEM_128HZ,
    sg_link200_oem_256hz = mscl.MSCL_NODE_MODEL_SG_LINK200_OEM_256HZ,
    sg_link200_oem_qbridge_350_128hz =
        mscl.MSCL_NODE_MODEL_SG_LINK200_OEM_QBRIDGE_350_128HZ,
    sg_link200_oem_qbridge_350_256hz =
        mscl.MSCL_NODE_MODEL_SG_LINK200_OEM_QBRIDGE_350_256HZ,
    sg_link_rgd = mscl.MSCL_NODE_MODEL_SG_LINK_RGD,
    shm_link = mscl.MSCL_NODE_MODEL_SHM_LINK,
    tc_link_1ch = mscl.MSCL_NODE_MODEL_TC_LINK_1CH,
    tc_link_6ch = mscl.MSCL_NODE_MODEL_TC_LINK_6CH,
    tc_link_3ch = mscl.MSCL_NODE_MODEL_TC_LINK_3CH,
    tc_link_6ch_ip67 = mscl.MSCL_NODE_MODEL_TC_LINK_6CH_IP67,
    tc_link200_oem = mscl.MSCL_NODE_MODEL_TC_LINK200_OEM,
    tc_link200_oem_ufl = mscl.MSCL_NODE_MODEL_TC_LINK200_OEM_UFL,
    tc_link200 = mscl.MSCL_NODE_MODEL_TC_LINK200,
    rtd_link200 = mscl.MSCL_NODE_MODEL_RTD_LINK200,
    tc_link_6ch_ip67_rht = mscl.MSCL_NODE_MODEL_TC_LINK_6CH_IP67_RHT,
    v_link = mscl.MSCL_NODE_MODEL_V_LINK,
    v_link200 = mscl.MSCL_NODE_MODEL_V_LINK200,
    v_link200_qbridge_1k = mscl.MSCL_NODE_MODEL_V_LINK200_QBRIDGE_1K,
    v_link200_qbridge_120 = mscl.MSCL_NODE_MODEL_V_LINK200_QBRIDGE_120,
    v_link200_qbridge_350 = mscl.MSCL_NODE_MODEL_V_LINK200_QBRIDGE_350,
    v_link200_hbridge_1k = mscl.MSCL_NODE_MODEL_V_LINK200_HBRIDGE_1K,
    v_link200_hbridge_120 = mscl.MSCL_NODE_MODEL_V_LINK200_HBRIDGE_120,
    v_link200_hbridge_350 = mscl.MSCL_NODE_MODEL_V_LINK200_HBRIDGE_350,
    iepe_link = mscl.MSCL_NODE_MODEL_IEPE_LINK,
    dvrt_link = mscl.MSCL_NODE_MODEL_DVRT_LINK,
    env_link_mini = mscl.MSCL_NODE_MODEL_ENV_LINK_MINI,
    watt_link = mscl.MSCL_NODE_MODEL_WATT_LINK,
    watt_link_3y208 = mscl.MSCL_NODE_MODEL_WATT_LINK_3Y208,
    watt_link_3d240 = mscl.MSCL_NODE_MODEL_WATT_LINK_3D240,
    watt_link_3y400 = mscl.MSCL_NODE_MODEL_WATT_LINK_3Y400,
    watt_link_3d400 = mscl.MSCL_NODE_MODEL_WATT_LINK_3D400,
    watt_link_3y480 = mscl.MSCL_NODE_MODEL_WATT_LINK_3Y480,
    watt_link_3d480 = mscl.MSCL_NODE_MODEL_WATT_LINK_3D480,
    watt_link_3y600 = mscl.MSCL_NODE_MODEL_WATT_LINK_3Y600,
    pt_link200 = mscl.MSCL_NODE_MODEL_PT_LINK200,
    rtd_link = mscl.MSCL_NODE_MODEL_RTD_LINK,
    shm_link2_cust1_old_number =
        mscl.MSCL_NODE_MODEL_SHM_LINK2_CUST1_OLD_NUMBER,
    shm_link2_cust1 = mscl.MSCL_NODE_MODEL_SHM_LINK2_CUST1,
    shm_link200 = mscl.MSCL_NODE_MODEL_SHM_LINK200,
    shm_link201 = mscl.MSCL_NODE_MODEL_SHM_LINK201,
    shm_link201_qbridge_1k = mscl.MSCL_NODE_MODEL_SHM_LINK201_QBRIDGE_1K,
    shm_link201_qbridge_348 = mscl.MSCL_NODE_MODEL_SHM_LINK201_QBRIDGE_348,
    shm_link201_hbridge_1k = mscl.MSCL_NODE_MODEL_SHM_LINK201_HBRIDGE_1K,
    shm_link201_hbridge_348 = mscl.MSCL_NODE_MODEL_SHM_LINK201_HBRIDGE_348,
    shm_link201_fullbridge = mscl.MSCL_NODE_MODEL_SHM_LINK201_FULLBRIDGE,
    shm_link210_fullbridge = mscl.MSCL_NODE_MODEL_SHM_LINK210_FULLBRIDGE,
    shm_link210_qbridge_3k = mscl.MSCL_NODE_MODEL_SHM_LINK210_QBRIDGE_3K,
    torque_link = mscl.MSCL_NODE_MODEL_TORQUE_LINK,
    torque_link200_3ch = mscl.MSCL_NODE_MODEL_TORQUE_LINK200_3CH,
    torque_link200 = mscl.MSCL_NODE_MODEL_TORQUE_LINK200,
    torque_link200_3ch_s = mscl.MSCL_NODE_MODEL_TORQUE_LINK200_3CH_S,
    sg_link_herm = mscl.MSCL_NODE_MODEL_SG_LINK_HERM,
    sg_link_herm_2600 = mscl.MSCL_NODE_MODEL_SG_LINK_HERM_2600,
    sg_link_herm_2700 = mscl.MSCL_NODE_MODEL_SG_LINK_HERM_2700,
    sg_link_herm_2800 = mscl.MSCL_NODE_MODEL_SG_LINK_HERM_2800,
    sg_link_herm_2900 = mscl.MSCL_NODE_MODEL_SG_LINK_HERM_2900,
    wireless_impact_sensor = mscl.MSCL_NODE_MODEL_WIRELESS_IMPACT_SENSOR,
    g_link_200_40g_s = mscl.MSCL_NODE_MODEL_G_LINK_200_40G_S,
    g_link_200_p = mscl.MSCL_NODE_MODEL_G_LINK_200_P,
    g_link_200_px8 = mscl.MSCL_NODE_MODEL_G_LINK_200_PX8,
    g_link_200_px40 = mscl.MSCL_NODE_MODEL_G_LINK_200_PX40,
    _,
};

/// The values that `poll` read, one per channel.
pub const PollData = struct {
    values: []mscl.mscl_poll_value,

    pub fn deinit(self: PollData) void {
        if (self.values.len == 0) {
            return;
        }
        mscl.mscl_poll_values_free(self.values.ptr);
    }
};

/// The data points that `getDiagnosticInfo` read.
pub const DiagnosticInfo = struct {
    points: []mscl.mscl_data_point,

    pub fn deinit(self: DiagnosticInfo) void {
        if (self.points.len == 0) {
            return;
        }
        mscl.mscl_data_points_free(self.points.ptr);
    }
};

/// The factory calibration stored on the Node for its channels.
/// `Features.supports.get_factory_cal` tells whether the Node has any.
pub const FactoryCalibration = struct {
    /// Gets the factory-calibrated linear equation for the specified
    /// ChannelMask.
    pub fn linearEquation(
        node: Node,
        channel_mask: root.ChannelMask,
    ) Error!mscl.mscl_linear_equation {
        var equation = std.mem.zeroes(mscl.mscl_linear_equation);
        const status = mscl.mscl_node_get_factory_calibration_linear_eq(
            node.handle,
            @bitCast(channel_mask),
            &equation,
        );
        return switch (status) {
            mscl.MSCL_OK => equation,
            // Linear Equation is not supported for the provided ChannelMask.
            mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
            // Failed to communicate with the Node.
            mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
            // A connection error has occurred with the parent BaseStation.
            mscl.MSCL_ERROR_CONNECTION => Error.Connection,
            else => mscl: {
                std.log.err("{s}", .{mscl.mscl_last_error()});
                break :mscl Error.MsclFailure;
            },
        };
    }

    /// Reads the factory calibration unit for the specified ChannelMask.
    pub fn unit(
        node: Node,
        channel_mask: root.ChannelMask,
    ) Error!root.CalCoefUnit {
        var res: mscl.mscl_cal_coef_unit = 0;
        const status = mscl.mscl_node_get_factory_calibration_unit(
            node.handle,
            @bitCast(channel_mask),
            &res,
        );
        return switch (status) {
            mscl.MSCL_OK => @fromBackingInt(res),
            // Unit is not supported for the provided ChannelMask.
            mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
            // Failed to communicate with the Node.
            mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
            // A connection error has occurred with the parent BaseStation.
            mscl.MSCL_ERROR_CONNECTION => Error.Connection,
            else => mscl: {
                std.log.err("{s}", .{mscl.mscl_last_error()});
                break :mscl Error.MsclFailure;
            },
        };
    }
};

/// The EEPROM of the Node and its cache.
pub const Eeprom = struct {
    /// The EEPROM cache of a node: the last known value of each location.
    pub const Cache = struct {
        entries: []mscl.mscl_eeprom_entry,

        pub fn deinit(self: Cache) void {
            if (self.entries.len == 0) {
                return;
            }
            mscl.mscl_eeprom_entries_free(self.entries.ptr);
        }
    };

    /// Gets a copy of the eeprom cache as a WirelessTypes::EepromMap.
    pub fn getCache(node: Node) Error!Cache {
        var entries: [*c]mscl.mscl_eeprom_entry = null;
        var count: usize = 0;
        const status =
            mscl.mscl_node_get_eeprom_cache(node.handle, &entries, &count);
        return switch (status) {
            mscl.MSCL_OK => .{
                .entries = if (count == 0) &.{} else entries[0..count],
            },
            else => mscl: {
                std.log.err("{s}", .{mscl.mscl_last_error()});
                break :mscl Error.MsclFailure;
            },
        };
    }

    /// Sets whether to use the eeprom cache when configuring this Node
    /// (enabled by default). This can be enabled/disabled at any time. It is
    /// highly recommended to have eeprom caching be enabled. Note:    The
    /// eeprom cache stores the last known value that was written to / read
    /// from the Node for each eeprom location. If this is enabled, any reads
    /// will get the last known value from the cache if it exists, and any
    /// writes will not write to the Node if the value attempting to be written
    /// is the same as that stored in the cache. Caching of these values will
    /// still be performed if this is disabled, however, read and write
    /// operations will then always reach out to the actual device.
    pub fn useCache(node: Node, use_cache: bool) void {
        _ = mscl.mscl_node_use_eeprom_cache(node.handle, use_cache);
    }

    /// Clears the eeprom cache for this Node. MSCL frees the features of the
    /// Node with the cache, so this reads `features` again. If that fails, do
    /// not call the functions of `features` until this succeeds.
    pub fn clearCache(
        node: *Node,
        gpa: std.mem.Allocator,
    ) (Error || std.mem.Allocator.Error)!void {
        _ = mscl.mscl_node_clear_eeprom_cache(node.handle);
        const features = try Features.init(gpa, node.handle);
        node.features.deinit(gpa);
        node.features = features;
    }

    /// Reads a uint16 from the given eeprom location of the node. This may use
    /// a page download or a read eeprom command. If the value stored in the
    /// eeprom cache is still valid, this will be returned instead. Note: This
    /// is an advanced command. In most cases, you should use the built-in
    /// commands for reading a Node's configuration options.
    pub fn read(node: Node, location: u16) Error!u16 {
        var value: u16 = 0;
        const status =
            mscl.mscl_node_read_eeprom(node.handle, location, &value);
        return switch (status) {
            mscl.MSCL_OK => value,
            // Attempted to read an unsupported eeprom location.
            mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
            // Failed to read the value from the Node.
            mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
            // A connection error has occurred with the parent BaseStation.
            mscl.MSCL_ERROR_CONNECTION => Error.Connection,
            else => mscl: {
                std.log.err("{s}", .{mscl.mscl_last_error()});
                break :mscl Error.MsclFailure;
            },
        };
    }

    /// Writes a uint16 to the given eeprom location of the node. If
    /// successful, the cache will be updated with the changed value as well.
    /// Note: This is an advanced command. In most cases, you should use the
    /// built-in commands for changing a Node's configuration options.
    pub fn write(node: Node, location: u16, value: u16) Error!void {
        const status =
            mscl.mscl_node_write_eeprom(node.handle, location, value);
        return switch (status) {
            mscl.MSCL_OK => {},
            // Unsupported eeprom location or value.
            mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
            // Failed to write the value to the Node.
            mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
            // A connection error has occurred with the parent BaseStation.
            mscl.MSCL_ERROR_CONNECTION => Error.Connection,
            else => mscl: {
                std.log.err("{s}", .{mscl.mscl_last_error()});
                break :mscl Error.MsclFailure;
            },
        };
    }
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
    const features = try Features.init(gpa, node);
    errdefer features.deinit(gpa);
    var result: Node = .{
        .handle = node,
        .features = features,
        .state = std.mem.zeroInit(State, .{}),
        .frequency = .unknown,
        .retries = 0,
        .active_channels = .{},
    };
    errdefer result.state.deinit(gpa);

    result.state.node_address = result.getNodeAddress();
    result.state.name = try result.getName(gpa);
    result.state.serial = try result.getSerial(gpa);
    result.state.model = try result.getModel();
    result.state.microcontroller = try result.getMicrocontroller();
    result.state.region_code = try result.getRegionCode();
    result.state.firmware_version = try result.getFirmwareVersion();
    result.frequency = try result.getFrequency();
    result.retries = result.getRetries();
    result.active_channels = try result.getActiveChannels();
    return result;
}

/// Destroys the node. Deinitialize everything using this node first.
pub fn deinit(self: Node, gpa: std.mem.Allocator) void {
    self.state.deinit(gpa);
    self.features.deinit(gpa);
    mscl.mscl_node_destroy(self.handle);
}

/// Sets the node's parent Base Station, which will perform all communication
/// with the node
pub fn setBaseStation(self: Node, base_station: BaseStation) void {
    _ = mscl.mscl_node_set_base_station(self.handle, base_station.handle);
}

/// Checks whether the given BaseStation is the same BaseStation that is
/// assigned to this Node.
pub fn hasBaseStation(self: Node, base_station: BaseStation) bool {
    var has = false;
    _ = mscl.mscl_node_has_base_station(
        self.handle,
        base_station.handle,
        &has,
    );
    return has;
}

/// Attempts to set the Node to the Idle state. This will stop the node from
/// sampling or sleeping, and put it into an idle state so that it may be
/// communicated with (configured, started sampling, etc.). This operation may
/// take several seconds to complete. The returned SetToIdleStatus object may be
/// used to determine the current status of the Set to Idle operation.
pub fn setToIdle(self: Node) Error!root.SetToIdleStatus {
    var handle: ?*mscl.mscl_set_to_idle_status = null;
    const status = mscl.mscl_node_set_to_idle(self.handle, &handle);
    return switch (status) {
        mscl.MSCL_OK => .{ .handle = handle.? },
        // Failed to communicate with the parent BaseStation.
        mscl.MSCL_ERROR_COMMUNICATION => Error.Communication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Polls the WirelessNode to get a single sweep of calibrated data.
pub fn poll(self: Node, channel_mask: root.ChannelMask) Error!PollData {
    var values: [*c]mscl.mscl_poll_value = null;
    var count: usize = 0;
    const status = mscl.mscl_node_poll(
        self.handle,
        @bitCast(channel_mask),
        &values,
        &count,
    );
    return switch (status) {
        mscl.MSCL_OK => .{
            .values = if (count == 0) &.{} else values[0..count],
        },
        // Autocal shunt is not supported by the Node or ChannelMask.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to communicate with the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Performs an immediate request for the Node's Diagnostic Info. Note: Nodes
/// can also be configured to transmit Diagnostic Info data packets at a
/// specified Diagnostic Interval via the WirelessNodeConfig object.
pub fn diagnosticInfo(self: Node) Error!DiagnosticInfo {
    var points: [*c]mscl.mscl_data_point = null;
    var count: usize = 0;
    const status =
        mscl.mscl_node_get_diagnostic_info(self.handle, &points, &count);
    return switch (status) {
        mscl.MSCL_OK => .{
            .points = if (count == 0) &.{} else points[0..count],
        },
        // The Get Diagnostic Info command is not supported.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to communicate with the Wireless Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the settings that a WirelessNodeConfig can hold from the Node, with
/// the per-channel settings of `channels`. A setting that the Node does not
/// support for `channels` is null or empty. The equation type cannot be read
/// from the Node, so it is always null.
/// Free the result with `Config.deinit`.
pub fn getConfig(
    self: Node,
    gpa: std.mem.Allocator,
    channels: root.ChannelMask,
) (Error || std.mem.Allocator.Error)!Config {
    var result: Config = std.mem.zeroInit(Config, .{});
    errdefer result.deinit(gpa);

    // A setting that the Node does not support stays null.
    result.default_mode = self.getDefaultMode() catch |err| switch (err) {
        Error.NotSupported => null,
        else => |e| {
            return e;
        },
    };
    result.inactivity_timeout =
        self.getInactivityTimeout() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.check_radio_interval =
        self.getCheckRadioInterval() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.transmit_power = self.getTransmitPower() catch |err| switch (err) {
        Error.NotSupported => null,
        else => |e| {
            return e;
        },
    };
    result.sampling_mode = self.getSamplingMode() catch |err| switch (err) {
        Error.NotSupported => null,
        else => |e| {
            return e;
        },
    };
    result.sample_rate = self.getSampleRate() catch |err| switch (err) {
        Error.NotSupported => null,
        else => |e| {
            return e;
        },
    };
    result.num_sweeps = self.getNumSweeps() catch |err| switch (err) {
        Error.NotSupported => null,
        else => |e| {
            return e;
        },
    };
    result.unlimited_duration =
        self.getUnlimitedDuration() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.data_format = self.getDataFormat() catch |err| switch (err) {
        Error.NotSupported => null,
        else => |e| {
            return e;
        },
    };
    result.data_collection_method =
        self.getDataCollectionMethod() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.time_between_bursts =
        self.getTimeBetweenBursts() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.lost_beacon_timeout =
        self.getLostBeaconTimeout() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.cfc_filter_config =
        self.getCfcFilterConfiguration() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.gauge_resistance =
        self.getGaugeResistance() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.excitation_voltage =
        self.getExcitationVoltage() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.num_active_gauges =
        self.getNumActiveGauges() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.low_battery_threshold =
        self.getLowBatteryThreshold() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.fatigue_options = self.getFatigueOptions() catch |err| switch (err) {
        Error.NotSupported => null,
        else => |e| {
            return e;
        },
    };
    result.histogram_options =
        self.getHistogramOptions() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.activity_sense = self.getActivitySense() catch |err| switch (err) {
        Error.NotSupported => null,
        else => |e| {
            return e;
        },
    };
    result.event_trigger_options =
        self.getEventTriggerOptions() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.diagnostic_interval =
        self.getDiagnosticInterval() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.storage_limit_mode =
        self.getStorageLimitMode() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.sensor_delay = self.getSensorDelay() catch |err| switch (err) {
        Error.NotSupported => null,
        else => |e| {
            return e;
        },
    };
    result.data_mode = self.getDataMode() catch |err| switch (err) {
        Error.NotSupported => null,
        else => |e| {
            return e;
        },
    };
    result.derived_data_rate =
        self.getDerivedDataRate() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.derived_velocity_unit =
        self.getDerivedVelocityUnit() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.communication_protocol =
        self.getCommunicationProtocol() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.sensor_output_mode =
        self.getSensorOutputMode() catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };

    const categories = self.features.channels_per_derived_category;
    const derived_channel_masks =
        try gpa.alloc(mscl.mscl_derived_channel_mask, categories.len);
    result.derived_channel_masks = derived_channel_masks;
    for (derived_channel_masks, categories) |*derived, supported| {
        const category: root.DerivedCategory =
            @fromBackingInt(supported.category);
        derived.* = .{
            .category = supported.category,
            .mask = @bitCast(try self.getDerivedChannelMask(category)),
        };
    }

    result.input_range =
        self.getInputRange(channels) catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.hardware_offset =
        self.getHardwareOffset(channels) catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.anti_aliasing_filter =
        self.getAntiAliasingFilter(channels) catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.low_pass_filter =
        self.getLowPassFilter(channels) catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.high_pass_filter =
        self.getHighPassFilter(channels) catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.gauge_factor =
        self.getGaugeFactor(channels) catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.linear_equation =
        self.getLinearEquation(channels) catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.unit = self.getUnit(channels) catch |err| switch (err) {
        Error.NotSupported => null,
        else => |e| {
            return e;
        },
    };
    result.filter_settling_time =
        self.getFilterSettlingTime(channels) catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.thermocouple_type =
        self.getThermocoupleType(channels) catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.temp_sensor_options =
        self.getTempSensorOptions(channels) catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.debounce_filter =
        self.getDebounceFilter(channels) catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    result.pull_up_resistor =
        self.getPullUpResistor(channels) catch |err| switch (err) {
            Error.NotSupported => null,
            else => |e| {
                return e;
            },
        };
    return result;
}

/// Applies a WirelessNodeConfig to the Node. Note: This applies all options
/// that have been set in the WirelessNodeConfig. Before applying, the options
/// will be validated. Options that are set will also be validated against each
/// other. If an option that needs to be validated isn't currently set, it will
/// be read from the Node.
/// The per-channel settings of `config` are applied to `channels`.
/// When the options are not valid, nothing is applied, `issues` receives one
/// line per problem, NUL-terminated and truncated to fit, and InvalidConfig is
/// returned.
pub fn applyConfig(
    self: Node,
    config: Config,
    channels: root.ChannelMask,
    issues: []u8,
) (Error || std.mem.Allocator.Error)!void {
    const mscl_config = try config.createHandle(channels);
    defer mscl.mscl_node_config_destroy(mscl_config);

    var ok = false;
    const verify_status = mscl.mscl_node_verify_config(
        self.handle,
        mscl_config,
        &ok,
        issues.ptr,
        issues.len,
    );
    switch (verify_status) {
        mscl.MSCL_OK => {},
        // The Node model, or firmware version, is not supported by MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => {
            return Error.NotSupported;
        },
        // Failed to communicate with the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => {
            return Error.NodeCommunication;
        },
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => {
            return Error.Connection;
        },
        else => {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            return Error.MsclFailure;
        },
    }
    if (!ok) {
        // The configuration is invalid; `issues` lists why.
        return Error.InvalidConfig;
    }

    const apply_status = mscl.mscl_node_apply_config(self.handle, mscl_config);
    return switch (apply_status) {
        mscl.MSCL_OK => {},
        // The Node model, or firmware version, is not supported by MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Invalid Configuration. Check the exception for specific details.
        mscl.MSCL_ERROR_INVALID_CONFIG => Error.InvalidConfig,
        // Failed to write to the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Sets which channels are active on the Node. When the sample rate currently
/// set on the Node is faster than the max the Node supports with `channels`,
/// the sample rate is lowered to that max in the same apply.
/// When the options are not valid, nothing is applied, `issues` receives one
/// line per problem, NUL-terminated and truncated to fit, and InvalidConfig is
/// returned.
/// Updates `active_channels`.
pub fn setActiveChannels(
    self: *Node,
    channels: root.ChannelMask,
    issues: []u8,
) (Error || Features.Error || std.mem.Allocator.Error)!void {
    const sampling_mode = try self.getSamplingMode();
    const collection_method = try self.getDataCollectionMethod();
    const data_mode = try self.getDataMode();
    const sample_rate = try self.getSampleRate();
    const max = try self.features.sample_rate.max(
        sampling_mode,
        channels,
        collection_method,
        data_mode,
    );
    const rate_count = @typeInfo(root.SampleRate).@"enum".field_names.len;
    var buffer: [rate_count]root.SampleRate = undefined;
    const rates = try self.features.sample_rate.list(
        sampling_mode,
        collection_method,
        data_mode,
        &buffer,
    );
    // The rates are listed from the fastest, so a rate listed before the max
    // is faster than the max.
    const max_index = std.mem.findScalar(root.SampleRate, rates, max);
    const rate_index = std.mem.findScalar(root.SampleRate, rates, sample_rate);

    var handle: ?*mscl.mscl_node_config = null;
    const create_status = mscl.mscl_node_config_create(&handle);
    switch (create_status) {
        mscl.MSCL_OK => {},
        // Allocating the config failed.
        mscl.MSCL_ERROR_OUT_OF_MEMORY => {
            return std.mem.Allocator.Error.OutOfMemory;
        },
        else => unreachable,
    }
    const mscl_config = handle.?;
    defer mscl.mscl_node_config_destroy(mscl_config);

    _ = mscl.mscl_node_config_set_active_channels(
        mscl_config,
        @bitCast(channels),
    );
    if (max_index != null and rate_index != null and
        rate_index.? < max_index.?)
    {
        _ = mscl.mscl_node_config_set_sample_rate(
            mscl_config,
            @backingInt(max),
        );
    }

    var ok = false;
    const verify_status = mscl.mscl_node_verify_config(
        self.handle,
        mscl_config,
        &ok,
        issues.ptr,
        issues.len,
    );
    switch (verify_status) {
        mscl.MSCL_OK => {},
        // The Node model, or firmware version, is not supported by MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => {
            return Error.NotSupported;
        },
        // Failed to communicate with the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => {
            return Error.NodeCommunication;
        },
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => {
            return Error.Connection;
        },
        else => {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            return Error.MsclFailure;
        },
    }
    if (!ok) {
        // The configuration is invalid; `issues` lists why.
        return Error.InvalidConfig;
    }

    const apply_status = mscl.mscl_node_apply_config(self.handle, mscl_config);
    switch (apply_status) {
        mscl.MSCL_OK => {},
        // The Node model, or firmware version, is not supported by MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => {
            return Error.NotSupported;
        },
        // Invalid Configuration. Check the exception for specific details.
        mscl.MSCL_ERROR_INVALID_CONFIG => {
            return Error.InvalidConfig;
        },
        // Failed to write to the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => {
            return Error.NodeCommunication;
        },
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => {
            return Error.Connection;
        },
        else => {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            return Error.MsclFailure;
        },
    }
    self.active_channels = try self.getActiveChannels();
}

/// Gets the Timestamp for the last time MSCL communicated with the Node. Note:
/// EEPROM reads using the cache will not update this timestamp.
pub fn getLastCommunicationTime(self: Node) Error!u64 {
    var time_ns: u64 = 0;
    const status = mscl.mscl_node_get_last_communication_time(
        self.handle,
        &time_ns,
    );
    return switch (status) {
        mscl.MSCL_OK => time_ns,
        // There is no communication time logged for this Node.
        mscl.MSCL_ERROR_NO_DATA => Error.NoData,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the last known DeviceState for the Node. This device state is updated
/// by diagnostic packets, as well as when operations are performed by MSCL,
/// such as setting a Node to idle.
pub fn getLastDeviceState(self: Node) root.DeviceState {
    var state: mscl.mscl_device_state = 0;
    _ = mscl.mscl_node_get_last_device_state(self.handle, &state);
    return @fromBackingInt(state);
}

/// Enables or disables the use of group eeprom read when trying to read a
/// single value (enabled by default). Note:    In most cases, leaving this
/// enabled will provide better performance, allowing the cache to be built
/// quicker, requiring less communication to the actual device. However, in some
/// cases such as with very high traffic, it may be beneficial to restrict reads
/// to use the single commands, as the packets are smaller over the air.
pub fn useGroupRead(self: Node, use_group: bool) void {
    _ = mscl.mscl_node_use_group_read(self.handle, use_group);
}

/// Sets the number of retry attempts for reading and writing config options
/// with the Node. By default, the number of retries is 0. Note:   The timeout
/// that is set per command will be per read and write attempt, meaning this
/// retry number is multiplied by the timeout for your overall timeout.
/// Updates `retries`.
pub fn setRetries(self: *Node, retries: u8) void {
    _ = mscl.mscl_node_set_retries(self.handle, retries);
    self.retries = self.getRetries();
}

/// Gets the RadioFeatures of the Node.
pub fn getRadioFeatures(self: Node) Error!mscl.mscl_radio_features {
    var radio_features = std.mem.zeroes(mscl.mscl_radio_features);
    const status = mscl.mscl_node_get_radio_features(
        self.handle,
        &radio_features,
    );
    return switch (status) {
        mscl.MSCL_OK => radio_features,
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read the value from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the number of bytes available for data storage on the Node.
pub fn getDataStorageSize(self: Node) Error!u64 {
    var size: u64 = 0;
    const status = mscl.mscl_node_get_data_storage_size(self.handle, &size);
    return switch (status) {
        mscl.MSCL_OK => size,
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read the value from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Performs a Long Ping command on the Node to check the communication between
/// the Base Station and the Node. The response to this command contains the
/// Node and BaseStation RSSI values.
pub fn ping(self: Node) Error!mscl.mscl_ping_result {
    var result = std.mem.zeroes(mscl.mscl_ping_result);
    const status = mscl.mscl_node_ping(self.handle, &result);
    return switch (status) {
        mscl.MSCL_OK => result,
        // A connection error has occurred with the parent BaseStation
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Puts the Node into a low power, sleep mode. This command attempts to ping
/// the node before sending the sleep command, to verify communication.
pub fn sleep(self: Node) Error!bool {
    var success: bool = false;
    const status = mscl.mscl_node_sleep(self.handle, &success);
    return switch (status) {
        mscl.MSCL_OK => success,
        // A connection error has occurred with the BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Cycles the power on the Node. Many configuration changes that are applied to
/// the node do not take effect until the power is cycled.
pub fn cyclePower(self: Node) Error!void {
    const status = mscl.mscl_node_cycle_power(self.handle);
    return switch (status) {
        mscl.MSCL_OK => {},
        // Attempted to write an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to reset the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Resets the radio on the Node.
pub fn resetRadio(self: Node) Error!void {
    const status = mscl.mscl_node_reset_radio(self.handle);
    return switch (status) {
        mscl.MSCL_OK => {},
        // Attempted to write an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to reset the Node
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Changes the radio frequency of the Node. Note: If successful, the Node will
/// be put onto a different frequency than its parent base station. It is up to
/// the user of MSCL to switch the base station to this frequency if you wish to
/// communicate with it.
/// Updates `frequency`.
pub fn changeFrequency(self: *Node, frequency: root.Frequency) Error!void {
    const status = mscl.mscl_node_change_frequency(
        self.handle,
        @backingInt(frequency),
    );
    switch (status) {
        mscl.MSCL_OK => {},
        // Attempted to write an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => {
            return Error.NotSupported;
        },
        // Failed to write the value to the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => {
            return Error.NodeCommunication;
        },
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => {
            return Error.Connection;
        },
        else => {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            return Error.MsclFailure;
        },
    }
    self.frequency = try self.getFrequency();
}

/// Erases all logged data on the Node. Note: Erasing the data on the Node may
/// take up to 30 seconds to complete for some devices. This command will return
/// immediately while the Node is being erased. If you wish to check the status
/// of the Erase operation, you can continuously ping the Node. A successful
/// ping means the erase has completed.
pub fn erase(self: Node) Error!void {
    const status = mscl.mscl_node_erase(self.handle);
    return switch (status) {
        mscl.MSCL_OK => {},
        // Failed to erase the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Starts the Node in Non-Synchronized Sampling Mode. This will immediately
/// start the Node sampling, with the current Sampling settings that are applied
/// to the Node. Note: To start the Node in Synchronized Sampling Mode, use the
/// SyncSamplingNetwork class.
pub fn startNonSyncSampling(self: Node) Error!void {
    var success: bool = false;
    const status = mscl.mscl_node_start_non_sync_sampling(
        self.handle,
        &success,
    );
    return switch (status) {
        // The Node did not confirm that it started sampling.
        mscl.MSCL_OK => if (success) {} else Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        // The Configuration of the Node is not set for Non-Sync Sampling Mode.
        mscl.MSCL_ERROR_INVALID_CONFIG => Error.InvalidConfig,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Important!: Use the SyncSamplingNetwork to start a Node in Sync Sampling
/// mode. Advanced Function that sends the Start Sync Sampling command to the
/// individual Node. This command is useful when you have already used the
/// SyncSamplingNetwork object to start a network of Nodes, but need to resend
/// the start command to a Node. For instance, if you had to set a node to idle,
/// and haven't changed any configuration settings. Note that this command does
/// not enable a beacon, which is needed for a Sync Sampling network to be
/// running. Warning: This function is rarely what you want to use to start Sync
/// Sampling. Instead, you should create a SyncSamplingNetwork object. Failing
/// to use the SyncSamplingNetwork object can cause the network to be
/// misconfigured, and result in loss of data.
pub fn resendStartSyncSampling(self: Node) Error!bool {
    var success: bool = false;
    const status = mscl.mscl_node_resend_start_sync_sampling(
        self.handle,
        &success,
    );
    return switch (status) {
        mscl.MSCL_OK => success,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        // The Configuration of the Node is not set for Sync Sampling Mode.
        mscl.MSCL_ERROR_INVALID_CONFIG => Error.InvalidConfig,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Clears the Histogram on the Node.
pub fn clearHistogram(self: Node) Error!void {
    const status = mscl.mscl_node_clear_histogram(self.handle);
    return switch (status) {
        mscl.MSCL_OK => {},
        // Histogram configuration is not supported by the Node.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to communicate with the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Performs an Auto Balance command on a specified channel on the Node. This
/// adjusts the sensor offset for differential channels to affect range.
pub fn autoBalance(
    self: Node,
    channel_mask: root.ChannelMask,
    target_percent: f32,
) Error!mscl.mscl_auto_balance_result {
    var result = std.mem.zeroes(mscl.mscl_auto_balance_result);
    const status = mscl.mscl_node_auto_balance(
        self.handle,
        @bitCast(channel_mask),
        target_percent,
        &result,
    );
    return switch (status) {
        mscl.MSCL_OK => result,
        // Auto balance is not supported by the Node or channel mask specified.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to communicate with the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Performs automatic calibration for the SHM-Link Wireless Node.
pub fn autoCalShmLink(self: Node) Error!mscl.mscl_auto_cal_result_shm_link {
    var result = std.mem.zeroes(mscl.mscl_auto_cal_result_shm_link);
    const status = mscl.mscl_node_auto_cal_shm_link(self.handle, &result);
    return switch (status) {
        mscl.MSCL_OK => result,
        // Autocal is not supported by the Node or The node is an invalid model
        // for this command.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to communicate with the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Performs automatic calibration for the SHM-Link-201 Wireless Node.
pub fn autoCalShmLink201(
    self: Node,
) Error!mscl.mscl_auto_cal_result_shm_link_201 {
    var result = std.mem.zeroes(mscl.mscl_auto_cal_result_shm_link_201);
    const status = mscl.mscl_node_auto_cal_shm_link_201(self.handle, &result);
    return switch (status) {
        mscl.MSCL_OK => result,
        // Autocal is not supported by the Node or The node is an invalid model
        // for this command.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to communicate with the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Performs automatic shunt calibration for a specified ChannelMask on
/// supported Nodes.
pub fn autoShuntCal(
    self: Node,
    channel_mask: root.ChannelMask,
    command_info: mscl.mscl_shunt_cal_cmd_info,
) Error!mscl.mscl_auto_shunt_cal_result {
    var result = std.mem.zeroes(mscl.mscl_auto_shunt_cal_result);
    const status = mscl.mscl_node_auto_shunt_cal(
        self.handle,
        @bitCast(channel_mask),
        &command_info,
        &result,
    );
    return switch (status) {
        mscl.MSCL_OK => result,
        // Autocal shunt is not supported by the Node or ChannelMask.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to communicate with the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Tests if the Node will still be able to communicate after changing the
/// Node's communication protocol. This is recommended to be used before
/// changing communication protocol as the range can change between protocol
/// modes. Note: Both the Node and BaseStation will return to the current
/// protocol after this test.
pub fn testCommunicationProtocol(
    self: Node,
    protocol: root.CommProtocol,
) Error!bool {
    var success: bool = false;
    const status = mscl.mscl_node_test_communication_protocol(
        self.handle,
        @backingInt(protocol),
        &success,
    );
    return switch (status) {
        mscl.MSCL_OK => success,
        // The given communication protocol, or the test communication protocol
        // function, is not supported by the Node or BaseStation.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to communicate with the Wireless Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the number of datalog sessions that are currently stored on the Node.
pub fn getNumDatalogSessions(self: Node) Error!u16 {
    var count: u16 = 0;
    const status = mscl.mscl_node_get_num_datalog_sessions(self.handle, &count);
    return switch (status) {
        mscl.MSCL_OK => count,
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the internal datalogging memory percentage that is currently stored on
/// the Node.
pub fn getPercentFull(self: Node) Error!f32 {
    var percent: f32 = 0;
    const status = mscl.mscl_node_get_percent_full(self.handle, &percent);
    return switch (status) {
        mscl.MSCL_OK => percent,
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the ADC WirelessTypes::Voltage Reference of the Node.
pub fn getAdcVoltageRef(self: Node) Error!root.Voltage {
    var voltage: mscl.mscl_voltage = 0;
    const status = mscl.mscl_node_get_adc_voltage_ref(self.handle, &voltage);
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(voltage),
        // ADC Voltage is not supported.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the Gain Amplifier WirelessTypes::Voltage Reference of the Node.
pub fn getGainAmplifierVoltageRef(self: Node) Error!root.Voltage {
    var voltage: mscl.mscl_voltage = 0;
    const status = mscl.mscl_node_get_gain_amplifier_voltage_ref(
        self.handle,
        &voltage,
    );
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(voltage),
        // ADC Voltage is not supported.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the Input Range of the specified ChannelMask currently set on the
/// Node.
fn getInputRange(
    self: Node,
    channel_mask: root.ChannelMask,
) Error!root.InputRange {
    var range: mscl.mscl_input_range = 0;
    const status = mscl.mscl_node_get_input_range(
        self.handle,
        @bitCast(channel_mask),
        &range,
    );
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(range),
        // Input range is not supported for the provided ChannelMask.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the hardware offset of the specified ChannelMask currently set on the
/// Node.
fn getHardwareOffset(self: Node, channel_mask: root.ChannelMask) Error!u16 {
    var offset: u16 = 0;
    const status = mscl.mscl_node_get_hardware_offset(
        self.handle,
        @bitCast(channel_mask),
        &offset,
    );
    return switch (status) {
        mscl.MSCL_OK => offset,
        // Hardware offset is not supported for the provided ChannelMask.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the Anti-Aliasing Filter of the specified ChannelMask currently set on
/// the Node.
fn getAntiAliasingFilter(
    self: Node,
    channel_mask: root.ChannelMask,
) Error!root.Filter {
    var filter: mscl.mscl_filter = 0;
    const status = mscl.mscl_node_get_anti_aliasing_filter(
        self.handle,
        @bitCast(channel_mask),
        &filter,
    );
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(filter),
        // Anti-Aliasing Filter is not supported for the provided ChannelMask.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the Low-Pass Filter of the specified ChannelMask currently set on the
/// Node.
fn getLowPassFilter(
    self: Node,
    channel_mask: root.ChannelMask,
) Error!root.Filter {
    var filter: mscl.mscl_filter = 0;
    const status = mscl.mscl_node_get_low_pass_filter(
        self.handle,
        @bitCast(channel_mask),
        &filter,
    );
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(filter),
        // Low-Pass Filter is not supported for the provided ChannelMask.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the High-Pass Filter of the specified ChannelMask currently set on the
/// Node.
fn getHighPassFilter(
    self: Node,
    channel_mask: root.ChannelMask,
) Error!root.HighPassFilter {
    var filter: mscl.mscl_high_pass_filter = 0;
    const status = mscl.mscl_node_get_high_pass_filter(
        self.handle,
        @bitCast(channel_mask),
        &filter,
    );
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(filter),
        // High-Pass Filter is not supported for the provided ChannelMask.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the Debounce Filter of the specified ChannelMask currently set on the
/// Node.
fn getDebounceFilter(self: Node, channel_mask: root.ChannelMask) Error!u16 {
    var milliseconds: u16 = 0;
    const status = mscl.mscl_node_get_debounce_filter(
        self.handle,
        @bitCast(channel_mask),
        &milliseconds,
    );
    return switch (status) {
        mscl.MSCL_OK => milliseconds,
        // Debounce Filter is not supported for the provided ChannelMask.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets whether the pull-up resistor is enabled on the Node.
fn getPullUpResistor(
    self: Node,
    channel_mask: root.ChannelMask,
) Error!bool {
    var enabled: bool = false;
    const status = mscl.mscl_node_get_pull_up_resistor(
        self.handle,
        @bitCast(channel_mask),
        &enabled,
    );
    return switch (status) {
        mscl.MSCL_OK => enabled,
        // Attempted to read an unsupported option.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the gauge factor of the specified ChannelMask currently set on the
/// Node.
fn getGaugeFactor(self: Node, channel_mask: root.ChannelMask) Error!f32 {
    var factor: f32 = 0;
    const status = mscl.mscl_node_get_gauge_factor(
        self.handle,
        @bitCast(channel_mask),
        &factor,
    );
    return switch (status) {
        mscl.MSCL_OK => factor,
        // Gauge Factor is not supported for the provided ChannelMask.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the linear equation of the specified ChannelMask currently set on the
/// Node.
fn getLinearEquation(
    self: Node,
    channel_mask: root.ChannelMask,
) Error!mscl.mscl_linear_equation {
    var equation = std.mem.zeroes(mscl.mscl_linear_equation);
    const status = mscl.mscl_node_get_linear_equation(
        self.handle,
        @bitCast(channel_mask),
        &equation,
    );
    return switch (status) {
        mscl.MSCL_OK => equation,
        // Linear Equation is not supported for the provided ChannelMask.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to communicate with the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the unit of the specified ChannelMask currently set on the Node. Note:
/// This unit is just used for reference (such as when downloading logged data)
/// and does not affect the actual data value.
fn getUnit(
    self: Node,
    channel_mask: root.ChannelMask,
) Error!root.CalCoefUnit {
    var unit: mscl.mscl_cal_coef_unit = 0;
    const status = mscl.mscl_node_get_unit(
        self.handle,
        @bitCast(channel_mask),
        &unit,
    );
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(unit),
        // Unit is not supported for the provided ChannelMask.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to communicate with the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the filter settling time of the specified ChannelMask currently set on
/// the Node.
fn getFilterSettlingTime(
    self: Node,
    channel_mask: root.ChannelMask,
) Error!root.SettlingTime {
    var settling_time: mscl.mscl_settling_time = 0;
    const status = mscl.mscl_node_get_filter_settling_time(
        self.handle,
        @bitCast(channel_mask),
        &settling_time,
    );
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(settling_time),
        // Filter Settling Time is not supported for the provided ChannelMask.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the WirelessTypes::ThermocoupleType of the specified ChannelMask
/// currently set on the Node.
fn getThermocoupleType(
    self: Node,
    channel_mask: root.ChannelMask,
) Error!root.ThermocoupleType {
    var thermocouple_type: mscl.mscl_thermocouple_type = 0;
    const status = mscl.mscl_node_get_thermocouple_type(
        self.handle,
        @bitCast(channel_mask),
        &thermocouple_type,
    );
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(thermocouple_type),
        // Thermocouple Type is not supported for the provided ChannelMask.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the TempSensorOptions of the specified ChannelMask currently set on
/// the Node.
fn getTempSensorOptions(
    self: Node,
    channel_mask: root.ChannelMask,
) Error!mscl.mscl_temp_sensor_options {
    var options = std.mem.zeroes(mscl.mscl_temp_sensor_options);
    const status = mscl.mscl_node_get_temp_sensor_options(
        self.handle,
        @bitCast(channel_mask),
        &options,
    );
    return switch (status) {
        mscl.MSCL_OK => options,
        // TempSensorOptions are not supported for the provided ChannelMask.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the ChannelMask for an individual WirelessTypes::DerivedCategory that
/// is currently set on the Node. This represents which of the actual Node's
/// channels are set to be mapped to derived channels. For example, if the mask
/// for RMS has ch1 and ch3 active, ch1RMS and ch3RMS channels will be output.
fn getDerivedChannelMask(
    self: Node,
    category: root.DerivedCategory,
) Error!root.ChannelMask {
    var mask: u16 = 0;
    const status = mscl.mscl_node_get_derived_channel_mask(
        self.handle,
        @backingInt(category),
        &mask,
    );
    return switch (status) {
        mscl.MSCL_OK => @bitCast(mask),
        // Derived Channels are not supported by this Node.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the WirelessTypes::DefaultMode that is currently set on the Node.
fn getDefaultMode(self: Node) Error!root.DefaultMode {
    var mode: mscl.mscl_default_mode = 0;
    const status = mscl.mscl_node_get_default_mode(self.handle, &mode);
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(mode),
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the user inactivity timeout that is currently set on the Node. This
/// controls how many seconds before the Node goes to sleep when idle.
fn getInactivityTimeout(self: Node) Error!u16 {
    var seconds: u16 = 0;
    const status = mscl.mscl_node_get_inactivity_timeout(self.handle, &seconds);
    return switch (status) {
        mscl.MSCL_OK => seconds,
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the check radio interval that is currently set on the Node. This
/// controls how often the Node wakes up from sleep to check for commands.
fn getCheckRadioInterval(self: Node) Error!u8 {
    var seconds: u8 = 0;
    const status = mscl.mscl_node_get_check_radio_interval(
        self.handle,
        &seconds,
    );
    return switch (status) {
        mscl.MSCL_OK => seconds,
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the WirelessTypes::TransmitPower that is currently set on the Node.
fn getTransmitPower(self: Node) Error!root.TransmitPower {
    var power: mscl.mscl_transmit_power = 0;
    const status = mscl.mscl_node_get_transmit_power(self.handle, &power);
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(power),
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the WirelessTypes::SamplingMode that is currently set on the Node.
fn getSamplingMode(self: Node) Error!root.SamplingMode {
    var mode: mscl.mscl_sampling_mode = 0;
    const status = mscl.mscl_node_get_sampling_mode(self.handle, &mode);
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(mode),
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the WirelessTypes::WirelessSampleRate currently set on the Node.
fn getSampleRate(self: Node) Error!root.SampleRate {
    var rate: mscl.mscl_sample_rate = 0;
    const status = mscl.mscl_node_get_sample_rate(self.handle, &rate);
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(rate),
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the number of sweeps currently set on the Node, which affects the
/// duration of sampling if unlimited duration is disabled, or the duration of
/// each burst if the sampling mode is Sync Sampling Burst.
fn getNumSweeps(self: Node) Error!u32 {
    var sweeps: u32 = 0;
    const status = mscl.mscl_node_get_num_sweeps(self.handle, &sweeps);
    return switch (status) {
        mscl.MSCL_OK => sweeps,
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets whether unlimited sampling duration is enabled on the Node.
fn getUnlimitedDuration(self: Node) Error!bool {
    var enabled: bool = false;
    const status = mscl.mscl_node_get_unlimited_duration(self.handle, &enabled);
    return switch (status) {
        mscl.MSCL_OK => enabled,
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the WirelessTypes::DataFormat that is currently set on the Node.
fn getDataFormat(self: Node) Error!root.DataFormat {
    var format: mscl.mscl_data_format = 0;
    const status = mscl.mscl_node_get_data_format(self.handle, &format);
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(format),
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the WirelessTypes::DataCollectionMethod that is currently set on the
/// Node, representing how the data will be collected. Note: this has no effect
/// if the sampling mode is Armed Datalogging, as this mode only operates in
/// "log only".
fn getDataCollectionMethod(self: Node) Error!root.DataCollectionMethod {
    var method: mscl.mscl_data_collection_method = 0;
    const status = mscl.mscl_node_get_data_collection_method(
        self.handle,
        &method,
    );
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(method),
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the amount of time between each burst currently set on the Node. This
/// is only used if the sampling mode is Synchronized Sampling Burst.
fn getTimeBetweenBursts(self: Node) Error!u64 {
    var time_ns: u64 = 0;
    const status = mscl.mscl_node_get_time_between_bursts(
        self.handle,
        &time_ns,
    );
    return switch (status) {
        mscl.MSCL_OK => time_ns,
        // Burst Sampling mode is not supported by the Node.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the lost beacon timeout, in minutes, currently set on the Node. If the
/// Node is Sync Sampling and loses the beacon for a length of time greater than
/// this value, then the node drops into a sleep mode. The Node will re-enter
/// sync sampling within 2 minutes of the beacon reappearing. Note: A value of 0
/// means the lost beacon timeout is disabled.
fn getLostBeaconTimeout(self: Node) Error!u16 {
    var minutes: u16 = 0;
    const status = mscl.mscl_node_get_lost_beacon_timeout(
        self.handle,
        &minutes,
    );
    return switch (status) {
        mscl.MSCL_OK => minutes,
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the channel frequency class filter option set on the Node.
fn getCfcFilterConfiguration(self: Node) Error!root.ChannelFrequencyClass {
    var cfc: mscl.mscl_channel_frequency_class = 0;
    const status = mscl.mscl_node_get_cfc_filter_configuration(
        self.handle,
        &cfc,
    );
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(cfc),
        // High-Pass Filter is not supported for the provided ChannelMask.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the gauge resistance currently set on the Node.
fn getGaugeResistance(self: Node) Error!u16 {
    var resistance: u16 = 0;
    const status = mscl.mscl_node_get_gauge_resistance(
        self.handle,
        &resistance,
    );
    return switch (status) {
        mscl.MSCL_OK => resistance,
        // Gauge Resistance is not supported.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the Excitation WirelessTypes::Voltage currently set on the Node.
fn getExcitationVoltage(self: Node) Error!root.Voltage {
    var voltage: mscl.mscl_voltage = 0;
    const status = mscl.mscl_node_get_excitation_voltage(self.handle, &voltage);
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(voltage),
        // Excitation Voltage is not supported.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the Number of Active Gauges currently set on the Node.
fn getNumActiveGauges(self: Node) Error!u16 {
    var count: u16 = 0;
    const status = mscl.mscl_node_get_num_active_gauges(self.handle, &count);
    return switch (status) {
        mscl.MSCL_OK => count,
        // Number of Active Gauges is not supported.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the threshold at which the low battery diagnostic flag is sent.
fn getLowBatteryThreshold(self: Node) Error!f32 {
    var voltage: f32 = 0;
    const status = mscl.mscl_node_get_low_battery_threshold(
        self.handle,
        &voltage,
    );
    return switch (status) {
        mscl.MSCL_OK => voltage,
        // Low Battery Threshold is not supported.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the FatigueOptions currently set on the Node.
fn getFatigueOptions(self: Node) Error!mscl.mscl_fatigue_options {
    var options = std.mem.zeroes(mscl.mscl_fatigue_options);
    const status = mscl.mscl_node_get_fatigue_options(self.handle, &options);
    return switch (status) {
        mscl.MSCL_OK => options,
        // FatigueOptions configuration is not supported by this Node.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the HistogramOptions currently set on the Node.
fn getHistogramOptions(self: Node) Error!mscl.mscl_histogram_options {
    var options = std.mem.zeroes(mscl.mscl_histogram_options);
    const status = mscl.mscl_node_get_histogram_options(self.handle, &options);
    return switch (status) {
        mscl.MSCL_OK => options,
        // HistogramOptions configuration is not supported by this Node.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the ActivitySense options currently set on the Node.
fn getActivitySense(self: Node) Error!mscl.mscl_activity_sense {
    var activity_sense = std.mem.zeroes(mscl.mscl_activity_sense);
    const status = mscl.mscl_node_get_activity_sense(
        self.handle,
        &activity_sense,
    );
    return switch (status) {
        mscl.MSCL_OK => activity_sense,
        // ActivitySense configuration is not supported by this Node.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the EventTriggerOptions currently set on the Node.
fn getEventTriggerOptions(
    self: Node,
) Error!mscl.mscl_event_trigger_options {
    var options = std.mem.zeroes(mscl.mscl_event_trigger_options);
    const status = mscl.mscl_node_get_event_trigger_options(
        self.handle,
        &options,
    );
    return switch (status) {
        mscl.MSCL_OK => options,
        // Event Triggering is not supported by this Node.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the interval (in seconds) at which the diagnostic info is configured
/// to be sent.
fn getDiagnosticInterval(self: Node) Error!u16 {
    var seconds: u16 = 0;
    const status = mscl.mscl_node_get_diagnostic_interval(
        self.handle,
        &seconds,
    );
    return switch (status) {
        mscl.MSCL_OK => seconds,
        // Diagnostic Info is not supported by this Node.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the WirelessTypes::StorageLimitMode that the Node is configured for.
/// This determines what happens when the datalogging storage limit is reached
/// on the Node.
fn getStorageLimitMode(self: Node) Error!root.StorageLimitMode {
    var mode: mscl.mscl_storage_limit_mode = 0;
    const status = mscl.mscl_node_get_storage_limit_mode(self.handle, &mode);
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(mode),
        // Storage Limit Mode (or datalogging) is not supported by this Node.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the sensor delay (in microseconds) that is currently set on the Node.
/// Note: A value of WirelessNodeConfig::SENSOR_DELAY_ALWAYS_ON indicates that
/// the sensor is always on.
fn getSensorDelay(self: Node) Error!u32 {
    var delay: u32 = 0;
    const status = mscl.mscl_node_get_sensor_delay(self.handle, &delay);
    return switch (status) {
        mscl.MSCL_OK => delay,
        // Sensor Delay is not supported by this Node.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the WirelessTypes::DataMode that is currently set on the Node.
fn getDataMode(self: Node) Error!root.DataMode {
    var mode: mscl.mscl_data_mode = 0;
    const status = mscl.mscl_node_get_data_mode(self.handle, &mode);
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(mode),
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the WirelessTypes::WirelessSampleRate for all Derived Data Channels
/// that is currently set on the Node.
fn getDerivedDataRate(self: Node) Error!root.SampleRate {
    var rate: mscl.mscl_sample_rate = 0;
    const status = mscl.mscl_node_get_derived_data_rate(self.handle, &rate);
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(rate),
        // Derived Channels are not supported by this Node.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Reads the WirelessTypes::DerivedVelocityUnit which indicates which unit the
/// Velocity derived channel is set to.
fn getDerivedVelocityUnit(self: Node) Error!root.DerivedVelocityUnit {
    var unit: mscl.mscl_derived_velocity_unit = 0;
    const status = mscl.mscl_node_get_derived_velocity_unit(self.handle, &unit);
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(unit),
        // The Derived Velocity channel is not supported by this Node.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the WirelessTypes::CommProtocol that the Node is currently set to use.
fn getCommunicationProtocol(self: Node) Error!root.CommProtocol {
    var protocol: mscl.mscl_comm_protocol = 0;
    const status = mscl.mscl_node_get_communication_protocol(
        self.handle,
        &protocol,
    );
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(protocol),
        // Failed to read the value from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the WirelessTypes::SensorOutputMode currently set on the Node.
fn getSensorOutputMode(self: Node) Error!root.SensorOutputMode {
    var mode: mscl.mscl_sensor_output_mode = 0;
    const status = mscl.mscl_node_get_sensor_output_mode(self.handle, &mode);
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(mode),
        // Attempted to read an unsupported option.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the node address of the Node.
fn getNodeAddress(self: Node) u32 {
    var address: u32 = 0;
    _ = mscl.mscl_node_get_node_address(self.handle, &address);
    return address;
}

/// Gets the name of the Node. This is the universal sensor name that should be
/// used for uploading to SensorCloud. This is the same as calling
/// WirelessNode::deviceName.
fn getName(
    self: Node,
    gpa: std.mem.Allocator,
) std.mem.Allocator.Error![]const u8 {
    // MSCL's name is the node address, at most 10 characters, so it always
    // fits.
    var buffer: [32]u8 = undefined;
    _ = mscl.mscl_node_get_name(self.handle, &buffer, buffer.len);
    return try gpa.dupe(u8, std.mem.sliceTo(&buffer, 0));
}

/// Gets the serial number of the Node.
fn getSerial(
    self: Node,
    gpa: std.mem.Allocator,
) (Error || std.mem.Allocator.Error)![]const u8 {
    // MSCL's serial is "model-class-number", at most 5 + 1 + 4 + 1 + 10
    // characters, so it always fits.
    var buffer: [32]u8 = undefined;
    const status =
        mscl.mscl_node_get_serial(self.handle, &buffer, buffer.len);
    return switch (status) {
        mscl.MSCL_OK => try gpa.dupe(u8, std.mem.sliceTo(&buffer, 0)),
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read the value from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the model of the Node.
fn getModel(self: Node) Error!Model {
    var model: mscl.mscl_node_model = 0;
    const status = mscl.mscl_node_get_model(self.handle, &model);
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(model),
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read the value from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the microcontroller of the Node.
fn getMicrocontroller(self: Node) Error!root.Microcontroller {
    var microcontroller: mscl.mscl_microcontroller = 0;
    const status = mscl.mscl_node_get_microcontroller(
        self.handle,
        &microcontroller,
    );
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(microcontroller),
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read the value from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the region code currently set on the Node.
fn getRegionCode(self: Node) Error!root.RegionCode {
    var region_code: mscl.mscl_region_code = 0;
    const status = mscl.mscl_node_get_region_code(self.handle, &region_code);
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(region_code),
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the firmware version of the Node.
fn getFirmwareVersion(self: Node) Error!std.SemanticVersion {
    var version = std.mem.zeroes(mscl.mscl_version);
    const status = mscl.mscl_node_get_firmware_version(self.handle, &version);
    return switch (status) {
        mscl.MSCL_OK => .{
            .major = version.major,
            .minor = version.minor,
            .patch = version.patch,
        },
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read the value from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the frequency that the Node is on.
fn getFrequency(self: Node) Error!root.Frequency {
    var frequency: mscl.mscl_frequency = 0;
    const status = mscl.mscl_node_get_frequency(self.handle, &frequency);
    return switch (status) {
        mscl.MSCL_OK => @fromBackingInt(frequency),
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read the value from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}

/// Gets the number of retry attempts for reading and writing config options
/// with the Node. By default, the number of retries is 0. Note:   The timeout
/// that is set per command will be per read and write attempt, meaning this
/// retry number is multiplied by the timeout for your overall timeout.
fn getRetries(self: Node) u8 {
    var retries: u8 = 0;
    _ = mscl.mscl_node_get_retries(self.handle, &retries);
    return retries;
}

/// Gets the ChannelMask currently set on the Node, representing which channels
/// are enabled and disabled.
fn getActiveChannels(self: Node) Error!root.ChannelMask {
    var mask: u16 = 0;
    const status = mscl.mscl_node_get_active_channels(self.handle, &mask);
    return switch (status) {
        mscl.MSCL_OK => @bitCast(mask),
        // Attempted to read an unsupported option. The device firmware is not
        // compatible with this version of MSCL.
        mscl.MSCL_ERROR_NOT_SUPPORTED => Error.NotSupported,
        // Failed to read from the Node.
        mscl.MSCL_ERROR_NODE_COMMUNICATION => Error.NodeCommunication,
        // A connection error has occurred with the parent BaseStation.
        mscl.MSCL_ERROR_CONNECTION => Error.Connection,
        else => mscl: {
            std.log.err("{s}", .{mscl.mscl_last_error()});
            break :mscl Error.MsclFailure;
        },
    };
}
