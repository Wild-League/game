-- local yui = require('lib.yui')
local Layout = require('src.helpers.layout')
local Map = require('src.entities.map')
local Tower = require('src.entities.tower')
local Deck = require('src.entities.deck')
local Timer = require('src.helpers.timer')
local Constants = require('src.constants')
local nakama = require('lib.nakama.nakama')
local json = require('lib.json')

local Game = { timer = Timer:new(), card_selected = nil }

function Game:load()
	Map:load()

	coroutine.resume(coroutine.create(function()
		local objects = {
			{
				collection = 'selected_deck',
				key = 'selected_deck',
				userId = Constants.USER_ID
			}
		}

		local result = nakama.read_storage_objects(Constants.NAKAMA_CLIENT, objects)

		if result then
			local selected_deck = json.decode(result.objects[1].value)
			Deck:load(selected_deck)
		end
	end))
end

function Game:update(dt)
	Map:update(dt)

	Deck:update(dt)

	self.card_selected = Deck.card_selected

	self.timer:update(dt)
end

function Game:draw()
	Map:draw()

	Deck:draw()

	if self.card_selected then
		self.card_selected:preview(love.mouse.getX(), love.mouse.getY())
	end

	self:draw_timer()
end

-- private functions ---------

function Game:load_towers()
	local tower1 = Tower:load('left', 'top')

	local tower2 = Tower:load('left', 'bottom')
end

function Game:draw_timer()
	local center_background = Layout:center(100, 100)
	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle('fill', center_background.width, 10, 100, 50)
	love.graphics.setColor(1, 1, 1)

	local center_timer = Layout:center(100, 100)

	love.graphics.setColor(1, 1, 1)
	self.timer:draw(center_timer.width, 35, 100, 0)
	love.graphics.setColor(1, 1, 1)
end

return Game
