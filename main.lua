require('src.helpers.env')

local Suit = require('lib.suit')
local Fonts = require('src.ui.fonts')
local Context = require('src.context')
local Ws = require('src.network.websocket')
local Toast = require('src.ui.toast')

function love.load()
	love.graphics.setFont(Fonts.jura(24))

	math.randomseed(os.time() + math.floor(os.clock() * 100000))

	-- initialize the global state manager
	CONTEXT = Context;
	CONTEXT:load()
end

function love.update(dt)
	require("lib.lurker").update()

	Ws:update()
	CONTEXT:update(dt)
	Toast:update(dt)
end

function love.draw()
	CONTEXT:draw()
	Suit.draw()
	Toast:draw()
end

function love.textinput(t)
	Suit.textinput(t)
end

function love.resize()
	CONTEXT:resize()
end

function love.keypressed(key)
	Suit.keypressed(key)
end

function love.mousepressed(x, y, button, istouch, presses)
	if not CONTEXT then return end
	local state = CONTEXT.states[CONTEXT.current]
	if state.mousepressed then
		state:mousepressed(x, y, button, istouch, presses)
	end
end

function love.mousemoved(x, y, dx, dy, istouch)
	if not CONTEXT then return end
	local state = CONTEXT.states[CONTEXT.current]
	if state.mousemoved then
		state:mousemoved(x, y, dx, dy, istouch)
	end
end

function love.mousereleased(x, y, button, istouch, presses)
	if not CONTEXT then return end
	local state = CONTEXT.states[CONTEXT.current]
	if state.mousereleased then
		state:mousereleased(x, y, button, istouch, presses)
	end
end

function love.wheelmoved(x, y)
	if not CONTEXT then return end
	local state = CONTEXT.states[CONTEXT.current]
	if state.wheelmoved then
		state:wheelmoved(x, y)
	end
end
