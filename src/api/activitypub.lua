local https = require('https')
local RoutesApi = require('src.api.routes')

local ActivityPubApi = {}

function ActivityPubApi:add_friend(username)
	https.request(RoutesApi.deck..'/'..username, {
		method = 'GET'
	})
end

return ActivityPubApi
