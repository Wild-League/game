local Suit = require('./lib/suit')
local Saver = require('./src/helpers/saver')

local Auth = {}

local nickname_input = { text = '' }

setmetatable(Auth, Auth)

function Auth:load() end

function Auth:update()
	Suit.Label('nickname: ', { align='center' }, 10, 0, 200, 30)
	Suit.Input(nickname_input, 10, 40, 200, 30)

	local save_nick = Suit.Button('Enter', 10, 80, 200, 30)

	if save_nick.hit then
		if (nickname_input.text ~= '') then
			local save = Saver:save({ nickname = nickname_input.text, level = 1 })
			if save == true then
				CONTEXT:change('game')
			end
		end
	end
end

function Auth:draw() end

-- love functions

function love.textinput(t)
	Suit.textinput(t)
end

function love.keypressed(key)
	Suit.keypressed(key)
end

return Auth
