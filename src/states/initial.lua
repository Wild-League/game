local Suit = require('./lib/suit') -- called from main
local Layout = require('./src/helpers/layout')

local Initial = {
	__call = function(self)
		self.draw()
	end
}

setmetatable(Initial, Initial)

function Initial:draw()
	local welcome_center = Layout:Centralize(WINDOW_SETTINGS.width, WINDOW_SETTINGS.height, 100, 50)
	Suit.Label('Welcome to Wild League', { align='center' }, welcome_center.width, welcome_center.height, 100, 50)

	Suit.draw()
end

return Initial
