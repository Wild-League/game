local Suit = require('./lib/suit')
local Layout = require('./src/helpers/layout')

local Assets = require('./src/assets')
local Constants = require('./src/constants')

local Utils = require('./src/helpers/utils')
local Map = require('./src/entities/map')

local Deck = require('./src/entities/deck')
local Tower = require('./src/entities/tower')

local Udp = require('./src/network/udp')
local Events = require('./src/network/events')

local timer = 0

local Game = {
	user = {},
	decks = {},
	deck_selected = '',
	deck = {},
	background = Assets.WORLD,

	udp_co = {}
}

-- used for message_timer
local should_message = false
local message = ''

local new_font = love.graphics.newFont(20, 'mono')

-- store the current selected card
-- used to block selecting more than one card at time
-- also used to show the preview char
local CARD_SELECTED = nil

--[[
	have all the objects in the game
	so we can compare collisions easily
	(I couln't find another way to implement it)

	type = character | building | spells
]]
local my_objects = {
	-- { x = 100, y = 100 }
}

local enemy_objects = {}

setmetatable(Game, Game)

function Game:load()
	-- setup the deck
	Deck()

	Game.user = Constants.LOGGED_USER

	Game.deck_selected = Game.user.deck_selected

	Game.deck = Deck[Game.deck_selected]

	Deck:define_positions(Game.deck)
end

function Game:handle_received_data()
	local data = Udp:receive_data()
	if data then
		if data.event == Events.Object then
			enemy_objects[data.identifier] = data.obj
		end
	end

	return data
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

	for _,value in pairs(my_objects) do
		value.animate.update(value, dt)

		Udp:send({ identifier=value.name, event=Events.Object, obj={ x=value.char_x, y=value.char_y} })

		for _,enemy in pairs(enemy_objects) do
			if Utils.circle_rect_collision(value.char_x + (value.img:getWidth() / 4), value.char_y + (value.img:getHeight() / 4), value.attack_range,
				enemy.x, enemy.y, 100, 100) then
					value.chars_around.key = value
					value.current_action = 'attack'
					break
			end

			if Utils.circle_rect_collision(value.char_x + (value.img:getWidth() / 4), value.char_y + (value.img:getHeight() / 4),
				value:perception_range(), enemy.x, enemy.y, 100, 100) then
				value.chars_around.key = value
				value.current_action = 'follow'
			end
		end
	end

	repeat
		local data = self:handle_received_data()
	until not data
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
	-- love.graphics.rectangle("fill", 100, 100, 20, 20)

	-- when card is selected
	if CARD_SELECTED ~= nil then
		Map:block_left_side()

		-- because the char is walking from right -> left (by now)
		if CARD_SELECTED.char_x <= Map.left_side.w then
			CARD_SELECTED.char_x = Map.left_side.w
		end

		Game:preview_char(CARD_SELECTED, CARD_SELECTED.char_x, CARD_SELECTED.char_y)
	end

	-- # tower
	-- Tower:draw()

	-- # deck
	Deck:draw()
	Deck:draw_preview_card()

	-- # draw map center building
	-- Map:center_building()

	-- draw all objects
	for _,card in pairs(my_objects) do
		card.char_x, card.char_y = card.animate.draw(card, card.char_x, card.char_y)
		-- if card.type == 'character' then
		-- 	card.char_x, card.char_y = card.animate.draw(card, card.char_x, card.char_y)
		-- end
	end

	for _,enemy in pairs(enemy_objects) do
		-- love.graphics.setColor(1,0,0)
		love.graphics.rectangle('fill', enemy.x, enemy.y, 50, 50)
		-- love.graphics.setColor(1,1,1)
		-- if card.type == 'character' then
			-- card.char_x, card.char_y = card.animate.draw(card, card.char_x, card.char_y)
		-- end
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

	local new_center = Layout:center(100, 200)

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
						table.insert(my_objects, Utils.copy_table(card))

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
