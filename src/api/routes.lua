local Base = require('src.api.base')

local Routes = {
	nodeinfo = Base[Base.current].world_url .. 'nodeinfo',
	test = Base[Base.current].world_url .. 'test',
	auth = Base[Base.current].world_url .. 'auth',
	user = Base[Base.current].world_url .. 'user',
	deck = Base[Base.current].world_url .. 'decks',
}

setmetatable(Routes, {
	__index = function(key)
		error(string.format('the route: "%s" is not set in routes', key))
	end
})

return Routes
