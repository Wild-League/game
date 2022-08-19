local Initial = require('src/states/initial') -- called from the main
local Get_Info = require('src/states/get_info')
local In_Game = require('src/states/in_game')

local Context = {
	-- states
	initial = Initial,
	get_info = Get_Info,
	in_game = In_Game,

	set_current = 'initial',

	current = function(self, ctx)
		if (ctx == nil) then
			return self.initial()
		elseif (self.set_current ~= nil) then
			return self[self.set_current]()
		else
			self.set_current = ctx
			return self[ctx]()
		end
	end,

	change = function(self, ctx)
		print('changing states', ctx)

		if ctx == nil then
			error('Context should not be nil')
		end

		if ctx == 'initial' or ctx == 'get_info' or ctx == 'in_game' then
			self:current(ctx)
		else
			error('This context does not exist')
		end
	end
}

return Context
