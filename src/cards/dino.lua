local Assets = require('assets.dino.assets')
local anim8 = require('lib.anim8')
local Range = require('src.config.range')

local Dino = {
	name = 'Dino',
	img = Assets.PREVIEW_LEFT, -- TODO: change name to `preview_img`
	card_img = Assets.CARD,
	is_card_loading = false,

	speed = 0.3,
	current_action = 'walk',
	attack_range = Range:getSize('melee_medium'),

	cooldown = 5, -- seconds

	------------

	-- TODO: move all props below to an abstract `card` class
	current_cooldown = 0,

	x = 0,
	y = 0,

	char_x = 0,
	char_y = 0,

	animate = {},
	actions = {},
	chars_around = {},
	selected = false,
	selectable = false,
	preview_card = false
}

local walking = Assets.WALK_LEFT
local grid_walking = anim8.newGrid(90, 90, walking:getWidth(), walking:getHeight())

local walk_animation = anim8.newAnimation(grid_walking('1-6', 1), 0.2)

Dino.animate.update = function(self, dt)
	return self.actions[self.current_action].update(dt)
end

Dino.animate.draw = function(self, x, y, ...)
	self.lifebar(x,y)

	return self.actions[self.current_action].draw(x,y)
end

Dino.actions = {
	walk = {
		update = function(dt)
			walk_animation:update(dt)
		end,
		draw = function(x,y)
			x = x - Dino.speed

			walk_animation:draw(walking, x,y)
			return x,y
		end
	}
}

-- show life level for each char
-- TODO: move to generic card module
function Dino.lifebar(x,y)
	love.graphics.setColor(255/255,29/255,29/255)
	love.graphics.rectangle("line", x - 10, y - 10, 50, 5)
	love.graphics.rectangle("fill", x - 10, y - 10, 50, 5)
	love.graphics.setColor(255,255,255)
end

-- only showed on preview
function Dino:perception_range()
	return self.attack_range * 2
end

return Dino
