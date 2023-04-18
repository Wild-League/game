local socket = require("socket")
local Json = require('lib.json')
local Events = require('./src/network/events')

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
	self:send({ event = Events.Connect })
	self:send({ event = Events.Matchmaking })
end

function Udp:receive_data()
	local data = self.connection:receive()

	if data ~= nil then
		return Json.decode(data)
	end

	return nil
end

--[[
	this should receive a event mandatorily

	Note: the identifier and obj is only mandatory when the event is 'object',
	where identifiers = the object name or id
	and obj = the actual object
]]
function Udp:send(data)
	-- TODO: check for only the events defined
	if data.event == nil then
		error('should have a valid event')
	end

	if data.event == Events.Object then
		if data.identifier == nil and data.obj == nil then
			error('Should have a identifier')
		end
	end

	self.connection:send(Json.encode(data))
end

return Udp
