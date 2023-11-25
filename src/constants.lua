local Constants = {
	LOGGED_USER = {},
	ACCESS_TOKEN = '',
	-- WINDOW_SETTINGS = {
	-- 	width = 1200,
	-- 	height = 800
	-- },
	-- the udp connection with server
	UDP = {},
	DECK_SELECTED = 'deck1'
}

setmetatable(Constants, {
	__index = function(key)
		error(string.format('the key: "%s" is not set in Constants', key))
	end
})

return Constants
