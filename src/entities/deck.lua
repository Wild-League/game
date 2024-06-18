local Layout = require('src.helpers.layout')
local Map = require('src.entities.map')
local Card = require('src.entities.card')
local Constants = require('src.constants')
local socket = require('lib.nakama.socket')
local MatchEvents = require('src.config.match_events')
local Images = require('src.ui.images')
local json = require('lib.json')
local Utils = require('src.helpers.utils')
local uuid = require('lib.uuid')

local Deck = {
	default_scale = 0.2,
	selectable_cards = 4,

	deck_selected = {},

	-- if num cards greather than `selectable_cards`
	queue_next_cards = {},

	-- the 4 cards that the player can select, with animations defined
	playable_cards = {},

	-- only one card can be selected at a time
	card_selected = nil,
}

function Deck:load(deck_selected)
	-- initiliaze cards
	for _, card in ipairs(deck_selected.cards) do
		table.insert(self.deck_selected, Card:new(card))
	end

	-- if greather than `selectable_cards`, should rotate cards
	if #self.deck_selected > self.selectable_cards then

		-- get the cards left from deck and make unselectable
		-- and add to queue
		for i = self.selectable_cards + 1, #self.deck_selected do
			self.deck_selected[i].selectable = false
			table.insert(self.queue_next_cards, self.deck_selected[i])
		end

		self.queue_next_cards[1].preview_card = true
	end
end

function Deck:update(dt)
	-- related to UI
	self:define_positions()

	self:check_cooldown(dt)
end

function Deck:draw_background()
	love.graphics.clear(1,1,1)

	local window_w, window_h = love.graphics.getDimensions()
	local image_w, image_h = 40, 40

	local tiles_x = math.ceil(window_w / image_w)
	local tiles_y = math.ceil(window_h / image_h)

	love.graphics.setScissor(0, window_h - 163, window_w, 163)

	for x = 0, tiles_x - 1 do
		for y = 0, tiles_y - 1 do
			if (x + y) % 2 == 0 then
				love.graphics.setColor(32/255, 32/255, 32/255)
			else
				love.graphics.setColor(48/255, 48/255, 48/255)
			end
			love.graphics.rectangle('fill', x * image_w, y * image_h, image_w, image_h)
			love.graphics.setColor(1, 1, 1)
		end
	end

	love.graphics.setScissor()
end

function Deck:draw()
	self:draw_background()

	if self.card_selected then
		self:highlight_selected_card(self.card_selected)
	end

	for i = 1, self.selectable_cards do
		local card = self.deck_selected[i]

		-- just in case the deck has less than `selectable_cards`
		if card == nil then return end

		love.graphics.draw(card.img_card, card.x, card.y)

		if card.is_card_loading then
			card:draw_loading_animation()
		end
	end

	if #self.queue_next_cards > 0 then
		self:draw_preview_card()
	end
end

function Deck:define_positions()
	-- TODO: remove magical numbers
	local position = Layout:down_right(196, 56)

	-- assign default positions
	for i = 1, self.selectable_cards do
		local card = self.deck_selected[i]

		-- for cases when the deck has less than 4 cards
		if card == nil then return end

		card.x = position.width - (i * 200)
		card.y = position.height - 50 -- padding
	end

	-- default position for preview card
	-- if more than 4 cards, should show the preview card
	if #self.deck_selected > 4 then
		-- get preview card
		self.queue_next_cards[1].x = position.width
		self.queue_next_cards[1].y = position.height + 35

		self.queue_next_cards[1].preview_card = true
	end
end

-- the next card on queue
function Deck:draw_preview_card()
	love.graphics.draw(self.queue_next_cards[1].img_card, self.queue_next_cards[1].x, self.queue_next_cards[1].y, 0, 0.65 * self.default_scale, 0.65 * self.default_scale)
end

function Deck:highlight_selected_card(card)
	love.graphics.setColor(1,0,0)
	love.graphics.rectangle("fill", card.x - 4, card.y - 4, card.img_card:getWidth() + 8, card.img_card:getHeight() + 8)
	love.graphics.setColor(1,1,1)
end

function Deck:set_queue_next_cards(deck)
	if #deck == 0 then return end

	self.queue_next_cards = {}

	for i = self.selectable_cards + 1, #deck do
		table.insert(self.queue_next_cards, deck[i])
	end

	self.queue_next_cards[1].preview_card = true
end

-- add the just spawned card to the end of the queue_next_cards
-- and the first one in the queue to the deck
function Deck:rotate_deck(card)
	if #self.deck_selected <= 4 then
		return self.deck_selected
	end

	self.queue_next_cards[1].preview_card = false
	self.queue_next_cards[1].selectable = true

	local card_to_add = self.queue_next_cards[1]

	local new_deck = self.deck_selected

	for i = 1, #new_deck - 1 do
		local curr_card = new_deck[i]
		local next_card = new_deck[i + 1]

		if curr_card.name == card.name then
			new_deck[i] = card_to_add
		end

		if next_card ~= nil then
			if next_card.name == card_to_add.name then
				table.remove(new_deck, i + 1)
			end
		end
	end

	new_deck[#new_deck + 1] = card

	self:set_queue_next_cards(new_deck)
	self:define_positions()

	return new_deck
end

-- used for check cooldown timer each second
-- local countdown_timer = 1

function Deck:check_cooldown(dt)
	for i = 1, #self.deck_selected do
		local card = self.deck_selected[i]
		if card.is_card_loading then
			card.current_cooldown = card.current_cooldown - dt
			if card.current_cooldown <= 0 then
				card.is_card_loading = false
				card.current_cooldown = card.cooldown
			end
		end
	end
end

function love.mousepressed(x, y, button)
	-- That's a global function, thats why we need to check the context
	-- TODO: find a better way to do that
	if CONTEXT.current ~= 'game' then return end

	-- right click
	if button ~= 1 then return end

	for _, card in pairs(Deck.deck_selected) do
		-- click on card?
		if (
			x >= card.x and x <= (card.x + card.img_card:getWidth())
			and y >= card.y and y <= (card.y + card.img_card:getHeight())
		) then
			if not card.is_card_loading then
				if Deck.card_selected == card then
					Deck.card_selected = nil
				else
					Deck.card_selected = card
				end
				break
			end
		else
			-- this is the selected card?
			if Deck.card_selected == card then
				-- click on map?
				if not (x >= card.x and x <= (card.x + card.img_card:getWidth()))
					and not (y >= card.y and y <= (card.y + card.img_card:getHeight())) then

					card.char_x = x
					card.char_y = y

					-- map limit
					if card.char_x <= Map.left_side.w then
						card.char_x = Map.left_side.w
					end

					card.is_card_loading = true
					card:reset_cooldown()

					local payload_card = {
						card_id = uuid:generate(),
						card_name = card.name,
						x = card.char_x,
						y = card.char_y,
						action = card.current_action
					}

					local Game = require('src.states.game')
					card.card_id = payload_card.card_id
					Game.cards[Constants.USER_ID][payload_card.card_id] = Utils.copy_table(card)

					coroutine.resume(coroutine.create(function()
						socket.match_data_send(
							Constants.SOCKET_CONNECTION,
							Constants.MATCH_ID,
							MatchEvents.spawn_card,
							json.encode(payload_card),
							nil
						)
					end))

					Deck.card_selected = nil
					Deck.deck_selected = Deck:rotate_deck(card)

					break
				end
			end
		end
	end
end

return Deck
