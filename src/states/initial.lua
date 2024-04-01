local Suit = require('lib.suit')
local Layout = require('src.helpers.layout')
local Instance = require('src.api.instance')
local Images = require('src.ui.images')
local Fonts = require('src.ui.fonts')

love.graphics.setFont(Fonts.jura(24))

local Initial = {
	instance_input = { text = 'https://wildleague.org' },
	is_instance_valid = true
}

function Initial:load() end

function Initial:update()
	local input_center = Layout:center(300, 30)
	Suit.Input(self.instance_input, input_center.width, input_center.height + 100, 300, 30)
end

function Initial:draw()
	love.graphics.setBackgroundColor(10/255,16/255,115/255)

	local default_scale = 0.3
	local center_logo = Layout:center(Images.logo_text:getWidth() * default_scale, Images.logo_text:getHeight() * default_scale)

	love.graphics.push()
	love.graphics.translate(center_logo.width, center_logo.height - 100)
	love.graphics.scale(default_scale)
	love.graphics.draw(Images.logo_text, 0, 0)
	love.graphics.pop()

	local text_center = Layout:center(350, 100)
	Suit.Label('Enter the server you want to join!', text_center.width, text_center.height, 350, 200)

	local play_button = Suit.Button('Enter', text_center.width + 25, text_center.height + 200, 300, 40)

	if not self.is_instance_valid then
		love.graphics.setColor(1,1,0)
		love.graphics.print('This instance is not valid.', text_center.width + 35, text_center.height + 250)
		love.graphics.setColor(1,1,1)
	end

	if self.instance_input ~= '' and play_button.hit then
		local response = Instance:validate(self.instance_input.text)

		if response.success then
			self.is_instance_valid = true
			CONTEXT:change('auth')
		else
			self.is_instance_valid = false
		end
	end
end

return Initial
