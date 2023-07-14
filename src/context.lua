local Initial = require('src/states/initial')
local Auth = require('src/states/auth')
local Game = require('src/states/game')
local Queue = require('src/states/queue')

local Context = {
	states = {
		initial = Initial,
		auth = Auth,
		game = Game,
		queue = Queue
	},

	current = 'initial',

	update = function(self, dt)
		return self.states[self.current]:update(dt)
	end,

	draw = function(self)
		return self.states[self.current]:draw()
	end,

	change = function(self, ctx)
		-- TODO: add log file
		-- print('changing state for: ', ctx)

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
