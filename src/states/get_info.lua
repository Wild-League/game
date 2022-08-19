local Suit = require('./lib/suit') -- called from main
local Layout = require('./src/helpers/layout')

local Get_Info = {
	__call = function(self)
		print('chamando todos')
		self.draw()
	end
}

setmetatable(Get_Info, Get_Info)

function Get_Info:draw()
	love.graphics.clear()

	-- local welcome_center = Layout:Centralize(100, 50)
	-- Suit.Label('This will be the first page of the game', { align='center' }, welcome_center.width, welcome_center.height, 100, 50)

	local nickname_input = { text = '' }

	Suit.Label('nickname: ', { align='center' }, 10, 0, 200, 30)
	Suit.Input(nickname_input, 10, 40, 200, 30)
	local save_nick = Suit.Button('Enter', 10, 80, 200, 30)

	if save_nick.hit then
		print('entering game...')
	end
end

return Get_Info
