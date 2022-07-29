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
	-- Suit.Label('Nickname: ', { align='left' }, (window.width / 2), ((window.height / 2) - 200), 200, 30)
	-- Suit.Input(nickname_input, (window.width / 2), ((window.height / 2) - 120), 200, 30)

	-- if Suit.Button('Send', (window.width / 2), ((window.height / 2) - 60), 200, 30).hit then
	-- 	print('entering the game .. ')
	-- 	-- Saver.save()
	-- end
end

function love.load()
	love.window.setMode(WINDOW_SETTINGS.width, WINDOW_SETTINGS.height, { resizable = true })

	local data = Saver:retrieveData()

	if data ~= nil then
		Constants.LOGGED_USER = data
	end
end

function love.draw()
	Suit.draw()
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
