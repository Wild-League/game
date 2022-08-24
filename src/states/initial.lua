local Suit = require('./lib/suit') -- called from main
local Layout = require('./src/helpers/layout')
local Saver = require('./src/helpers/saver')
local Constants = require('./src/constants')

local Initial = {
	__call = function(self)
		self.draw()
	end
}

setmetatable(Initial, Initial)

function Initial:draw()
	local title_central = Layout:Centralize(659, 213)
	love.graphics.draw(GAME_TITLE, title_central.width, title_central.height)

	local button_central = Layout:Centralize(280, 72)
	local play_button = Suit.ImageButton(BUTTON, { hovered = BUTTON_HOVER }, button_central.width, (button_central.height + 200))

	if play_button.hit then
		local data = Saver:retrieveData()

		if data ~= nil then
			Constants.LOGGED_USER = data
		else
			print(CONTEXT:change('get_info'))
		end
	end
	-- local welcome_center = Layout:Centralize(WINDOW_SETTINGS.width, WINDOW_SETTINGS.height, 100, 50)
	-- Suit.Label('Welcome to Wild League', { align='center' }, welcome_center.width, welcome_center.height, 100, 50)
end

return Initial
