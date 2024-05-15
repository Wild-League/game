--- Utility functions to manipulate colors.
--
-- Colors are represented as RGB or RGBA, each channel
-- with values in range [0, 1].
--
-- @module gear.color
-- @copyright 2023 The DoubleFourteen Code Forge
-- @author Lorenzo Cogotti

local Color = {}


--- Darken RGB color by the specified amount.
--
-- @number r red channel
-- @number g green channel
-- @number b blue channel
-- @number amount darken factor, must be in [0,1] range.
function Color.darken(r, g, b, amount)
	r = r * (1 - amount)
	g = g * (1 - amount)
	b = b * (1 - amount)

	return r, g, b
end

--- Lighten RGB color by the specified amount.
--
-- @number r red channel
-- @number g green channel
-- @number b blue channel
-- @number amount lightening factor, must be in [0,1] range.
function Color.lighten(r, g, b, amount)
	r = r + (1 - r) * amount
	g = g + (1 - g) * amount
	b = b + (1 - b) * amount

	return r, g, b
end

function Color.hsl(h, s, l, a)
	a = a or 1
	if s <= 0 then return 1, 1, 1, a end

	h = h * 6

	local abs = math.abs
	local c = (1 - abs(l*2 - 1))*s
	local x = (1 - abs(h%2 - 1))*c
	local m = l - c*0.5

	local r, g, b
	if h < 1 then     r, g, b = c, x, 0
	elseif h < 2 then r, g, b = x, c, 0
	elseif h < 3 then r, g, b = 0, c, x
	elseif h < 4 then r, g, b = 0, x, c
	elseif h < 5 then r, g, b = x, 0, c
	else              r, g, b = c, 0, x
	end
	return r+m, g+m, b+m, a
end

function Color.hsv(h, s, v, a)
	a = a or 1
	if s <= 0 then return v, v, v, a end

	h = h * 6

	local c = v * s
	local x = (1 - math.abs(h%2 - 1))*c
	local m = v - c

	local r, g, b
	if h < 1 then     r, g, b = c, x, 0
	elseif h < 2 then r, g, b = x, c, 0
	elseif h < 3 then r, g, b = 0, c, x
	elseif h < 4 then r, g, b = 0, x, c
	elseif h < 5 then r, g, b = x, 0, c
	else              r, g, b = c, 0, x
	end
	return r+m, g+m, b+m, a

end

--- Given two RGB colors, calculate fade by the specified amount.
--
-- @number cr first color, red channel
-- @number cg first color, green channel
-- @number cb first color, blue channel
-- @number ar second color, red channel
-- @number ag second color, green channel
-- @number ab second color, blue channel
-- @number amount fading factor, must be in [0,1] range.
function Color.fade(cr, cg, cb, ar, ag, ab, amount)
	cr = cr + (ar - cr) * amount
	cg = cg + (ag - cg) * amount
	cb = cb + (ab - cb) * amount

	return cr, cg, cb
end

return Color
