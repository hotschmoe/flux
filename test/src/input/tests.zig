//! FLUX Conformance Test Suite - Input Tests
//!
//! Tests for input handling and event processing covering:
//! mouse events, keyboard events, focus management, hit testing, and event propagation.

const framework = @import("../framework.zig");

pub const suite = framework.TestSuite{
    .name = "flux.input",
    .tests = &.{
        // Mouse events
        .{ .name = "INP-001_mouse_click", .run = notImplemented },
        .{ .name = "INP-002_mouse_double_click", .run = notImplemented },
        .{ .name = "INP-003_mouse_right_click", .run = notImplemented },
        .{ .name = "INP-004_mouse_move", .run = notImplemented },
        .{ .name = "INP-005_mouse_enter_leave", .run = notImplemented },
        .{ .name = "INP-006_mouse_drag", .run = notImplemented },
        .{ .name = "INP-007_mouse_scroll", .run = notImplemented },

        // Keyboard events
        .{ .name = "INP-008_key_press", .run = notImplemented },
        .{ .name = "INP-009_key_release", .run = notImplemented },
        .{ .name = "INP-010_key_repeat", .run = notImplemented },
        .{ .name = "INP-011_key_modifiers", .run = notImplemented },
        .{ .name = "INP-012_text_input", .run = notImplemented },

        // Focus management
        .{ .name = "INP-013_focus_click", .run = notImplemented },
        .{ .name = "INP-014_focus_tab", .run = notImplemented },
        .{ .name = "INP-015_focus_shift_tab", .run = notImplemented },
        .{ .name = "INP-016_focus_trap", .run = notImplemented },
        .{ .name = "INP-017_focus_visible", .run = notImplemented },

        // Hit testing
        .{ .name = "INP-018_hit_test_basic", .run = notImplemented },
        .{ .name = "INP-019_hit_test_nested", .run = notImplemented },
        .{ .name = "INP-020_hit_test_overlap", .run = notImplemented },
        .{ .name = "INP-021_hit_test_transform", .run = notImplemented },
        .{ .name = "INP-022_hit_test_clip", .run = notImplemented },

        // Event propagation
        .{ .name = "INP-023_event_bubble", .run = notImplemented },
        .{ .name = "INP-024_event_capture", .run = notImplemented },
        .{ .name = "INP-025_event_stop_propagation", .run = notImplemented },
        .{ .name = "INP-026_event_prevent_default", .run = notImplemented },
    },
};

fn notImplemented() framework.TestError!void {
    return error.NotImplemented;
}
