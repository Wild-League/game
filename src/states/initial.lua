local Suit = require('./lib/suit') -- called from main
local Layout = require('./src/helpers/layout')
local Saver = require('./src/helpers/saver')
local Constants = require('./src/constants')
local Assets = require('./src/assets')

local Initial = {
	__call = function(self)
		self.load()
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
end

function Initial:load()
	GAME_TITLE = Assets.GAME_TITLE
	BUTTON = Assets.BUTTON
	BUTTON_HOVER = Assets.BUTTON_HOVER
end

return Initial
