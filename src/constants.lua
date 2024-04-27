local Constants = {
	LOGGED_USER = {},
	ACCESS_TOKEN = '',
	UDP = {},

	NAKAMA_CLIENT = {},
	USER_ID = '',

	IN_GAME_LOADED_ASSETS = {}
}

setmetatable(Constants, {
	__index = function(key)
		error(string.format('the key: "%s" is not set in Constants', key))
	end
})

return Constants
