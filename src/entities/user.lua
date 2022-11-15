local Deck = require('./src/entities/deck')

local function User(nickname, level)
	local obj = {
		__call = function(self)
			return self.new()
		end,

		__tostring = function(self)
			return string.format('nickname: %s, level: %d', self.nickname, self.level)
		end,

		nickname = nickname,
		level = level or 1,

		decks = Deck,
		deck_selected = 'deck1'
	}

	obj.__index = obj

	setmetatable(obj, {})

	function obj.new()
		if obj._instance then
			return obj._instance
		end

		local instance = setmetatable({}, obj)

		obj._instance = instance
		return obj._instance
	end

	return obj
end

return User
