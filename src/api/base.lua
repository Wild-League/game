local Constants = require('src.constants')

local BaseApi = {
	current = 'prod',

	dev = {
		world_api_url = 'http://localhost:8000/v1/',
		world_url = 'http://localhost:3000/',
		host_url = 'https://host-api.wildleague.org/v1/',
		multiplayer_server_url = 'localhost',
		multiplayer_server_port = 7350
	},

	prod = {
		world_api_url = Constants.WORLD_SERVER_API .. '/v1/',
		world_url = Constants.WORLD_SERVER,
		host_url = 'https://host-api.wildleague.org/v1/',
		multiplayer_server_url = 'localhost',
		multiplayer_server_port = 7350
	}
}

function BaseApi:get_resource_url(resource)
	if self.current == 'prod' then
		self[self.current].world_api_url = Constants.WORLD_SERVER_API .. '/v1/'
		self[self.current].world_url = Constants.WORLD_SERVER
	end

	local routes = {
		nodeinfo = self[self.current].world_api_url .. 'nodeinfo',
		test = self[self.current].world_api_url .. 'test',
		auth = self[self.current].world_api_url .. 'auth',
		user = self[self.current].world_api_url .. 'users',
		deck = self[self.current].world_api_url .. 'decks',
		host = self[self.current].host_url
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

return BaseApi
