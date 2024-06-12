-- local yui = require('lib.yui')
local Layout = require('src.helpers.layout')
local Map = require('src.entities.map')
local Tower = require('src.entities.tower')
local Deck = require('src.entities.deck')
local MatchEvents = require('src.config.match_events')
local EnemyDeck = require('src.entities.enemy_deck')
local Timer = require('src.helpers.timer')
local Constants = require('src.constants')
local Utils = require('src.helpers.utils')
local nakama = require('lib.nakama.nakama')
local socket = require('lib.nakama.socket')
local json = require('lib.json')

local Game = {
	timer = Timer:new(),
	cards = {},
	enemy_cards = {}
}

function Game:load()
	Map:load()

	socket.on_match_data(Constants.SOCKET_CONNECTION, function(data)
		self:handle_received_data(data)
	end)

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

	-- get enemy deck
	coroutine.resume(coroutine.create(function()
		local objects = {
			{
				collection = 'selected_deck',
				key = 'selected_deck',
				userId = '54ef1560-ba9b-465d-a5eb-835c7c154534' -- Constants.ENEMY_ID
			}
		}

		local result = nakama.read_storage_objects(Constants.NAKAMA_CLIENT, objects)

		if result then
			local selected_deck = json.decode(result.objects[1].value)
			EnemyDeck:load(selected_deck)
		end
	end))
end

function Game:update(dt)
	Map:update(dt)

	Deck:update(dt)

	self.timer:update(dt)

	for _, card in pairs(self.cards) do
		card:update(dt)
	end

	for _, card in pairs(self.enemy_cards) do
		card:update(dt)
	end
end

function Game:draw()
	Map:draw()

	Deck:draw()

	for _, card in pairs(self.cards) do
		card:draw()
	end

	for _, card in pairs(self.enemy_cards) do
		card:draw()
	end

	if Deck.card_selected then
		Deck.card_selected:preview(love.mouse.getX(), love.mouse.getY())
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

function Game:handle_received_data(message)
	local data = json.decode(message.match_data.data)
	local user_id = message.match_data.presence.user_id
	local opcode = data.opcode

	self:handle_opcode_event(opcode, user_id, data)
end

function Game:handle_opcode_event(opcode, user_id, data)
	if opcode == MatchEvents.card_spawn then
		if Constants.USER_ID ~= user_id then
			-- mirroring enemy cards
			local enemy_card = self:get_enemy_card(data.card_name)
			enemy_card.char_x = love.graphics.getWidth() - data.x
			enemy_card.char_y = data.y

			self.enemy_cards[data.card_id] = enemy_card
		end
	end
end

function Game:get_enemy_card(card_name)
	for _, value in pairs(EnemyDeck.deck) do
		if value.name == card_name then
			return Utils.copy_table(value)
		end
	end
end

return Game
