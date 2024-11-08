local https = require('https')
local json = require('lib.json')
local BaseApi = require('src.api.base')
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

	local url_signin = BaseApi:get_resource_url('auth') .. '/signin/'

	local _,response = https.request(url_signin, {
		data = body,
		method = 'POST',
		headers = headers
	})

	return json.decode(response)
end

function UserApi:signup(username, email, password)
	local body = json.encode({
		username = username,
		email = email,
		password = password
	})

	local headers = {
		['Content-Type'] = 'application/json',
		['Content-Lenght'] = #body
	}

	local url_signup = BaseApi:get_resource_url('auth') .. '/signup/'

	local _, response = https.request(url_signup, {
		data = body,
		method = 'POST',
		headers = headers
	})

	if response == '' then
		return { success = true }
	end

	return json.decode(response)
end

--[[
	return the user data
]]
function UserApi:get()
	local url = BaseApi:get_resource_url('user') .. '/current/'

	local _,response = https.request(url, {
		method = 'GET',
		headers = { authorization = 'Bearer '..Constants.ACCESS_TOKEN }
	})

	return json.decode(response)
end

function UserApi:add_friend(username)
	local url = BaseApi:get_resource_url('user') .. '/add_friend/'

	local body = json.encode({ username = username })

	local headers = {
		authorization = 'Bearer '..Constants.ACCESS_TOKEN,
		['Content-Type'] = 'application/json',
		['Content-Lenght'] = #body
	}

	local status, response = https.request(url, {
		method = 'POST',
		headers = headers,
		data = body
	})

	if response == '' then
		return BaseApi:Response(status, nil, status == 200 or status == 201)
	end

	return BaseApi:Response(
		status,
		response == '' and nil or json.decode(response),
		status == 200 or status == 201
	)
end

return UserApi
