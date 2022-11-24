local Char1 = require('./src/cards/char1')
local Char2 = require('./src/cards/char2')
local Char3 = require('./src/cards/char3')
local Char4 = require('./src/cards/char4')

local Layout = require('./src/helpers/layout')

local card1 = Char1
local card2 = Char2
local card3 = Char3
local card4 = Char4

local center = Layout:Center(card1.card_img:getWidth(),card1.card_img:getHeight())

local Deck = {
	positions = {
		card1 = {
			x = center.width,
			y = center.height + 300
		},
		card2 = {
			x = center.width + 100,
			y = center.height + 300
		},
		card3 = {
			x = center.width + 200,
			y = center.height + 300
		},
		card4 = {
			x = center.width + 300,
			y = center.height + 300
		}
	},
	deck1 = {
		card1,
		card2,
		card3,
		card4
	}
}

return Deck
