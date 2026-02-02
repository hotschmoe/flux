//! FLUX Conformance Test Suite - Golden Image Comparison
//!
//! Provides infrastructure for golden image testing:
//! - Image capture from rendered widgets
//! - Pixel-by-pixel comparison with tolerance
//! - Diff image generation for failures
//! - Golden image management (update, approve)

const std = @import("std");
const framework = @import("framework.zig");

/// Represents an RGBA pixel
pub const Pixel = struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,

    pub fn eql(self: Pixel, other: Pixel) bool {
        return self.r == other.r and
            self.g == other.g and
            self.b == other.b and
            self.a == other.a;
    }

    pub fn eqlWithTolerance(self: Pixel, other: Pixel, tolerance: u8) bool {
        return absDiff(self.r, other.r) <= tolerance and
            absDiff(self.g, other.g) <= tolerance and
            absDiff(self.b, other.b) <= tolerance and
            absDiff(self.a, other.a) <= tolerance;
    }

    fn absDiff(a: u8, b: u8) u8 {
        return if (a > b) a - b else b - a;
    }
};

/// Represents a rendered image for comparison
pub const Image = struct {
    width: u32,
    height: u32,
    pixels: []Pixel,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, width: u32, height: u32) !Image {
        const pixels = try allocator.alloc(Pixel, @as(usize, width) * @as(usize, height));
        return .{
            .width = width,
            .height = height,
            .pixels = pixels,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Image) void {
        self.allocator.free(self.pixels);
    }

    pub fn getPixel(self: Image, x: u32, y: u32) ?Pixel {
        if (x >= self.width or y >= self.height) return null;
        return self.pixels[@as(usize, y) * @as(usize, self.width) + @as(usize, x)];
    }

    pub fn setPixel(self: *Image, x: u32, y: u32, pixel: Pixel) void {
        if (x >= self.width or y >= self.height) return;
        self.pixels[@as(usize, y) * @as(usize, self.width) + @as(usize, x)] = pixel;
    }
};

/// Result of comparing two images
pub const CompareResult = struct {
    matches: bool,
    total_pixels: usize,
    different_pixels: usize,
    max_diff: u8,
    diff_percentage: f32,

    pub fn format(self: CompareResult, writer: anytype) !void {
        if (self.matches) {
            try writer.print("Images match ({} pixels)", .{self.total_pixels});
        } else {
            try writer.print("Images differ: {}/{} pixels ({d:.2}%), max diff: {}", .{
                self.different_pixels,
                self.total_pixels,
                self.diff_percentage,
                self.max_diff,
            });
        }
    }
};

/// Configuration for golden image comparison
pub const CompareConfig = struct {
    /// Per-channel tolerance (0-255)
    tolerance: u8 = 0,
    /// Maximum percentage of pixels allowed to differ
    max_diff_percentage: f32 = 0.0,
    /// Generate diff image on failure
    generate_diff: bool = true,
};

/// Compares two images and returns the result
pub fn compareImages(actual: Image, expected: Image, config: CompareConfig) CompareResult {
    if (actual.width != expected.width or actual.height != expected.height) {
        return .{
            .matches = false,
            .total_pixels = @max(actual.pixels.len, expected.pixels.len),
            .different_pixels = @max(actual.pixels.len, expected.pixels.len),
            .max_diff = 255,
            .diff_percentage = 100.0,
        };
    }

    var different_pixels: usize = 0;
    var max_diff: u8 = 0;

    for (actual.pixels, expected.pixels) |actual_pixel, expected_pixel| {
        if (!actual_pixel.eqlWithTolerance(expected_pixel, config.tolerance)) {
            different_pixels += 1;
            const diff = @max(
                @max(
                    Pixel.absDiff(actual_pixel.r, expected_pixel.r),
                    Pixel.absDiff(actual_pixel.g, expected_pixel.g),
                ),
                @max(
                    Pixel.absDiff(actual_pixel.b, expected_pixel.b),
                    Pixel.absDiff(actual_pixel.a, expected_pixel.a),
                ),
            );
            max_diff = @max(max_diff, diff);
        }
    }

    const total_pixels = actual.pixels.len;
    const diff_percentage = if (total_pixels > 0)
        @as(f32, @floatFromInt(different_pixels)) / @as(f32, @floatFromInt(total_pixels)) * 100.0
    else
        0.0;

    return .{
        .matches = diff_percentage <= config.max_diff_percentage,
        .total_pixels = total_pixels,
        .different_pixels = different_pixels,
        .max_diff = max_diff,
        .diff_percentage = diff_percentage,
    };
}

/// Generates a diff image highlighting differences between two images
pub fn generateDiffImage(allocator: std.mem.Allocator, actual: Image, expected: Image) !Image {
    const width = @max(actual.width, expected.width);
    const height = @max(actual.height, expected.height);

    var diff = try Image.init(allocator, width, height);

    for (0..height) |y| {
        for (0..width) |x| {
            const actual_pixel = actual.getPixel(@intCast(x), @intCast(y)) orelse Pixel{ .r = 0, .g = 0, .b = 0, .a = 0 };
            const expected_pixel = expected.getPixel(@intCast(x), @intCast(y)) orelse Pixel{ .r = 0, .g = 0, .b = 0, .a = 0 };

            const diff_pixel = if (actual_pixel.eql(expected_pixel))
                // Matching pixels: show in grayscale
                Pixel{
                    .r = actual_pixel.r / 2,
                    .g = actual_pixel.g / 2,
                    .b = actual_pixel.b / 2,
                    .a = 255,
                }
            else
                // Different pixels: highlight in red
                Pixel{
                    .r = 255,
                    .g = 0,
                    .b = 0,
                    .a = 255,
                };

            diff.setPixel(@intCast(x), @intCast(y), diff_pixel);
        }
    }

    return diff;
}

// ============================================================================
// Golden Image File Operations
// ============================================================================

/// Loads a golden image from disk
pub fn loadGoldenImage(allocator: std.mem.Allocator, path: []const u8) !Image {
    _ = allocator;
    _ = path;
    // TODO: Implement PNG loading
    return framework.TestError.NotImplemented;
}

/// Saves an image to disk
pub fn saveImage(image: Image, path: []const u8) !void {
    _ = image;
    _ = path;
    // TODO: Implement PNG saving
    return framework.TestError.NotImplemented;
}

/// Captures the current rendered state as an image
pub fn captureRenderedImage(allocator: std.mem.Allocator, width: u32, height: u32) !Image {
    _ = allocator;
    _ = width;
    _ = height;
    // TODO: Implement capture from FLUX renderer
    return framework.TestError.NotImplemented;
}

// ============================================================================
// Golden Image Test Helpers
// ============================================================================

/// Asserts that the current rendered state matches the golden image
pub fn assertGolden(test_name: []const u8, allocator: std.mem.Allocator, width: u32, height: u32) framework.TestError!void {
    const golden_path = try std.fmt.allocPrint(allocator, "golden/{s}.png", .{test_name});
    defer allocator.free(golden_path);

    const actual = captureRenderedImage(allocator, width, height) catch |err| {
        std.log.err("Failed to capture rendered image: {}", .{err});
        return framework.TestError.RenderFailed;
    };
    defer @constCast(&actual).deinit();

    const expected = loadGoldenImage(allocator, golden_path) catch |err| {
        std.log.err("Failed to load golden image '{s}': {}", .{ golden_path, err });
        return framework.TestError.FileNotFound;
    };
    defer @constCast(&expected).deinit();

    const result = compareImages(actual, expected, .{});

    if (!result.matches) {
        // Generate diff image
        const diff = generateDiffImage(allocator, actual, expected) catch |err| {
            std.log.err("Failed to generate diff image: {}", .{err});
            return framework.TestError.GoldenMismatch;
        };
        defer @constCast(&diff).deinit();

        const diff_path = try std.fmt.allocPrint(allocator, "diffs/{s}_diff.png", .{test_name});
        defer allocator.free(diff_path);

        saveImage(diff, diff_path) catch {};

        std.log.err("Golden image mismatch for '{s}':", .{test_name});
        std.log.err("  {}/{} pixels differ ({d:.2}%)", .{
            result.different_pixels,
            result.total_pixels,
            result.diff_percentage,
        });
        std.log.err("  Diff image saved to: {s}", .{diff_path});

        return framework.TestError.GoldenMismatch;
    }
}

/// Updates the golden image with the current rendered state
pub fn updateGolden(test_name: []const u8, allocator: std.mem.Allocator, width: u32, height: u32) framework.TestError!void {
    const golden_path = try std.fmt.allocPrint(allocator, "golden/{s}.png", .{test_name});
    defer allocator.free(golden_path);

    const image = captureRenderedImage(allocator, width, height) catch |err| {
        std.log.err("Failed to capture rendered image: {}", .{err});
        return framework.TestError.RenderFailed;
    };
    defer @constCast(&image).deinit();

    saveImage(image, golden_path) catch |err| {
        std.log.err("Failed to save golden image: {}", .{err});
        return framework.TestError.FileNotFound;
    };

    std.log.info("Updated golden image: {s}", .{golden_path});
}
