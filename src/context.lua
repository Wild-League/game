local Initial = require('src/states/initial') -- called from the main
local Info = require('src/states/info')
local In_Game = require('src/states/in_game')

local Context = {
	-- contexts
	initial = Initial,
	info = Info,
	in_game = In_Game,

	current = function(self, ctx)
		if (ctx == nil) then
			return self.initial()
		else
			return self[ctx]()
		end
	end,

	change = function(self, ctx)
		if ctx == nil then
			error('Context should not be nil')
		end

		if ctx == 'initial' or ctx == 'info' or ctx == 'in_game' then
			self:current(ctx)
		else
			error('This context does not exist')
		end
	end
}

return Context
