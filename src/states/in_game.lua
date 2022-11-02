local Suit = require('./lib/suit')
-- local Layout = require('./src/helpers/layout')

local Assets = require('./src/assets')
local Constants = require('./src/constants')

local user = {}

local decks = {}
local deck_selected = ''

local background = Assets.WORLD

local In_Game = {
	__call = function(self)
		self:load()
		self:draw()
	end
}

setmetatable(In_Game, In_Game)

-- function love.mousepressed(x, y, button)
-- 	if button == 1 then -- left
-- 		local deck = decks[deck_selected]
-- 		if deck ~= nil then
-- 			print('deck', deck)
-- 			for i = 1, #deck do
-- 				local card = deck[i]
-- 				if x >= card.x and x <= (card.x + card.img:getWidth())
-- 					and y >= card.y and y <= (card.y + card.img:getHeight()) then
-- 						card.can_move = true
-- 				end
-- 			end
-- 		end
-- 	end
-- end

function love.mousereleased(x, y, button)
	if button == 1 then
		local deck = decks[deck_selected]
		if deck ~= nil then
			for i = 1, #deck do
				local card = deck[i]
				if card.can_move == true then
					card.can_move = false
					-- card.x = card.initial_position.x
					-- card.y = card.initial_position.y
				end
			end
		end
	end
end

function In_Game:load()
	user = Constants.LOGGED_USER

	local new_font = love.graphics.newFont(16, 'mono')

	Suit.Label(Constants.LOGGED_USER.nickname, { align='center', font = new_font}, 10, 680, 200, 30)
	Suit.Label('lv. '..Constants.LOGGED_USER.level, { align='center', font = new_font  }, 10, 695, 200, 30)

	-- draw world background
	for i = 0, Constants.WINDOW_SETTINGS.width / background:getWidth() do
		love.graphics.setColor(255,255,255)
		for j = 0, Constants.WINDOW_SETTINGS.height / background:getHeight() do
			love.graphics.draw(background, i * background:getWidth(), j * background:getHeight())
		end
	end

	decks = user.decks
	deck_selected = user.deck_selected

	local deck = decks[deck_selected]

	for i = 1, #deck do
		local card = deck[i]
		love.graphics.draw(card.img, card.x + ((i - 1) * 100), card.y)
	end

	-- draw separator
	-- love.graphics.setColor(255, 0, 0)
	-- love.graphics.line(center.width, center.height, center.width, center.height + 300)
end

function In_Game:draw()
	local x,y = love.mouse.getPosition()

	local deck = decks[deck_selected]

	-- TODO: fix move card individually
	-- all the cards are using the same memory address
	-- deep copy without the memory address
	if love.mouse.isDown(1) then
		for i = 1, #deck do
			local card = deck[i]
			if x >= card.x and x <= (card.x + card.img:getWidth())
				and y >= card.y and y <= (card.y + card.img:getHeight()) then
					card.can_move = true
			end
		end
	end

	for i = 1, #deck do
		local card = deck[i]
		if card.can_move then
			card.x = x - (card.img:getWidth() / 2)
			card.y = y - (card.img:getHeight() / 2)
		end
	end
end

return In_Game
