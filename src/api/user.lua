local https = require('https')
local json = require('lib.json')
local Routes = require('src.api.routes')

local User = {}

--[[
	try to sign in at domain.com/auth/signin
]]
function User:signin(username, password)
	local body = json.encode({
		username = username,
		password = password
	})

	local headers = {
		['Content-Type'] = 'application/json',
		['Content-Lenght'] = #body
	}

	local _,response = https.request(Routes.auth..'/signin', {
		data = body,
		method = 'POST',
		headers = headers
	})

	return json.decode(response)
end

--[[
	return the user data
]]
function User:get()
end

return User
