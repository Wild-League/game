local Card = {}

-- TODO: bring all common functions of card here

function Card:get_nearest_enemy(around)
	-- shoot.x = Char1.char_x
	-- shoot.y = Char1.char_y

	-- for _,v in pairs(around) do
	-- 	local distance_x = v.x - Char1.char_x
	-- 	local distance_y = v.y - Char1.char_y

	-- 	if (distance_x >= (nearest_enemy.x - Char1.char_x))
	-- 		and (distance_y >= (nearest_enemy.y - Char1.char_y)) then
	-- 		return v
	-- 	end
	-- end
end

function Card:lifebar(x,y)
	love.graphics.setColor(255/255,29/255,29/255)
	love.graphics.rectangle("line", x - 10, y - 10, 50, 5)
	love.graphics.rectangle("fill", x - 10, y - 10, 50, 5)
	love.graphics.setColor(255,255,255)
end

function Card:show_name(x, y)
	love.graphics.print(self.name, x, y + 30)
end

local CardMetatable = {
	__call = function(self)
		print(self)	 -- ....
	end
}

setmetatable(Card, CardMetatable)

return Card
