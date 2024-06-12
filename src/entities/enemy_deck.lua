local Card = require('src.entities.card')

local EnemyDeck = {
	deck = {}
}

function EnemyDeck:load(deck_selected)
	-- initiliaze cards
	for index, card in ipairs(deck_selected.cards) do
		local is_enemy = true
		deck_selected.cards[index] = Card:new(card, is_enemy)
	end

	self.deck = deck_selected.cards
end

return EnemyDeck
