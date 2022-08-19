local Constants = require('./src/constants')

local Layout = {}

function Layout:Centralize(obj_width, obj_height)
	local width = Constants.WINDOW_SETTINGS.width
	local height = Constants.WINDOW_SETTINGS.height

	obj_width = obj_width or 0
	obj_height = obj_height or 0

	local central = {
		width = ((width - obj_width) / 2),
		height = ((height - obj_height) / 2)
	}

	return central
end

return Layout
