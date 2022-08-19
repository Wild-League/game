local Constants = {
	LOGGED_USER = {},
	WINDOW_SETTINGS = {
		width = 800,
		height = 600
	}
}

setmetatable(Constants, {
	__index = function(self, key)
		error(string.format('the key: "%s" is not set in Constants', key))
	end
})

return Constants
