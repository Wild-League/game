local Layout = {}

function Layout:Centralize(width, height, obj_width, obj_height)
	local central = {
		width = ((width - obj_width) / 2),
		height = ((height - obj_height) / 2)
	}

	return central
end

return Layout
