local https = require('https')
local json = require('lib.json')
local Routes = require('src.api.routes')

local Instance = {}

--[[
	returns whether is valid or not
]]
function Instance:validate(url)
	local body = json.encode({
		url = url
	})

	local headers = {
		['Content-Type'] = 'application/json',
		['Content-Lenght'] = string.len(body)
	}

	local _,response = https.request(Routes.nodeinfo..'/validate', {
		data = body,
		method = 'POST',
		headers = headers
	})

	return json.decode(response)
end

return Instance
