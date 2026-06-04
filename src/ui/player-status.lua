local Constants = require('src.constants')
local Image = require('src.ui.images')
local Fonts = require('src.ui.fonts')
local nakama = require('lib.nakama.nakama')

local PlayerStatus = {
	nickname = 'Player',
	level = 1,
	trophies = 0
}

function PlayerStatus:new(player_id)
	local player = {
		id = player_id,
		nickname = 'Player',
		level = 1,
		trophies = 0
	}

	coroutine.resume(coroutine.create(function()
		local result = nakama.get_users(Constants.NAKAMA_CLIENT, { player_id })

		if result and not result.error then
			for _, u in ipairs(result.users) do
				player.nickname = u.username
				-- TODO: how to get level / trophies from backend?
			end
		end
	end))

	setmetatable(player, self)
	self.__index = self

	return player
end

function PlayerStatus:update(dt) end

function PlayerStatus:draw_badge(corner, strip_top)
	local window_w = love.graphics.getWidth()
	local window_h = love.graphics.getHeight()
	local ui_height = window_h - strip_top
	local padding = 12

	local avatar_img = corner == 'bottom_left' and Image.avatar_enemy or Image.avatar_player
	local avatar_scale = math.min(1, (ui_height - padding * 2) / avatar_img:getHeight())
	local avatar_w = avatar_img:getWidth() * avatar_scale
	local avatar_h = avatar_img:getHeight() * avatar_scale
	local avatar_y = strip_top + (ui_height - avatar_h) / 2

	local name_font = Fonts.jura(14)
	local level_font = Fonts.jura(12)
	local level_text = 'Lv. ' .. tostring(self.level or 1)

	love.graphics.setColor(1, 1, 1, 1)

	if corner == 'bottom_left' then
		local avatar_x = padding
		love.graphics.draw(avatar_img, avatar_x, avatar_y, 0, avatar_scale, avatar_scale)

		local text_x = avatar_x + avatar_w + 8
		local text_y = strip_top + (ui_height - 36) / 2
		love.graphics.setFont(name_font)
		love.graphics.print(self.nickname, text_x, text_y)
		love.graphics.setFont(level_font)
		love.graphics.print(level_text, text_x, text_y + 18)
	elseif corner == 'bottom_right' then
		local avatar_x = window_w - padding - avatar_w
		love.graphics.draw(avatar_img, avatar_x, avatar_y, 0, avatar_scale, avatar_scale)

		love.graphics.setFont(name_font)
		local name_w = name_font:getWidth(self.nickname)
		love.graphics.setFont(level_font)
		local level_w = level_font:getWidth(level_text)
		local text_w = math.max(name_w, level_w)
		local text_x = avatar_x - 8 - text_w
		local text_y = strip_top + (ui_height - 36) / 2

		love.graphics.setFont(name_font)
		love.graphics.print(self.nickname, text_x, text_y)
		love.graphics.setFont(level_font)
		love.graphics.print(level_text, text_x, text_y + 18)
	end
end

return PlayerStatus
