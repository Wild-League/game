local Routes = {
	users = 'https://api-wild-league-production.up.railway.app/users'
}

setmetatable(Routes, {
	__index = function(key)
		error(string.format('the route: "%s" is not set in routes', key))
	end
})

return Routes
