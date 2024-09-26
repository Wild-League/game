local json = require('lib.json')
local https = require('https')
local BaseApi = require('src.api.base')

local InstanceApi = {}

function InstanceApi:validate(url)
	local headers = {
		['Content-Type'] = 'application/json'
	}

	local formatted_url = url .. '/.well-known/nodeinfo/'

	local status_server, response_server = https.request(formatted_url, {
		method = 'GET',
		headers = headers
	})

	if status_server ~= 200 then
		return BaseApi:Response(status_server, nil, false)
	end

	response_server = json.decode(response_server)

	local nodeinfo_href = response_server.links[1].href

	local status, response = https.request(nodeinfo_href, {
		method = 'GET',
		headers = headers
	})

	response = json.decode(response)

	if status == 200 and response.software.name == 'WildLeague' then
		return BaseApi:Response(status, nil, true)
	end

	return BaseApi:Response(status, nil, false)
end

return InstanceApi
