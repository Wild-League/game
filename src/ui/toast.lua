local Fonts = require('src.ui.fonts')

local Toast = {
	queue = {},
	default_duration = 3,
	max_visible = 4,
	spacing = 12,
	width = 420,
	height = 72,
	padding = 12
}

local type_styles = {
	success = {
		background = { 0.10, 0.35, 0.18, 0.90 },
		border = { 0.26, 0.80, 0.42, 1 },
		title = 'Success'
	},
	info = {
		background = { 0.11, 0.22, 0.40, 0.90 },
		border = { 0.35, 0.62, 0.96, 1 },
		title = 'Info'
	},
	warning = {
		background = { 0.40, 0.27, 0.07, 0.92 },
		border = { 0.95, 0.73, 0.17, 1 },
		title = 'Warning'
	},
	error = {
		background = { 0.40, 0.10, 0.10, 0.92 },
		border = { 0.93, 0.34, 0.34, 1 },
		title = 'Error'
	}
}

local function normalize_type(toast_type)
	if type_styles[toast_type] ~= nil then
		return toast_type
	end

	return 'info'
end

local function clamp(value, min_value, max_value)
	return math.max(min_value, math.min(max_value, value))
end

function Toast:show(toast_type, message, duration, title)
	if message == nil or message == '' then return end

	local normalized_type = normalize_type(toast_type)

	table.insert(self.queue, {
		type = normalized_type,
		message = tostring(message),
		title = title or type_styles[normalized_type].title,
		duration = duration or self.default_duration,
		age = 0
	})
end

function Toast:success(message, duration, title)
	self:show('success', message, duration, title)
end

function Toast:info(message, duration, title)
	self:show('info', message, duration, title)
end

function Toast:warning(message, duration, title)
	self:show('warning', message, duration, title)
end

function Toast:error(message, duration, title)
	self:show('error', message, duration, title)
end

function Toast:update(dt)
	for index = #self.queue, 1, -1 do
		local toast = self.queue[index]
		toast.age = toast.age + dt

		if toast.age >= toast.duration then
			table.remove(self.queue, index)
		end
	end
end

function Toast:draw()
	if #self.queue == 0 then return end

	local base_x = love.graphics.getWidth() - self.width - 20
	local base_y = 20
	local visible_count = math.min(#self.queue, self.max_visible)

	for i = 1, visible_count do
		local toast = self.queue[i]
		local style = type_styles[toast.type]
		local time_left = toast.duration - toast.age
		local alpha = clamp(time_left / 0.3, 0, 1)
		local y = base_y + (i - 1) * (self.height + self.spacing)

		love.graphics.setColor(style.background[1], style.background[2], style.background[3], style.background[4] * alpha)
		love.graphics.rectangle('fill', base_x, y, self.width, self.height, 8, 8)

		love.graphics.setColor(style.border[1], style.border[2], style.border[3], style.border[4] * alpha)
		love.graphics.setLineWidth(2)
		love.graphics.rectangle('line', base_x, y, self.width, self.height, 8, 8)

		love.graphics.setColor(1, 1, 1, alpha)
		love.graphics.setFont(Fonts.jura(18))
		love.graphics.print(toast.title, base_x + self.padding, y + 8)

		love.graphics.setFont(Fonts.jura(14))
		love.graphics.printf(toast.message, base_x + self.padding, y + 34, self.width - (self.padding * 2), 'left')
	end

	love.graphics.setColor(1, 1, 1, 1)
end

return Toast
