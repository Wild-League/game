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
	range = '' -- melee (short, medium, long) or distance (number of frames)
}

local MetaBaseCard = { __index = BaseCard }

-- implementation of inheritance
function BaseCard.create()
	local instance = {}
	setmetatable(instance, MetaBaseCard)
	return instance
end

return BaseCard
