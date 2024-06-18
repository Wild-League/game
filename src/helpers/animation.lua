local anim8 = require('lib.anim8')

local Animation = {}

function Animation:new(card, action)
	local action_image = card['img_'..action]

	local number_frames = math.floor(action_image:getWidth() / card.frame_width)

	local grid = anim8.newGrid(card.frame_width, card.frame_height, action_image:getWidth(), action_image:getHeight())

	return anim8.newAnimation(grid('1-'..number_frames, 1), card.speed/10, function()
		if action == 'attack' then
			--- --
		end

		if action == 'death' then
			--- ---
		end
	end)
end

return Animation
