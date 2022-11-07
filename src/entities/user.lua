local Char1 = require('./src/cards/char1')
local Char2 = require('./src/cards/char2')
local Char3 = require('./src/cards/char3')
local Char4 = require('./src/cards/char4')

local card1 = Char1
local card2 = Char2
local card3 = Char3
local card4 = Char4

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
		decks = {
			positions = {
				card1 = {
					x = 120,
					y = 620
				},
				card2 = {
					x = 220,
					y = 620
				},
				card3 = {
					x = 320,
					y = 620
				},
				card4 = {
					x = 420,
					y = 620
				}
			},
			deck1 = {
				card1,
				card2,
				card3,
				card4
			}
		},
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
