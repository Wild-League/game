local yui = require('lib.yui')
local Suit = require('lib.suit')
local Layout = require('src.helpers.layout')
local Instance = require('src.api.instance')
local Images = require('src.ui.images')
local Fonts = require('src.ui.fonts')
local Host = require('src.api.host')

local Initial = {
	instance_input = 'https://wildleague.org',
	is_instance_valid = true,
	server_options = {}
}

function Initial:load()
	love.graphics.setFont(Fonts.jura(24))

	local worlds = Host:get_worlds().body

	for _, value in pairs(worlds) do
		table.insert(self.server_options, { text = value.name, value = value.url })
	end

	self.ui = yui.Ui:new({
		x = 500,
		y = 350,

		yui.Rows {
			yui.Label({
				w = 350, h = 100,
				text = 'Choose the server you want to join!',
				theme = { color = { normal = { fg = { 1, 1, 1 } } }}
			}),

			yui.Choice({
				w = 350, h = 50,
				choices = self.server_options,
				onChange = function(option)
					self.instance_input = self.server_options[option.index]
				end
			}),

			yui.Spacer({
				w = 350, h = 50
			}),

			yui.Label({
				w = 350, h = 50,
				text = self.is_instance_valid and '' or 'Invalid wildleague instance!',
				theme = { color = { normal = { fg = { 1, 1, 0 } } }},
			}),

			yui.Button({
				w = 350, h = 50,
				text = 'Enter',
				onHit = function()
					local response = Instance:validate(self.instance_input)

					if response.success then
						CONTEXT:change('lobby')
					else
						self.is_instance_valid = false
					end
				end
			})
		}
	})
end

function Initial:update(dt)
	self.ui:update(dt)
end

function Initial:draw()
	love.graphics.draw(Images.background_cloud, 0, 0, 0, love.graphics.getWidth() / Images.background_cloud:getWidth(), love.graphics.getHeight() / Images.background_cloud:getHeight())

	self.ui:draw()

	local default_scale = 0.3
	local center_logo = Layout:center(Images.logo_text:getWidth() * default_scale, Images.logo_text:getHeight() * default_scale)

	love.graphics.push()
	love.graphics.translate(center_logo.width, center_logo.height - 100)
	love.graphics.scale(default_scale)
	love.graphics.draw(Images.logo_text, 0, 0)
	love.graphics.pop()
end

return Initial
