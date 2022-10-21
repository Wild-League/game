local Suit = require('./lib/suit') -- called from main

local nickname_input = { text = '' }

function love.textinput(t)
	Suit.textinput(t)
end

function love.keypressed(key)
	Suit.keypressed(key)
end

local Get_Info = {
	__call = function(self)
		self:draw()
	end
}

setmetatable(Get_Info, Get_Info)

function Get_Info:draw()
	Suit.Label('nickname: ', { align='center' }, 10, 0, 200, 30)
	Suit.Input(nickname_input, 10, 40, 200, 30)

	local save_nick = Suit.Button('Enter', 10, 80, 200, 30)

	if save_nick.hit then
		if (nickname_input.text ~= '') then
			CONTEXT:change('in_game')
		end
	end
end

return Get_Info
