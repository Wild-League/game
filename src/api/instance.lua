local https = require('https')
local Base = require('src.api.base')

local Instance = {}

function Instance:validate(url)
	local headers = {
		['Content-Type'] = 'application/json'
	}

	local formatted_url = url .. '/.well-known/nodeinfo/'

	local status = https.request(formatted_url, {
		method = 'GET',
		headers = headers
	})

	return Base:Response(status, nil, status == 200)
end

return Instance
