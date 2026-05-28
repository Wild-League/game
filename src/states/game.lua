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

local function resolve_card_bucket(owner_id)
	if owner_id == Constants.USER_ID then
		return Constants.USER_ID
	end
	return Constants.ENEMY_ID
end

local Game = {
	timer = Timer:new(),
	cards = {},
	pending_spawns = {},
	last_match_tick = 0,
	match_winner_id = nil,

	me_status = PlayerStatus:new('2d618372-1220-49b3-b22e-00f6ca0c12a5'),
	enemy_status = PlayerStatus:new('2d618372-1220-49b3-b22e-00f6ca0c12a5')
}

function Game:load()
	Assets.TOWER = love.graphics.newImage('assets/tower.png')

	local cursor = love.mouse.newCursor('assets/cursor.png', 0, 0)
	love.mouse.setCursor(cursor)

	Map:load()
	socket.on_match_data(Constants.SOCKET_CONNECTION, function(data)
		self:handle_received_data(data)
	end)

	self.cards[Constants.USER_ID] = {}
	self.cards[Constants.ENEMY_ID] = {}
	self.pending_spawns = {}
	self.last_match_tick = 0
	self.match_winner_id = nil

	self:load_towers()

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
			if selected_deck and selected_deck.cards and #selected_deck.cards > 0 then
				Deck:load(selected_deck)
			end
		end
	end))

	-- get enemy deck
	coroutine.resume(coroutine.create(function()
		local objects = {
			{
				collection = 'selected_deck',
				key = 'selected_deck',
				userId = Constants.ENEMY_ID
			}
		}

		local result = nakama.read_storage_objects(Constants.NAKAMA_CLIENT, objects)

		if result then
			local selected_deck = json.decode(result.objects[1].value)
			if selected_deck and selected_deck.cards and #selected_deck.cards > 0 then
				EnemyDeck:load(selected_deck)
			end
		end
	end))
end

function Game:update(dt)
	Map:update(dt)

	Deck:update(dt)
	self:update_player_status()

	self.timer:update(dt)

	for _, card in pairs(self.cards[Constants.USER_ID]) do
		card:update(dt)
	end

	for _, enemy_card in pairs(self.cards[Constants.ENEMY_ID]) do
		enemy_card:update(dt)
	end

	self:cleanup_finished_deaths()
end

function Game:draw()
	Map:draw()

	Deck:draw()
	self:draw_player_status()

	love.graphics.setColor(1, 1, 1, 1)
	for _, card in pairs(self.cards[Constants.USER_ID]) do
		card:draw()
	end

	love.graphics.setColor(1, 1, 1, 1)
	for _, card in pairs(self.cards[Constants.ENEMY_ID]) do
		card:draw()
	end

	if Deck.card_selected then
		love.graphics.setColor(1, 1, 1, 1)
		Deck.card_selected:preview(love.mouse.getX(), love.mouse.getY())
	end

	love.graphics.setColor(1, 1, 1, 1)
	self:draw_towers()

	-- self:draw_timer()
end

-- private functions ---------

function Game:load_towers()
	table.insert(self.cards[Constants.USER_ID], Tower:load('right', 'top', Constants.USER_ID .. '_tower_top'))
	table.insert(self.cards[Constants.USER_ID], Tower:load('right', 'bottom', Constants.USER_ID .. '_tower_bottom'))
	table.insert(self.cards[Constants.ENEMY_ID], Tower:load('left', 'top', Constants.ENEMY_ID .. '_tower_top'))
	table.insert(self.cards[Constants.ENEMY_ID], Tower:load('left', 'bottom', Constants.ENEMY_ID .. '_tower_bottom'))
end

function Game:draw_towers()
	for _, tower in ipairs(self.cards[Constants.USER_ID]) do
		tower:draw(tower.current_life)
	end
	for _, tower in ipairs(self.cards[Constants.ENEMY_ID]) do
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
	local opcode = tonumber(message.match_data.op_code)
	local user_id = nil
	if message.match_data.presence then
		user_id = message.match_data.presence.user_id
	end

	self:handle_opcode_event(opcode, user_id, data or {})
end

function Game:handle_opcode_event(opcode, user_id, data)
	if opcode == MatchEvents.state_snapshot then
		self:apply_snapshot(data)
		return
	end

	if opcode == MatchEvents.entity_spawned then
		if data and data.entity then
			self:apply_entity_state(data.entity)
			self.pending_spawns[data.client_intent_id] = nil
		end
		return
	end

	if opcode == MatchEvents.entity_updated then
		self:apply_entity_state(data)
		return
	end

	if opcode == MatchEvents.entity_removed then
		if data and data.entity_id and data.owner_id then
			local bucket = resolve_card_bucket(data.owner_id)
			if self.cards[bucket] then
				self:queue_entity_removal(bucket, data.entity_id)
			end
		end
		return
	end

	if opcode == MatchEvents.reject_intent then
		if data and data.client_intent_id and self.pending_spawns[data.client_intent_id] then
			local pending = self.pending_spawns[data.client_intent_id]
			if self.cards[Constants.USER_ID] then
				self.cards[Constants.USER_ID][pending.card_id] = nil
			end
			self.pending_spawns[data.client_intent_id] = nil
		end
		return
	end

	if opcode == MatchEvents.match_end then
		self.match_winner_id = data.winner_id
		return
	end
end

function Game:get_card_template(card_name, owner_id)
	local search_decks
	if owner_id == Constants.USER_ID then
		search_decks = { Deck.deck_selected, EnemyDeck.deck }
	else
		search_decks = { EnemyDeck.deck, Deck.deck_selected }
	end

	for _, deck in ipairs(search_decks) do
		for _, value in pairs(deck or {}) do
			if value.name == card_name then
				return value
			end
		end
	end
end

function Game:apply_entity_state(entity)
	if not entity or not entity.entity_id or not entity.owner_id then return end

	local bucket = resolve_card_bucket(entity.owner_id)

	if not self.cards[bucket] then
		self.cards[bucket] = {}
	end

	local card = self.cards[bucket][entity.entity_id]
	local is_new = card == nil
	if is_new then
		local template = self:get_card_template(entity.card_name, entity.owner_id)
		if not template then return end

		card = Utils.copy_table(template)
		card.card_id = entity.entity_id
		card.predicted = false
		card.enemy = bucket == Constants.ENEMY_ID
		card._prev_char_x = nil
		self.cards[bucket][entity.entity_id] = card
	end

	local prev_x = card.char_x
	local prev_y = card.char_y
	local has_authoritative_position = card.has_authoritative_position == true

	local incoming_version = entity.entity_version or 0
	local current_version = card.entity_version or -1
	if incoming_version < current_version then
		return
	end

	card.entity_version = incoming_version
	card.card_id = entity.entity_id
	card.enemy = bucket == Constants.ENEMY_ID
	card.current_action = entity.action or card.current_action or 'walk'
	card.current_life = entity.current_life or card.current_life
	card.life = entity.max_life or card.life
	if card.current_action ~= 'death' then
		card.pending_removal = false
		card.death_elapsed = 0
	end

	local screen_x = entity.x or card.char_x
	local target_y = entity.y or card.char_y

	if has_authoritative_position and prev_x and prev_y and card.predicted == false then
		local alpha = 0.35
		card.char_x = prev_x + (screen_x - prev_x) * alpha
		card.char_y = prev_y + (target_y - prev_y) * alpha
	else
		card.char_x = screen_x
		card.char_y = target_y
	end

	if card.type == 'char' then
		-- Keep previous screen X so Char:update can derive walk direction for scale_x.
		-- First apply: avoid template char_x (often 0) vs real spawn X (huge fake delta).
		if is_new then
			card._prev_char_x = screen_x
		else
			card._prev_char_x = prev_x
		end
		-- Network handlers may run after Char:update; set facing immediately for this frame.
		if card.char_x > card._prev_char_x then
			card.scale_x = -1
		elseif card.char_x < card._prev_char_x then
			card.scale_x = 1
		end
	end

	card.predicted = false
	card.has_authoritative_position = true
end

function Game:apply_snapshot(snapshot)
	if not snapshot or not snapshot.cards then return end
	if snapshot.match_tick and snapshot.match_tick < self.last_match_tick then return end

	self.last_match_tick = snapshot.match_tick or self.last_match_tick
	self.match_winner_id = snapshot.winner_id or self.match_winner_id

	local seen = {}

	for _, entity in ipairs(snapshot.cards) do
		local b = resolve_card_bucket(entity.owner_id)
		seen[b] = seen[b] or {}
		seen[b][entity.entity_id] = true
		self:apply_entity_state(entity)
	end

	for _, bucket_id in ipairs({ Constants.USER_ID, Constants.ENEMY_ID }) do
		local entities = self.cards[bucket_id]
		if entities then
			for entity_id, card in pairs(entities) do
				if type(entity_id) == 'string' and card.type == 'char' then
					local is_seen = seen[bucket_id] and seen[bucket_id][entity_id]
					if not is_seen and not card.predicted then
						self:queue_entity_removal(bucket_id, entity_id)
					end
				end
			end
		end
	end

	for _, tower_state in ipairs(snapshot.towers or {}) do
		local tower_bucket = resolve_card_bucket(tower_state.owner_id)
		local towers = self.cards[tower_bucket] or {}
		for _, tower in ipairs(towers) do
			if tower.type == 'tower' and tower.tower_id == tower_state.tower_id then
				tower.current_life = tower_state.current_life
			end
		end
	end
end

function Game:spawn_card_intent(card, payload)
	if not payload or not payload.client_intent_id or not payload.card_id then return end

	local predicted = Utils.copy_table(card)
	predicted.card_id = payload.card_id
	predicted.char_x = payload.x
	predicted.char_y = payload.y
	predicted.predicted = true
	predicted.current_action = 'walk'
	predicted.entity_version = 0
	predicted.enemy = false
	predicted.scale_x = 1

	self.cards[Constants.USER_ID][payload.card_id] = predicted
	self.pending_spawns[payload.client_intent_id] = {
		card_id = payload.card_id
	}

	coroutine.resume(coroutine.create(function()
		socket.match_data_send(
			Constants.SOCKET_CONNECTION,
			Constants.MATCH_ID,
			MatchEvents.spawn_intent,
			json.encode(payload),
			nil
		)
	end))
end

function Game:queue_entity_removal(bucket, entity_id)
	local entities = self.cards[bucket]
	if not entities then return end

	local entity = entities[entity_id]
	if not entity then return end

	if entity.type ~= 'char' then
		entities[entity_id] = nil
		return
	end

	entity.pending_removal = true
	if entity.current_action ~= 'death' then
		entity.current_action = 'death'
		entity.death_elapsed = 0
	end
end

function Game:cleanup_finished_deaths()
	for _, bucket in ipairs({ Constants.USER_ID, Constants.ENEMY_ID }) do
		local entities = self.cards[bucket]
		if entities then
			for entity_id, entity in pairs(entities) do
				if entity.pending_removal and entity.type == 'char' then
					local elapsed = entity.death_elapsed or 0
					local duration = entity.death_animation_duration or 0.35
					if elapsed >= duration then
						entities[entity_id] = nil
					end
				end
			end
		end
	end
end

-- TODO: UI player status in game
function Game:update_player_status() end

function Game:draw_player_status() end

function Game:mousepressed(x, y, button)
	Deck:mousepressed(x, y, button)
end

function Game:resize() end

return Game
