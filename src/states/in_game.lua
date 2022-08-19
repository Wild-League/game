local Suit = require('./lib/suit') -- called from main
local Layout = require('./src/helpers/layout')

local In_Game = {
	__call = function(self)
		self.draw()
	end
}

setmetatable(In_Game, In_Game)

function In_Game:draw()
	local welcome_center = Layout:Centralize(100, 50)
	Suit.Label('This will be the first page of the game', { align='center' }, welcome_center.width, welcome_center.height, 100, 50)
end

return In_Game
