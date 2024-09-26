local yui = require('lib.yui')
local Layout = require('src.helpers.layout')
local InstanceApi = require('src.api.instance')
local Images = require('src.ui.images')
local ImageHelper = require('src.helpers.image')
local HostApi = require('src.api.host')

local Initial = {
	instance_input = 'https://wildleague.org',
	is_instance_valid = true,
	server_options = {},
	current_background = Images.background_cloud,
	list_worlds = nil
}

function Initial:load()
	self.list_worlds = HostApi:get_worlds().body

	for _, value in pairs(self.list_worlds) do
		table.insert(self.server_options, { text = value.name, value = value.url })
	end

	self:load_background_image(self.server_options[1])

	self.ui = yui.Ui:new({
		x = 500,
		y = 350,

		yui.Rows {
			yui.Label({
				w = 350, h = 100,
				text = 'Choose the server you want to join!',
				theme = { color = { normal = { fg = { 1, 1, 1 } } }}
			}),

			yui.Spacer({
				w = 350, h = 50
			}),

			yui.Choice({
				w = 350, h = 50,
				choices = self.server_options,
				onChange = function(option)
					self.instance_input = self.server_options[option.index].value
					Initial:load_background_image(self.server_options[option.index])
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
					self.text = 'Loading...'

					local response = InstanceApi:validate(self.instance_input)

					if response.success then
						self.text = 'Enter'
						CONTEXT:change('lobby')
					else
						self.text = 'Enter'
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
	love.graphics.draw(self.current_background, 0, 0, 0, love.graphics.getWidth() / self.current_background:getWidth(), love.graphics.getHeight() / self.current_background:getHeight())

	self.ui:draw()

	local default_scale = 0.3
	local center_logo = Layout:center(Images.logo_text:getWidth() * default_scale, Images.logo_text:getHeight() * default_scale)

	love.graphics.push()
	love.graphics.translate(center_logo.width, center_logo.height - 100)
	love.graphics.scale(default_scale)
	love.graphics.draw(Images.logo_text, 0, 0)
	love.graphics.pop()
end

function Initial:load_background_image(url_server)
	local world = nil

	for _, w in pairs(self.list_worlds) do
		if w.url == url_server.value then
			world = w
			break
		end
	end

	if world then
		local background = world.background
		and ImageHelper:load_from_url(world.background, 'background')
		or Images.background_cloud

		self.current_background = background
	end
end

return Initial
