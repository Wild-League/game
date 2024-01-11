local Suit = require('lib.suit')
local Layout = require('src.helpers.layout')

local Instance = require('src.api.instance')

local Initial = {
	instance_input = { text = 'https://wildleague.org' },
	instance_invalid = false
}

function Initial:load() end

function Initial:update()
	local center = Layout:center(100, 100 - 200)
	Suit.Input(self.instance_input, center.width, center.height - 80, 300, 30)
end

function Initial:draw()
	local center = Layout:center(100, 100 - 200)

	Suit.Label('Enter the instance you want to join', center.width, center.height - 200, 300, 200)

	local play_button = Suit.Button('Enter', center.width, center.height)

	if self.instance_invalid then
		love.graphics.setColor(1,0,0)
		love.graphics.print('This instance is not valid.', center.width, center.height - 250)
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
