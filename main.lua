-- if arg[2] == "debug" then
-- 	require("lldebugger").start()
-- end

local Suit = require('./lib/suit')

local Constants = require('./src/constants')
local Context = require('./src/context')

function love.load()
	-- initialize the global state manager
	CONTEXT = Context;
end

function love.update(dt)
	CONTEXT:update(dt)
end

function love.draw()
	CONTEXT:draw()
	Suit.draw()
end
