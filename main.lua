-- if arg[2] == "debug" then
-- 	require("lldebugger").start()
-- end

local Suit = require('lib.suit')

local Constants = require('src.constants')
local Context = require('src.context')

function love.load()
	love.window.setFullscreen(false, "desktop")

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

-- function love.resize(w,h)
-- 	Constants.WINDOW_SETTINGS.width = w
-- 	Constants.WINDOW_SETTINGS.height = h
-- end

function love.textinput(t)
	Suit.textinput(t)
end

function love.keypressed(key)
	Suit.keypressed(key)

	if key == "f" then
		local isFullscreen = love.window.getFullscreen()
		love.window.setFullscreen(not isFullscreen, "desktop")
	end
end
