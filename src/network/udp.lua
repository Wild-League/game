local socket = require("socket")
local Json = require('lib.json')
local Events = require('src.network.events')

local Udp = {
	connection = {}
}

function Udp:connect()
	-- TODO: check if connected successfully
	self.connection = socket.udp()
	self.connection:settimeout(0)
	self.connection:setpeername('localhost', 9091)

	-- TODO: sends matchmaking on connect just in this initial phase - just a reminder to remove later
	self:send({ event = Events.Connect })
	self:send({ event = Events.Matchmaking })
end

function Udp:receive_data()
	local data = self.connection:receive()
	if data then
		return Json.decode(data)
	end

	return data
end

--[[
	this should send a event mandatorily

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

	local encoded_data = Json.encode(data)
	self.connection:send(encoded_data)
end

return Udp
