local Constants = {
	LOGGED_USER = {},
	ACCESS_TOKEN = '',
	UDP = {}
}

setmetatable(Constants, {
	__index = function(key)
		error(string.format('the key: "%s" is not set in Constants', key))
	end
})

return Constants
