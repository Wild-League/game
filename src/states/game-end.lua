local Suit = require('lib.suit')
local Layout = require('src.helpers.layout')
local Fonts = require('src.ui.fonts')
local Images = require('src.ui.images')
local Constants = require('src.constants')
local socket = require('lib.nakama.socket')
local Game = require('src.states.game')

local PANEL_W = 520
local PANEL_H = 380

local RESULT_STYLES = {
	victory = {
		title = 'Victory',
		subtitle = 'You destroyed the enemy stronghold.',
		title_color = { 0.55, 1, 0.62 },
		glow_color = { 0.25, 0.9, 0.4, 0.4 },
		accent = { 0.35, 0.95, 0.48 },
	},
	defeat = {
		title = 'Defeat',
		subtitle = 'Both of your towers have fallen.',
		title_color = { 1, 0.48, 0.42 },
		glow_color = { 0.95, 0.22, 0.2, 0.38 },
		accent = { 0.92, 0.28, 0.26 },
	},
}

local label_theme = {
	align = 'center',
	color = { normal = { fg = { 0.88, 0.9, 1 } } },
}

local function ease_out_cubic(t)
	return 1 - (1 - t) ^ 3
end

local GameEnd = {
	result = 'defeat',
	text_alpha = 0,
	fade_duration = 0.75,
	title_font = nil,
	subtitle_font = nil,
	background = nil,
	bg_time = 0,
}

function GameEnd:load()
	self.result = Game.result_for_screen or 'defeat'
	self.text_alpha = 0
	self.bg_time = 0
	self.background = Constants.WORLD_BACKGROUND or Images.background_cloud
	self.title_font = Fonts.juvanze(56)
	self.subtitle_font = Fonts.jura(18)
end

function GameEnd:update(dt)
	self.bg_time = self.bg_time + dt
	if self.text_alpha < 1 then
		self.text_alpha = math.min(1, self.text_alpha + dt / self.fade_duration)
	end
end

function GameEnd:draw_background()
	local bg = self.background or Images.background_cloud
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(bg, 0, 0, 0, w / bg:getWidth(), h / bg:getHeight())

	love.graphics.setColor(10 / 255, 16 / 255, 115 / 255, 0.78)
	love.graphics.rectangle('fill', 0, 0, w, h)

	local drift = math.sin(self.bg_time * 0.35) * 12
	love.graphics.setColor(1, 1, 1, 0.06)
	love.graphics.draw(
		Images.sun,
		w * 0.82 + drift,
		h * 0.12,
		0,
		0.35,
		0.35,
		Images.sun:getWidth() / 2,
		Images.sun:getHeight() / 2
	)
end

function GameEnd:draw_panel(x, y, style, alpha)
	love.graphics.setColor(0.03, 0.05, 0.18, 0.94 * alpha)
	love.graphics.rectangle('fill', x, y, PANEL_W, PANEL_H, 14, 14)

	love.graphics.setColor(style.accent[1], style.accent[2], style.accent[3], 0.95 * alpha)
	love.graphics.rectangle('fill', x, y, PANEL_W, 5, 14, 14)

	love.graphics.setColor(1, 1, 1, 0.14 * alpha)
	love.graphics.setLineWidth(2)
	love.graphics.rectangle('line', x + 1, y + 1, PANEL_W - 2, PANEL_H - 2, 14, 14)
	love.graphics.setLineWidth(1)
end

function GameEnd:draw_title_glow(cx, cy, style, alpha, scale)
	local r = 120 * scale
	love.graphics.setColor(style.glow_color[1], style.glow_color[2], style.glow_color[3], style.glow_color[4] * alpha)
	love.graphics.ellipse('fill', cx, cy, r, r * 0.55)
end

function GameEnd:draw()
	self:draw_background()

	local style = RESULT_STYLES[self.result] or RESULT_STYLES.defeat
	local progress = ease_out_cubic(self.text_alpha)
	local title_scale = 0.88 + 0.12 * progress

	local panel_pos = Layout:center(PANEL_W, PANEL_H)
	local px, py = panel_pos.width, panel_pos.height

	self:draw_panel(px, py, style, progress)

	local title = style.title
	local title_w = self.title_font:getWidth(title) * title_scale
	local title_h = self.title_font:getHeight() * title_scale
	local title_x = px + PANEL_W / 2 - title_w / 2
	local title_y = py + 72

	local glow_cx = px + PANEL_W / 2
	local glow_cy = title_y + title_h / 2
	self:draw_title_glow(glow_cx, glow_cy, style, progress, title_scale)

	love.graphics.setFont(self.title_font)
	love.graphics.push()
	love.graphics.translate(title_x, title_y)
	love.graphics.scale(title_scale, title_scale)
	love.graphics.setColor(style.title_color[1], style.title_color[2], style.title_color[3], progress)
	love.graphics.print(title, 0, 0)
	love.graphics.pop()

	love.graphics.setFont(self.subtitle_font)
	local subtitle = style.subtitle
	local sub_w = self.subtitle_font:getWidth(subtitle)
	local sub_x = px + PANEL_W / 2 - sub_w / 2
	local sub_y = title_y + title_h + 18
	love.graphics.setColor(0.82, 0.86, 1, 0.9 * progress)
	-- love.graphics.print(subtitle, sub_x, sub_y)

	if self.result == 'victory' then
		love.graphics.setColor(1, 1, 1, 0.35 * progress)
		-- love.graphics.draw(
		-- 	Images.sun,
		-- 	px + PANEL_W - 56,
		-- 	py + 48,
		-- 	0,
		-- 	0.2,
		-- 	0.2,
		-- 	Images.sun:getWidth() / 2,
		-- 	Images.sun:getHeight() / 2
		-- )
	end

	local btn_w, btn_h = 280, 48
	local btn_x = px + PANEL_W / 2 - btn_w / 2
	local btn_y = py + PANEL_H - btn_h - 36
	local return_btn = Suit.Button('Return to Lobby', btn_x, btn_y, btn_w, btn_h)

	Suit.Label('Match complete', label_theme, px, py + PANEL_H - 92, PANEL_W, 24)

	love.graphics.setColor(1, 1, 1, 1)

	if return_btn.hit then
		coroutine.resume(coroutine.create(function()
			if Constants.MATCH_ID and Constants.MATCH_ID ~= '' then
				socket.match_leave(Constants.SOCKET_CONNECTION, Constants.MATCH_ID)
			end
			Game:reset_match_state()
			CONTEXT:change('lobby')
		end))
	end
end

function GameEnd:resize() end

return GameEnd
