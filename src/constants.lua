local Constants = {
	LOGGED_USER = {},
	WINDOW_SETTINGS = {
		width = 1200,
		height = 720
	}
}

setmetatable(Constants, {
	__index = function(self, key)
		error(string.format('the key: "%s" is not set in Constants', key))
	end
})

return Constants
