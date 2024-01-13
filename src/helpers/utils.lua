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

function Utils.copy_table(orig, copies)
	copies = copies or {}
	local orig_type = type(orig)
	local copy

	if orig_type == 'table' then
		if copies[orig] then
			copy = copies[orig]
		else
			copy = {}
			copies[orig] = copy

			for orig_key, orig_value in next, orig, nil do
				copy[Utils.copy_table(orig_key, copies)] = Utils.copy_table(orig_value, copies)
			end

			setmetatable(copy, Utils.copy_table(getmetatable(orig), copies))
		end
	else -- number, string, boolean, etc
		copy = orig
	end

	return copy
end

function Utils.merge_tables(t1, t2)
	local t3 = {}
	for k,v in pairs(t1) do t3[k] = v end
	for k,v in pairs(t2) do t3[k] = v end
	return t3
end

function Utils.list_to_obj(list)
	local set = {}
  for _,l in pairs(list) do set[l.name] = l end
  return set
end

function Utils.obj_to_list(obj)
	local list = {}
	for k,v in ipairs(obj) do list[k] = v end
	return list
end

return Utils
