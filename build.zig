const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const use_nettle = b.option(bool, "use_nettle", "") orelse false;
    const enable_localhost_address = b.option(bool, "enable_localhost_address", "") orelse false;
    const disable_consent_freshness = b.option(bool, "disable_consent_freshness", "") orelse false;
    const enable_local_address_translation = b.option(bool, "enable_local_address_translation", "") orelse false;
    const no_server = b.option(bool, "no_server", "") orelse false;

    const upstream = b.dependency("juice", .{});

    var juice_flags = std.ArrayList([]const u8).init(b.allocator);

    // Setup flags
    {
        if (use_nettle) {
            try juice_flags.append("-DUSE_NETTLE=1");

            // TODO (lukas): Would have to find / link the library
            return error.NettleNotSupported;
        } else {
            try juice_flags.append("-DUSE_NETTLE=0");
        }

        if (no_server) {
            try juice_flags.append("-dno_server");
        }

        if (disable_consent_freshness) {
            try juice_flags.append("-DJUICE_DISABLE_CONSENT_FRESHNESS=1");
        }

        if (enable_localhost_address) {
            try juice_flags.append("-DJUICE_ENABLE_LOCALHOST_ADDRESS=1");
        }

        if (enable_local_address_translation) {
            try juice_flags.append("-DJUICE_ENABLE_LOCAL_ADDRESS_TRANSLATION=1");
        }

        try juice_flags.append("-DJUICE_STATIC");
    }

    const juice = b.addLibrary(.{
        .name = "juice",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });

    juice.addCSourceFiles(.{
        .files = juice_sources,
        .flags = juice_flags.items,
        .language = .c,
        .root = upstream.path(""),
    });
    juice.addIncludePath(upstream.path("include"));
    juice.addIncludePath(upstream.path("include/juice"));
    juice.addIncludePath(upstream.path("src"));

    juice.linkLibC();
    juice.linkLibCpp();

    juice.installHeadersDirectory(upstream.path("include"), "", .{});

    b.installArtifact(juice);
}

const juice_sources = &.{
    "src/addr.c",
    "src/agent.c",
    "src/crc32.c",
    "src/const_time.c",
    "src/conn.c",
    "src/conn_poll.c",
    "src/conn_thread.c",
    "src/conn_mux.c",
    "src/base64.c",
    "src/hash.c",
    "src/hmac.c",
    "src/ice.c",
    "src/juice.c",
    "src/log.c",
    "src/random.c",
    "src/server.c",
    "src/stun.c",
    "src/timestamp.c",
    "src/turn.c",
    "src/udp.c",
};
