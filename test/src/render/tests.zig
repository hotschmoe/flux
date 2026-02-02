//! FLUX Conformance Test Suite - Render Tests
//!
//! Tests for rendering and painting correctness covering:
//! backgrounds, borders, clipping, transforms, layers, shadows, and anti-aliasing.

const framework = @import("../framework.zig");

pub const suite = framework.TestSuite{
    .name = "flux.render",
    .tests = &.{
        // Background
        .{ .name = "RND-001_solid_background", .run = notImplemented },
        .{ .name = "RND-002_gradient_linear", .run = notImplemented },
        .{ .name = "RND-003_gradient_radial", .run = notImplemented },
        .{ .name = "RND-004_background_image", .run = notImplemented },

        // Border
        .{ .name = "RND-005_border_solid", .run = notImplemented },
        .{ .name = "RND-006_border_radius", .run = notImplemented },
        .{ .name = "RND-007_border_width_asymmetric", .run = notImplemented },
        .{ .name = "RND-008_border_color_sides", .run = notImplemented },

        // Clipping
        .{ .name = "RND-009_clip_overflow_hidden", .run = notImplemented },
        .{ .name = "RND-010_clip_border_radius", .run = notImplemented },
        .{ .name = "RND-011_nested_clipping", .run = notImplemented },

        // Transform
        .{ .name = "RND-012_transform_translate", .run = notImplemented },
        .{ .name = "RND-013_transform_rotate", .run = notImplemented },
        .{ .name = "RND-014_transform_scale", .run = notImplemented },
        .{ .name = "RND-015_transform_combined", .run = notImplemented },
        .{ .name = "RND-016_transform_origin", .run = notImplemented },

        // Layer
        .{ .name = "RND-017_opacity", .run = notImplemented },
        .{ .name = "RND-018_blend_modes", .run = notImplemented },
        .{ .name = "RND-019_z_index", .run = notImplemented },

        // Shadow
        .{ .name = "RND-020_box_shadow", .run = notImplemented },
        .{ .name = "RND-021_box_shadow_inset", .run = notImplemented },
        .{ .name = "RND-022_multiple_shadows", .run = notImplemented },

        // Anti-aliasing
        .{ .name = "RND-023_edge_antialiasing", .run = notImplemented },
        .{ .name = "RND-024_subpixel_positioning", .run = notImplemented },
    },
};

fn notImplemented() framework.TestError!void {
    return error.NotImplemented;
}
