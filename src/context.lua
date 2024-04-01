local Initial = require('src.states.initial')
local Auth = require('src.states.auth')
local Game = require('src.states.game')
local Queue = require('src.states.queue')
local Lobby = require('src.states.lobby')
local LoadingGame = require('src.states.loading-game')

local Context = {
	states = {
		initial = Initial,
		auth = Auth,
		lobby = Lobby,
		queue = Queue,
		loading_game = LoadingGame,
		game = Game
	},

	current = 'initial',

	update = function(self, dt)
		return self.states[self.current]:update(dt)
	end,

	draw = function(self)
		return self.states[self.current]:draw()
	end,

	change = function(self, ctx)
		if ctx == nil then
			error('Context should not be nil')
		end

		local new_ctx = self.states[ctx]

		if new_ctx ~= nil then
			self.current = ctx
			self.states[self.current]:load()
		else
			error('This context does not exist')
		end
	end
}

return Context
