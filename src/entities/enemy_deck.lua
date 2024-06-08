local Layout = require('src.helpers.layout')
local Map = require('src.entities.map')
local Card = require('src.entities.card')
local Constants = require('src.constants')
local socket = require('lib.nakama.socket')
local MatchEvents = require('src.config.match_events')
local json = require('lib.json')

local EnemyDeck = {
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

function EnemyDeck:load(deck_selected)
	-- initiliaze cards
	for index, card in ipairs(deck_selected.cards) do
		deck_selected.cards[index] = Card:new(card)
	end

	self.deck_selected = deck_selected.cards

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

function EnemyDeck:update(dt)
	-- related to UI
	self:define_positions()

	self:check_cooldown(dt)
end

function EnemyDeck:draw()
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

function EnemyDeck:define_positions()
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
function EnemyDeck:draw_preview_card()
	love.graphics.draw(self.queue_next_cards[1].img, self.queue_next_cards[1].x, self.queue_next_cards[1].y, 0, 0.65 * self.default_scale, 0.65 * self.default_scale)
end

function EnemyDeck:highlight_selected_card(card)
	love.graphics.setColor(1,0,0)
	love.graphics.rectangle("fill", card.x - 4, card.y - 4, card.img_card:getWidth() + 8, card.img_card:getHeight() + 8)
	love.graphics.setColor(1,1,1)
end

function EnemyDeck:set_queue_next_cards(deck)
	if #deck == 0 then return end

	self.queue_next_cards = {}

	for i = self.selectable_cards + 1, #deck do
		table.insert(self.queue_next_cards, deck[i])
	end

	self.queue_next_cards[1].preview_card = true
end

-- add the just spawned card to the end of the queue_next_cards
-- and the first one in the queue to the deck
function EnemyDeck:rotate_deck(card)
	if #self.deck_selected <= 4 then
		return self.deck_selected
	end

	self.queue_next_cards[1].preview_card = false
	self.queue_next_cards[1].selectable = true
	local new_card = self.queue_next_cards[1]

	local new_deck = self.deck_selected

	for i = 1, #new_deck - 1 do
		local curr_card = new_deck[i]
		local next_card = new_deck[i + 1]

		if curr_card.name == card.name then
			new_deck[i] = new_card
		end

		if next_card ~= nil then
			if next_card.name == new_card.name then
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

function EnemyDeck:check_cooldown(dt)
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

return EnemyDeck
