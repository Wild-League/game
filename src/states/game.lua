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
local PlayerStatus = require('src.ui.player-status')
local json = require('lib.json')
local Assets = require('src.assets')

local Game = {
	timer = Timer:new(),
	cards = {},
	-- enemy_cards = {}

	me_status = PlayerStatus:new('2d618372-1220-49b3-b22e-00f6ca0c12a5'),
	enemy_status = PlayerStatus:new('2d618372-1220-49b3-b22e-00f6ca0c12a5')
}

function Game:load()
    -- Carregar a imagem da torre
    Assets.TOWER = love.graphics.newImage('assets/tower.png')

	local cursor = love.mouse.newCursor('assets/cursor.png', 0, 0)
	love.mouse.setCursor(cursor)

	Map:load()
	self:load_towers()

	-- socket.on_match_data(Constants.SOCKET_CONNECTION, function(data)
	-- 	self:handle_received_data(data)
	-- end)

	Constants.USER_ID = '2d618372-1220-49b3-b22e-00f6ca0c12a5'
	self.cards[Constants.USER_ID] = {}
	-- self.cards[Constants.ENEMY_ID] = {}

	coroutine.resume(coroutine.create(function()
		local objects = {
			{
				collection = 'selected_deck',
				key = 'selected_deck',
				userId = '2d618372-1220-49b3-b22e-00f6ca0c12a5' -- Constants.USER_ID
			}
		}

		local result = nakama.read_storage_objects(Constants.NAKAMA_CLIENT, objects)

		if result then
			local selected_deck = json.decode(result.objects[1].value)
			Deck:load(selected_deck)
		end
	end))

	-- get enemy deck
	-- coroutine.resume(coroutine.create(function()
	-- 	local objects = {
	-- 		{
	-- 			collection = 'selected_deck',
	-- 			key = 'selected_deck',
	-- 			userId = Constants.ENEMY_ID
	-- 		}
	-- 	}

	-- 	local result = nakama.read_storage_objects(Constants.NAKAMA_CLIENT, objects)

	-- 	if result then
	-- 		local selected_deck = json.decode(result.objects[1].value)
	-- 		EnemyDeck:load(selected_deck)
	-- 	end
	-- end))
end

function Game:update(dt)
	Map:update(dt)

	Deck:update(dt)
	self:update_player_status()

	self.timer:update(dt)

	for _, card in pairs(self.cards[Constants.USER_ID]) do
		card:update(dt)
		card:get_enemies_in_range(self.cards[Constants.ENEMY_ID])
	end

	-- for _, enemy_card in pairs(self.cards[Constants.ENEMY_ID]) do
	-- 	enemy_card:update(dt)
	-- end
end

function Game:draw()
	Map:draw()

	Deck:draw()
	self:draw_player_status()

	for _, card in pairs(self.cards[Constants.USER_ID]) do
		card:draw()
	end

	-- for _, card in pairs(self.cards[Constants.ENEMY_ID]) do
	-- 	card:draw()
	-- end

	if Deck.card_selected then
		Deck.card_selected:preview(love.mouse.getX(), love.mouse.getY())
	end

	-- Desenhar as torres
	self:draw_towers()

	-- self:draw_timer()
end

-- private functions ---------

function Game:load_towers()
	local tower1 = Tower:load('left', 'top')
	local tower2 = Tower:load('left', 'bottom')
	local tower3 = Tower:load('right', 'top')
	local tower4 = Tower:load('right', 'bottom')

	self.towers = {tower1, tower2, tower3, tower4}
end

function Game:draw_towers()
	for _, tower in ipairs(self.towers) do
		tower:draw(tower.current_life)
	end
end

function Game:draw_timer()
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
	if user_id == Constants.USER_ID then return end

	if opcode == MatchEvents.card_spawn then
		-- mirroring enemy cards
		local enemy_card = self:get_enemy_card(data.card_name)
		enemy_card.char_x = love.graphics.getWidth() - data.x
		enemy_card.char_y = data.y

		self.cards[user_id][data.card_id] = Utils.copy_table(enemy_card)
	end

	if opcode == MatchEvents.card_action then
		print('hey changing action', opcode, user_id, data.card_id, data.action)
		self.cards[user_id][data.card_id].current_action = data.action
	end
end

function Game:get_enemy_card(card_name)
	for _, value in pairs(EnemyDeck.deck) do
		if value.name == card_name then
			return value
		end
	end
end

function Game:update_player_status()
	self.me_status:update()
	self.enemy_status:update()
end

function Game:draw_player_status()
	-- self.me_status:draw()
	-- self.enemy_status:draw()
end

return Game
