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
		['Content-Length'] = #body
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
		['Content-Length'] = #body
	}

	local url_signup = BaseApi:get_resource_url('auth') .. '/signup/'

	local status, response = https.request(url_signup, {
		data = body,
		method = 'POST',
		headers = headers
	})

	-- Backend: 201 Created with empty body on success (see AuthModelViewSet.signup)
	if status == 201 or status == 200 then
		return { success = true }
	end

	if response == nil or response == '' then
		return {
			success = false,
			status = status,
			detail = 'Signup failed (HTTP ' .. tostring(status) .. ').',
		}
	end

	local ok, decoded = pcall(json.decode, response)
	if not ok or decoded == nil or type(decoded) ~= 'table' then
		return {
			success = false,
			status = status,
			detail = 'Unable to read server response.',
		}
	end

	local result = { success = false, status = status }
	for key, value in pairs(decoded) do
		result[key] = value
	end
	return result
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
		['Content-Length'] = #body
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

function UserApi:get_friends()
	local url = BaseApi:get_resource_url('user') .. '/get_friends/'

	local _, response = https.request(url, {
		method = 'GET',
		headers = { authorization = 'Bearer '..Constants.ACCESS_TOKEN }
	})

	return json.decode(response)
end

function UserApi:accept_friend_request(friend_request_id)
	local url = BaseApi:get_resource_url('user') .. '/accept_friend_request/'

	local body = json.encode({ friend_request_id = friend_request_id })

	local headers = {
		authorization = 'Bearer '..Constants.ACCESS_TOKEN,
		['Content-Type'] = 'application/json',
		['Content-Length'] = #body
	}

	local _ = https.request(url, {
		method = 'POST',
		headers = headers,
		data = body
	})

	return nil
end

function UserApi:reject_friend_request(friend_request_id)
	local url = BaseApi:get_resource_url('user') .. '/reject_friend_request/'

	local body = json.encode({ friend_request_id = friend_request_id })

	local headers = {
		authorization = 'Bearer '..Constants.ACCESS_TOKEN,
		['Content-Type'] = 'application/json',
		['Content-Length'] = #body
	}

	local _ = https.request(url, {
		method = 'POST',
		headers = headers,
		data = body
	})

	return nil
end

function UserApi:get_me()
	local url = BaseApi:get_resource_url('user') .. '/me/'

	local _, response = https.request(url, {
		method = 'GET',
		headers = { authorization = 'Bearer '..Constants.ACCESS_TOKEN }
	})

	return json.decode(response)
end

return UserApi
