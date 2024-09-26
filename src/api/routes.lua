local BaseApi = require('src.api.base')

local RoutesApi = {
	nodeinfo = BaseApi[BaseApi.current].world_url .. 'nodeinfo',
	test = BaseApi[BaseApi.current].world_url .. 'test',
	auth = BaseApi[BaseApi.current].world_url .. 'auth',
	user = BaseApi[BaseApi.current].world_url .. 'user',
	deck = BaseApi[BaseApi.current].world_url .. 'decks',
}

setmetatable(RoutesApi, {
	__index = function(key)
		error(string.format('the route: "%s" is not set in routes', key))
	end
})

return RoutesApi
