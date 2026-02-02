//! FLUX Conformance Test Framework
//!
//! Core infrastructure for running conformance tests including:
//! - Test suite and test case structures
//! - Layout assertion helpers

const std = @import("std");

pub const TestError = error{
    NotImplemented,
    AssertionFailed,
    GoldenMismatch,
    InvalidState,
    RenderFailed,
    LayoutFailed,
    Timeout,
    OutOfMemory,
    FileNotFound,
};

pub const TestCase = struct {
    name: []const u8,
    run: *const fn () TestError!void,
    skip: bool = false,
    expected_fail: bool = false,
};

pub const TestSuite = struct {
    name: []const u8,
    tests: []const TestCase,
    setup: ?*const fn () TestError!void = null,
    teardown: ?*const fn () void = null,
};

pub const TestResult = struct {
    name: []const u8,
    status: Status,
    duration_ns: u64 = 0,
    error_message: ?[]const u8 = null,

    pub const Status = enum {
        passed,
        failed,
        skipped,
        expected_fail,
    };
};

pub const SuiteResult = struct {
    name: []const u8,
    results: []TestResult,
    total: usize,
    passed: usize,
    failed: usize,
    skipped: usize,
};

// Layout Assertion Types

pub const Rect = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,

    const default_tolerance: f32 = 0.001;

    pub fn eql(self: Rect, other: Rect) bool {
        return self.eqlWithTolerance(other, default_tolerance);
    }

    pub fn eqlWithTolerance(self: Rect, other: Rect, tolerance: f32) bool {
        return @abs(self.x - other.x) <= tolerance and
            @abs(self.y - other.y) <= tolerance and
            @abs(self.width - other.width) <= tolerance and
            @abs(self.height - other.height) <= tolerance;
    }
};

pub const Size = struct {
    width: f32,
    height: f32,

    const default_tolerance: f32 = 0.001;

    pub fn eql(self: Size, other: Size) bool {
        return self.eqlWithTolerance(other, default_tolerance);
    }

    pub fn eqlWithTolerance(self: Size, other: Size, tolerance: f32) bool {
        return @abs(self.width - other.width) <= tolerance and
            @abs(self.height - other.height) <= tolerance;
    }
};

pub const Point = struct {
    x: f32,
    y: f32,

    const default_tolerance: f32 = 0.001;

    pub fn eql(self: Point, other: Point) bool {
        return self.eqlWithTolerance(other, default_tolerance);
    }

    pub fn eqlWithTolerance(self: Point, other: Point, tolerance: f32) bool {
        return @abs(self.x - other.x) <= tolerance and
            @abs(self.y - other.y) <= tolerance;
    }
};

// Layout Assertions

pub fn assertRect(actual: Rect, expected: Rect) TestError!void {
    return assertRectWithTolerance(actual, expected, Rect.default_tolerance);
}

pub fn assertRectWithTolerance(actual: Rect, expected: Rect, tolerance: f32) TestError!void {
    if (!actual.eqlWithTolerance(expected, tolerance)) {
        std.log.err("Rect assertion failed:", .{});
        std.log.err("  Expected: ({d:.2}, {d:.2}, {d:.2}, {d:.2})", .{ expected.x, expected.y, expected.width, expected.height });
        std.log.err("  Actual:   ({d:.2}, {d:.2}, {d:.2}, {d:.2})", .{ actual.x, actual.y, actual.width, actual.height });
        return TestError.AssertionFailed;
    }
}

pub fn assertSize(actual: Size, expected: Size) TestError!void {
    return assertSizeWithTolerance(actual, expected, Size.default_tolerance);
}

pub fn assertSizeWithTolerance(actual: Size, expected: Size, tolerance: f32) TestError!void {
    if (!actual.eqlWithTolerance(expected, tolerance)) {
        std.log.err("Size assertion failed:", .{});
        std.log.err("  Expected: ({d:.2}, {d:.2})", .{ expected.width, expected.height });
        std.log.err("  Actual:   ({d:.2}, {d:.2})", .{ actual.width, actual.height });
        return TestError.AssertionFailed;
    }
}

pub fn assertPoint(actual: Point, expected: Point) TestError!void {
    return assertPointWithTolerance(actual, expected, Point.default_tolerance);
}

pub fn assertPointWithTolerance(actual: Point, expected: Point, tolerance: f32) TestError!void {
    if (!actual.eqlWithTolerance(expected, tolerance)) {
        std.log.err("Point assertion failed:", .{});
        std.log.err("  Expected: ({d:.2}, {d:.2})", .{ expected.x, expected.y });
        std.log.err("  Actual:   ({d:.2}, {d:.2})", .{ actual.x, actual.y });
        return TestError.AssertionFailed;
    }
}

pub fn assertFloat(actual: f32, expected: f32, tolerance: f32) TestError!void {
    if (@abs(actual - expected) > tolerance) {
        std.log.err("Float assertion failed:", .{});
        std.log.err("  Expected: {d:.4}", .{expected});
        std.log.err("  Actual:   {d:.4}", .{actual});
        return TestError.AssertionFailed;
    }
}
