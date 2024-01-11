local User = require('src.api.user')
local Suit = require('lib.suit')

-- TODO: draw the actual lobby

local Lobby = {
	user = {}
}

function Lobby:load()
	-- self.user = User:get()
end

function Lobby:update() end

function Lobby:draw()
	local play_button = Suit.Button('Play', 10, 10)

	if play_button.hit then
		CONTEXT:change('queue')
	end

	-- love.graphics.print('Lobby', 10, 10)
	-- love.graphics.print('Welcome '..self.user.username, 10, 30)
	-- love.graphics.print('Level: '..self.user.level, 10, 50)
end

return Lobby
