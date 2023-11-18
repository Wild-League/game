local Base = require('src.api.base')

local Routes = {
	nodeinfo = Base[Base.current].base_url .. 'nodeinfo',
	test = Base[Base.current].base_url .. 'test'
}

setmetatable(Routes, {
	__index = function(key)
		error(string.format('the route: "%s" is not set in routes', key))
	end
})

return Routes
