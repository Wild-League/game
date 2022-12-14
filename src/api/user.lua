local http = require('socket.http')
local ltn12 = require('ltn12')

local function get_users()
	local res = {}

	http.request {
		url='http://localhost:3001/users',
		method='GET',
		sink = ltn12.sink.table(res)
	}

	return res
end

return get_users
