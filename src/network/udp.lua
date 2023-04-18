-- local Layout = require('./src/helpers/layout')
local socket = require("socket")

--[[
	TODO:
	# 1 - defines possible network events
	# 2 - implements pattern matching in Udp:receive_data
]]

local Udp = {
	connection = {}
}

function Udp:connect()
	self.connection = socket.udp()
	self.connection:settimeout(0)
	self.connection:setpeername('127.0.0.1', 9091)

	-- TODO: sends matchmaking on connect just in this initial phase - just a reminder to remove later
	self.connection:send('Matchmaking')
end

function Udp:receive_data()
	local data = self.connection:receive()
	return data
end

function Udp:send(data)
	-- print(self.connection == nil)
	-- print(self.connection:send('') == nil)
	-- if self.connection:send() == nil then

	-- end
	self.connection:send(data)
end

return Udp
