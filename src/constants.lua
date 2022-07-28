local Constants = {
	LOGGED_USER = {}
}

setmetatable(Constants, {
	__index = function(self, key)
		error(string.format('the key: "%s" is not set in Constants', key))
	end
})

return Constants
