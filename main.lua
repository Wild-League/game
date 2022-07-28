local Suit = require './lib/suit'
local User = require './src/entities/user'
local Constants = require './src/constants'
local Saver = require('./src/helpers/saver')

local nickname_input = { text = '' }

local window = {
	width = 800,
	height = 600
}

function love.update(dt)
	Suit.Label('Nickname: ', { align='left' }, (window.width / 2), ((window.height / 2) - 200), 200, 30)
	Suit.Input(nickname_input, (window.width / 2), ((window.height / 2) - 120), 200, 30)

	if Suit.Button('Send', (window.width / 2), ((window.height / 2) - 60), 200, 30).hit then
		print('entering the game .. ')
		-- Saver.save()
	end
end

function love.load()
	love.window.setMode(window.width, window.height, { resizable = true })

	local data = Saver:retrieveData()

	if data ~= nil then
		Constants.LOGGED_USER = data
	end
end

function love.draw()
	Suit.draw()
	-- trying to centralize things correctly
	-- love.graphics.rectangle("fill", (window.width / 2 - 76), (window.height / 2 + 35), 50, 50)
end

function love.textinput(t)
	Suit.textinput(t)
end

function love.keypressed(key)
	Suit.keypressed(key)
end
