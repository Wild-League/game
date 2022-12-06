local Utils = {}

function Utils.has_collision(x1, y1, w1, h1, x2, y2, w2, h2)
	return (
		x2 < x1 + w1 and
		x1 < x2 + w2 and
		y1 < y2 + h2 and
		y2 < y1 + h1
	)
end

function Utils.circle_rect_collision(cx, cy, cr, rx, ry, rw, rh)
	rw = rw or 2
	rh = rh or 2

	local circle_distance_x = math.abs(cx - rx - rw/2)
	local circle_distance_y = math.abs(cy - ry - rh/2)

	if circle_distance_x > (rw/2 + cr) then return false end
	if circle_distance_y > (rh/2 + cr) then return false end

	if circle_distance_x <= (rw/2) then return true end
	if circle_distance_y <= (rh/2) then return true end

	local corner_distance_sq = math.pow(circle_distance_x - rw/2, 2)
		+ math.pow(circle_distance_y - rh/2, 2)

	return corner_distance_sq <= math.pow(cr, 2)
end

function Utils.copy_table(tb)
	local copy = {}

	for k,v in pairs(tb) do
		copy[k] = v

		if type(v) == 'table' then
			Utils.copy_table(v)
		end
	end

	return copy
end

return Utils
