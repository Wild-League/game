local function Context()
	return {
		contexts = {
			initial = true,
			info = false,
			in_game = false
		},

		change = function(self, context)
			self.contexts.initial = context == 'initial'
			self.contexts.info = context == 'info'
			self.contexts.game = context == 'in_game'
		end
	}
end

return Context
