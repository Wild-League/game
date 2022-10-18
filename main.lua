local Suit = require('./lib/suit')
local Constants = require('./src/constants')

local Context = require('./src/context')

local DT = 0

function love.load()
	-- initialize the global state manager
	CONTEXT = Context;

	love.window.setMode(Constants.WINDOW_SETTINGS.width, Constants.WINDOW_SETTINGS.height, { resizable = true })
end

function love.update(dt)
	DT = dt
	CONTEXT:current(dt)
	-- return

	-- local button_central = Layout:Centralize(WINDOW_SETTINGS.width, WINDOW_SETTINGS.height, 280, 72)
	-- local play_button = Suit.ImageButton(BUTTON, { hovered = BUTTON_HOVER }, button_central.width, (button_central.height + 200))

	-- if play_button.hit then
	-- 	local data = Saver:retrieveData()

	-- 	if data ~= nil then
	-- 		Constants.LOGGED_USER = data
	-- 	else
	-- 		GET_DATA = true
	-- 	end
	-- end

	-- if GET_DATA and not INITIAL_PAGE then
		-- Suit.Label('nickname: ', { align='center' }, 10, 0, 200, 30)
		-- Suit.Input(nickname_input, 10, 40, 200, 30)
	-- 	local save_nick = Suit.Button('Enter', 10, 80, 200, 30)

	-- 	if save_nick.hit then
	-- 		print('entering game...')
	-- 		INITIAL_PAGE = true
	-- 	end
	-- end

	-- if INITIAL_PAGE then
	-- 	local welcome_center = Layout:Centralize(WINDOW_SETTINGS.width, WINDOW_SETTINGS.height, 100, 50)
	-- 	Suit.Label('Welcome to Wild League', { align='center' }, welcome_center.width, welcome_center.height, 100, 50)
	-- end
	Suit.draw()
end

function love.draw()
	CONTEXT:current(DT)
	-- if not GET_DATA then
	-- 	local title_central = Layout:Centralize(WINDOW_SETTINGS.width, WINDOW_SETTINGS.height, 659, 213)
	-- 	love.graphics.draw(GAME_TITLE, title_central.width, title_central.height)
	-- end

	-- if not CAN_MOVE then
	-- 	local center  = Layout:Centralize(WINDOW_SETTINGS.width, WINDOW_SETTINGS.height, 50, 50)
	-- 	RECTANGLE = { x = center.width, y = center.height, width = 50, height = 50 }
	-- end

	-- love.graphics.rectangle("line", RECTANGLE.x, RECTANGLE.y, RECTANGLE.width, RECTANGLE.height)

	Suit.draw()
end

function love.resize(width, height)
	Constants.WINDOW_SETTINGS.width = width
	Constants.WINDOW_SETTINGS.height = height
end

-- CAN_MOVE = false

-- function love.mousepressed(x, y, button)
-- 	if button == 1 then -- left
-- 		if (x >= RECTANGLE.x and x <= (RECTANGLE.x + RECTANGLE.width))
-- 			and (y >= RECTANGLE.y and y <= (RECTANGLE.y + RECTANGLE.height)) then
-- 				CAN_MOVE = true
-- 				print('can_move', CAN_MOVE)
-- 		end
-- 	end
-- end

-- function love.mousereleased(x, y, button)
-- 	if button == 1 then -- left
-- 		CAN_MOVE = false
-- 		print('cannot move', CAN_MOVE)
-- 	end
-- end

-- function love.mousemoved(x, y, dx, dy)
-- 	if CAN_MOVE then
-- 		RECTANGLE.x = x
-- 		RECTANGLE.y = y
-- 	end
-- end
