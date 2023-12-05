local anim8 = require('lib.anim8')
local Image = require('src.helpers.image')

local Char = {
	-- some actions may use the same animation. e.g: walk | follow
	possible_animations = {
		'walk',
		'attack'
	},
	current_action = 'walk',
	current_life = 0,
	chars_around = {},
	nearest_enemy = {
		x = 0,
		y = 0,
		current_life = 0
	}
}

function Char:new(enemy, name, type, cooldown, damage, life, speed, attack_range, width, height)
	local char = {
		name = name,
		type = type,
		cooldown = cooldown,
		damage = damage,
		life = life,
		speed = speed,
		attack_range = attack_range,
		perception_range = attack_range * 2,
		frame_width = width,
		frame_height = height,
		actions = {},
		animations = {}
	}

	char = self:load_images(char, enemy)
	char = self:load_animations(char)
	char = self:load_actions(char)

	setmetatable(char, self)
	self.__index = self

	return char
end

function Char:load_actions(char)
	char.actions = {
		walk = {
			update = function(dt)
				char.animations['walk']:update(dt)
			end,
			draw = function(x,y)
				x = x - char.speed

				char.animations['walk']:draw(char.img_walk, x,y)
				return x,y
			end
		},
		follow = {
			update = function(dt)
				char.nearest_enemy = char:get_nearest_enemy(char.chars_around)

				char.animations['walk']:update(dt)
			end,
			draw = function(x,y)
				local dx = char.nearest_enemy.x - x
				 local dy = char.nearest_enemy.y - y

				 local distance = math.sqrt(dx*dx + dy*dy)

				 if distance > 1 then
					local angle = math.atan2(dy, dx)
					x = x + char.speed * math.cos(angle)
					y = y + char.speed * math.sin(angle)
				 end

				 char.animations['walk']:draw(char.img_walk, x, y)
				return x,y
			end
		},
		attack = {
			update = function(dt)
				char.animations['attack']:update(dt)
			end,
			draw = function(x,y)
				if char.nearest_enemy.width == nil then
					char.nearest_enemy = char:get_nearest_enemy(char.chars_around)
				end

				char.animations['attack']:draw(char.img_attack,x,y)
				return x,y
			end
		}
	}

	return char
end

function Char:get_nearest_enemy(around)
	for _,v in pairs(around) do
		local distance_x = v.x - self.char_x
		local distance_y = v.y - self.char_y

		if (distance_x >= (self.nearest_enemy.x - self.char_x))
			and (distance_y >= (self.nearest_enemy.y - self.char_y)) then
			return v
		end
	end
end

function Char:load_animations(char)
	for _, value in pairs(self.possible_animations) do
		char.animations[value] = {}

		local number_frames = math.floor(char['img_'..value]:getWidth() / char.frame_width)

		local grid = anim8.newGrid(char.frame_width, char.frame_height, char['img_'..value]:getWidth(), char['img_'..value]:getHeight())
		local animation = anim8.newAnimation(grid('1-'..number_frames, 1), char.speed/10)

		char.animations[value] = animation
	end

	return char
end

function Char:load_images(card, enemy)
	local name = card.name

	local side = enemy and 'right' or 'left'

	card.img = Image:load_from_url('http://localhost:9000/cards/'.. string.lower(name) ..'/card.png', name..'.png')
	card.img_preview = Image:load_from_url('http://localhost:9000/cards/'.. string.lower(name) ..'/preview.png', name..'.png')
	card.img_attack = Image:load_from_url('http://localhost:9000/cards/'.. string.lower(name) ..'/attack-'..side..'.png', name..'.png')
	card.img_death = Image:load_from_url('http://localhost:9000/cards/'.. string.lower(name) ..'/death-'..side..'.png', name..'.png')
	card.img_walk = Image:load_from_url('http://localhost:9000/cards/'.. string.lower(name) ..'/walk-'..side..'.png', name..'.png')

	return card
end

return Char
