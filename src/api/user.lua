local https = require('lib.lua-https')
local ltn12 = require('ltn12')

local function get_users()
	local status_code, body = https.request('https://api-wild-league-production.up.railway.app/users', {method='get'})

	return body
end

return get_users
