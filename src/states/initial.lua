local Suit = require('lib.suit')
local Layout = require('src.helpers.layout')
local InstanceApi = require('src.api.instance')
local Images = require('src.ui.images')
local ImageHelper = require('src.helpers.image')
local Constants = require('src.constants')

local Initial = {
	instance_input = 'https://wildleague.org', -- default instance
	is_instance_valid = true,
	server_options = {},
	current_background = Images.background_cloud,
	list_worlds = {
		{
			name = 'WildLeague',
			url = 'https://wildleague.org',
			api_url = 'https://wildleague.org/api'
		},
	},
	selected_index = 1
}


function Initial:load()
	for i, world in ipairs(self.list_worlds) do
		if world.url == 'https://wildleague.org' then
			if i > 1 then
				local temp = self.list_worlds[1]
				self.list_worlds[1] = world
				self.list_worlds[i] = temp
			end
			break
		end
	end

	self.server_options = {}
	for _, value in pairs(self.list_worlds) do
		table.insert(self.server_options, { text = value.name, value = value.url })
	end

	self.selected_index = 1
	if self.server_options[1] then
		self.instance_input = self.server_options[1].value
		self:load_background_image(self.instance_input)
	end
end

function Initial:get_api_url(world_url)
	for _, world in ipairs(self.list_worlds) do
		if world.url == world_url then
			return world.api_url
		end
	end
end

function Initial:update(dt)
	local width = love.graphics.getWidth()
	local panel_w = 350
	local center_x = width / 2 - panel_w / 2
	local start_y = 350
	local label_theme = { align = 'center', color = { normal = { fg = { 1, 1, 1 } } } }
	local err_theme = { align = 'center', color = { normal = { fg = { 1, 0, 0 } } } }

	Suit.Label('Choose the server you want to join!', label_theme, center_x, start_y, panel_w, 60)

	local row_y = start_y + 80
	local btn_small = 50
	local name_w = panel_w - 2 * btn_small - 10

	local prev = Suit.Button('<', center_x, row_y, btn_small, btn_small)
	local opt = self.server_options[self.selected_index]
	Suit.Label(opt and opt.text or '', {
		align = 'center',
		color = { normal = { fg = { 1, 1, 1 } } }
	}, center_x + btn_small + 5, row_y, name_w, btn_small)
	local next_btn = Suit.Button('>', center_x + panel_w - btn_small, row_y, btn_small, btn_small)

	if prev.hit and #self.server_options > 0 then
		self.selected_index = self.selected_index - 1
		if self.selected_index < 1 then
			self.selected_index = #self.server_options
		end
		self.instance_input = self.server_options[self.selected_index].value
		self:load_background_image(self.instance_input)
	end

	if next_btn.hit and #self.server_options > 0 then
		self.selected_index = self.selected_index + 1
		if self.selected_index > #self.server_options then
			self.selected_index = 1
		end
		self.instance_input = self.server_options[self.selected_index].value
		self:load_background_image(self.instance_input)
	end

	if not self.is_instance_valid then
		Suit.Label('Invalid wildleague instance!', err_theme, center_x, start_y + 150, panel_w, 40)
	end

	local enter = Suit.Button('Enter', center_x, start_y + 210, panel_w, 50)
	if enter.hit then
		Constants.WORLD_SERVER = self.instance_input
		Constants.WORLD_SERVER_API = self:get_api_url(self.instance_input)

		local response = InstanceApi:validate(self.instance_input)
		if response.success then
			CONTEXT:change('auth')
		else
			self.is_instance_valid = false
		end
	end
end

function Initial:draw()
	love.graphics.draw(
		self.current_background,
		0, 0, 0,
		love.graphics.getWidth() / self.current_background:getWidth(),
		love.graphics.getHeight() / self.current_background:getHeight()
	)

	local default_scale = 0.3
	local center_logo = Layout:center(Images.logo_text:getWidth() * default_scale,
		Images.logo_text:getHeight() * default_scale)

	love.graphics.push()
	love.graphics.translate(center_logo.width, center_logo.height - 100)
	love.graphics.scale(default_scale)
	love.graphics.draw(Images.logo_text, 0, 0)
	love.graphics.pop()
end

function Initial:load_background_image(world_url)
	local world = nil

	for _, w in pairs(self.list_worlds) do
		if w.url == world_url then
			world = w
			break
		end
	end

	if world then
		local background = world.background
				and ImageHelper:load_from_url(world.background, 'background')
				or Images.background_cloud

		self.current_background = background
		Constants.WORLD_BACKGROUND = background
	end
end

function Initial:resize()

end

return Initial
