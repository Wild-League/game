local BaseCard = {
	name = '',
	cooldown = 0,
	type = '',
	cost_elixir = 0, -- TODO: find alternative name for 'elixir'
	damage = 0,
	life = 0,
	hit_speed = 0,
	speed_movement = 0,
	targets = '', -- ground or air or both
	range = '', -- melee (short, medium, long) or distance (number of frames)

	-- more code related configs
	img = '', -- card img

	-- CHECK: I really need this?
	-- the position in the map where the card will be dropped
	initial_position_x = 0,
	initial_position_y = 0,

	-- the actual card position
	x = 0,
	y = 0,

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
