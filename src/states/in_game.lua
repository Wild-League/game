local Layout = require('./src/helpers/layout')
local anim8 = require('./lib/anim8')
local Assets = require('./src/assets')
local Constants = require('./src/constants')
local center = Layout:Centralize(34, 36) -- sprite size

local initial = 600

local background = Assets.WORLD

local tower = Assets.TOWER

local tower2 = Assets.TOWER

local tower3 = Assets.TOWER

local tower4 = Assets.TOWER

local world_detail = Assets.WORLD_DETAIL

local deck = {
	card_1 = {
		img = Assets.CHAR1.CARD,
		initial_position = {
			x = 200,
			y = 620,
		},
		x = 200,
		y = 620,
		can_move = false
	},
	card_2 = {
		img = Assets.CHAR1.CARD,
		initial_position = {
			x = 300,
			y = 620,
		},
		x = 300,
		y = 620,
		can_move = false
	},
	card_3 = {
		img = Assets.CHAR1.CARD,
		initial_position = {
			x = 400,
			y = 620,
		},
		x = 400,
		y = 620,
		can_move = false
	},
	card_4 = {
		img = Assets.CHAR1.CARD,
		initial_position = {
			x = 500,
			y = 620,
		},
		x = 500,
		y = 620,
		can_move = false
	},
}

local In_Game = {
	__call = function(self)
		self:load()
		self:draw()
	end,
	walk_animation = {}
}

setmetatable(In_Game, In_Game)

function love.mousepressed(x, y, button)
	if button == 1 then -- left
		for i = 1, 4 do
			local card = deck['card_'..i]
			if x >= card.x and x <= (card.x + card.img:getWidth())
				and y >= card.y and y <= (card.y + card.img:getHeight()) then
					card.can_move = true
			end
		end
	end
end

function love.mousereleased(x, y, button)
	if button == 1 then
		for i = 1, 4 do
			local card = deck['card_'..i]
			if card.can_move == true then
				card.can_move = false
				card.x = card.initial_position.x
				card.y = card.initial_position.y
			end
		end
	end
end

function In_Game:load()
	-- draw world background
	for i = 0, Constants.WINDOW_SETTINGS.width / background:getWidth() do
		love.graphics.setColor(255,255,255)
		for j = 0, Constants.WINDOW_SETTINGS.height / background:getHeight() do
			love.graphics.draw(background, i * background:getWidth(), j * background:getHeight())
		end
	end

	-- draw world details
	love.graphics.draw(world_detail, center.width, center.height)

	love.graphics.draw(tower, 100, 170)

	love.graphics.draw(tower2, 530, 170)

	love.graphics.draw(tower3, 100, 600)

	love.graphics.draw(tower4, 530, 600)

	for i = 1, 4 do
		local card = deck['card_'..i]
		love.graphics.draw(card.img, card.x, card.y)
	end

	WALKING = Assets.CHAR1.WALKING

	local grid = anim8.newGrid(34, 36, WALKING:getWidth(), WALKING:getHeight())

	self.walk_animation = anim8.newAnimation(grid('2-3', 1), 12)
	self.stop_animation = anim8.newAnimation(grid('1-1', 1), 12)
end

function In_Game:draw()
	local x,y = love.mouse.getPosition()

	for i = 1, 4 do
		local card = deck['card_'..i]
		if card.can_move then
			card.x = x - (card.img:getWidth() / 2)
			card.y = y - (card.img:getHeight() / 2)
		end
	end

	-- initial = initial - 0.5

	-- if initial <= 280 then
	-- 	self.stop_animation:draw(WALKING, center.width, 280)
	-- 	return
	-- end

	-- self.walk_animation:update(initial)
	-- self.walk_animation:draw(WALKING, center.width, initial)
end

return In_Game
