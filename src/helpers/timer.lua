local Timer = {
	timer = 0
}

function Timer:match(dt)
	self.timer = self.timer + dt

	local seconds = tostring(math.floor(self.timer % 60))
	local minutes = tostring(math.floor(self.timer / 60))

	if tonumber(seconds) <= 9 then
		seconds = '0'..seconds
	end
	if tonumber(minutes) <= 9 then
		minutes = '0'..minutes
	end

	local time = minutes..':'..seconds

	return time
end

return Timer
