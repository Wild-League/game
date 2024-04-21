local PlayerStatus = {}

function PlayerStatus:load()
	self.player = {
		health = 100,
		mana = 100,
		deck = {}
	}
end

function PlayerStatus:update(dt)
end

function PlayerStatus:draw()
	-- love.graphics.setColor(1,1,1)
	-- love.graphics.print('Health: ' .. self.player.health, 10, 10)
	-- love.graphics.print('Mana: ' .. self.player.mana, 10, 30)
end

return PlayerStatus
