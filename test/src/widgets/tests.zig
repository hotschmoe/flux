//! FLUX Conformance Test Suite - Widget Tests
//!
//! Tests for widget behavior and functionality covering:
//! buttons, text input, checkbox/radio, slider, scroll container, list views, and dropdowns.

const framework = @import("../framework.zig");

pub const suite = framework.TestSuite{
    .name = "flux.widgets",
    .tests = &.{
        // Button
        .{ .name = "WGT-001_button_click", .run = notImplemented },
        .{ .name = "WGT-002_button_hover", .run = notImplemented },
        .{ .name = "WGT-003_button_disabled", .run = notImplemented },
        .{ .name = "WGT-004_button_keyboard", .run = notImplemented },

        // Text input
        .{ .name = "WGT-005_text_input_typing", .run = notImplemented },
        .{ .name = "WGT-006_text_input_selection", .run = notImplemented },
        .{ .name = "WGT-007_text_input_cursor", .run = notImplemented },
        .{ .name = "WGT-008_text_input_copy_paste", .run = notImplemented },
        .{ .name = "WGT-009_text_input_undo_redo", .run = notImplemented },
        .{ .name = "WGT-010_text_input_placeholder", .run = notImplemented },

        // Checkbox
        .{ .name = "WGT-011_checkbox_toggle", .run = notImplemented },
        .{ .name = "WGT-012_checkbox_indeterminate", .run = notImplemented },
        .{ .name = "WGT-013_checkbox_keyboard", .run = notImplemented },

        // Radio button
        .{ .name = "WGT-014_radio_select", .run = notImplemented },
        .{ .name = "WGT-015_radio_group", .run = notImplemented },
        .{ .name = "WGT-016_radio_keyboard", .run = notImplemented },

        // Slider
        .{ .name = "WGT-017_slider_drag", .run = notImplemented },
        .{ .name = "WGT-018_slider_click", .run = notImplemented },
        .{ .name = "WGT-019_slider_keyboard", .run = notImplemented },
        .{ .name = "WGT-020_slider_range", .run = notImplemented },

        // Scroll container
        .{ .name = "WGT-021_scroll_wheel", .run = notImplemented },
        .{ .name = "WGT-022_scroll_drag", .run = notImplemented },
        .{ .name = "WGT-023_scroll_bar_click", .run = notImplemented },
        .{ .name = "WGT-024_scroll_momentum", .run = notImplemented },
        .{ .name = "WGT-025_scroll_bounds", .run = notImplemented },

        // List view
        .{ .name = "WGT-026_list_selection", .run = notImplemented },
        .{ .name = "WGT-027_list_multi_select", .run = notImplemented },
        .{ .name = "WGT-028_list_virtualization", .run = notImplemented },
        .{ .name = "WGT-029_list_keyboard_nav", .run = notImplemented },

        // Dropdown
        .{ .name = "WGT-030_dropdown_open", .run = notImplemented },
        .{ .name = "WGT-031_dropdown_select", .run = notImplemented },
        .{ .name = "WGT-032_dropdown_keyboard", .run = notImplemented },
    },
};

fn notImplemented() framework.TestError!void {
    return error.NotImplemented;
}
