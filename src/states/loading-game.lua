local Deck = require('src.entities.deck')

local LoadingGame = {
	state = 'loading'
}

function LoadingGame:load()
	love.thread.newThread(
		[[
			local DeckApi = require('src.api.deck')

			local deck = DeckApi:get_current_deck()

			love.thread.getChannel('deck'):push(deck)
			love.thread.getChannel('state'):push('ready')
		]]
	):start()
end

function LoadingGame:update()
	local deck = love.thread.getChannel('deck'):pop()

	if deck and deck.cards then
		Deck:load(deck)
	end

	local new_state = love.thread.getChannel('state'):pop()
	if new_state == 'ready' then
		CONTEXT:change('game')
	end
end

function LoadingGame:draw()
	if self.state == 'loading' then
		love.graphics.print('Loading ...', 10, 10)
	end
end

function LoadingGame:resize()

end

return LoadingGame
