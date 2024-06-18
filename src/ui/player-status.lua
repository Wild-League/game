local Constants = require('src.constants')
local Image = require('src.ui.images')
local Fonts = require('src.ui.fonts')
local nakama = require('lib.nakama.nakama')

local PlayerStatus = {
	nickname = 'ropoko', -- todo: remove
	trophies = 0
}

function PlayerStatus:new(player_id)
	local player = {}

	coroutine.resume(coroutine.create(function()
		local result = nakama.get_users(Constants.NAKAMA_CLIENT, { player_id })

		player.id = player_id

		if result and not result.error then
			for _, u in ipairs(result.users) do
				player.nickname = u.username
				-- TODO: how to get trophies?
				-- player.trophies = u.trophies
			end
		end
	end))


	setmetatable(player, self)
	self.__index = self

	return player
end

function PlayerStatus:update(dt) end

function PlayerStatus:draw()
	local padding = 20

	if self.id == Constants.USER_ID then
		padding = love.graphics.getWidth() - 100
	end

	love.graphics.clear()

	-- todo: fix arbitrary values

	love.graphics.draw(Image.player_status, padding, love.graphics.getHeight() - 100)
	love.graphics.print(self.nickname, Fonts.juvanze(24), padding * 4.1, love.graphics.getHeight() - 90)
end

return PlayerStatus
