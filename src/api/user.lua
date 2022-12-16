local https = require('lib.lua-https')
local Routes = require('src.api.routes')

local function get_users()
	local status_code, body = https.request(Routes.users, {method='get'})

	print(status_code, body)

	return body
end

return get_users
