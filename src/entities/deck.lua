local Char1 = require('./src/cards/char1')
local Char2 = require('./src/cards/char2')
local Char3 = require('./src/cards/char3')
local Char4 = require('./src/cards/char4')
local Char5 = require('./src/cards/char5')
local Char6 = require('./src/cards/char6')

local Layout = require('./src/helpers/layout')

local Constants = require('./src/constants')

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
		-- TODO: remove magic number (4)
		local user = Constants.LOGGED_USER

		if #self[user.deck_selected] > 4 then
			for i = 5, #self[user.deck_selected] do
				table.insert(self.queue_next_cards, self[user.deck_selected][i])
			end
		end
	end,

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
		card5,
		card6
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

setmetatable(Deck, Deck)

return Deck
