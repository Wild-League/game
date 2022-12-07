local Char1 = require('./src/cards/char1')
local Char2 = require('./src/cards/char2')
local Char3 = require('./src/cards/char3')
local Char4 = require('./src/cards/char4')
local Char5 = require('./src/cards/char5')
local Char6 = require('./src/cards/char6')

local Layout = require('./src/helpers/layout')

local Constants = require('./src/constants')

local Utils = require('./src/helpers/utils')

local card1 = Char1
local card2 = Char2
local card3 = Char3
local card4 = Char4
local card5 = Char5
local card6 = Char6

local center = Layout:Center(card1.card_img:getWidth(),card1.card_img:getHeight())
local default_height_card = center.height + 300

local Deck = {
	__call = function(self)
		-- TODO: randomize cards
		local user = Constants.LOGGED_USER
		if #self[user.deck_selected] > self.num_cards then
			-- self:set_queue_next_cards(self[user.deck_selected])
			for i = self.num_cards + 1, #self[user.deck_selected] do
				table.insert(self.queue_next_cards, self[user.deck_selected][i])
			end

			self.queue_next_cards[1].preview_card = true
		end
	end,

	-- the default number of cards
	-- selectable to play
	num_cards = 4,

	queue_next_cards = {},
	positions = {
		card1 = {
			x = center.width,
			y = default_height_card
		},
		card2 = {
			x = center.width + 100,
			y = default_height_card
		},
		card3 = {
			x = center.width + 200,
			y = default_height_card
		},
		card4 = {
			x = center.width + 300,
			y = default_height_card
		},
		-- not selectable
		preview_card = {
			x = center.width - 70,
			y = default_height_card + 25
		}
	},
	deck1 = {
		card1,
		card2,
		card3,
		card4,
		card5
		-- card6
	}
}

function Deck:define_positions()
	local user = Constants.LOGGED_USER

	local deck = self[user.deck_selected]

	for i = 1, #deck do
		local card = deck[i]

		local pos = self.positions['card'..i]

		if pos ~= nil then
			card.x = pos.x
			card.y = pos.y
		end
	end

	if #deck > 4 then
		local pos = self.positions['preview_card']

		-- get preview card
		self.queue_next_cards[1].x = pos.x
		self.queue_next_cards[1].y = pos.y

		self.queue_next_cards[1].preview_card = true
	end
end

-- add the just spawned card to the end of the queue_next_cards
-- and the first one in the queue to the deck
function Deck:rotate_deck(card)
	self.queue_next_cards[1].preview_card = false
	local new_card = self.queue_next_cards[1]

	local user = Constants.LOGGED_USER

	local new_deck = Deck[user.deck_selected]

	for i = 1, #new_deck - 1 do
		local curr_card = new_deck[i]
		local next_card = new_deck[i + 1]

		if curr_card.name == card.name then
			new_deck[i] = new_card
		end

		if next_card.name == new_card.name then
			new_deck[i + 1] = card
		end
	end

	Deck:set_queue_next_cards(new_deck)
end

function Deck:set_queue_next_cards(deck)
	if #deck == 0 then return end

	self.queue_next_cards = {}

	for i = self.num_cards + 1, #deck do
		table.insert(self.queue_next_cards, deck[i])
	end

	self.queue_next_cards[1].preview_card = true
end

setmetatable(Deck, Deck)

return Deck
