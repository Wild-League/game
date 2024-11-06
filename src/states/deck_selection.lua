local DeckApi = require('src.api.deck')

local DeckSelection = {}

function DeckSelection:load()
	local decks = DeckApi:get_list()

	print(#decks)

	for _, deck in ipairs(decks) do
		print(deck.name)
	end
end

function DeckSelection:update(dt) end

function DeckSelection:draw() end

return DeckSelection
