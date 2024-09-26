local https = require('https')
local json = require('lib.json')
local RoutesApi = require('src.api.routes')

local DeckApi = {}

function DeckApi:get(deck_id)
	local _, response = https.request(RoutesApi.deck..'/'..deck_id, {
		method = 'GET'
	})

	return json.decode(response)
end

return DeckApi
