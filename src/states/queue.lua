local Suit = require('./lib/suit')
local Layout = require('./src/helpers/layout')
local Udp = require('./src/network/udp')
local Events = require('./src/network/events')
local Constants = require('./src/constants')

local Queue = {
	found = false
}

function Queue:load()
	Constants.UDP = Udp:connect()
end

function Queue:update()
	local data = Udp:receive_data()
	if data ~= nil and data.event == Events.MatchFound then
		self.found = true
	end
end

function Queue:draw()
	local pos = Layout:center(100, 100)

	love.graphics.print('searching match ...', pos.width, pos.height - 50)
	local btn_cancel = Suit.Button('Cancel', pos.width, pos.height, 100, 50)

	if btn_cancel.hit then
		CONTEXT:change('initial')
	end

	if self.found then
		love.graphics.print('FOUND!', pos.width + 125, pos.height - 50)
		CONTEXT:change('game')
	end
end

return Queue

