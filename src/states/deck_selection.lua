local DeckApi = require('src.api.deck')
local CardsApi = require('src.api.cards')
local FriendListSidebar = require('src.ui.friend-list-sidebar')
local HeaderBar = require('src.ui.header-bar')
local Image = require('src.helpers.image')
local Toast = require('src.ui.toast')
local Suit = require('lib.suit')
local Fonts = require('src.ui.fonts')

local DeckSelection = {
	max_decks = 10,
	friends = {},
	show_add_friend_input = false,
	friend_input = { text = '' },
	new_deck_input = { text = '' },
	catalog = {},
	catalog_by_id = {},
	catalog_images = {},
	catalog_pending = {},
	deck_summaries = {},
	active_deck_id = nil,
	active_deck = nil,
	catalog_scroll = 0,
	deck_scroll = 0,
	deck_list_scroll = 0,
	drag = nil,
	busy = false,
	ui_top = 118,
	cell_w = 96,
	cell_h = 112,
	cell_gap = 8,
}

local function point_in_rect(px, py, rx, ry, rw, rh)
	return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
end

local function layout_regions(self)
	local ww, wh = love.graphics.getDimensions()
	local sidebar = FriendListSidebar.width
	local content_w = ww - sidebar
	local content_h = wh - HeaderBar.height
	local left_w = 172
	local mid_x = 12 + left_w
	local rest_w = content_w - left_w - 36
	local catalog_w = math.max(200, math.floor(rest_w * 0.52))
	local deck_w = rest_w - catalog_w - 12

	self.regions = {
		content_x = 0,
		content_y = HeaderBar.height,
		content_w = content_w,
		content_h = content_h,
		deck_list = { x = 12, y = self.ui_top, w = left_w, h = content_h - (self.ui_top - HeaderBar.height) - 8 },
		catalog = { x = mid_x, y = self.ui_top, w = catalog_w, h = content_h - (self.ui_top - HeaderBar.height) - 8 },
		deck_zone = { x = mid_x + catalog_w + 12, y = self.ui_top, w = deck_w, h = content_h - (self.ui_top - HeaderBar.height) - 8 },
	}
	local cols = math.max(1, math.floor((catalog_w - 16) / (self.cell_w + self.cell_gap)))
	self.catalog_cols = cols
end

function DeckSelection:reload_data()
	self.deck_summaries = DeckApi:get_list()
	table.sort(self.deck_summaries, function(a, b)
		return a.id < b.id
	end)

	self.catalog = CardsApi:get_list({ limit = 500 })

	self.catalog_by_id = {}
	self.catalog_images = {}
	self.catalog_pending = {}
	for _, c in ipairs(self.catalog) do
		self.catalog_by_id[c.id] = c
		table.insert(self.catalog_pending, c.id)
	end

	if self.active_deck_id then
		self.active_deck = DeckApi:get_deck_by_id(self.active_deck_id)
	end
end

function DeckSelection:card_ids_in_deck()
	local ids = {}
	if not self.active_deck or not self.active_deck.cards then return ids end
	for _, c in ipairs(self.active_deck.cards) do
		table.insert(ids, c.id)
	end
	return ids
end

function DeckSelection:has_card_in_deck(card_id)
	local want = tonumber(card_id)
	for _, c in ipairs(self:card_ids_in_deck()) do
		if tonumber(c) == want then return true end
	end
	return false
end

function DeckSelection:pick_catalog_index(mx, my)
	local r = self.regions.catalog
	if not point_in_rect(mx, my, r.x, r.y, r.w, r.h) then return nil end
	local cols = self.catalog_cols
	local inner_w = self.cell_w + self.cell_gap
	local inner_h = self.cell_h + self.cell_gap
	local lx = mx - r.x - 8
	local ly = my - r.y - 8 + self.catalog_scroll
	if lx < 0 or ly < 0 then return nil end
	local col = math.floor(lx / inner_w)
	if col < 0 or col >= cols then return nil end
	local row = math.floor(ly / inner_h)
	local idx = row * cols + col + 1
	if idx >= 1 and idx <= #self.catalog then
		return idx
	end
	return nil
end

function DeckSelection:pick_deck_list_row(mx, my)
	local r = self.regions.deck_list
	if not point_in_rect(mx, my, r.x, r.y, r.w, r.h) then return nil end
	local ly = my - r.y - 30 + self.deck_list_scroll
	local row = math.floor(ly / 32)
	if row >= 0 and row < #self.deck_summaries then
		return row + 1
	end
	return nil
end

function DeckSelection:pick_deck_remove(mx, my)
	if not self.active_deck or not self.active_deck.cards then return nil end
	local r = self.regions.deck_zone
	if not point_in_rect(mx, my, r.x, r.y, r.w, r.h) then return nil end
	local cols = math.max(1, math.floor((r.w - 16) / (self.cell_w + self.cell_gap)))
	local inner_w = self.cell_w + self.cell_gap
	local inner_h = self.cell_h + self.cell_gap
	local lx = mx - r.x - 8
	local ly = my - r.y - 28 + self.deck_scroll
	if lx < 0 or ly < 0 then return nil end
	local col = math.floor(lx / inner_w)
	if col < 0 or col >= cols then return nil end
	local row = math.floor(ly / inner_h)
	local idx = row * cols + col + 1
	local cards = self.active_deck.cards
	if idx < 1 or idx > #cards then return nil end
	local cx = r.x + 8 + col * inner_w
	local cy = r.y + 28 + row * inner_h - self.deck_scroll
	local rbx = cx + self.cell_w - 18
	local rby = cy + 4
	if point_in_rect(mx, my, rbx, rby, 14, 14) then
		return idx
	end
	return nil
end

function DeckSelection:deck_zone_contains(mx, my)
	local r = self.regions.deck_zone
	return point_in_rect(mx, my, r.x, r.y, r.w, r.h)
end

function DeckSelection:save_card_ids(ids)
	if not self.active_deck_id then return end
	self.busy = true
	coroutine.resume(coroutine.create(function()
		local code, body = DeckApi:set_deck_cards(self.active_deck_id, ids)
		self.busy = false
		if code == 200 and body then
			self.active_deck = body
		else
			Toast:show('error', 'Could not save deck.', 4)
		end
	end))
end

function DeckSelection:load()
	FriendListSidebar:load()
	layout_regions(self)
	self:reload_data()

	if #self.deck_summaries > 0 then
		self.active_deck_id = self.deck_summaries[1].id
		self.active_deck = DeckApi:get_deck_by_id(self.active_deck_id)
	end
end

function DeckSelection:update(dt)
	layout_regions(self)

	Suit.Input(self.new_deck_input, 16, HeaderBar.height + 38, 220, 32)
	local create = Suit.Button('Create deck', 248, HeaderBar.height + 38, 140, 32)
	local use_match = Suit.Button('Use for match', 400, HeaderBar.height + 38, 160, 32)
	local del_btn = Suit.Button('Delete deck', 572, HeaderBar.height + 38, 140, 32)

	if create.hit then
		local name = self.new_deck_input.text or ''
		name = name:match('^%s*(.-)%s*$') or ''
		if name == '' then
			Toast:show('warning', 'Enter a deck name (max 25 characters).', 3)
		elseif #self.deck_summaries >= self.max_decks then
			Toast:show('warning', 'You can have at most ' .. self.max_decks .. ' decks.', 4)
		else
			coroutine.resume(coroutine.create(function()
				local code, body = DeckApi:create_deck(name:sub(1, 25))
				if code == 201 and body then
					self.new_deck_input.text = ''
					self:reload_data()
					self.active_deck_id = body.id
					self.active_deck = DeckApi:get_deck_by_id(body.id)
					Toast:show('success', 'Deck created.', 2)
				elseif code == 400 then
					Toast:show('error', 'Could not create deck (limit reached or invalid name).', 4)
				else
					Toast:show('error', 'Could not create deck.', 3)
				end
			end))
		end
	end

	if use_match.hit and self.active_deck_id then
		coroutine.resume(coroutine.create(function()
			local code, _ = DeckApi:set_selected_deck(self.active_deck_id)
			if code == 200 then
				Toast:show('success', 'Selected deck will be used for matchmaking.', 3)
			else
				Toast:show('error', 'Could not select deck.', 3)
			end
		end))
	end

	if del_btn.hit and self.active_deck_id then
		local id = self.active_deck_id
		coroutine.resume(coroutine.create(function()
			local code = DeckApi:delete_deck(id)
			if code == 204 then
				self.active_deck_id = nil
				self.active_deck = nil
				self:reload_data()
				if #self.deck_summaries > 0 then
					self.active_deck_id = self.deck_summaries[1].id
					self.active_deck = DeckApi:get_deck_by_id(self.active_deck_id)
				end
				Toast:show('success', 'Deck deleted.', 2)
			else
				Toast:show('error', 'Could not delete deck.', 3)
			end
		end))
	end

	if self.catalog_pending and #self.catalog_pending > 0 then
		local id = table.remove(self.catalog_pending, 1)
		local card = self.catalog_by_id[id]
		if card and card.img_card then
			self.catalog_images[id] = Image:load_from_url(card.img_card, 'card' .. tostring(id))
		end
	end
end

function DeckSelection:mousepressed(x, y, button, istouch, presses)
	if self.busy or button ~= 1 then return end
	if not self.regions then layout_regions(self) end
	local ww = love.graphics.getDimensions()
	if y < HeaderBar.height then return end
	if x >= ww - FriendListSidebar.width then return end

	local row = self:pick_deck_list_row(x, y)
	if row then
		local d = self.deck_summaries[row]
		if d then
			self.active_deck_id = d.id
			self.active_deck = DeckApi:get_deck_by_id(d.id)
			self.deck_scroll = 0
		end
		return
	end

	local rem = self:pick_deck_remove(x, y)
	if rem and self.active_deck and self.active_deck.cards then
		local ids = self:card_ids_in_deck()
		table.remove(ids, rem)
		self:save_card_ids(ids)
		return
	end

	local idx = self:pick_catalog_index(x, y)
	if idx then
		local card = self.catalog[idx]
		if card then
			self.drag = {
				card_id = card.id,
				img = self.catalog_images[card.id],
				name = card.name,
				x = x,
				y = y,
			}
		end
	end
end

function DeckSelection:mousemoved(x, y, dx, dy, istouch)
	if self.drag then
		self.drag.x = x
		self.drag.y = y
	end
end

function DeckSelection:mousereleased(x, y, button, istouch, presses)
	if button ~= 1 or not self.drag then return end
	local d = self.drag
	self.drag = nil
	if self.busy then return end
	if not d or not d.card_id then return end

	if not self.active_deck_id then
		Toast:show('warning', 'Create or select a deck first.', 3)
		return
	end

	if not self:deck_zone_contains(x, y) then return end

	if self:has_card_in_deck(d.card_id) then
		Toast:show('warning', 'That card is already in this deck.', 3)
		return
	end

	local ids = self:card_ids_in_deck()
	table.insert(ids, tonumber(d.card_id))
	self:save_card_ids(ids)
end

function DeckSelection:wheelmoved(dx, dy)
	if not self.regions then return end
	local mx, my = love.mouse.getPosition()
	local ww = select(1, love.graphics.getDimensions())
	if mx >= ww - FriendListSidebar.width then return end

	if self.regions.catalog and point_in_rect(mx, my, self.regions.catalog.x, self.regions.catalog.y, self.regions.catalog.w, self.regions.catalog.h) then
		self.catalog_scroll = math.max(0, self.catalog_scroll - dy * 48)
	end

	if self.regions.deck_zone and point_in_rect(mx, my, self.regions.deck_zone.x, self.regions.deck_zone.y, self.regions.deck_zone.w, self.regions.deck_zone.h) then
		self.deck_scroll = math.max(0, self.deck_scroll - dy * 48)
	end

	if self.regions.deck_list and point_in_rect(mx, my, self.regions.deck_list.x, self.regions.deck_list.y, self.regions.deck_list.w, self.regions.deck_list.h) then
		self.deck_list_scroll = math.max(0, self.deck_list_scroll - dy * 32)
	end
end

local function draw_card_cell(x, y, img, name_text)
	love.graphics.setColor(0.15, 0.15, 0.18, 1)
	love.graphics.rectangle('fill', x, y, DeckSelection.cell_w, DeckSelection.cell_h, 4, 4)
	love.graphics.setColor(0.4, 0.4, 0.45, 1)
	love.graphics.rectangle('line', x, y, DeckSelection.cell_w, DeckSelection.cell_h, 4, 4)
	if img and img.getDimensions then
		local iw, ih = img:getDimensions()
		local image_x = x + 1
		local image_y = y + 1
		local image_w = DeckSelection.cell_w - 2
		local image_h = DeckSelection.cell_h - 20
		local scale = math.max(image_w / iw, image_h / ih)
		local draw_w = iw * scale
		local draw_h = ih * scale
		local draw_x = image_x + (image_w - draw_w) / 2
		local draw_y = image_y + (image_h - draw_h) / 2
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setScissor(image_x, image_y, image_w, image_h)
		love.graphics.draw(img, draw_x, draw_y, 0, scale, scale)
		love.graphics.setScissor()
	end
	love.graphics.setColor(0, 0, 0, 0.45)
	love.graphics.rectangle('fill', x + 1, y + DeckSelection.cell_h - 20, DeckSelection.cell_w - 2, 19)
	love.graphics.setColor(1, 1, 1, 0.9)
	love.graphics.setFont(Fonts.jura(11))
	local short = name_text or ''
	if #short > 18 then short = short:sub(1, 15) .. '…' end
	love.graphics.print(short, x + 4, y + DeckSelection.cell_h - 16)
end

function DeckSelection:draw()
	local ww, wh = love.graphics.getDimensions()
	layout_regions(self)

	HeaderBar:draw('Lobby', 'lobby')

	love.graphics.setColor(0.12, 0.12, 0.14, 1)
	love.graphics.rectangle('fill', 0, HeaderBar.height, ww - FriendListSidebar.width, wh - HeaderBar.height)

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(Fonts.jura(18))
	love.graphics.print('Deck builder', 16, HeaderBar.height + 8)

	local r = self.regions
	love.graphics.setColor(0.18, 0.18, 0.22, 1)
	love.graphics.rectangle('fill', r.deck_list.x, r.deck_list.y, r.deck_list.w, r.deck_list.h, 6, 6)
	love.graphics.rectangle('fill', r.catalog.x, r.catalog.y, r.catalog.w, r.catalog.h, 6, 6)
	love.graphics.rectangle('fill', r.deck_zone.x, r.deck_zone.y, r.deck_zone.w, r.deck_zone.h, 6, 6)

	love.graphics.setFont(Fonts.jura(14))
	love.graphics.setColor(0.85, 0.85, 0.9, 1)
	love.graphics.print('Your decks', r.deck_list.x + 8, r.deck_list.y + 6)
	love.graphics.print('Card catalog', r.catalog.x + 8, r.catalog.y + 6)
	love.graphics.print('Current deck', r.deck_zone.x + 8, r.deck_zone.y + 6)

	-- Deck list
	love.graphics.setScissor(r.deck_list.x, r.deck_list.y, r.deck_list.w, r.deck_list.h)
	for i, d in ipairs(self.deck_summaries) do
		local iy = r.deck_list.y + 30 + (i - 1) * 32 - self.deck_list_scroll
		local sel = self.active_deck_id == d.id
		if sel then
			love.graphics.setColor(0.25, 0.35, 0.55, 1)
		else
			love.graphics.setColor(0.22, 0.22, 0.26, 1)
		end
		love.graphics.rectangle('fill', r.deck_list.x + 6, iy, r.deck_list.w - 12, 28, 4, 4)
		love.graphics.setColor(1, 1, 1, 1)
		local label = d.name or ('#' .. tostring(d.id))
		if #label > 22 then label = label:sub(1, 19) .. '…' end
		love.graphics.print(label, r.deck_list.x + 12, iy + 6)
	end
	love.graphics.setScissor()

	-- Catalog grid
	love.graphics.setScissor(r.catalog.x, r.catalog.y, r.catalog.w, r.catalog.h)
	local cols = self.catalog_cols
	local inner_w = self.cell_w + self.cell_gap
	local inner_h = self.cell_h + self.cell_gap
	for i, card in ipairs(self.catalog) do
		local col = (i - 1) % cols
		local row = math.floor((i - 1) / cols)
		local cx = r.catalog.x + 8 + col * inner_w
		local cy = r.catalog.y + 28 + row * inner_h - self.catalog_scroll
		if cy + self.cell_h > r.catalog.y and cy < r.catalog.y + r.catalog.h then
			draw_card_cell(cx, cy, self.catalog_images[card.id], card.name)
		end
	end
	love.graphics.setScissor()

	-- Deck zone
	love.graphics.setScissor(r.deck_zone.x, r.deck_zone.y, r.deck_zone.w, r.deck_zone.h)
	if self.active_deck and self.active_deck.cards then
		local cols_d = math.max(1, math.floor((r.deck_zone.w - 16) / (self.cell_w + self.cell_gap)))
		for i, card in ipairs(self.active_deck.cards) do
			local col = (i - 1) % cols_d
			local row = math.floor((i - 1) / cols_d)
			local cx = r.deck_zone.x + 8 + col * inner_w
			local cy = r.deck_zone.y + 28 + row * inner_h - self.deck_scroll
			if cy + self.cell_h > r.deck_zone.y and cy < r.deck_zone.y + r.deck_zone.h then
				local img = self.catalog_images[card.id]
				draw_card_cell(cx, cy, img, card.name)
				love.graphics.setColor(0.6, 0.2, 0.2, 1)
				love.graphics.rectangle('fill', cx + self.cell_w - 18, cy + 4, 14, 14, 2, 2)
				love.graphics.setColor(1, 1, 1, 1)
				love.graphics.print('x', cx + self.cell_w - 14, cy + 4)
			end
		end
	else
		love.graphics.setColor(0.6, 0.6, 0.65, 1)
		love.graphics.print('Select a deck, then drag cards here.', r.deck_zone.x + 12, r.deck_zone.y + 40)
	end
	love.graphics.setScissor()

	-- Drag ghost
	if self.drag then
		local img = self.drag.img
		if img and img.getDimensions then
			local iw, ih = img:getDimensions()
			local scale = math.min(80 / iw, 90 / ih)
			love.graphics.setColor(1, 1, 1, 0.85)
			love.graphics.draw(img, self.drag.x - 40, self.drag.y - 45, 0, scale, scale)
		else
			love.graphics.setColor(0.5, 0.5, 0.55, 0.9)
			love.graphics.rectangle('fill', self.drag.x - 40, self.drag.y - 45, 80, 90, 4, 4)
		end
	end

	love.graphics.setColor(1, 1, 1, 1)
	FriendListSidebar:draw(self)
end

function DeckSelection:resize()
	layout_regions(self)
end

return DeckSelection
