const std = @import("std");
const assert = std.debug.assert;
const epsilon: f32 = 1e-5;
const ArithmeticError = @import("errors.zig").ArithmeticError;
const DivisionByZero = ArithmeticError.DivisionByZero;
const NormalizingZeroVector = ArithmeticError.NormalizingZeroVector;

pub const float4 = struct {
    x: f32,
    y: f32,
    z: f32,
    w: f32,

    pub fn eq(self: float4, other: float4) bool {
        const x_eq = @abs(self.x - other.x) < epsilon;
        const y_eq = @abs(self.x - other.x) < epsilon;
        const z_eq = @abs(self.x - other.x) < epsilon;
        const w_eq = @abs(self.x - other.x) < epsilon;
        return x_eq and y_eq and z_eq and w_eq;
    }

    pub fn neg(self: float4) float4 {
        return float4 {
            .x = -self.x,
            .y = -self.y,
            .z = -self.z,
            .w = -self.w
        };
    }
};

pub fn tuple(x: f32, y: f32, z: f32, w: f32) float4 {
    return float4 {.x = x, .y = y, .z = z, .w = w};
}

pub fn point(x: f32, y: f32, z: f32) float4 {
    return tuple(x, y, z, 1.0);
}

pub fn vector(x: f32, y: f32, z: f32) float4 {
    return tuple(x, y, z, 0.0);
}

pub fn add_float4(left: float4, right: float4) float4 {
    return tuple(left.x + right.x, left.y + right.y, left.z + right.z, left.w + right.w);
}

pub fn sub_float4(left: float4, right: float4) float4 {
    return tuple(left.x - right.x, left.y - right.y, left.z - right.z, left.w - right.w);
}

pub fn scalar_mul(left: float4, right: f32) float4 {
    return tuple(left.x * right, left.y * right, left.z * right, left.w * right);
}   

pub fn scalar_div(left: float4, right: f32) ArithmeticError!float4 {
    if (right == 0) return DivisionByZero;
    return tuple(left.x / right, left.y / right, left.z / right, left.w / right);
}  

pub fn magnitude(v: float4) f32 {
    return std.math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
}

pub fn normalize(v: float4) ArithmeticError!float4 {
    const length = magnitude(v);
    if (length < epsilon) return NormalizingZeroVector;
    return scalar_div(v, length);
}

pub fn is_close(left: f32, right: f32) bool {
    return @abs(left - right) < epsilon;
}

pub fn dot(left: float4, right: float4) f32 {
    return left.x * right.x + left.y * right.y + left.z * right.z + left.w * right.w;
}

pub fn cross(left: float4, right: float4) float4 {
    return vector(
        left.y * right.z - left.z * right.y,
        left.z * right.x - left.x * right.z,
        left.x * right.y - left.y * right.x
    );
}

pub const Color = struct {
    red: f32,
    green: f32,
    blue: f32,

    pub fn eq(self: Color, other: Color) bool {
        const red_eq = @abs(self.red - other.red) < epsilon;
        const green_eq = @abs(self.green - other.green) < epsilon;
        const blue_eq = @abs(self.blue - other.blue) < epsilon;
        return red_eq and green_eq and blue_eq;
    }
};

pub fn color(red: f32, green: f32, blue: f32) Color {
    return Color {.red = red, .green = green, .blue = blue};
}

pub fn color_add(c1: Color, c2: Color) Color {
    return color(c1.red + c2.red, c1.green + c2.green, c1.blue + c2.blue);
}

pub fn color_sub(c1: Color, c2: Color) Color {
    return color(c1.red - c2.red, c1.green - c2.green, c1.blue - c2.blue);
}

pub fn color_scalar_mul(c: Color, lambda: f32) Color {
    return color(c.red * lambda, c.green * lambda, c.blue * lambda);
}

pub fn color_mul(c1: Color, c2: Color) Color {
    return color(c1.red * c2.red, c1.green * c2.green, c1.blue * c2.blue);
}


test "A tuple with w=1.0 is a point" {
    const t = tuple(1.0, 1.0, 1.0, 1.0);
    const p = point(1.0, 1.0, 1.0);
    assert(t.eq(p));
}

test "A tuple with w=0 is a vector" {
    const t = tuple(1.0, 1.0, 1.0, 0.0);
    const v = vector(1.0, 1.0, 1.0);
    assert(t.eq(v));
}

test "Adding two tuples" {
    const t1 = tuple(1.0, 1.0, 1.0, 0.0);
    const t2 = tuple(-1.0, -1.0, -1.0, 0.0);
    const expected = tuple(0.0, 0.0, 0.0, 0.0);

    assert(add_float4(t1, t2).eq(expected));
}

test "Subtracting two points" {
    const t1 = tuple(1.0, 1.0, 1.0, 0.0);
    const t2 = tuple(1.0, 1.0, 1.0, 0.0);
    const expected = tuple(0.0, 0.0, 0.0, 0.0);

    assert(sub_float4(t1, t2).eq(expected));
}

test "Subtracting a vector from a point" {
    const v = vector(1.0, 1.0, 1.0);
    const p = point(1.0, 1.0, 1.0);
    const expected = point(0.0, 0.0, 0.0);

    assert(sub_float4(p, v).eq(expected));
}

test "Subtracting two vectors" {
    const v1 = vector(1.0, 1.0, 1.0);
    const v2 = vector(1.0, 1.0, 1.0);
    const expected = vector(0.0, 0.0, 0.0);

    assert(sub_float4(v1, v2).eq(expected));
}

test "Subtracting a vector from the zero vector" {
    const v1 = vector(0.0, 0.0, 0.0);
    const v2 = vector(1.0, 1.0, 1.0);
    const expected = vector(-1.0, -1.0, -1.0);

    assert(sub_float4(v1, v2).eq(expected));
}

test "Negating a tuple" {
    const t = tuple(1.0, 2.0, 3.0, 4.0);
    const expected = tuple(-1.0, -2.0, -3.0, -4.0);

    assert(t.neg().eq(expected));
}

test "Multiplying a tuple by a scalar" {
    const t = tuple(1.0, 2.0, 3.0, 4.0);
    const lambda: f32 = 2.0;
    const expected = tuple(2.0, 4.0, 6.0, 8.0);

    assert(scalar_mul(t, lambda).eq(expected));
}

test "Multiplying a tuple by a fraction" {
    const t = tuple(2.0, 4.0, 6.0, 8.0);
    const lambda: f32 = 0.5;    
    const expected = tuple(1.0, 2.0, 3.0, 4.0);

    assert(scalar_mul(t, lambda).eq(expected));
}

test "Dividing a tuple by a scalar" {
    const t = tuple(2.0, 4.0, 6.0, 8.0);
    const lambda: f32 = 2.0;    
    const expected = tuple(1.0, 2.0, 3.0, 4.0);
    const res = scalar_div(t, lambda) catch unreachable;

    assert(res.eq(expected));
}

test "Computing the magnitude of vector(1, 0, 0), vector(0, 1, 0), vector(0, 0, 1)" {
    const v1 = vector(1.0, 0.0, 0.0);
    const v2 = vector(0.0, 1.0, 0.0);
    const v3 = vector(0.0, 0.0, 1.0);
    const expected: f32 = 1.0;

    assert(is_close(magnitude(v1), expected));
    assert(is_close(magnitude(v2), expected));
    assert(is_close(magnitude(v3), expected));
}

test "Computing the magnitude of vector(1, 2, 3)" {
    const v = vector(1.0, 2.0, 3.0);
    const expected: f32 = std.math.sqrt(14.0);

    assert(is_close(magnitude(v), expected));
}

test "Normalizing vector(4, 0, 0) gives (1, 0, 0)" {
    const v = vector(4.0, 0.0, 0.0);
    const expected = vector(1.0, 0.0, 0.0);
    const res = normalize(v) catch unreachable;

    assert(res.eq(expected));
}

test "The magnitude of a normalized vector" {
    const v = vector(4.0, 0.0, 0.0);
    const normalized = normalize(v) catch unreachable;
    const res = magnitude(normalized);

    assert(is_close(res, 1.0));
}

test "The dot product of two tuples" {
    const v1 = vector(1, 2, 3);
    const v2 = vector(2, 3, 4);

    assert(is_close(dot(v1, v2), 20.0));
}

test "The cross product of two vectors" {
    const v1 = vector(1, 2, 3);
    const v2 = vector(2, 3, 4);
    const expected = vector(-1, 2, -1);

    assert(cross(v1, v2).eq(expected));
    assert(cross(v2, v1).eq(expected.neg()));
}

test "Colors are (red, green, blue) tuples" {
    const c = color(-0.5, 0.4, 1.7);
    assert(is_close(c.red, -0.5));
    assert(is_close(c.green, 0.4));
    assert(is_close(c.blue, 1.7));
}

test "Adding colors" {
    const c1 = color(0.9, 0.6, 0.75);
    const c2 = color(0.7, 0.1, 0.25);
    const expected = color(1.6, 0.7, 1.0);
    const res = color_add(c1, c2);

    assert(res.eq(expected));
}

test "Subtracting colors" {
    const c1 = color(0.9, 0.6, 0.75);
    const c2 = color(0.7, 0.1, 0.25);
    const expected = color(0.2, 0.5, 0.5);
    const res = color_sub(c1, c2);

    assert(res.eq(expected));
}

test "Multiplying a color by a scalar" {
    const c1 = color(0.9, 0.6, 0.75);
    const lambda: f32 = 2.0;
    const expected = color(1.8, 1.2, 1.5);
    const res = color_scalar_mul(c1, lambda);

    assert(res.eq(expected));
}

test "Multiplying colors" {
    const c1 = color(1, 0.2, 0.4);
    const c2 = color(0.9, 1, 0.1);
    const expected = color(0.9, 0.2, 0.04);
    const res = color_mul(c1, c2);

    assert(res.eq(expected));
}