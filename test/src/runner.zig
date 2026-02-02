//! FLUX Conformance Test Suite Runner
//!
//! Main entry point for running the conformance test suite.
//! Supports:
//! - Running all tests or specific suites
//! - Filtering tests by name pattern
//! - JSON output for CI integration

const std = @import("std");
const framework = @import("framework.zig");

const layout_tests = @import("layout/tests.zig");
const render_tests = @import("render/tests.zig");
const input_tests = @import("input/tests.zig");
const widgets_tests = @import("widgets/tests.zig");
const text_tests = @import("text/tests.zig");

const all_suites = [_]framework.TestSuite{
    layout_tests.suite,
    render_tests.suite,
    input_tests.suite,
    widgets_tests.suite,
    text_tests.suite,
};

const Options = struct {
    filter: ?[]const u8 = null,
    suite: ?[]const u8 = null,
    format: Format = .text,
    update_golden: bool = false,
    verbose: bool = false,
    fail_fast: bool = false,

    const Format = enum { text, json };
};

const RunStats = struct {
    total: usize = 0,
    passed: usize = 0,
    failed: usize = 0,
    skipped: usize = 0,
    duration_ns: u64 = 0,

    fn addResult(self: *RunStats, result: framework.TestResult) void {
        self.total += 1;
        self.duration_ns += result.duration_ns;
        switch (result.status) {
            .passed, .expected_fail => self.passed += 1,
            .failed => self.failed += 1,
            .skipped => self.skipped += 1,
        }
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const options = parseArgs();
    const stats = runAllTests(options);

    printSummary(stats, options);

    if (stats.failed > 0) {
        std.process.exit(1);
    }
}

fn parseArgs() Options {
    var options = Options{};
    var args = std.process.args();
    _ = args.skip();

    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "--filter")) {
            options.filter = args.next();
        } else if (std.mem.eql(u8, arg, "--suite")) {
            options.suite = args.next();
        } else if (std.mem.eql(u8, arg, "--json")) {
            options.format = .json;
        } else if (std.mem.eql(u8, arg, "--update-golden")) {
            options.update_golden = true;
        } else if (std.mem.eql(u8, arg, "--verbose") or std.mem.eql(u8, arg, "-v")) {
            options.verbose = true;
        } else if (std.mem.eql(u8, arg, "--fail-fast")) {
            options.fail_fast = true;
        } else if (std.mem.eql(u8, arg, "--help") or std.mem.eql(u8, arg, "-h")) {
            printUsage();
            std.process.exit(0);
        }
    }

    return options;
}

fn printUsage() void {
    const usage =
        \\FLUX Conformance Test Suite Runner
        \\
        \\Usage: flux-cts [options]
        \\
        \\Options:
        \\  --filter <pattern>   Run only tests matching pattern
        \\  --suite <name>       Run only the specified suite
        \\  --json               Output results in JSON format
        \\  --update-golden      Update golden images instead of comparing
        \\  --verbose, -v        Show verbose output
        \\  --fail-fast          Stop on first failure
        \\  --help, -h           Show this help message
        \\
        \\Test Suites:
        \\  flux.layout          Flexbox layout algorithm tests
        \\  flux.render          Rendering and painting tests
        \\  flux.input           Input handling and event tests
        \\  flux.widgets         Widget behavior tests
        \\  flux.text            Text rendering and editing tests
        \\
    ;
    std.debug.print("{s}\n", .{usage});
}

fn runAllTests(options: Options) RunStats {
    var stats = RunStats{};
    const start_time = std.time.nanoTimestamp();

    for (all_suites) |suite| {
        if (options.suite) |suite_filter| {
            if (!std.mem.eql(u8, suite.name, suite_filter)) continue;
        }

        if (options.format == .text and options.verbose) {
            std.debug.print("\n=== {s} ===\n", .{suite.name});
        }

        const suite_stats = runSuite(suite, options);
        stats.total += suite_stats.total;
        stats.passed += suite_stats.passed;
        stats.failed += suite_stats.failed;
        stats.skipped += suite_stats.skipped;

        if (options.fail_fast and suite_stats.failed > 0) break;
    }

    const end_time = std.time.nanoTimestamp();
    stats.duration_ns = @intCast(@as(i128, end_time) - @as(i128, start_time));

    return stats;
}

fn runSuite(suite: framework.TestSuite, options: Options) RunStats {
    var stats = RunStats{};

    for (suite.tests) |test_case| {
        if (options.filter) |filter| {
            if (std.mem.indexOf(u8, test_case.name, filter) == null) continue;
        }

        const result = runTest(suite, test_case);
        stats.addResult(result);

        if (options.format == .text) {
            printTestResult(result, options.verbose);
        }

        if (options.fail_fast and result.status == .failed) break;
    }

    return stats;
}

fn runTest(suite: framework.TestSuite, test_case: framework.TestCase) framework.TestResult {
    if (test_case.skip) {
        return .{ .name = test_case.name, .status = .skipped };
    }

    const start_time = std.time.nanoTimestamp();

    if (suite.setup) |setup| {
        setup() catch |err| {
            return .{
                .name = test_case.name,
                .status = .failed,
                .error_message = @errorName(err),
            };
        };
    }

    const test_result = test_case.run();

    if (suite.teardown) |teardown| {
        teardown();
    }

    const end_time = std.time.nanoTimestamp();
    const duration: u64 = @intCast(@as(i128, end_time) - @as(i128, start_time));

    if (test_result) |_| {
        return .{
            .name = test_case.name,
            .status = .passed,
            .duration_ns = duration,
        };
    } else |err| {
        const status: framework.TestResult.Status = if (test_case.expected_fail) .expected_fail else .failed;
        return .{
            .name = test_case.name,
            .status = status,
            .duration_ns = duration,
            .error_message = @errorName(err),
        };
    }
}

fn printTestResult(result: framework.TestResult, verbose: bool) void {
    const status_str = switch (result.status) {
        .passed => "\x1b[32mPASS\x1b[0m",
        .failed => "\x1b[31mFAIL\x1b[0m",
        .skipped => "\x1b[33mSKIP\x1b[0m",
        .expected_fail => "\x1b[33mXFAIL\x1b[0m",
    };

    if (verbose or result.status == .failed) {
        const duration_ms = @as(f64, @floatFromInt(result.duration_ns)) / 1_000_000.0;
        std.debug.print("[{s}] {s} ({d:.2}ms)", .{ status_str, result.name, duration_ms });
        if (result.error_message) |msg| {
            std.debug.print(" - {s}", .{msg});
        }
        std.debug.print("\n", .{});
    } else if (result.status == .passed) {
        std.debug.print(".", .{});
    }
}

fn printSummary(stats: RunStats, options: Options) void {
    if (options.format == .json) {
        printJsonSummary(stats);
        return;
    }

    const duration_ms = @as(f64, @floatFromInt(stats.duration_ns)) / 1_000_000.0;

    std.debug.print("\n\n", .{});
    std.debug.print("========================================\n", .{});
    std.debug.print("FLUX Conformance Test Results\n", .{});
    std.debug.print("========================================\n", .{});
    std.debug.print("Total:   {}\n", .{stats.total});
    std.debug.print("Passed:  \x1b[32m{}\x1b[0m\n", .{stats.passed});
    std.debug.print("Failed:  \x1b[31m{}\x1b[0m\n", .{stats.failed});
    std.debug.print("Skipped: \x1b[33m{}\x1b[0m\n", .{stats.skipped});
    std.debug.print("Duration: {d:.2}ms\n", .{duration_ms});
    std.debug.print("========================================\n", .{});

    if (stats.failed == 0) {
        std.debug.print("\x1b[32mAll tests passed!\x1b[0m\n", .{});
    } else {
        std.debug.print("\x1b[31m{} test(s) failed.\x1b[0m\n", .{stats.failed});
    }
}

fn printJsonSummary(stats: RunStats) void {
    const stdout = std.io.getStdOut().writer();
    stdout.print(
        \\{{
        \\  "total": {},
        \\  "passed": {},
        \\  "failed": {},
        \\  "skipped": {},
        \\  "duration_ns": {}
        \\}}
        \\
    , .{
        stats.total,
        stats.passed,
        stats.failed,
        stats.skipped,
        stats.duration_ns,
    }) catch {};
}
