local Assets = require('assets.caveman.assets')
local anim8 = require('lib.anim8')
local Range = require('src.config.range')

local Caveman = {
	name = 'Caveman',
	img = Assets.PREVIEW_LEFT, -- TODO: change name to `preview_img`
	card_img = Assets.CARD,
	is_card_loading = false,

	speed = 1.5,
	current_action = 'walk',
	attack_range = Range:getSize('melee_short'),

	cooldown = 10, -- seconds

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
local grid_walking = anim8.newGrid(60, 60, walking:getWidth(), walking:getHeight())
local walk_animation = anim8.newAnimation(grid_walking('1-11', 1), 0.2)

local attack = Assets.ATTACK_LEFT
local grid_attack = anim8.newGrid(70, 60, attack:getWidth(), attack:getHeight())
local attack_animation = anim8.newAnimation(grid_attack('1-9', 1), 0.2)

Caveman.animate.update = function(self, dt)
	return self.actions[self.current_action].update(dt)
end

Caveman.animate.draw = function(self, x, y, ...)
	self.lifebar(x,y)

	return self.actions[self.current_action].draw(x,y)
end

local nearest_enemy = {
	x = 0,
	y = 0
}

Caveman.actions = {
	walk = {
		update = function(dt)
			walk_animation:update(dt)
		end,
		draw = function(x,y)
			x = x - Caveman.speed

			walk_animation:draw(walking, x,y)
			return x,y
		end
	},
	follow = {
		update = function(dt)
			nearest_enemy = Caveman:get_nearest_enemy(Caveman.chars_around)

			walk_animation:update(dt)
		end,
		draw = function(x,y)
			local dx = nearest_enemy.x - x
   		local dy = nearest_enemy.y - y

   		local distance = math.sqrt(dx*dx + dy*dy)

			 if distance > 1 then
				local angle = math.atan2(dy, dx)
				x = x + Caveman.speed * math.cos(angle)
				y = y + Caveman.speed * math.sin(angle)
		 	end

			walk_animation:draw(walking, x, y)
			return x,y
		end
	},
	attack = {
		update = function(dt)
			attack_animation:update(dt)
		end,
		draw = function(x,y)
			if nearest_enemy.width == nil then
				nearest_enemy = Caveman:get_nearest_enemy(Caveman.chars_around)
			end

			attack_animation:draw(attack,x,y)
			return x,y
		end
	}
}

-- show life level for each char
-- TODO: move to generic card module
function Caveman.lifebar(x,y)
	love.graphics.setColor(255/255,29/255,29/255)
	love.graphics.rectangle("line", x - 10, y - 10, 50, 5)
	love.graphics.rectangle("fill", x - 10, y - 10, 50, 5)
	love.graphics.setColor(255,255,255)
end

-- only showed on preview
function Caveman:perception_range()
	return self.attack_range * 2
end

function Caveman:get_nearest_enemy(around)
	for _,v in pairs(around) do
		local distance_x = v.x - self.char_x
		local distance_y = v.y - self.char_y

		if (distance_x >= (nearest_enemy.x - self.char_x))
			and (distance_y >= (nearest_enemy.y - self.char_y)) then
			return v
		end
	end
end

return Caveman
