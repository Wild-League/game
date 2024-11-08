local Fonts = require('src.ui.fonts')

local Alert = {
	alerts = {}
}

--[[
	duration: in seconds
]]
function Alert:show(title, message, duration)
	table.insert(self.alerts, {
		title = title,
		message = message,
		duration = duration or 3,
		start_time = love.timer.getTime()
	})
end

function Alert:draw()
	if #self.alerts == 0 then return end

	local current_time = love.timer.getTime()

	for i, alert in ipairs(self.alerts) do
		local elapsed = current_time - alert.start_time

		if elapsed >= alert.duration then
			table.remove(self.alerts, i)
		end

		love.graphics.setFont(Fonts.jura(22))

		local mainX = 20
		local mainY = love.graphics.getHeight() - 100

		love.graphics.setColor(0, 0, 0, 0.5)
		love.graphics.rectangle('fill', mainX, mainY, 300, 80)
		love.graphics.setColor(1, 1, 1, 1)

		love.graphics.printf(alert.title, mainX - 50, mainY + 10, 300, 'center')

		if alert.message then
			love.graphics.setFont(Fonts.jura(15))
			love.graphics.printf(alert.message, mainX - 65, mainY + 50, 300, "right")
		end
	end
end

return Alert
