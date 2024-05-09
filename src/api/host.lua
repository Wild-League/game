local https = require('https')
local json = require('lib.json')
local Base = require('src.api.base')

local Host = {}

function Host:get_worlds()
	local headers = {
		['Content-Type'] = 'application/json'
	}

	local url = Base[Base.current].host_url .. 'worlds'

	local status, response = https.request(url, {
		method = 'GET',
		headers = headers
	})

	local worlds = json.decode(response)
	return Base:Response(status, worlds, status == 200)
end

return Host
