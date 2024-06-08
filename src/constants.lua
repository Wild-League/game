local Constants = {
	LOGGED_USER = {},
	ACCESS_TOKEN = '',
	UDP = {},

	NAKAMA_CLIENT = {},
	USER_ID = '',
	ENEMY_ID = '',
	MATCH_ID = '',
	SOCKET_CONNECTION = {}
}

setmetatable(Constants, {
	__index = function(key)
		error(string.format('the key: "%s" is not set in Constants', key))
	end
})

return Constants
