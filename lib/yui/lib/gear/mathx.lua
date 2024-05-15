--- Extended math functions
--
-- @module gear.mathx
-- @copyright 2022 The 1414 Code Forge
-- @author Lorenzo Cogotti

local floor = math.floor
local min, max = math.min, math.max
local cos, pi = math.cos, math.pi
local random = love and love.math.random or math.random

local mathx = setmetatable({}, math)


--- Clamp x within range [a,b] (where b >= a).
--
-- @number x value to clamp.
-- @number a interval lower bound (inclusive).
-- @number b interval upper bound (inclusive).
-- @treturn number clamped value.
function mathx.clamp(x, a, b) return min(max(x, a), b) end

--- Sign function.
--
-- @number x value whose sign should be returned.
-- @treturn number sign of x, -1 if negative, 1 if positive, 0 otherwise.
function mathx.sign(x) return x > 0 and 1 or x < 0 and -1 or 0 end

--- sign() variant returning 1 if x is non-negative.
--
-- @number x value whose sign should be returned.
-- @treturn number sign of x, -1 if negative, 1 if non-negative.
function mathx.sign2(x) return x >= 0 and 1 or -1 end

--- Linear interpolation between a and b.
--
-- @number a first interpolation point.
-- @number b second interpolation point.
-- @number t the interpolation factor, a real number within [0,1].
-- @treturn number the interpolated value.
function mathx.lerp(a, b, t) return a*(1 - t) + b*t end

--- Less accurate, but slightly faster, variant of lerp().
function mathx.lerp2(a, b, t) return a + (b - a)*t end

--- Cosine interpolation between a and b.
--
-- @number a first interpolation point.
-- @number b second interpolation point.
-- @number t the interpolation factor, a real number within [0,1].
-- @treturn number interpolated value.
function mathx.cerp(a, b, t)
	local tt = (1 - cos(t * pi)) * 0.5
	return a*(1 - tt) + b*tt
end

--- Cubic interpolation between a, b, c and d.
--
-- @number a first interpolation point.
-- @number b second interpolation point.
-- @number c third interpolation point.
-- @number d fourth interpolation point.
-- @number t the interpolation factor, a real number within [0,1].
-- @treturn number the interpolated value.
function mathx.cberp(a, b, c, d, t)
	local tt = t * t
	local a0 = d - c - a + b
	return a0*t*tt + (a - b - a0)*tt + (c - a)*t + b
end

--- Catmull-Rom spline interpolation between a, b, c and d.
--
-- @number a first interpolation point.
-- @number b second interpolation point.
-- @number c third interpolation point.
-- @number d fourth interpolation point.
-- @number t the interpolation factor, a real number within [0,1].
-- @treturn number the interpolated value.
function mathx.catmullrom(a, b, c, d, t)
	local tt  =  t * t
	local mha = -a * 0.5
	local hd  =  d * 0.5
	return (mha + 1.5*b - 1.5*c + hd)*t*tt + (a - 2.5*b + 2*c - hd)*tt + (mha + 0.5*c)*t + b
end

--- Hermite interpolation between a, b, c and d.
--
-- @number a first interpolation point.
-- @number b second interpolation point.
-- @number c third interpolation point.
-- @number d fourth interpolation point.
-- @number t the interpolation factor, a real number within [0,1].
-- @number tension the tension factor, 1 is high, 0 normal (default), -1 is low.
-- @number bias the bias factor, 0 is even (default), positive is towards the first segment, negative towards the other.
-- @treturn number the interpolated value.
function mathx.herp(a, b, c, d, t, tension, bias)
	tension = tension or 0
	bias = bias or 0

	local b0 = 1 + bias
	local b1 = 1 - bias
	local ht = (1 - tension) * 0.5
	local s0 = b0 * ht
	local s1 = b1 * ht

	local tt   = t   * t
	local ttt  = tt  * t
	local ttt2 = ttt * 2
	local tt3  = tt  * 3

	local m0 = (b - a)*s0 + (c - b)*s1
	local m1 = (c - b)*s0 + (d - c)*s1

	local a0 = ttt2 - tt3  + 1
	local a1 = ttt  - tt*2 + t
	local a2 = ttt  - tt
	local a3 = tt3  - ttt2

	return a0*b + a1*m0 + a2*m1 + a3*c
end

--- Pseudo-random sign value.
--
-- @treturn number the pseudo-random sign value, either -1, 0, or 1.
function mathx.rsign() return random(-1, 1) end

--- rsign() variant returning -1 or 1.
--
-- @treturn number the pseudo-random sign value, either -1 or 1.
function mathx.rsign2() return random(2) == 2 and 1 or -1 end

--- Precise pseudo-random number within [min,max] (where max >= min).
--
-- @number min interval lower bound (inclusive).
-- @number max interval upper bound (inclusive).
-- @treturn number the pseudo-random real number within [a,b].
function mathx.prandom(min, max)
	local t = random()
	return min * (1 - t) + max * t
end

return mathx
