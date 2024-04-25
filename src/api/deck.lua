local https = require('https')
local json = require('lib.json')
local Routes = require('src.api.routes')

local Deck = {}

function Deck:get(deck_id)
	local _, response = https.request(Routes.deck..'/'..deck_id, {
		method = 'GET'
	})

	return json.decode(response)
end

return Deck
