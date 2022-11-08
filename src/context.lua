local Initial = require('src/states/initial')
local Get_Info = require('src/states/get_info')
local In_Game = require('src/states/in_game')

local Context = {
	states = {
		initial = Initial,
		get_info = Get_Info,
		in_game = In_Game
	},

	current = 'initial',

	-- current = function(self)
	-- 	return self.states[self.current]()
	-- end,

	update = function(self, dt)
		return self.states[self.current]:update(dt)
	end,

	draw = function(self)
		return self.states[self.current]:draw()
	end,

	change = function(self, ctx)
		print('changing state for: ', ctx)

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
