-- if arg[2] == "debug" then
-- 	require("lldebugger").start()
-- end

local Suit = require('lib.suit')
local Context = require('src.context')

function love.load()
	local default_font = love.graphics.newFont('assets/fonts/retro.ttf', 16)
	default_font:setFilter('linear', 'linear')
	love.graphics.setFont(default_font)
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

function love.textinput(t)
	Suit.textinput(t)
end

function love.keypressed(key)
	Suit.keypressed(key)
end
