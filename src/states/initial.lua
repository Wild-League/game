local Suit = require('lib.suit')
local Layout = require('src.helpers.layout')

local Instance = require('src.api.instance')

local Initial = {
	logo = love.graphics.newImage('assets/logo-text.png'),

	instance_input = { text = 'https://wildleague.org' },
	instance_invalid = false
}

function Initial:load() end

function Initial:update()
	local input_center = Layout:center(300, 30)
	Suit.Input(self.instance_input, input_center.width, input_center.height + 100, 300, 30)
end

function Initial:draw()
	love.graphics.setBackgroundColor(10/255,16/255,115/255)

	local default_scale = 0.3
	local center_logo = Layout:center(self.logo:getWidth() * default_scale, self.logo:getHeight() * default_scale)

	love.graphics.push()
	love.graphics.translate(center_logo.width, center_logo.height - 100)
	love.graphics.scale(default_scale)
	love.graphics.draw(self.logo, 0, 0)
	love.graphics.pop()

	local text_center = Layout:center(350, 100)
	Suit.Label('Enter the server you want to join!', text_center.width, text_center.height, 350, 200)

	local play_button = Suit.Button('Enter', text_center.width + 25, text_center.height + 200, 300, 30)

	if self.instance_invalid then
		love.graphics.setColor(1,0,0)
		love.graphics.print('This instance is not valid.', text_center.width, text_center.height - 250, 250)
		love.graphics.setColor(0,0,0)
	end

	if self.instance_input ~= '' and play_button.hit then
		-- need to check the instance
		local data = Instance:validate(self.instance_input.text)

		-- TODO: create loading state

		if not data.valid then
			self.instance_invalid = true
		else
			self.instance_invalid = false
			CONTEXT:change('auth')
		end
	end
end

return Initial
