local Suit = require './lib/suit'
local User = require './src/entities/user'

local name_input = { text = '' }
local age_input = { text = '' }

local under_age = false

function love.update(dt)
	Suit.Label('Name: ', { align='left' }, 10, 10, 200, 30)
	Suit.Input(name_input, 10, 40, 200, 30)

	Suit.Label('Age: ', { align='left' }, 10, 70, 200, 30)
	Suit.Input(age_input, 10, 100, 200, 30)

	if Suit.Button('Send', 10, 150, 200, 30).hit then
		-- Saver.save()

		if tonumber(age_input.text) < 18 then under_age = true
		else under_age = true end
	end

	if under_age then
		Suit.Label('Must be over 18 years old!', { align='center' }, 10, 200, 200, 30)
	end
end

function love.load()
	LOGGED_USER = User('ropoko', 32)

	-- local Saver = require('./src/helpers/saver')
	-- Saver.save()
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
