local anim8 = require('lib.anim8')

local Animation = {}

function Animation:new(card, action)
	local action_image = card['img_' .. action]

	local number_frames = math.floor(action_image:getWidth() / card.frame_width)

	local grid = anim8.newGrid(card.frame_width, card.frame_height, action_image:getWidth(), action_image:getHeight())

	local frame_duration = card.speed / 10

	if action == 'attack' then
		-- attack_speed = attacks per second
		local aps = tonumber(card.attack_speed)
		if not aps or aps <= 0 then
			aps = 1.0
		end
		local attack_cycle_seconds = 1 / aps
		frame_duration = attack_cycle_seconds / math.max(1, number_frames)
	end

	return anim8.newAnimation(grid('1-' .. number_frames, 1), frame_duration)
end

return Animation
