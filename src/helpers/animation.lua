local anim8 = require('lib.anim8')
-- local ImageHelper = require('src.helpers.image')

local Animation = {}

function Animation:new(card, action, frame_width, frame_height)
	local number_frames = math.floor(card['img_'..action]:getWidth() / frame_width)

	local grid = anim8.newGrid(frame_width, frame_height, card['img_'..action]:getWidth(), card['img_'..action]:getHeight())

	return anim8.newAnimation(grid('1-'..number_frames, 1), card.speed/10)
end

return Animation
