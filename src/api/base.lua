local Constants = require('src.constants')
local Env = require('src.helpers.env')
local json = require('lib.json')
local Utils = require('src.helpers.utils')

local function env_str(key, default)
	local v = Env.get(key)
	if v and v ~= '' then
		return v
	end
	return default
end

local function env_int(key, default)
	local v = Env.get(key)
	local n = tonumber(v)
	if n then
		return n
	end
	return default
end

local mode = os.getenv('ENV') or 'dev'
local default_api_env = (mode == 'prod') and 'prod' or 'dev'

local BaseApi = {
	current = env_str('ENV', default_api_env),

	dev = {
		world_api_url = env_str('WORLD_API_URL', 'http://localhost:8000/v1/'),
		multiplayer_server_url = env_str('NAKAMA_HOST', 'localhost'),
		multiplayer_server_port = env_int('NAKAMA_PORT', 7350)
	},

	prod = {
		world_api_url = Constants.WORLD_SERVER_API .. '/v1/',
		multiplayer_server_url = env_str('NAKAMA_HOST', 'localhost'),
		multiplayer_server_port = env_int('NAKAMA_PORT', 7350)
	}
}

function BaseApi:get_resource_url(resource)
	if self.current == 'prod' then
		self[self.current].world_api_url = Constants.WORLD_SERVER_API .. '/v1/'
	end

	local routes = {
		nodeinfo = self[self.current].world_api_url .. 'nodeinfo',
		test = self[self.current].world_api_url .. 'test',
		auth = self[self.current].world_api_url .. 'auth',
		user = self[self.current].world_api_url .. 'users',
		deck = self[self.current].world_api_url .. 'decks',
		cards = self[self.current].world_api_url .. 'cards'
	}

	return routes[resource]
end

function BaseApi:Response(status, body, success)
	return {
		status = status,
		body = body,
		success = success
	}
end

function BaseApi:decode_json_or_nil(response)
	local payload = Utils.trim(response)
	if payload == '' then return nil end

	local first_char = payload:sub(1, 1)
	local is_json = first_char == '{' or first_char == '['
	if not is_json then return nil end

	local ok, decoded = pcall(json.decode, payload)
	if not ok then return nil end
	return decoded
end

return BaseApi
