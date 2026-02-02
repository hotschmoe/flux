//! FLUX Conformance Test Suite - Layout Tests
//!
//! Tests for flexbox layout algorithm correctness covering:
//! single element sizing, row/column layouts, nested layouts,
//! flex grow/shrink, alignment, justification, gaps, and wrap behavior.

const framework = @import("../framework.zig");

pub const suite = framework.TestSuite{
    .name = "flux.layout",
    .tests = &.{
        // Basic layout
        .{ .name = "LAY-001_single_element", .run = notImplemented },
        .{ .name = "LAY-002_row_layout", .run = notImplemented },
        .{ .name = "LAY-003_column_layout", .run = notImplemented },
        .{ .name = "LAY-004_nested_layout", .run = notImplemented },

        // Flex sizing
        .{ .name = "LAY-005_flex_grow", .run = notImplemented },
        .{ .name = "LAY-006_flex_shrink", .run = notImplemented },
        .{ .name = "LAY-007_flex_basis", .run = notImplemented },
        .{ .name = "LAY-008_flex_combined", .run = notImplemented },

        // Alignment
        .{ .name = "LAY-009_align_items_start", .run = notImplemented },
        .{ .name = "LAY-010_align_items_center", .run = notImplemented },
        .{ .name = "LAY-011_align_items_end", .run = notImplemented },
        .{ .name = "LAY-012_align_items_stretch", .run = notImplemented },

        // Justification
        .{ .name = "LAY-013_justify_start", .run = notImplemented },
        .{ .name = "LAY-014_justify_center", .run = notImplemented },
        .{ .name = "LAY-015_justify_end", .run = notImplemented },
        .{ .name = "LAY-016_justify_space_between", .run = notImplemented },
        .{ .name = "LAY-017_justify_space_around", .run = notImplemented },
        .{ .name = "LAY-018_justify_space_evenly", .run = notImplemented },

        // Gap and spacing
        .{ .name = "LAY-019_row_gap", .run = notImplemented },
        .{ .name = "LAY-020_column_gap", .run = notImplemented },
        .{ .name = "LAY-021_padding", .run = notImplemented },
        .{ .name = "LAY-022_margin", .run = notImplemented },

        // Wrap
        .{ .name = "LAY-023_wrap_basic", .run = notImplemented },
        .{ .name = "LAY-024_wrap_reverse", .run = notImplemented },
        .{ .name = "LAY-025_align_content", .run = notImplemented },

        // Edge cases
        .{ .name = "LAY-026_zero_size_children", .run = notImplemented },
        .{ .name = "LAY-027_overflow_handling", .run = notImplemented },
        .{ .name = "LAY-028_min_max_constraints", .run = notImplemented },
        .{ .name = "LAY-029_aspect_ratio", .run = notImplemented },
        .{ .name = "LAY-030_absolute_positioning", .run = notImplemented },
    },
};

fn notImplemented() framework.TestError!void {
    return error.NotImplemented;
}
