local Char1 = require('./src/cards/char1')
local Char2 = require('./src/cards/char2')
local Char3 = require('./src/cards/char3')
local Char4 = require('./src/cards/char4')
local Char5 = require('./src/cards/char5')
local Char6 = require('./src/cards/char6')
local Char7 = require('./src/cards/char7')
local Char8 = require('./src/cards/char8')

local Layout = require('./src/helpers/layout')

local Constants = require('./src/constants')

local Utils = require('./src/helpers/utils')

local card1 = Char1
local card2 = Char2
local card3 = Char3
local card4 = Char4
local card5 = Char5
local card6 = Char6
local card7 = Char7
local card8 = Char8

local deck_selected = ''

local Deck = {
	-- the default number of cards selectable to play
	selectable_cards = 4,

	queue_next_cards = {},

	-- TODO: should store decks on DB
	deck1 = {
		card1,
		card2,
		card3,
		card4,
		card5,
		-- card6,
		-- card7,
		-- card8
	},

	deck2 = {
		card1
	}
}

local DeckMetatable = {
	__call = function(self)
		-- TODO: randomize cards
		-- TODO: get the deck choosen by user for the current match
		self.deck_selected = Constants.LOGGED_USER.deck_selected

		if #self[self.deck_selected] > self.selectable_cards then
			-- if more than 4 cards, should rotate cards

			-- get the cards left from deck and make unselectable
			-- and add to queue
			for i = self.selectable_cards + 1, #self[self.deck_selected] do
				self[self.deck_selected][i].selectable = false
				table.insert(self.queue_next_cards, self[self.deck_selected][i])
			end

			self.queue_next_cards[1].preview_card = true
		end
	end
}

function Deck:update(dt)
	local deck = self[self.deck_selected]
	self:define_positions(deck)
end

function Deck:define_positions(deck)
	local position = Layout:down_right(card1.card_img:getWidth(), card1.card_img:getHeight())
	local default_height_card = position.height - 25

	-- assign default positions
	for i = 1, self.selectable_cards do
		local card = deck[i]

		-- for cases when the deck has less than 4 cards
		if card == nil then return end

		card.x = position.width - (i * 100)
		card.y = default_height_card
	end

	-- default position for preview card
	-- if more than 4 cards, should show the preview card
	if #deck > 4 then
		-- get preview card
		self.queue_next_cards[1].x = position.width
		self.queue_next_cards[1].y = default_height_card + 35

		self.queue_next_cards[1].preview_card = true
	end
end

-- add the just spawned card to the end of the queue_next_cards
-- and the first one in the queue to the deck
function Deck:rotate_deck(card)
	if #self[self.deck_selected] <= 4 then
		return self[self.deck_selected]
	end

	self.queue_next_cards[1].preview_card = false
	self.queue_next_cards[1].selectable = true
	local new_card = self.queue_next_cards[1]

	local new_deck = self[self.deck_selected]

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
	self:define_positions(new_deck)

	return new_deck
end

function Deck:set_queue_next_cards(deck)
	if #deck == 0 then return end

	self.queue_next_cards = {}

	for i = self.selectable_cards + 1, #deck do
		table.insert(self.queue_next_cards, deck[i])
	end

	self.queue_next_cards[1].preview_card = true
end

function Deck:draw()

	local test = Layout:down_right(20,20)

	love.graphics.circle("fill", test.width, test.height, 20)

	-- loop based on selectable_cards because have it's position defined
	for i = 1, self.selectable_cards do
		local card = self[self.deck_selected][i]

		if card == nil then return end

		if card.selected then
			self:highlight_selected_card(card)
		end

		love.graphics.draw(card.card_img, card.x, card.y)

		-- TEST: show card names to see the rotation
		love.graphics.print(card.name, card.x, card.y - 30)

		if card.is_card_loading then
			love.graphics.print(tostring(card.current_cooldown), card.x + 12, card.y + 25, 0, 1.2)
		end
	end
	if #self.queue_next_cards > 0 then
		self:draw_preview_card()
	end
end

function Deck:draw_preview_card()
	love.graphics.draw(self.queue_next_cards[1].card_img, self.queue_next_cards[1].x, self.queue_next_cards[1].y, 0, 0.65, 0.65)

	-- TEST: show card names to see the rotation
	love.graphics.print(self.queue_next_cards[1].name, self.queue_next_cards[1].x, self.queue_next_cards[1].y - 30)
end

function Deck:highlight_selected_card(card)
	love.graphics.setColor(1,1,0)
	love.graphics.rectangle("fill", card.x - 2, card.y - 2, card.card_img:getWidth() + 4, card.card_img:getHeight() + 4)
	love.graphics.setColor(1,1,1)
end

setmetatable(Deck, DeckMetatable)

return Deck
