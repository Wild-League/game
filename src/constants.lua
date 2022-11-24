local Constants = {
	LOGGED_USER = {},
	WINDOW_SETTINGS = {
		width = 1024,
		height = 768
	}
}

setmetatable(Constants, {
	__index = function(self, key)
		error(string.format('the key: "%s" is not set in Constants', key))
	end
})

return Constants
