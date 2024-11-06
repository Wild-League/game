local https = require('https')
local json = require('lib.json')
local BaseApi = require('src.api.base')

local HostApi = {}

function HostApi:get_worlds()
	local headers = {
		['Content-Type'] = 'application/json'
	}

	local url = BaseApi:get_resource_url('host') .. 'worlds'

	local status, response = https.request(url, {
		method = 'GET',
		headers = headers
	})

	local worlds = json.decode(response)
	return BaseApi:Response(status, worlds, status == 200)
end

return HostApi
