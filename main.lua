local Suit = require './lib/suit'
local User = require './src/entities/user'
local Constants = require './src/constants'
local Saver = require('./src/helpers/saver')

local nickname_input = { text = '' }

function love.update(dt)
	Suit.Label('Nickname: ', { align='left' }, 10, 10, 200, 30)
	Suit.Input(nickname_input, 10, 40, 200, 30)

	if Suit.Button('Send', 10, 80, 200, 30).hit then
		Saver.save()
	end
end

function love.load()
	local data = Saver:retrieveData()

	if data ~= nil then
		Constants.LOGGED_USER = data
	end
end

function love.draw()
	Suit.draw()
end

function love.textinput(t)
	Suit.textinput(t)
end

function love.keypressed(key)
	Suit.keypressed(key)
end
