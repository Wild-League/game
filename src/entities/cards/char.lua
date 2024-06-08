local Char = {
	current_action = 'walk',
	current_life = 0,

	-- chars_around = {},

	-- nearest_enemy = {
	-- 	char_x = 0,
	-- 	char_y = 0,
	-- 	current_life = 0
	-- },

	animations = {
		walk = {},
		attack = {},
		death = {}
	}
}

-- function Char.handle_chars_around(char, enemy)
-- 	char.chars_around[enemy.key] = enemy
-- 	char.chars_around[enemy.key].key = enemy.key
-- end

-- function Char:load_actions(char)
-- 	char.actions = {
-- 		walk = {
-- 			update = function(dt)
-- 				char.animations['walk']:update(dt)
-- 			end,
-- 			draw = function(x, y, current_life, enemy)
-- 				char:lifebar(x,y, current_life)

-- 				if enemy then
-- 					x = x + char.speed
-- 				else
-- 					x = x - char.speed
-- 				end

-- 				char.animations['walk']:draw(char.img_walk, x, y)
-- 				return x, y
-- 			end
-- 		},
-- 		follow = {
-- 			update = function(dt)
-- 				char.nearest_enemy = char:get_nearest_enemy(char, char.chars_around)

-- 				char.animations['walk']:update(dt)
-- 			end,
-- 			draw = function(x,y, current_life)
-- 				char:lifebar(x,y, current_life)

-- 				local dx = char.nearest_enemy.char_x - x
-- 				local dy = char.nearest_enemy.char_y - y

-- 				local distance = math.sqrt(dx*dx + dy*dy)

-- 				if distance > 1 then
-- 					local angle = math.atan2(dy, dx)
-- 					x = x + char.speed * math.cos(angle)
-- 					y = y + char.speed * math.sin(angle)
-- 				end

-- 				char.animations['walk']:draw(char.img_walk, x, y)
-- 				return x,y
-- 			end
-- 		},
-- 		attack = {
-- 			update = function(dt)
-- 				char.animations['attack']:update(dt)
-- 			end,
-- 			draw = function(x,y, current_life)
-- 				char:lifebar(x,y, current_life)

-- 				char.nearest_enemy = char:get_nearest_enemy(char, char.chars_around)

-- 				char.animations['attack']:draw(char.img_attack,x,y)
-- 				return x,y
-- 			end
-- 		},
-- 		death = {
-- 			update = function(dt)
-- 				char.animations['death']:update(dt)
-- 			end,
-- 			draw = function(x,y, _)
-- 				char.animations['death']:draw(char.img_death,x,y)
-- 				return x,y
-- 			end
-- 		}
-- 	}

-- 	return char
-- end

-- function Char:get_nearest_enemy(char, around)
-- 	for _,v in pairs(around) do
-- 		local distance_x = v.char_x - char.char_x
-- 		local distance_y = v.char_y - char.char_y

-- 		if (distance_x >= (char.nearest_enemy.char_x - char.char_x))
-- 			and (distance_y >= (char.nearest_enemy.char_y - char.char_y)) then
-- 			return v
-- 		end
-- 	end
-- end

function Char:preview(x, y)
	-- -- attack range
	-- love.graphics.ellipse("line", x, y, card.attack_range, card.attack_range)
	-- -- perception range
	-- love.graphics.ellipse("line", x, y, card.perception_range, card.perception_range)

	local center_x = x - self.img_preview:getWidth() / 2
	local center_y = y - self.img_preview:getHeight() / 2

	love.graphics.setColor(0.2,0.2,0.7,0.5)
	love.graphics.draw(self.img_preview, center_x, center_y)
	love.graphics.setColor(1,1,1)
end

function Char:lifebar(x,y, current_life)
	love.graphics.setColor(255/255,29/255,29/255)
	love.graphics.rectangle("line", x - 10, y - 10, self.life, 5)
	love.graphics.rectangle("fill", x - 10, y - 10, current_life, 5)
	love.graphics.setColor(255,255,255)
end

function Char:update(dt)
	self.animations[self.current_action]:update(dt)
end

function Char:draw()
	self.animations[self.current_action]:draw(self['img_'..self.current_action], self.char_x, self.char_y)
end

return Char
