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
	hand_intents = {},
	hand_intent_order = {},
	hand_baseline_state = nil,
	last_match_tick = 0,
	match_winner_id = nil,

	me_status = nil,
	enemy_status = nil
}

function Game:load()
	Assets.TOWER = love.graphics.newImage('assets/tower.png')

	local cursor = love.mouse.newCursor('assets/cursor.png', 0, 0)
	love.mouse.setCursor(cursor)

	Map:load()
	self.me_status = PlayerStatus:new(Constants.USER_ID)
	self.enemy_status = PlayerStatus:new(Constants.ENEMY_ID)

	socket.on_match_data(Constants.SOCKET_CONNECTION, function(data)
		self:handle_received_data(data)
	end)

	self.cards[Constants.USER_ID] = {}
	self.cards[Constants.ENEMY_ID] = {}
	self.pending_spawns = {}
	self.hand_intents = {}
	self.hand_intent_order = {}
	self.hand_baseline_state = nil
	self.last_match_tick = 0
	self.match_winner_id = nil

	self:load_towers()
	self:layout_towers()

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

	self:update_char_combat()

	for _, card in pairs(self.cards[Constants.USER_ID]) do
		if type(card) == 'table' and type(card.update) == 'function' then
			card:update(dt)
		end
	end

	for _, enemy_card in pairs(self.cards[Constants.ENEMY_ID]) do
		if type(enemy_card) == 'table' and type(enemy_card.update) == 'function' then
			enemy_card:update(dt)
		end
	end

	self:cleanup_finished_deaths()
end

function Game:draw()
	local w = Map:get_play_width()
	local play_h = Map:get_play_height()

	Deck:draw_background()
	Map:draw()
	-- Repaint deck strip over any map scale bleed (STI cannot be scissor-clipped safely).
	Deck:draw_background()

	love.graphics.setScissor(0, 0, w, play_h)
	if Deck.card_selected then
		Map:block_left_side()
	end

	love.graphics.setColor(1, 1, 1, 1)
	for entity_id, card in pairs(self.cards[Constants.USER_ID]) do
		if type(entity_id) == 'string' then
			card:draw()
		end
	end

	love.graphics.setColor(1, 1, 1, 1)
	for entity_id, card in pairs(self.cards[Constants.ENEMY_ID]) do
		if type(entity_id) == 'string' then
			card:draw()
		end
	end

	self:draw_towers()

	if Deck.card_selected then
		local mx, my = love.mouse.getPosition()
		love.graphics.setColor(1, 1, 1, 1)
		Deck.card_selected:preview(Map:clamp_player_x(mx), math.min(my, Deck:get_play_area_bottom()))
	end

	love.graphics.setScissor()

	love.graphics.setScissor(0, play_h, w, math.floor(love.graphics.getHeight()) - play_h)
	self:draw_player_status()
	Deck:draw()
	love.graphics.setScissor()

	-- self:draw_timer()
end

-- private functions ---------

function Game:update_char_combat()
	local allies = self.cards[Constants.USER_ID] or {}
	local enemies = self.cards[Constants.ENEMY_ID] or {}

	for _, card in pairs(allies) do
		if type(card.get_enemies_in_range) ~= 'function' then
			-- skip
		elseif card.type == 'char' then
			card:get_enemies_in_range(enemies)
		elseif card.type == 'spell' then
			card:get_enemies_in_range(enemies)
		end
	end

	for _, card in pairs(enemies) do
		if type(card.get_enemies_in_range) ~= 'function' then
			-- skip
		elseif card.type == 'char' then
			card:get_enemies_in_range(allies)
		elseif card.type == 'spell' then
			card:get_enemies_in_range(allies)
		end
	end
end

function Game:load_towers()
	table.insert(self.cards[Constants.USER_ID], Tower:load('right', 'top', Constants.USER_ID .. '_tower_top'))
	table.insert(self.cards[Constants.USER_ID], Tower:load('right', 'bottom', Constants.USER_ID .. '_tower_bottom'))
	table.insert(self.cards[Constants.ENEMY_ID], Tower:load('left', 'top', Constants.ENEMY_ID .. '_tower_top'))
	table.insert(self.cards[Constants.ENEMY_ID], Tower:load('left', 'bottom', Constants.ENEMY_ID .. '_tower_bottom'))
end

function Game:layout_towers()
	for _, bucket_id in ipairs({ Constants.USER_ID, Constants.ENEMY_ID }) do
		for _, entity in pairs(self.cards[bucket_id] or {}) do
			if type(entity) == 'table' and entity.type == 'tower' then
				Tower:reposition(entity)
			end
		end
	end
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
			local intent_id = data.client_intent_id
			local pending = intent_id and self.pending_spawns[intent_id]
			if pending and data.entity.entity_id ~= pending.card_id then
				local predicted = self.cards[Constants.USER_ID]
						and self.cards[Constants.USER_ID][pending.card_id]
				if predicted then
					predicted.card_id = data.entity.entity_id
					self.cards[Constants.USER_ID][data.entity.entity_id] = predicted
					self.cards[Constants.USER_ID][pending.card_id] = nil
					pending.card_id = data.entity.entity_id
				end
			end

			self:apply_entity_state(data.entity)
			if intent_id and self.hand_intents[intent_id] then
				self.hand_intents[intent_id].status = 'accepted'
			end
			self.pending_spawns[intent_id] = nil
			self:maybe_finalize_hand_intents()
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
			self:handle_reject_intent(data.client_intent_id)
		end
		return
	end

	if opcode == MatchEvents.damage_event then
		self:apply_damage_event(data)
		return
	end

	if opcode == MatchEvents.match_end then
		self.match_winner_id = data.winner_id
		return
	end
end

function Game:should_keep_local_spell(card)
	return card
			and card.type == 'spell'
			and (card.local_cast or card.predicted)
			and not card.pending_removal
end

function Game:handle_reject_intent(intent_id)
	local pending = self.pending_spawns[intent_id]
	local intent = self.hand_intents[intent_id]
	local played_card = intent and intent.played_card

	self.pending_spawns[intent_id] = nil
	self.hand_intents[intent_id] = nil
	self:remove_hand_intent_order(intent_id)

	if played_card and played_card.type == 'spell' then
		if self.hand_baseline_state then
			Deck:restore_hand_state(self.hand_baseline_state)
			played_card.is_card_loading = true
			played_card:reset_cooldown()
			Deck.card_selected = nil
			Deck.deck_selected = Deck:rotate_deck(played_card)
		end
		self:maybe_finalize_hand_intents()
		return
	end

	if self.cards[Constants.USER_ID] and pending then
		self.cards[Constants.USER_ID][pending.card_id] = nil
	end
	self:rebuild_hand_from_intents()
	self:maybe_finalize_hand_intents()
end

function Game:find_entity_by_id(entity_id, owner_id)
	if not entity_id then return nil end

	if owner_id then
		local bucket = resolve_card_bucket(owner_id)
		return self.cards[bucket] and self.cards[bucket][entity_id]
	end

	for _, bucket_id in ipairs({ Constants.USER_ID, Constants.ENEMY_ID }) do
		local entity = self.cards[bucket_id] and self.cards[bucket_id][entity_id]
		if entity then
			return entity
		end
	end

	return nil
end

function Game:flash_damage_target(entity_id, owner_id, current_life)
	local entity = self:find_entity_by_id(entity_id, owner_id)
	if not entity then return end

	if current_life ~= nil and entity.type == 'char' then
		entity.current_life = current_life
	end

	entity.damage_flash_until = love.timer.getTime() + 0.15
end

function Game:apply_damage_event(data)
	if not data then return end

	local hits = data.hits
	if not hits then
		if data.target_entity_id or data.entity_id then
			hits = { data }
		end
	end

	if hits then
		for _, hit in ipairs(hits) do
			self:flash_damage_target(
				hit.entity_id or hit.target_entity_id,
				hit.owner_id or hit.target_owner_id,
				hit.target_current_life
			)
		end
	end

	local source_id = data.source_entity_id
	local source_owner = data.source_owner_id or data.owner_id
	if source_id and source_owner then
		local spell = self:find_entity_by_id(source_id, source_owner)
		if spell and spell.type == 'spell' and type(spell.flash_hit) == 'function' then
			spell:flash_hit()
		end
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
		card.enemy = bucket == Constants.ENEMY_ID
		card._prev_char_x = nil
		if card.type == 'spell' then
			card.cast_elapsed = 0
			card.targets_hit = false
			card.hit_targets = {}
			card.enemies_around = {}
			card.local_cast = true
			card.predicted = true
		else
			card.predicted = false
		end
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
	card.current_life = entity.current_life or card.current_life
	card.life = entity.max_life or card.life
	local action = entity.action or card.current_action
	if card.type == 'spell' then
		if card.local_cast then
			action = 'attack'
		else
			action = action or 'attack'
		end
	elseif card.type == 'char' then
		action = action or 'walk'
		if (card.current_life or 0) <= 0 then
			action = 'death'
		elseif action == 'attack' then
			local opp_bucket = bucket == Constants.USER_ID and Constants.ENEMY_ID or Constants.USER_ID
			local opponents = self.cards[opp_bucket] or {}
			if type(card.has_attackable_enemy) == 'function' and not card:has_attackable_enemy(opponents) then
				action = 'walk'
			end
		end
	else
		action = action or card.current_action or 'walk'
	end
	card.current_action = action
	if card.current_action == 'death' and card.type == 'char' then
		card.pending_removal = true
		if not card.death_elapsed then
			card.death_elapsed = 0
		end
	elseif card.type == 'char' then
		card.pending_removal = false
		card.death_elapsed = 0
	elseif card.type ~= 'spell' then
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

	if card.type == 'spell' then
		if not self:should_keep_local_spell(card) then
			card.predicted = false
			card.local_cast = false
		end
	else
		card.predicted = false
	end
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
				if type(entity_id) == 'string' and (card.type == 'char' or card.type == 'spell') then
					local is_seen = seen[bucket_id] and seen[bucket_id][entity_id]
					if self:should_keep_local_spell(card) then
						-- client-driven cast VFX; ignore snapshot prune until finished
					elseif not is_seen and not card.predicted then
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
	local hand_state = payload._hand_state
	payload._hand_state = nil
	local intent_id = payload.client_intent_id

	if hand_state and not self.hand_baseline_state then
		self.hand_baseline_state = hand_state
	end

	local predicted = Utils.copy_table(card)
	predicted.card_id = payload.card_id
	predicted.char_x = payload.x
	predicted.char_y = payload.y
	predicted.predicted = true
	predicted.entity_version = 0
	predicted.enemy = false
	predicted.scale_x = 1

	if card.type == 'spell' then
		predicted.current_action = 'attack'
		predicted.cast_elapsed = 0
		predicted.targets_hit = false
		predicted.hit_targets = {}
		predicted.enemies_around = {}
		predicted.local_cast = true
		payload.card_type = 'spell'
	else
		predicted.current_action = 'walk'
	end

	self.cards[Constants.USER_ID][payload.card_id] = predicted
	self.pending_spawns[intent_id] = {
		card_id = payload.card_id,
		hand_state = hand_state
	}
	self.hand_intents[intent_id] = {
		id = intent_id,
		status = 'pending',
		played_card = hand_state and hand_state.played_card or card
	}
	table.insert(self.hand_intent_order, intent_id)

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

function Game:remove_hand_intent_order(intent_id)
	for i, id in ipairs(self.hand_intent_order) do
		if id == intent_id then
			table.remove(self.hand_intent_order, i)
			return
		end
	end
end

function Game:rebuild_hand_from_intents()
	if not self.hand_baseline_state then return end

	Deck:restore_hand_state(self.hand_baseline_state)

	for _, intent_id in ipairs(self.hand_intent_order) do
		local intent = self.hand_intents[intent_id]
		if intent then
			Deck:apply_hand_intent(intent)
		end
	end
end

function Game:maybe_finalize_hand_intents()
	for _, intent in pairs(self.hand_intents) do
		if intent.status == 'pending' then
			return
		end
	end

	self.hand_intents = {}
	self.hand_intent_order = {}
	self.hand_baseline_state = nil
end

function Game:queue_entity_removal(bucket, entity_id)
	local entities = self.cards[bucket]
	if not entities then return end

	local entity = entities[entity_id]
	if not entity then return end

	if entity.type == 'spell' then
		if self:should_keep_local_spell(entity) then
			return
		end
		entity.pending_removal = true
		return
	end

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
				elseif entity.pending_removal and entity.type == 'spell' then
					local elapsed = entity.cast_elapsed or 0
					local duration = 0.35
					if type(entity.get_cast_duration) == 'function' then
						duration = entity:get_cast_duration()
					end
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

function Game:draw_player_status()
	if not self.me_status or not self.enemy_status then return end

	local strip_top = Deck:get_strip_top()
	self.enemy_status:draw_badge('bottom_left', strip_top)
	self.me_status:draw_badge('bottom_right', strip_top)
end

function Game:mousepressed(x, y, button)
	Deck:mousepressed(x, y, button)
end

function Game:resize()
	Map:refresh_bounds(true)
	self:layout_towers()
end

return Game
