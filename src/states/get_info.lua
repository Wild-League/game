local Suit = require('./lib/suit')
local Saver = require('./src/helpers/saver')


local Get_Info = {}

local nickname_input = { text = '' }

setmetatable(Get_Info, Get_Info)

function Get_Info:load() end

function Get_Info:update()
	Suit.Label('nickname: ', { align='center' }, 10, 0, 200, 30)
	Suit.Input(nickname_input, 10, 40, 200, 30)

	local save_nick = Suit.Button('Enter', 10, 80, 200, 30)

	if save_nick.hit then
		if (nickname_input.text ~= '') then
			local save = Saver:save({ nickname = nickname_input.text, level = 1 })
			if save == true then
				CONTEXT:change('in_game')
			end
		end
	end
end

function Get_Info:draw() end

-- love functions

function love.textinput(t)
	Suit.textinput(t)
end

function love.keypressed(key)
	Suit.keypressed(key)
end

return Get_Info
