local Range = {
	melee_short = 20,
	melee_medium = 30,
	melee_long = 40,
	distance = 0
}

function Range:getSize(type_range, distance)
	distance = distance or 0

	if self[type_range] == nil then
		error('invalid range type')
	end

	if type_range == 'distance' then
		return distance
	end

	return self[type_range]
end

return Range
