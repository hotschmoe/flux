//! FLUX Conformance Test Suite Build Configuration
//!
//! Provides build steps for:
//! - test-cts: Run the conformance test suite
//! - update-golden: Update golden images

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Get the flux dependency from the parent project
    // Note: This assumes the test suite is built as part of the main project
    const flux_dep = b.dependency("flux", .{
        .target = target,
        .optimize = optimize,
    });

    // Build the conformance test runner executable
    const cts_exe = b.addExecutable(.{
        .name = "flux-cts",
        .root_source_file = b.path("src/runner.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Add flux module
    if (flux_dep.module("flux")) |flux_module| {
        cts_exe.root_module.addImport("flux", flux_module);
    }

    b.installArtifact(cts_exe);

    // Create the test-cts step
    const run_cts = b.addRunArtifact(cts_exe);
    run_cts.step.dependOn(b.getInstallStep());

    // Pass through command line arguments
    if (b.args) |args| {
        run_cts.addArgs(args);
    }

    const cts_step = b.step("test-cts", "Run the FLUX conformance test suite");
    cts_step.dependOn(&run_cts.step);

    // Create the update-golden step
    const update_golden = b.addRunArtifact(cts_exe);
    update_golden.addArg("--update-golden");
    update_golden.step.dependOn(b.getInstallStep());

    const update_step = b.step("update-golden", "Update golden images for conformance tests");
    update_step.dependOn(&update_golden.step);

    // Create unit test step for the framework itself
    const framework_tests = b.addTest(.{
        .root_source_file = b.path("src/framework.zig"),
        .target = target,
        .optimize = optimize,
    });

    const golden_tests = b.addTest(.{
        .root_source_file = b.path("src/golden.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_framework_tests = b.addRunArtifact(framework_tests);
    const run_golden_tests = b.addRunArtifact(golden_tests);

    const unit_test_step = b.step("test-unit", "Run unit tests for the test framework");
    unit_test_step.dependOn(&run_framework_tests.step);
    unit_test_step.dependOn(&run_golden_tests.step);
}
