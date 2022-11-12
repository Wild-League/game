local BaseCard = {
	name = '',
	cooldown = 0,
	type = '',
	cost_elixir = 0, -- TODO: find alternative name for 'elixir'
	damage = 0,
	life = 0,
	hit_speed = 0,
	speed = 0,
	targets = '', -- ground or air or both
	attack_range = '', -- melee (short, medium, long) or distance (in pixels)

	-- more code related configs
	img = '', -- card img

	-- the actual card position
	x = 0,
	y = 0,

	-- the char position
	char_x = 0,
	char_y = 0,

	-- CHECK: I really need this?
	-- state to move the card - changes on card click
	can_move = false,

	-- CHECK: I really need this?
	-- state to the animations hero - changes on card realease
	spawned = false,

	-- all possible char animations / actions
	actions = {},

	-- "status" - the current char action
	current_action = '',

	-- implementation of the default functions of anim8
	animate = {},

	-- list of all anothers cards that is in perception_range
	-- get the one nearest
	chars_around = {}
}

function BaseCard:perception_range()
	return self.attack_range * 2
end

local MetaBaseCard = { __index = BaseCard }

-- implementation of inheritance
function BaseCard.create()
	local instance = {}
	setmetatable(instance, MetaBaseCard)
	return instance
end

return BaseCard
