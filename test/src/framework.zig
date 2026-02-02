//! FLUX Conformance Test Framework
//!
//! Provides core infrastructure for running conformance tests including:
//! - Test suite and test case structures
//! - Layout assertion helpers
//! - Event simulation helpers
//! - Golden image comparison utilities

const std = @import("std");

/// Errors that can occur during test execution
pub const TestError = error{
    NotImplemented,
    AssertionFailed,
    GoldenMismatch,
    InvalidState,
    RenderFailed,
    LayoutFailed,
    EventSimulationFailed,
    Timeout,
    OutOfMemory,
    FileNotFound,
};

/// Represents a single test case
pub const TestCase = struct {
    name: []const u8,
    run: *const fn () TestError!void,
    /// Optional: Skip this test
    skip: bool = false,
    /// Optional: Expected to fail (for known bugs)
    expected_fail: bool = false,
};

/// Represents a collection of related tests
pub const TestSuite = struct {
    name: []const u8,
    tests: []const TestCase,
    /// Optional: Setup function called before each test
    setup: ?*const fn () TestError!void = null,
    /// Optional: Teardown function called after each test
    teardown: ?*const fn () void = null,
};

/// Result of running a single test
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

/// Result of running an entire suite
pub const SuiteResult = struct {
    name: []const u8,
    results: []TestResult,
    total: usize,
    passed: usize,
    failed: usize,
    skipped: usize,
};

/// Represents a rectangle for layout assertions
pub const Rect = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,

    pub fn eql(self: Rect, other: Rect) bool {
        return self.eqlWithTolerance(other, 0.001);
    }

    pub fn eqlWithTolerance(self: Rect, other: Rect, tolerance: f32) bool {
        return @abs(self.x - other.x) <= tolerance and
            @abs(self.y - other.y) <= tolerance and
            @abs(self.width - other.width) <= tolerance and
            @abs(self.height - other.height) <= tolerance;
    }
};

/// Represents a size for layout assertions
pub const Size = struct {
    width: f32,
    height: f32,

    pub fn eql(self: Size, other: Size) bool {
        return self.eqlWithTolerance(other, 0.001);
    }

    pub fn eqlWithTolerance(self: Size, other: Size, tolerance: f32) bool {
        return @abs(self.width - other.width) <= tolerance and
            @abs(self.height - other.height) <= tolerance;
    }
};

/// Represents a point for position assertions
pub const Point = struct {
    x: f32,
    y: f32,

    pub fn eql(self: Point, other: Point) bool {
        return self.eqlWithTolerance(other, 0.001);
    }

    pub fn eqlWithTolerance(self: Point, other: Point, tolerance: f32) bool {
        return @abs(self.x - other.x) <= tolerance and
            @abs(self.y - other.y) <= tolerance;
    }
};

// ============================================================================
// Layout Assertion Helpers
// ============================================================================

/// Assert that a computed rect matches the expected rect
pub fn assertRect(actual: Rect, expected: Rect) TestError!void {
    return assertRectWithTolerance(actual, expected, 0.001);
}

/// Assert that a computed rect matches the expected rect within tolerance
pub fn assertRectWithTolerance(actual: Rect, expected: Rect, tolerance: f32) TestError!void {
    if (!actual.eqlWithTolerance(expected, tolerance)) {
        std.log.err("Rect assertion failed:", .{});
        std.log.err("  Expected: ({d:.2}, {d:.2}, {d:.2}, {d:.2})", .{ expected.x, expected.y, expected.width, expected.height });
        std.log.err("  Actual:   ({d:.2}, {d:.2}, {d:.2}, {d:.2})", .{ actual.x, actual.y, actual.width, actual.height });
        return TestError.AssertionFailed;
    }
}

/// Assert that a computed size matches the expected size
pub fn assertSize(actual: Size, expected: Size) TestError!void {
    return assertSizeWithTolerance(actual, expected, 0.001);
}

/// Assert that a computed size matches the expected size within tolerance
pub fn assertSizeWithTolerance(actual: Size, expected: Size, tolerance: f32) TestError!void {
    if (!actual.eqlWithTolerance(expected, tolerance)) {
        std.log.err("Size assertion failed:", .{});
        std.log.err("  Expected: ({d:.2}, {d:.2})", .{ expected.width, expected.height });
        std.log.err("  Actual:   ({d:.2}, {d:.2})", .{ actual.width, actual.height });
        return TestError.AssertionFailed;
    }
}

/// Assert that a computed point matches the expected point
pub fn assertPoint(actual: Point, expected: Point) TestError!void {
    return assertPointWithTolerance(actual, expected, 0.001);
}

/// Assert that a computed point matches the expected point within tolerance
pub fn assertPointWithTolerance(actual: Point, expected: Point, tolerance: f32) TestError!void {
    if (!actual.eqlWithTolerance(expected, tolerance)) {
        std.log.err("Point assertion failed:", .{});
        std.log.err("  Expected: ({d:.2}, {d:.2})", .{ expected.x, expected.y });
        std.log.err("  Actual:   ({d:.2}, {d:.2})", .{ actual.x, actual.y });
        return TestError.AssertionFailed;
    }
}

/// Assert that two float values are equal within tolerance
pub fn assertFloat(actual: f32, expected: f32, tolerance: f32) TestError!void {
    if (@abs(actual - expected) > tolerance) {
        std.log.err("Float assertion failed:", .{});
        std.log.err("  Expected: {d:.4}", .{expected});
        std.log.err("  Actual:   {d:.4}", .{actual});
        return TestError.AssertionFailed;
    }
}

// ============================================================================
// Event Simulation Helpers
// ============================================================================

/// Simulated mouse button
pub const MouseButton = enum {
    left,
    right,
    middle,
};

/// Simulated key code
pub const KeyCode = enum {
    a,
    b,
    c,
    // ... add more as needed
    enter,
    escape,
    tab,
    backspace,
    delete,
    left,
    right,
    up,
    down,
    home,
    end,
    page_up,
    page_down,
};

/// Modifier keys
pub const Modifiers = struct {
    shift: bool = false,
    ctrl: bool = false,
    alt: bool = false,
    super: bool = false,
};

/// Simulates a mouse click event
pub fn simulateClick(x: f32, y: f32, button: MouseButton) TestError!void {
    _ = x;
    _ = y;
    _ = button;
    // TODO: Implement when FLUX event system is ready
    return TestError.NotImplemented;
}

/// Simulates a mouse move event
pub fn simulateMouseMove(x: f32, y: f32) TestError!void {
    _ = x;
    _ = y;
    // TODO: Implement when FLUX event system is ready
    return TestError.NotImplemented;
}

/// Simulates a mouse drag event
pub fn simulateDrag(start_x: f32, start_y: f32, end_x: f32, end_y: f32, button: MouseButton) TestError!void {
    _ = start_x;
    _ = start_y;
    _ = end_x;
    _ = end_y;
    _ = button;
    // TODO: Implement when FLUX event system is ready
    return TestError.NotImplemented;
}

/// Simulates a key press event
pub fn simulateKeyPress(key: KeyCode, modifiers: Modifiers) TestError!void {
    _ = key;
    _ = modifiers;
    // TODO: Implement when FLUX event system is ready
    return TestError.NotImplemented;
}

/// Simulates text input
pub fn simulateTextInput(text: []const u8) TestError!void {
    _ = text;
    // TODO: Implement when FLUX event system is ready
    return TestError.NotImplemented;
}

/// Simulates a scroll event
pub fn simulateScroll(x: f32, y: f32, delta_x: f32, delta_y: f32) TestError!void {
    _ = x;
    _ = y;
    _ = delta_x;
    _ = delta_y;
    // TODO: Implement when FLUX event system is ready
    return TestError.NotImplemented;
}

// ============================================================================
// Test Context
// ============================================================================

/// Context provided to tests for setup and resource management
pub const TestContext = struct {
    allocator: std.mem.Allocator,
    golden_dir: []const u8,
    diff_dir: []const u8,

    pub fn init(allocator: std.mem.Allocator) TestContext {
        return .{
            .allocator = allocator,
            .golden_dir = "golden",
            .diff_dir = "diffs",
        };
    }

    pub fn deinit(self: *TestContext) void {
        _ = self;
        // Cleanup resources
    }
};
