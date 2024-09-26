local https = require('https')
local json = require('lib.json')
local RoutesApi = require('src.api.routes')
local Constants = require('src.constants')

local UserApi = {}

--[[
	try to sign in at domain.com/auth/signin
]]
function UserApi:signin(username, password)
	local body = json.encode({
		username = username,
		password = password
	})

	local headers = {
		['Content-Type'] = 'application/json',
		['Content-Lenght'] = #body
	}

	local _,response = https.request(RoutesApi.auth..'/signin', {
		data = body,
		method = 'POST',
		headers = headers
	})

	return json.decode(response)
end

--[[
	return the user data
]]
function UserApi:get()
	local _,response = https.request(RoutesApi.user..'/current', {
		method = 'GET',
		headers = { authorization = 'Bearer '..Constants.ACCESS_TOKEN }
	})

	return json.decode(response)
end

return UserApi
