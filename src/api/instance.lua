local https = require('https')
local BaseApi = require('src.api.base')

local InstanceApi = {}

function InstanceApi:validate(url)
	local headers = {
		['Content-Type'] = 'application/json'
	}

	local formatted_url = url .. '/.well-known/nodeinfo/'

	local status = https.request(formatted_url, {
		method = 'GET',
		headers = headers
	})

	return BaseApi:Response(status, nil, status == 200)
end

return InstanceApi
