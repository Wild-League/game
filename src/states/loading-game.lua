local LoadingGame = {
	state = 'loading'
}

function LoadingGame:load()
	-- TODO: get user selected deck
	local loading_cards = love.thread.newThread(
		[[
			local Deck = require('src.api.deck')
			Deck:get_cards('2')
			love.thread.getChannel('state'):push('ready')
		]]
	)

	loading_cards:start()
end

function LoadingGame:update()
	if love.thread.getChannel('state'):pop() then
		self.state = love.thread.getChannel('state'):pop()
		-- CONTEXT:change('game')
		-- self.loading = false
	end
end

function LoadingGame:draw()
	if self.state == 'loading' then
		love.graphics.print('Loading ...', 10, 10)
	end
end

return LoadingGame
