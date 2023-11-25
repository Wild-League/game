local User = require('src.api.user')

local Lobby = {
	user = {}
}

function Lobby:load()
	self.user = User:get()
end

function Lobby:update() end

function Lobby:draw()
	love.graphics.print('Lobby', 10, 10)
	love.graphics.print('Welcome '..self.user.username, 10, 30)
	love.graphics.print('Level: '..self.user.level, 10, 50)
end

return Lobby
