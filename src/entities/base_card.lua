local BaseCard = {
	name = '',
	cooldown = 0,
	type = '',
	cost_elixir = 0,
	damage = 0,
	life = 0,
	hit_speed = 0,
	speed_movement = 0,
	targets = '', -- ground or air or both
	range = '', -- melee (short, medium, long) or distance (number of frames)

	-- more code related configs
	img = '', -- card img
	initial_position = {
		x = 0, -- CHECK: I really need this?
		y = 0, -- the position in the map where the card was dropped
	},
	-- the actual card position
	-- these values represent the first card only
	x = 120,
	y = 620,
	-- CHECK: I really need this?
	-- the state changes when the card is released (to true)
	can_move = false,
	animations = {}
}

local MetaBaseCard = { __index = BaseCard }

-- implementation of inheritance
function BaseCard.create()
	local instance = {}
	setmetatable(instance, MetaBaseCard)
	return instance
end

return BaseCard
