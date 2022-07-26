local suit = require 'suit'

local show_message = false
function love.update(dt)
	-- Put a button on the screen. If hit, show a message.
	if suit.Button("Hello, World!", 100,100, 300,30).hit then
		show_message = true
	end

	-- if the button was pressed at least one time, but a label below
	if show_message then
		suit.Label("How are you today?", 100,150, 300,30)
	end
end

function love.draw()
	suit.draw()
end
