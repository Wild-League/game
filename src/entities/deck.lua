local Map = require('src.entities.map')
local Card = require('src.entities.card')
local MatchUi = require('src.config.match_ui')
local Images = require('src.ui.images')
local uuid = require('lib.uuid')

local DECK_BG = {
	base = { 18 / 255, 16 / 255, 22 / 255, 1 },
	top = { 52 / 255, 42 / 255, 36 / 255, 1 },
	bottom = { 12 / 255, 11 / 255, 16 / 255, 1 },
	panel = { 38 / 255, 32 / 255, 44 / 255, 0.72 },
	panel_edge = { 24 / 255, 20 / 255, 28 / 255, 0.9 },
	accent = { 210 / 255, 168 / 255, 72 / 255, 1 },
	accent_shadow = { 0, 0, 0, 0.35 },
	highlight = { 1, 1, 1, 0.07 },
}

local PREVIEW_QUEUE_SCALE = 0.65
local BADGE_MARGIN = 120

local Deck = {
	ui_height = MatchUi.deck_ui_height,
	default_scale = 1,
	hand_slot_spacing = 80,
	selectable_cards = 4,

	deck_selected = {},

	-- if num cards greather than `selectable_cards`
	queue_next_cards = {},

	-- the 4 cards that the player can select, with animations defined
	playable_cards = {},

	-- only one card can be selected at a time
	card_selected = nil,
}

local function clone_array(array)
	local cloned = {}
	for i, value in ipairs(array or {}) do
		cloned[i] = value
	end
	return cloned
end

local function point_in_rect(px, py, rx, ry, rw, rh)
	return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
end

local function capture_card_runtime_state(card)
	if not card then return nil end
	return {
		is_card_loading = card.is_card_loading == true,
		current_cooldown = card.current_cooldown,
		selectable = card.selectable,
		preview_card = card.preview_card,
		char_x = card.char_x,
		char_y = card.char_y
	}
end

local function capture_cards_runtime_state(cards)
	local states = {}
	for _, card in ipairs(cards or {}) do
		local state = capture_card_runtime_state(card)
		if state then
			states[card] = state
		end
	end
	return states
end

function Deck:load(deck_selected)
	self.deck_selected = {}
	self.queue_next_cards = {}
	self.playable_cards = {}
	self.card_selected = nil

	-- initiliaze cards
	for _, card in ipairs(deck_selected.cards) do
		table.insert(self.deck_selected, Card:new(card))
	end

	-- if greather than `selectable_cards`, should rotate cards
	if #self.deck_selected > self.selectable_cards then
		-- get the cards left from deck and make unselectable
		-- and add to queue
		for i = self.selectable_cards + 1, #self.deck_selected do
			self.deck_selected[i].selectable = false
			table.insert(self.queue_next_cards, self.deck_selected[i])
		end

		self.queue_next_cards[1].preview_card = true
	end
end

function Deck:update(dt)
	-- related to UI
	self:define_positions()

	self:check_cooldown(dt)
end

function Deck:get_strip_top()
	return Map:get_play_height()
end

function Deck:get_play_area_bottom()
	return self:get_strip_top() - 1
end

function Deck:is_in_strip(y)
	return y >= self:get_strip_top()
end

local function lerp_color(a, b, t)
	return {
		a[1] + (b[1] - a[1]) * t,
		a[2] + (b[2] - a[2]) * t,
		a[3] + (b[3] - a[3]) * t,
		(a[4] or 1) + ((b[4] or 1) - (a[4] or 1)) * t,
	}
end

local function set_color(c)
	love.graphics.setColor(c[1], c[2], c[3], c[4] or 1)
end

local function draw_vertical_gradient(x, y, w, h, color_top, color_bottom, bands)
	bands = bands or 14
	local band_h = h / bands
	for i = 0, bands - 1 do
		local t = (i + 0.5) / bands
		set_color(lerp_color(color_top, color_bottom, t))
		love.graphics.rectangle('fill', x, y + i * band_h, w, band_h + 1)
	end
end

local function draw_texture_overlay(strip_top, window_w, ui_height)
	local img = Images.background_deck
	if not img or not img.getDimensions then return end

	local iw, ih = img:getDimensions()
	if iw <= 0 or ih <= 0 then return end

	local scale = math.max(window_w / iw, ui_height / ih)
	local draw_w = iw * scale
	local draw_h = ih * scale
	local draw_x = (window_w - draw_w) / 2
	local draw_y = strip_top + (ui_height - draw_h) / 2

	love.graphics.setColor(1, 1, 1, 0.18)
	love.graphics.draw(img, draw_x, draw_y, 0, scale, scale)
end

local function draw_subtle_grid(strip_top, window_w, ui_height)
	local cell = 24
	local cols = math.ceil(window_w / cell)
	local rows = math.ceil(ui_height / cell)

	for row = 0, rows - 1 do
		for col = 0, cols - 1 do
			if (col + row) % 2 == 0 then
				set_color({ 1, 1, 1, 0.035 })
			else
				set_color({ 1, 1, 1, 0.015 })
			end
			love.graphics.rectangle(
				'fill',
				col * cell,
				strip_top + row * cell,
				cell,
				cell
			)
		end
	end
end

local function draw_hand_panel(strip_top, window_w, ui_height)
	local panel_x = BADGE_MARGIN
	local panel_w = window_w - BADGE_MARGIN * 2
	local panel_y = strip_top + 10
	local panel_h = ui_height - 20
	local radius = 8

	set_color(DECK_BG.panel_edge)
	love.graphics.rectangle('fill', panel_x, panel_y, panel_w, panel_h, radius, radius)

	set_color(DECK_BG.panel)
	love.graphics.rectangle('fill', panel_x + 2, panel_y + 2, panel_w - 4, panel_h - 4, radius - 2, radius - 2)

	set_color(DECK_BG.highlight)
	love.graphics.rectangle('line', panel_x + 1.5, panel_y + 1.5, panel_w - 3, panel_h - 3, radius - 1, radius - 1)
end

local function draw_top_accent(strip_top, window_w)
	set_color(DECK_BG.accent_shadow)
	love.graphics.rectangle('fill', 0, strip_top + 2, window_w, 3)

	set_color(DECK_BG.accent)
	love.graphics.rectangle('fill', 0, strip_top, window_w, 2)

	set_color(DECK_BG.highlight)
	love.graphics.rectangle('fill', 0, strip_top + 5, window_w, 1)
end

function Deck:draw_background()
	local window_w = love.graphics.getWidth()
	local strip_top = self:get_strip_top()
	local ui_height = self.ui_height

	love.graphics.setScissor(0, strip_top, window_w, ui_height)

	-- Opaque base (covers map bleed when this runs after the map pass).
	set_color(DECK_BG.base)
	love.graphics.rectangle('fill', 0, strip_top, window_w, ui_height)

	draw_vertical_gradient(0, strip_top, window_w, ui_height, DECK_BG.top, DECK_BG.bottom)
	draw_texture_overlay(strip_top, window_w, ui_height)
	draw_subtle_grid(strip_top, window_w, ui_height)
	draw_hand_panel(strip_top, window_w, ui_height)
	draw_top_accent(strip_top, window_w)

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setScissor()
end

function Deck:draw()

	if self.card_selected then
		self:highlight_selected_card(self.card_selected)
	end

	local s = self.default_scale
	for i = 1, self.selectable_cards do
		local card = self.deck_selected[i]

		-- just in case the deck has less than `selectable_cards`
		if card == nil then return end

		love.graphics.draw(card.img_card, card.x, card.y, 0, s, s)

		if card.is_card_loading then
			card:draw_loading_animation(s)
		end
	end

	if #self.queue_next_cards > 0 then
		self:draw_preview_card()
	end
end

function Deck:define_positions()
	local window_w = love.graphics.getWidth()
	local strip_top = self:get_strip_top()
	local s = self.default_scale
	local step = self.hand_slot_spacing

	local first_card = self.deck_selected[1]
	if first_card == nil then return end

	local card_w = first_card.img_card:getWidth() * s
	local card_h = first_card.img_card:getHeight() * s
	local hand_count = math.min(self.selectable_cards, #self.deck_selected)
	local total_width = (hand_count - 1) * step + card_w
	local start_x = (window_w - total_width) / 2
	local card_y = strip_top + (self.ui_height - card_h) / 2

	for i = 1, self.selectable_cards do
		local card = self.deck_selected[i]
		if card == nil then return end

		card.x = start_x + (i - 1) * step
		card.y = card_y
	end

	if #self.deck_selected > self.selectable_cards and self.queue_next_cards[1] then
		local preview = self.queue_next_cards[1]
		local ps = s * PREVIEW_QUEUE_SCALE
		local preview_w = preview.img_card:getWidth() * ps
		local preview_h = preview.img_card:getHeight() * ps
		local hand_end_x = start_x + (hand_count - 1) * step + card_w
		local max_preview_x = window_w - BADGE_MARGIN - preview_w

		preview.x = math.min(hand_end_x + 12, max_preview_x)
		preview.y = strip_top + (self.ui_height - preview_h) / 2
		preview.preview_card = true
	end
end

-- the next card on queue
function Deck:draw_preview_card()
	local ps = self.default_scale * PREVIEW_QUEUE_SCALE
	love.graphics.draw(self.queue_next_cards[1].img_card, self.queue_next_cards[1].x, self.queue_next_cards[1].y, 0, ps, ps)
end

function Deck:highlight_selected_card(card)
	local s = self.default_scale
	local w = card.img_card:getWidth() * s
	local h = card.img_card:getHeight() * s
	love.graphics.setColor(1, 0, 0)
	love.graphics.rectangle("fill", card.x - 4, card.y - 4, w + 8, h + 8)
	love.graphics.setColor(1, 1, 1)
end

function Deck:set_queue_next_cards(deck)
	if #deck == 0 then return end

	self.queue_next_cards = {}

	for i = self.selectable_cards + 1, #deck do
		table.insert(self.queue_next_cards, deck[i])
	end

	self.queue_next_cards[1].preview_card = true
end

-- add the just spawned card to the end of the queue_next_cards
-- and the first one in the queue to the deck
function Deck:rotate_deck(card)
	if #self.deck_selected <= 4 then
		return self.deck_selected
	end

	self.queue_next_cards[1].preview_card = false
	self.queue_next_cards[1].selectable = true

	local card_to_add = self.queue_next_cards[1]

	local new_deck = self.deck_selected

	local index_to_remove = nil

	for i = 1, #new_deck do
		local curr_card = new_deck[i]

		if curr_card then
			if curr_card.name == card.name then
				new_deck[i] = card_to_add
			end

			if curr_card.name == card_to_add.name then
				index_to_remove = i
			end
		end
	end

	if index_to_remove then
		table.remove(new_deck, index_to_remove)
	end

	new_deck[#new_deck + 1] = card

	self:set_queue_next_cards(new_deck)
	self:define_positions()

	return new_deck
end

-- used for check cooldown timer each second
-- local countdown_timer = 1

function Deck:check_cooldown(dt)
	for i = 1, #self.deck_selected do
		local card = self.deck_selected[i]
		if card.is_card_loading then
			card.current_cooldown = card.current_cooldown - dt
			if card.current_cooldown <= 0 then
				card.is_card_loading = false
				card.current_cooldown = card.cooldown
			end
		end
	end
end

function Deck:capture_hand_state(card)
	local runtime_states = capture_cards_runtime_state(self.deck_selected)
	for _, queued_card in ipairs(self.queue_next_cards or {}) do
		local state = capture_card_runtime_state(queued_card)
		if state then
			runtime_states[queued_card] = state
		end
	end

	return {
		card_selected = self.card_selected,
		deck_selected = clone_array(self.deck_selected),
		queue_next_cards = clone_array(self.queue_next_cards),
		card_runtime_states = runtime_states,
		played_card = card,
		played_card_loading = card and card.is_card_loading or false,
		played_card_cooldown = card and card.current_cooldown or nil
	}
end

function Deck:restore_hand_state(state)
	if not state then return end

	self.deck_selected = clone_array(state.deck_selected)
	self.queue_next_cards = clone_array(state.queue_next_cards)
	self.card_selected = state.card_selected

	for card, card_state in pairs(state.card_runtime_states or {}) do
		card.is_card_loading = card_state.is_card_loading == true
		card.current_cooldown = card_state.current_cooldown
		card.selectable = card_state.selectable
		card.preview_card = card_state.preview_card
		card.char_x = card_state.char_x
		card.char_y = card_state.char_y
	end

	local played_card = state.played_card
	if played_card then
		played_card.is_card_loading = state.played_card_loading == true
		if state.played_card_cooldown ~= nil then
			played_card.current_cooldown = state.played_card_cooldown
		end
	end

	if #self.queue_next_cards > 0 and self.queue_next_cards[1] then
		self.queue_next_cards[1].preview_card = true
	end

	self:define_positions()
end

function Deck:apply_hand_intent(intent)
	if not intent or not intent.played_card then return end

	local card = intent.played_card
	card.is_card_loading = true
	card:reset_cooldown()

	self.card_selected = nil
	self.deck_selected = self:rotate_deck(card)
end

function Deck:mousepressed(x, y, button)
	if button ~= 1 then return end

	local s = self.default_scale
	local clicked_card = nil

	for _, card in ipairs(self.deck_selected) do
		local cw = card.img_card:getWidth() * s
		local ch = card.img_card:getHeight() * s
		if point_in_rect(x, y, card.x, card.y, cw, ch) then
			clicked_card = card
			break
		end
	end

	if clicked_card then
		if not clicked_card.is_card_loading then
			if self.card_selected == clicked_card then
				self.card_selected = nil
			else
				self.card_selected = clicked_card
			end
		end
		return
	end

	if not self.card_selected then return end

	if self:is_in_strip(y) then return end

	local card = self.card_selected
	card.char_x = Map:clamp_player_x(x)
	card.char_y = math.min(y, self:get_play_area_bottom())

	card.is_card_loading = true
	card:reset_cooldown()

	local hand_state = self:capture_hand_state(card)
	hand_state.played_card_loading = true
	hand_state.played_card_cooldown = card.current_cooldown

	local payload_card = {
		client_intent_id = uuid:generate(),
		card_id = uuid:generate(),
		card_name = card.name,
		x = card.char_x,
		y = card.char_y
	}
	payload_card._hand_state = hand_state

	local Game = require('src.states.game')
	Game:spawn_card_intent(card, payload_card)

	self.card_selected = nil
	self.deck_selected = self:rotate_deck(card)
end

return Deck
