local Constants = {
	LOGGED_USER = {},
	WINDOW_SETTINGS = {
		width = 1024,
		height = 600
	}
}

setmetatable(Constants, {
	__index = function(key)
		error(string.format('the key: "%s" is not set in Constants', key))
	end
})

return Constants
