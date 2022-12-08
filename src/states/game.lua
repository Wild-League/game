local Suit = require('./lib/suit')
local Layout = require('./src/helpers/layout')

local Assets = require('./src/assets')
local Constants = require('./src/constants')

local Utils = require('./src/helpers/utils')
local Map = require('./src/domain/map')

local Deck = require('./src/entities/deck')

local timer = 0

local Game = {
	user = {},
	decks = {},
	deck_selected = '',
	deck = {},
	background = Assets.WORLD,
	spawned = {}
}

-- used for message_timer
local should_message = false
local message = ''

local center = Layout:Center(20, 20)

local new_font = love.graphics.newFont(20, 'mono')

-- store the current selected card
-- used to block selecting more than one card at time
-- also used to show the preview char
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

setmetatable(Game, Game)

function Game:load()
	-- setup the deck
	Deck()

	Game.user = Constants.LOGGED_USER

	Game.deck_selected = Game.user.deck_selected

	Game.deck = Deck[Game.deck_selected]

	Deck:define_positions(Game.deck)
end

function Game:update(dt)
	Game:timer(dt)

	Game:check_cooldown(dt)

	Game:message_timer(dt)

	-- TODO: implement function to show player details
	-- nickname, level
	-- Suit.Label(Game.user.nickname, { align='center', font = new_font}, 10, 680, 200, 30)
	-- Suit.Label('lv. '..Game.user.level, { align='center', font = new_font  }, 10, 695, 200, 30)

	if CARD_SELECTED ~= nil then
		local x,y = love.mouse.getPosition()
		CARD_SELECTED.char_x = x
		CARD_SELECTED.char_y = y
	end

	for _,card in pairs(Game.spawned) do
		if ALL_OBJECTS[card.name] == nil then
			ALL_OBJECTS[card.name] = card
		end

		card.animate.update(card, dt)

		for _,value in pairs(ALL_OBJECTS) do
			if Utils.circle_rect_collision(card.char_x + (card.img:getWidth() / 4), card.char_y + (card.img:getHeight() / 4), card.attack_range,
			value.x, value.y, value.width, value.height) then
				card.chars_around.key = value
				card.current_action = 'attack'
				break
			end

			if Utils.circle_rect_collision(card.char_x + (card.img:getWidth() / 4), card.char_y + (card.img:getHeight() / 4),
					card:perception_range(), value.x, value.y, value.width, value.height) then
				card.chars_around.key = value
				card.current_action = 'follow'
			end
		end
	end
end

function Game:draw()
	-- world background
	local sx = love.graphics.getWidth() / Game.background:getWidth()
	local sy = love.graphics.getHeight() / Game.background:getHeight()
	for i = 0, Constants.WINDOW_SETTINGS.width / Game.background:getWidth() do
		for j = 0, Constants.WINDOW_SETTINGS.height / Game.background:getHeight() do
			love.graphics.draw(Game.background, i * Game.background:getWidth(), j * Game.background:getHeight(), 0, sx, sy)
		end
	end

	-- TEST: fake char to be attacked
	-- should remove after tests
	love.graphics.rectangle("fill", center.width, center.height, 20, 20)

	-- when card is selected
	if CARD_SELECTED ~= nil then
		Map:block_left_side()

		-- <= because it's from right -> left
		if CARD_SELECTED.char_x <= Map.left_side.w then
			CARD_SELECTED.char_x = Map.left_side.w
		end

		Game:preview_char(CARD_SELECTED, CARD_SELECTED.char_x, CARD_SELECTED.char_y)
	end

	Deck:draw()

	-- draw the preview card
	if #Deck.queue_next_cards > 0 then
		love.graphics.draw(Deck.queue_next_cards[1].card_img, Deck.queue_next_cards[1].x, Deck.queue_next_cards[1].y, 0, 0.65, 0.65)

		-- TEST: show card names to see the rotation
		love.graphics.print(Deck.queue_next_cards[1].name, Deck.queue_next_cards[1].x, Deck.queue_next_cards[1].y - 30)
	end

	-- draw spawned cards
	for _,card in pairs(Game.spawned) do
		card.char_x, card.char_y = card.animate.draw(card, card.char_x, card.char_y)
	end
end

-- shows the time passed in the game
function Game:timer(dt)
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

-- used for check cooldown timer each second
local countdown_timer = 1

function Game:check_cooldown(dt)
	countdown_timer = countdown_timer - dt

	if countdown_timer <= 0 then
		countdown_timer = countdown_timer + 1

		for i = 1, #Game.deck do
			local card = Game.deck[i]
			if card.is_card_loading then
				card.current_cooldown = card.current_cooldown - 1
				if card.current_cooldown <= 0 then
					card.is_card_loading = false
				end
			end
		end
	end
end

local countdown_message = 5
-- TODO: create class for messages like this
function Game:message_timer(dt)
	countdown_message = countdown_message - dt

	if should_message then
		Suit.Label(message, {align='center',font=new_font},100,25,100,200)
		if countdown_message <= 0 then
			countdown_message = countdown_message + 5
			should_message = false
		end
	end
end

function Game:preview_char(card,x,y)
	-- attack range
	love.graphics.ellipse("line", x + (card.img:getWidth() / 4), y + (card.img:getHeight() / 4), card.attack_range, card.attack_range)
	-- perception range
	love.graphics.ellipse("line", x + (card.img:getWidth() / 4), y + (card.img:getHeight() / 4), card:perception_range(), card:perception_range())

	-- represents the char preview
	love.graphics.setColor(0.2,0.2,0.7,0.5)
	love.graphics.draw(CARD_SELECTED.img, CARD_SELECTED.char_x, CARD_SELECTED.char_y)
	love.graphics.setColor(1,1,1)
end

function Game:unselect_all_cards()
	for i = 1, #Game.deck do
		local card = Game.deck[i]
		card.selected = false
	end
end


-- love functions

function love.mousepressed(x,y,button)
	if button == 1 then
		for _,card in pairs(Game.deck) do
			-- click on card?
			if x >= card.x and x <= (card.x + card.card_img:getWidth())
				and y >= card.y and y <= (card.y + card.card_img:getHeight())
				and card.selectable ~= false then
				if not card.is_card_loading then
					if card.selected then
						CARD_SELECTED = nil
						card.selected = false
					else
						Game:unselect_all_cards()
						CARD_SELECTED = card
						card.selected = true
					end
					break
				end
			else
				-- this is the selected card?
				if card.selected then
					-- click on map?
					if not (x >= card.x and x <= (card.x + card.card_img:getWidth()))
						and not (y >= card.y and y <= (card.y + card.card_img:getHeight())) then

						card.char_x = x
						card.char_y = y

						if CARD_SELECTED.char_x <= Map.left_side.w then
							CARD_SELECTED.char_x = Map.left_side.w
						end

						card.is_card_loading = true

						-- insert a copy, so we can insert the same card more than once.
						-- TIP: you can check the behavior by passing only 'card'.
						table.insert(Game.spawned, Utils.copy_table(card))

						CARD_SELECTED = nil
						card.selected = false

						card.current_cooldown = card.cooldown

						Game.deck = Deck:rotate_deck(card)

						break
					end
				end
			end
		end
	end
end

return Game
