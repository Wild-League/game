local Suit = require('./lib/suit')
local User = require('./src/entities/user')
local Constants = require('./src/constants')
local Saver = require('./src/helpers/saver')
local Layout = require('./src/helpers/layout')

local nickname_input = { text = '' }

WINDOW_SETTINGS = {
	width = 800,
	height = 600
}

function love.update(dt)
	local button_central = Layout:Centralize(WINDOW_SETTINGS.width, WINDOW_SETTINGS.height, 280, 72)
	local play_button = Suit.ImageButton(BUTTON, { hovered = BUTTON_HOVER }, button_central.width, (button_central.height + 200))

	if play_button.hit then
		print('entering game...')

		local data = Saver:retrieveData()

		if data ~= nil then
			Constants.LOGGED_USER = data
		end
	end
end

function love.load()
	-- TODO: move to constants file
	GAME_TITLE = love.graphics.newImage('assets/game-title.png')
	BUTTON = love.graphics.newImage('assets/button.png')
	BUTTON_HOVER = love.graphics.newImage('assets/button-hover.png')

	love.window.setMode(WINDOW_SETTINGS.width, WINDOW_SETTINGS.height, { resizable = true })

	local center  = Layout:Centralize(WINDOW_SETTINGS.width, WINDOW_SETTINGS.height, 50, 50)
	RECTANGLE = { x = center.width, y = center.height, width = 50, height = 50 }
end

function love.draw()
	-- local title_central = Layout:Centralize(WINDOW_SETTINGS.width, WINDOW_SETTINGS.height, 659, 213)
	-- love.graphics.draw(GAME_TITLE, title_central.width, title_central.height)


	love.graphics.rectangle("line", RECTANGLE.x, RECTANGLE.y, RECTANGLE.width, RECTANGLE.height)

	-- Suit.draw()
end

function love.resize(width, height)
	WINDOW_SETTINGS.width = width
	WINDOW_SETTINGS.height = height
end

function love.textinput(t)
	Suit.textinput(t)
end

function love.keypressed(key)
	Suit.keypressed(key)
end

CAN_MOVE = false

function love.mousepressed(x, y, button)
	if button == 1 then -- left
		if (x >= RECTANGLE.x and x <= (RECTANGLE.x + RECTANGLE.width))
			and (y >= RECTANGLE.y and y <= (RECTANGLE.y + RECTANGLE.height)) then
				CAN_MOVE = true
				print('can_move', CAN_MOVE)
		end
	end
end

function love.mousereleased(x, y, button)
	if button == 1 then -- left
		CAN_MOVE = false
		print('cannot move', CAN_MOVE)
	end
end

function love.mousemoved(x, y, dx, dy)
	if CAN_MOVE then
		RECTANGLE.x = x
		RECTANGLE.y = y
	end
end
