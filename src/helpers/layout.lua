local Constants = require('./src/constants')

local Layout = {}

function Layout:center(obj_width, obj_height)
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

function Layout:down_left(obj_width, obj_height)
	local height = Constants.WINDOW_SETTINGS.height

	obj_width = obj_width or 0
	obj_height = obj_height or 0

	local down_left = {
		width = obj_width,
		height = height - obj_height * 2
	}

	return down_left
end

function Layout:up_right(obj_width, obj_height)
	local width = Constants.WINDOW_SETTINGS.width

	obj_width = obj_width or 0
	obj_height = obj_height or 0

	local down_left = {
		width = width - obj_width * 2,
		height = obj_height
	}

	return down_left
end

return Layout
