local anim8 = require('lib.anim8')
local Image = require('src.helpers.image')

local Udp = require('src.network.udp')
local Events = require('src.network.events')

local Char = {
	-- some actions may use the same animation. e.g: walk | follow
	possible_animations = {
		'walk',
		'attack',
		'death'
	},
	current_action = 'walk',
	current_life = 0,
	chars_around = {},
	nearest_enemy = {
		char_x = 0,
		char_y = 0,
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
		current_life = life,
		speed = speed,
		attack_range = attack_range,
		perception_range = attack_range * 2,
		frame_width = width,
		frame_height = height,
		actions = {},
		animations = {},
		enemy = enemy
	}

	char = self:load_images(char, enemy)
	char = self:load_animations(char)
	char = self:load_actions(char)

	setmetatable(char, self)
	self.__index = self

	return char
end

function Char.handle_chars_around(enemy)
	Char.chars_around[enemy.key] = enemy
	Char.chars_around[enemy.key].key = enemy.key
end

function Char:load_actions(char)
	char.actions = {
		walk = {
			update = function(dt)
				char.animations['walk']:update(dt)
			end,
			draw = function(x, y, current_life, enemy)
				char:lifebar(x,y, current_life)

				if enemy then
					x = x + char.speed
				else
					x = x - char.speed
				end

				char.animations['walk']:draw(char.img_walk, x, y)
				return x, y
			end
		},
		follow = {
			update = function(dt)
				char.nearest_enemy = char:get_nearest_enemy(char.chars_around)

				char.animations['walk']:update(dt)
			end,
			draw = function(x,y, current_life)
				char:lifebar(x,y, current_life)

				local dx = char.nearest_enemy.char_x - x
				local dy = char.nearest_enemy.char_y - y

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
			draw = function(x,y, current_life)
				char:lifebar(x,y, current_life)

				char.nearest_enemy = char:get_nearest_enemy(char.chars_around)

				char.animations['attack']:draw(char.img_attack,x,y)
				return x,y
			end
		},
		death = {
			update = function(dt)
				char.animations['death']:update(dt)
			end,
			draw = function(x,y, current_life)
				char:lifebar(x,y, current_life)
				char.animations['death']:draw(char.img_death,x,y)
				return x,y
			end
		}
	}

	return char
end

function Char:get_nearest_enemy(around)
	for _,v in pairs(around) do
		local distance_x = v.char_x - self.char_x
		local distance_y = v.char_y - self.char_y

		if (distance_x >= (self.nearest_enemy.char_x - self.char_x))
			and (distance_y >= (self.nearest_enemy.char_y - self.char_y)) then
			return v
		end
	end
end

function Char:load_animations(char)
	for _, value in pairs(self.possible_animations) do
		char.animations[value] = {}

		local number_frames = math.floor(char['img_'..value]:getWidth() / char.frame_width)

		local grid = anim8.newGrid(char.frame_width, char.frame_height, char['img_'..value]:getWidth(), char['img_'..value]:getHeight())

		local animation = {}

		if value == 'attack' then
			animation = anim8.newAnimation(grid('1-'..number_frames, 1), char.speed/10, function()
				if char.nearest_enemy.current_life > 0 then
					char.nearest_enemy.current_life = char.nearest_enemy.current_life - char.damage

					if char.nearest_enemy.type == 'tower' then
						Udp:send({ identifier=char.nearest_enemy.key, event=Events.EnemyTower, obj={
							key = char.nearest_enemy.key,
							current_life = char.nearest_enemy.current_life
						} })
					else
						Udp:send({ identifier=char.nearest_enemy.key, event=Events.EnemyObject, obj={
							key = char.nearest_enemy.key,
							name = char.nearest_enemy.name,
							current_life = char.nearest_enemy.current_life
						} })
					end

				else
					char.nearest_enemy.current_life = 0
				end
			end)
		elseif value == 'death' then
			animation = anim8.newAnimation(grid('1-'..number_frames, 1), char.speed/10, function()
				local Game = require('src.states.game')

				-- why the char does not disappear?
				if char.enemy then
					Game.enemy_objects[tostring(char)] = nil
				else
					Game.my_objects[tostring(char)] = nil
				end

				-- Game.enemy_objects[tostring(char.nearest_enemy)] = nil
			end)
		else
			animation = anim8.newAnimation(grid('1-'..number_frames, 1), char.speed/10)
		end

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

function Char:lifebar(x,y, current_life)
	love.graphics.setColor(255/255,29/255,29/255)
	love.graphics.rectangle("line", x - 10, y - 10, self.life, 5)
	love.graphics.rectangle("fill", x - 10, y - 10, current_life, 5)
	love.graphics.setColor(255,255,255)
end

return Char
