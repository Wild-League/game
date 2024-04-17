local Suit = require('lib.suit')
local Context = require('src.context')
local Ws = require('src.network.websocket')

function love.load()
	-- initialize the global state manager
	CONTEXT = Context;
end

function love.update(dt)
	Ws:update()
	CONTEXT:update(dt)
end

function love.draw()
	CONTEXT:draw()
	Suit.draw()
end

function love.textinput(t)
	Suit.textinput(t)
end

function love.keypressed(key)
	Suit.keypressed(key)
end
