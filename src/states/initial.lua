local Suit = require('./lib/suit')
local Layout = require('./src/helpers/layout')
local Saver = require('./src/helpers/saver')
local Assets = require('./src/assets')
local Constants = require('./src/constants')

local BACKGROUND = Assets.BACKGROUND_INITIAL
local BUTTON = Assets.BUTTON
local BUTTON_HOVER = Assets.BUTTON_HOVER

local Initial = {
	__call = function(self)
		self:load()
		self:draw()
	end
}

setmetatable(Initial, Initial)

function Initial:load()
	local sx = love.graphics.getWidth() / BACKGROUND:getWidth()
	local sy = love.graphics.getHeight() / BACKGROUND:getHeight()

	for i = 0, Constants.WINDOW_SETTINGS.width / BACKGROUND:getWidth() do
		for j = 0, Constants.WINDOW_SETTINGS.height / BACKGROUND:getHeight() do
			love.graphics.draw(BACKGROUND, i * BACKGROUND:getWidth(), j * BACKGROUND:getHeight(), 0, sx, sy)
		end
	end
end

function Initial:draw()
	-- local title_central = Layout:Centralize(659, 213)
	-- love.graphics.draw(GAME_TITLE, title_central.width, title_central.height)

	local button_central = Layout:Centralize(BUTTON:getWidth(), BUTTON:getHeight() - 200)
	local play_button = Suit.ImageButton(BUTTON, { hovered = BUTTON_HOVER }, button_central.width, button_central.height)

	if play_button.hit then
		local data = Saver:retrieveData()

		if data ~= nil then
			CONTEXT:change('in_game')
		else
			print(CONTEXT:change('get_info'))
		end
	end
end

return Initial
