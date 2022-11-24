local Suit = require('./lib/suit')
local Layout = require('./src/helpers/layout')

local Assets = require('./src/assets')
local Constants = require('./src/constants')

local Utils = require('./src/helpers/utils')
local Map = require('./src/domain/map')

local Deck = require('./src/entities/deck')

local timer = 0

local In_Game = {
	user = {},
	decks = {},
	deck_selected = '',
	deck = {},
	background = Assets.WORLD
}

local center = Layout:Center(20, 20)

local new_font = love.graphics.newFont(20, 'mono')

-- store the current selected card
-- used to block selecting more than one card at time
local CARD_SELECTED = nil

-- have all the objects in the game
-- so we can compare collisions easily
-- (I couln't find another way)
local ALL_OBJECTS = {
	test = {
		x = center.width,
		y = center.height,
		width = 20,
		height = 20
	}
}

setmetatable(In_Game, In_Game)

function love.mousepressed(x,y,button)
	if button == 1 then
		for i = 1, #In_Game.deck do
			local card = In_Game.deck[i]
			if x >= card.x and x <= (card.x + card.card_img:getWidth())
				and y >= card.y and y <= (card.y + card.card_img:getHeight()) then
					if CARD_SELECTED == nil then
						CARD_SELECTED = card
						break
					else
						CARD_SELECTED = nil
						break
					end
			else
				if CARD_SELECTED ~= nil then
					card.char_x = x
					card.char_y = y

					card.spawned = true

					CARD_SELECTED = nil
					card.selected = false

					break

				else
					-- TODO: how to add timer for this message?
					Suit.Label('no card selected!', { align='center', font = new_font}, 100, 25, 100, 200)
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
	In_Game:timer(dt)

	Suit.Label(In_Game.user.nickname, { align='center', font = new_font}, 10, 680, 200, 30)
	Suit.Label('lv. '..In_Game.user.level, { align='center', font = new_font  }, 10, 695, 200, 30)

	local x,y = love.mouse.getPosition()

	-- TODO: change for love function
	-- problem: double click
	-- if love.mouse.isDown(1) then

	-- end

	if CARD_SELECTED ~= nil then
		CARD_SELECTED.char_x = x
		CARD_SELECTED.char_y = y
	end

	for i = 1, #In_Game.deck do
		local card = In_Game.deck[i]
		if card.spawned then
			if ALL_OBJECTS[card.name] == nil then
				ALL_OBJECTS[card.name] = card
			end

			card.animate.update(dt)

			for key, value in pairs(ALL_OBJECTS) do
				if Utils.circle_rect_collision(card.char_x + (card.card_img:getWidth() / 4), card.char_y + (card.card_img:getHeight() / 4), card.attack_range,
				value.x, value.y, value.width, value.height) then
					card.chars_around.key = value
					card.current_action = 'attack'
					return
				end

				if Utils.circle_rect_collision(card.char_x + (card.card_img:getWidth() / 4), card.char_y + (card.card_img:getHeight() / 4),
						card:perception_range(), value.x, value.y, value.width, value.height) then
					card.chars_around.key = value
					card.current_action = 'follow'
				end
			end
		end
	end
end

function In_Game:draw()
	-- world background
	local sx = love.graphics.getWidth() / In_Game.background:getWidth()
	local sy = love.graphics.getHeight() / In_Game.background:getHeight()
	for i = 0, Constants.WINDOW_SETTINGS.width / In_Game.background:getWidth() do
		for j = 0, Constants.WINDOW_SETTINGS.height / In_Game.background:getHeight() do
			love.graphics.draw(In_Game.background, i * In_Game.background:getWidth(), j * In_Game.background:getHeight(), 0, sx, sy)
		end
	end

	-- TEST: fake char to be attacked
	-- should remove after tests
	love.graphics.rectangle("fill", center.width, center.height, 20, 20)

	-- when card is selected
	if CARD_SELECTED ~= nil then
		Map:block_left_side()
		for i = 1, #In_Game.deck do
			local card = In_Game.deck[i]

			if card.selected then
				-- TEST: represent selected card
				love.graphics.rectangle("line", Deck.positions['card'..i].x, Deck.positions['card'..i].y, card.card_img:getWidth(), card.card_img:getHeight())
			end

			-- <= because it's from right -> left
			if card.x <= Map.left_side.w then
				card.x = Map.left_side.w
			end

			love.graphics.setColor(0.2,0.2,0.7,0.5)
			love.graphics.draw(CARD_SELECTED.img, CARD_SELECTED.char_x, CARD_SELECTED.char_y)
			love.graphics.setColor(1,1,1)
		end
	end

	for i = 1, #In_Game.deck do
		local card = In_Game.deck[i]
		love.graphics.draw(card.card_img, card.x, card.y)
		if card.spawned then
			card.char_x, card.char_y = card.animate.draw(card.char_x, card.char_y)
		end
	end
end

function In_Game:timer(dt)
	timer = timer + dt

	local seconds = tostring(math.floor(timer % 60))
	local minutes = tostring(math.floor(timer / 60))

	if tonumber(seconds) <= 9 then
		seconds = '0'..seconds
	end
	if tonumber(minutes) <= 9 then
		minutes = '0'..minutes
	end

	local time = minutes..':'..seconds

	local new_center = Layout:Center(100, 200)

	Suit.Label(time, { align='center', font = new_font}, new_center.width, 10, 100, 200)
end

return In_Game
