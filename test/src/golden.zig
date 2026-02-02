//! FLUX Conformance Test Suite - Golden Image Comparison
//!
//! Infrastructure for golden image testing:
//! - Image capture from rendered widgets
//! - Pixel-by-pixel comparison with tolerance
//! - Diff image generation for failures

const std = @import("std");
const framework = @import("framework.zig");

const TestError = framework.TestError;

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

pub const Image = struct {
    width: u32,
    height: u32,
    pixels: []Pixel,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, width: u32, height: u32) !Image {
        const pixel_count = @as(usize, width) * @as(usize, height);
        const pixels = try allocator.alloc(Pixel, pixel_count);
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
        const index = @as(usize, y) * @as(usize, self.width) + @as(usize, x);
        return self.pixels[index];
    }

    pub fn setPixel(self: *Image, x: u32, y: u32, pixel: Pixel) void {
        if (x >= self.width or y >= self.height) return;
        const index = @as(usize, y) * @as(usize, self.width) + @as(usize, x);
        self.pixels[index] = pixel;
    }
};

pub const CompareResult = struct {
    matches: bool,
    total_pixels: usize,
    different_pixels: usize,
    max_diff: u8,
    diff_percentage: f32,
};

pub const CompareConfig = struct {
    tolerance: u8 = 0,
    max_diff_percentage: f32 = 0.0,
    generate_diff: bool = true,
};

pub fn compareImages(actual: Image, expected: Image, config: CompareConfig) CompareResult {
    if (actual.width != expected.width or actual.height != expected.height) {
        const max_pixels = @max(actual.pixels.len, expected.pixels.len);
        return .{
            .matches = false,
            .total_pixels = max_pixels,
            .different_pixels = max_pixels,
            .max_diff = 255,
            .diff_percentage = 100.0,
        };
    }

    var different_pixels: usize = 0;
    var max_diff: u8 = 0;

    for (actual.pixels, expected.pixels) |actual_pixel, expected_pixel| {
        if (!actual_pixel.eqlWithTolerance(expected_pixel, config.tolerance)) {
            different_pixels += 1;
            const channel_max = @max(
                @max(
                    Pixel.absDiff(actual_pixel.r, expected_pixel.r),
                    Pixel.absDiff(actual_pixel.g, expected_pixel.g),
                ),
                @max(
                    Pixel.absDiff(actual_pixel.b, expected_pixel.b),
                    Pixel.absDiff(actual_pixel.a, expected_pixel.a),
                ),
            );
            max_diff = @max(max_diff, channel_max);
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

pub fn generateDiffImage(allocator: std.mem.Allocator, actual: Image, expected: Image) !Image {
    const width = @max(actual.width, expected.width);
    const height = @max(actual.height, expected.height);

    var diff = try Image.init(allocator, width, height);

    for (0..height) |y| {
        for (0..width) |x| {
            const x_u32: u32 = @intCast(x);
            const y_u32: u32 = @intCast(y);
            const transparent = Pixel{ .r = 0, .g = 0, .b = 0, .a = 0 };
            const actual_pixel = actual.getPixel(x_u32, y_u32) orelse transparent;
            const expected_pixel = expected.getPixel(x_u32, y_u32) orelse transparent;

            const diff_pixel = if (actual_pixel.eql(expected_pixel))
                Pixel{
                    .r = actual_pixel.r / 2,
                    .g = actual_pixel.g / 2,
                    .b = actual_pixel.b / 2,
                    .a = 255,
                }
            else
                Pixel{ .r = 255, .g = 0, .b = 0, .a = 255 };

            diff.setPixel(x_u32, y_u32, diff_pixel);
        }
    }

    return diff;
}

// File Operations (stubs - to be implemented with actual PNG support)

pub fn loadGoldenImage(_: std.mem.Allocator, _: []const u8) TestError!Image {
    return TestError.NotImplemented;
}

pub fn saveImage(_: Image, _: []const u8) TestError!void {
    return TestError.NotImplemented;
}

pub fn captureRenderedImage(_: std.mem.Allocator, _: u32, _: u32) TestError!Image {
    return TestError.NotImplemented;
}

// Test Helpers

pub fn assertGolden(test_name: []const u8, allocator: std.mem.Allocator, width: u32, height: u32) TestError!void {
    const golden_path = std.fmt.allocPrint(allocator, "golden/{s}.png", .{test_name}) catch {
        return TestError.OutOfMemory;
    };
    defer allocator.free(golden_path);

    var actual = captureRenderedImage(allocator, width, height) catch {
        std.log.err("Failed to capture rendered image", .{});
        return TestError.RenderFailed;
    };
    defer actual.deinit();

    var expected = loadGoldenImage(allocator, golden_path) catch {
        std.log.err("Failed to load golden image '{s}'", .{golden_path});
        return TestError.FileNotFound;
    };
    defer expected.deinit();

    const result = compareImages(actual, expected, .{});
    if (result.matches) return;

    var diff = generateDiffImage(allocator, actual, expected) catch {
        std.log.err("Failed to generate diff image", .{});
        return TestError.GoldenMismatch;
    };
    defer diff.deinit();

    const diff_path = std.fmt.allocPrint(allocator, "diffs/{s}_diff.png", .{test_name}) catch {
        return TestError.OutOfMemory;
    };
    defer allocator.free(diff_path);

    saveImage(diff, diff_path) catch {};

    std.log.err("Golden image mismatch for '{s}':", .{test_name});
    std.log.err("  {}/{} pixels differ ({d:.2}%)", .{
        result.different_pixels,
        result.total_pixels,
        result.diff_percentage,
    });
    std.log.err("  Diff image saved to: {s}", .{diff_path});

    return TestError.GoldenMismatch;
}

pub fn updateGolden(test_name: []const u8, allocator: std.mem.Allocator, width: u32, height: u32) TestError!void {
    const golden_path = std.fmt.allocPrint(allocator, "golden/{s}.png", .{test_name}) catch {
        return TestError.OutOfMemory;
    };
    defer allocator.free(golden_path);

    var image = captureRenderedImage(allocator, width, height) catch {
        std.log.err("Failed to capture rendered image", .{});
        return TestError.RenderFailed;
    };
    defer image.deinit();

    saveImage(image, golden_path) catch {
        std.log.err("Failed to save golden image", .{});
        return TestError.FileNotFound;
    };

    std.log.info("Updated golden image: {s}", .{golden_path});
}
