//! FLUX Conformance Test Suite - Text Tests
//!
//! Tests for text rendering and editing covering:
//! text shaping, fonts, text layout, cursor positioning, selection, unicode, bidi, and decorations.

const framework = @import("../framework.zig");

pub const suite = framework.TestSuite{
    .name = "flux.text",
    .tests = &.{
        // Basic text rendering
        .{ .name = "TXT-001_render_simple", .run = notImplemented },
        .{ .name = "TXT-002_render_multiline", .run = notImplemented },
        .{ .name = "TXT-003_render_styled", .run = notImplemented },
        .{ .name = "TXT-004_render_mixed_styles", .run = notImplemented },

        // Font
        .{ .name = "TXT-005_font_family", .run = notImplemented },
        .{ .name = "TXT-006_font_size", .run = notImplemented },
        .{ .name = "TXT-007_font_weight", .run = notImplemented },
        .{ .name = "TXT-008_font_style", .run = notImplemented },
        .{ .name = "TXT-009_font_fallback", .run = notImplemented },

        // Text layout
        .{ .name = "TXT-010_wrap_word", .run = notImplemented },
        .{ .name = "TXT-011_wrap_char", .run = notImplemented },
        .{ .name = "TXT-012_wrap_none", .run = notImplemented },
        .{ .name = "TXT-013_align_left", .run = notImplemented },
        .{ .name = "TXT-014_align_center", .run = notImplemented },
        .{ .name = "TXT-015_align_right", .run = notImplemented },
        .{ .name = "TXT-016_align_justify", .run = notImplemented },
        .{ .name = "TXT-017_line_height", .run = notImplemented },
        .{ .name = "TXT-018_letter_spacing", .run = notImplemented },

        // Cursor positioning
        .{ .name = "TXT-019_cursor_from_position", .run = notImplemented },
        .{ .name = "TXT-020_position_from_cursor", .run = notImplemented },
        .{ .name = "TXT-021_cursor_line_navigation", .run = notImplemented },
        .{ .name = "TXT-022_cursor_word_navigation", .run = notImplemented },

        // Selection
        .{ .name = "TXT-023_selection_single_line", .run = notImplemented },
        .{ .name = "TXT-024_selection_multi_line", .run = notImplemented },
        .{ .name = "TXT-025_selection_word_double_click", .run = notImplemented },
        .{ .name = "TXT-026_selection_line_triple_click", .run = notImplemented },

        // Unicode
        .{ .name = "TXT-027_unicode_basic", .run = notImplemented },
        .{ .name = "TXT-028_unicode_emoji", .run = notImplemented },
        .{ .name = "TXT-029_unicode_combining", .run = notImplemented },
        .{ .name = "TXT-030_unicode_grapheme_clusters", .run = notImplemented },

        // Bidirectional text
        .{ .name = "TXT-031_bidi_rtl", .run = notImplemented },
        .{ .name = "TXT-032_bidi_mixed", .run = notImplemented },
        .{ .name = "TXT-033_bidi_cursor", .run = notImplemented },

        // Text decoration
        .{ .name = "TXT-034_decoration_underline", .run = notImplemented },
        .{ .name = "TXT-035_decoration_strikethrough", .run = notImplemented },
        .{ .name = "TXT-036_decoration_overline", .run = notImplemented },
    },
};

fn notImplemented() framework.TestError!void {
    return error.NotImplemented;
}
