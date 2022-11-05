local Suit = require('./lib/suit')
-- local Layout = require('./src/helpers/layout')

local Assets = require('./src/assets')
local Constants = require('./src/constants')

local In_Game = {
	user = {},
	decks = {},
	deck_selected = '',
	deck = {},
	background = Assets.WORLD
}

setmetatable(In_Game, In_Game)

function love.mousereleased(x, y, button)
	-- if button == 1 then
	-- 	local deck = decks[deck_selected]
	-- 	if deck ~= nil then
	-- 		for i = 1, #deck do
	-- 			local card = deck[i]
	-- 			if card.can_move == true then
	-- 				card.can_move = false
	-- 				card.x = card.initial_position_x
	-- 				card.y = card.initial_position_y
	-- 			end
	-- 		end
	-- 	end
	-- end
end

function In_Game:load()
	In_Game.user = Constants.LOGGED_USER
	In_Game.decks = In_Game.user.decks

	In_Game.deck_selected = In_Game.user.deck_selected

	In_Game.deck = In_Game.decks[In_Game.deck_selected]
end

function In_Game:update()
	local new_font = love.graphics.newFont(20, 'mono')

	Suit.Label(In_Game.user.nickname, { align='center', font = new_font}, 10, 680, 200, 30)
	Suit.Label('lv. '..In_Game.user.level, { align='center', font = new_font  }, 10, 695, 200, 30)
end

function In_Game:draw()
	-- world background
	for i = 0, Constants.WINDOW_SETTINGS.width / In_Game.background:getWidth() do
		for j = 0, Constants.WINDOW_SETTINGS.height / In_Game.background:getHeight() do
			love.graphics.draw(In_Game.background, i * In_Game.background:getWidth(), j * In_Game.background:getHeight())
		end
	end


	local x,y = love.mouse.getPosition()

	-- for i = 1, #deck do
	-- 	local card = deck[i]
	-- 	love.graphics.draw(card.img, card.initial_position_x, card.initial_position_y)
	-- end

	-- if love.mouse.isDown(1) then
	-- 	for i = 1, #deck do
	-- 		local card = deck[i]
	-- 		if x >= card.x and x <= (card.x + card.img:getWidth())
	-- 			and y >= card.y and y <= (card.y + card.img:getHeight()) then
	-- 				card.can_move = true
	-- 		end
	-- 	end
	-- end

	-- for i = 1, #deck do
	-- 	local card = deck[i]
	-- 	if card.can_move then
	-- 		card.x = x - (card.img:getWidth() / 2)
	-- 		card.y = y - (card.img:getHeight() / 2)
	-- 	end
	-- end
end

return In_Game
