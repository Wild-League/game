local suit = require 'suit'
local user = require('./src/models/user')

local name_input = { text = '' }
local age_input = { text = '' }

local under_age = false

function love.update(dt)
	suit.Label('Name: ', { align='left' }, 10, 10, 200, 30)
	suit.Input(name_input, 10, 40, 200, 30)

	suit.Label('Age: ', { align='left' }, 10, 70, 200, 30)
	suit.Input(age_input, 10, 100, 200, 30)

	if suit.Button('Send', 10, 150, 200, 30).hit then
		if tonumber(age_input.text) < 18 then under_age = true
		else under_age = true end
	end

	if under_age then
		suit.Label('Must be over 18 years old!', { align='center' }, 10, 200, 200, 30)
	end
end

function love.draw()
	suit.draw()
end

function love.textinput(t)
	suit.textinput(t)
end

function love.keypressed(key)
	suit.keypressed(key)
end
