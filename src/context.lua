local Initial = require('src/states/initial')
local Get_Info = require('src/states/get_info')
local In_Game = require('src/states/in_game')

local Context = {
	states = {
		initial = Initial,
		get_info = Get_Info,
		in_game = In_Game
	},

	set_current = 'initial',

	-- current = function(self)
	-- 	return self.states[self.set_current]()
	-- end,

	update = function(self, dt)
		return self.states[self.set_current]:update(dt)
	end,

	draw = function(self)
		return self.states[self.set_current]:draw()
	end,

	change = function(self, ctx)
		print('changing state for: ', ctx)

		if ctx == nil then
			error('Context should not be nil')
		end

		local new_ctx = self.states[ctx]

		if new_ctx ~= nil then
			self.set_current = ctx
			self.states[self.set_current]:load()
		else
			error('This context does not exist')
		end
	end
}

return Context
