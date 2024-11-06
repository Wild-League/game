local https = require('https')
local json = require('lib.json')
local RoutesApi = require('src.api.routes')

local ActivityPubApi = {}

function ActivityPubApi:add_friend(username)
	local _, response = https.request(RoutesApi.deck..'/'..deck_id, {
		method = 'GET'
	})
end

return ActivityPubApi
