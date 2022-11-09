local Suit = require('./lib/suit')
local Layout = require('./src/helpers/layout')

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
	if button == 1 then
		local deck = In_Game.decks[In_Game.deck_selected]
		if deck ~= nil then
			for i = 1, #deck do
				local card = deck[i]
				if card.can_move == true then
					card.can_move = false

					card.spawned = true

					local initial_position = In_Game.decks.positions['card'..i]
					card.x = initial_position.x
					card.y = initial_position.y

					card.char_x = x
					card.char_y = y
				end
			end
		end
	end
end

function In_Game:load()
	In_Game.user = Constants.LOGGED_USER
	In_Game.decks = In_Game.user.decks

	In_Game.deck_selected = In_Game.user.deck_selected

	In_Game.deck = In_Game.decks[In_Game.deck_selected]

	-- define initial position for all cards
	for i = 1, #In_Game.deck do
		local card = In_Game.deck[i]

		local initial_position = In_Game.decks.positions['card'..i]

		card.x = initial_position.x
		card.y = initial_position.y
	end
end

function In_Game:update(dt)
	local new_font = love.graphics.newFont(20, 'mono')

	Suit.Label(In_Game.user.nickname, { align='center', font = new_font}, 10, 680, 200, 30)
	Suit.Label('lv. '..In_Game.user.level, { align='center', font = new_font  }, 10, 695, 200, 30)

	local x,y = love.mouse.getPosition()

	if love.mouse.isDown(1) then
		for i = 1, #In_Game.deck do
			local card = In_Game.deck[i]
			if x >= card.x and x <= (card.x + card.img:getWidth())
				and y >= card.y and y <= (card.y + card.img:getHeight()) then
					card.can_move = true
			end
		end
	end

	for i = 1, #In_Game.deck do
		local card = In_Game.deck[i]
		if card.can_move then
			card.x = x - (card.img:getWidth() / 2)
			card.y = y - (card.img:getHeight() / 2)
		end

		if card.spawned then
			card.animations.walk.update(dt)
		end
	end
end

function In_Game:draw()
	-- world background
	for i = 0, Constants.WINDOW_SETTINGS.width / In_Game.background:getWidth() do
		for j = 0, Constants.WINDOW_SETTINGS.height / In_Game.background:getHeight() do
			love.graphics.draw(In_Game.background, i * In_Game.background:getWidth(), j * In_Game.background:getHeight())
		end
	end

	for i = 1, #In_Game.deck do
		local card = In_Game.deck[i]
		love.graphics.draw(card.img, card.x, card.y)

		if card.spawned then
			card.animations.walk.draw(card.char_x, card.char_y)
		end
	end

	-- test as a fake char to attacked
	local center = Layout:Centralize(20, 20)
	love.graphics.rectangle("fill", center.width, center.height, 20, 20)
end

local function change_card_by_char() end

return In_Game
