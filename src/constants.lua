local Constants = {
	LOGGED_USER = {},
	ACCESS_TOKEN = '',
	REFRESH_TOKEN = '',
	UDP = {},

	NAKAMA_CLIENT = {},
	USER_ID = '',
	ENEMY_ID = '',
	MATCH_ID = '',
	SOCKET_CONNECTION = {},

	WS_CONNECTION_SERVER = {},
	WORLD_SERVER_API = '', -- url of the chosen world api
	WORLD_BACKGROUND = nil,
}

setmetatable(Constants, {
	__index = function(_, key)
		error(string.format('the key: "%s" is not set in Constants', key))
	end
})

return Constants
