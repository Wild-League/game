local websocket = require("lib.websocket")

local Ws = {
	connection = nil
}

function Ws:connect(host, port, path)
	self.connection = websocket.new(host, port, path)
	return self.connection
end

function Ws:update()
	if not self.connection then return end
	self.connection:update()
end

function Ws:send(message)
	self.connection:send(message)
end

return Ws
