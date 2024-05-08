local Layout = {}

function Layout:center(obj_width, obj_height)
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()

	obj_width = obj_width or 0
	obj_height = obj_height or 0

	local center = {
		width = ((width - obj_width) / 2),
		height = ((height - obj_height) / 2)
	}

	return center
end

function Layout:down_left(obj_width, obj_height)
	local height = love.graphics.getHeight()

	obj_width = obj_width or 0
	obj_height = obj_height or 0

	local down_left = {
		width = obj_width,
		height = height - obj_height * 2
	}

	return down_left
end

function Layout:down_right(obj_width, obj_height)
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()

	obj_width = obj_width or 0
	obj_height = obj_height or 0

	local down_right = {
		width = width - obj_width,
		height = height - obj_height
	}

	return down_right
end

function Layout:up_right(obj_width, obj_height)
	local width = love.graphics.getWidth()

	obj_width = obj_width or 0
	obj_height = obj_height or 0

	local down_left = {
		width = width - obj_width * 2,
		height = obj_height
	}

	return down_left
end

function Layout.centerRectOnScreen(w, h)
    local x = math.floor((love.graphics.getWidth() - w) / 2)
    local y = math.floor((love.graphics.getHeight() - h) / 2)

    return x, y
end

return Layout
