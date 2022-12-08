local Suit = require('./lib/suit')
local Layout = require('./src/helpers/layout')
local Saver = require('./src/helpers/saver')
local Assets = require('./src/assets')
local Constants = require('./src/constants')

local BACKGROUND = Assets.BACKGROUND_INITIAL
local BUTTON = Assets.BUTTON
local BUTTON_HOVER = Assets.BUTTON_HOVER

local Initial = {}

function Initial:update() end

function Initial:draw()
	local sx = love.graphics.getWidth() / BACKGROUND:getWidth()
	local sy = love.graphics.getHeight() / BACKGROUND:getHeight()

	for i = 0, Constants.WINDOW_SETTINGS.width / BACKGROUND:getWidth() do
		for j = 0, Constants.WINDOW_SETTINGS.height / BACKGROUND:getHeight() do
			love.graphics.draw(BACKGROUND, i * BACKGROUND:getWidth(), j * BACKGROUND:getHeight(), 0, sx, sy)
		end
	end

	local button_central = Layout:center(BUTTON:getWidth(), BUTTON:getHeight() - 200)
	local play_button = Suit.ImageButton(BUTTON, { hovered = BUTTON_HOVER }, button_central.width, button_central.height)

	if play_button.hit then
		local data = Saver:retrieveData()

		if data ~= nil then
			CONTEXT:change('game')
		else
			CONTEXT:change('auth')
		end
	end
end

return Initial
