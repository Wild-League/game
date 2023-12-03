local Image = require('src.helpers.image')

local Spell = {
	current_action = 'attack',
	actions = {}
}

function Spell:load_images(card)
	local name = card.name

	card.img = Image:load_from_url('http://localhost:9000/cards/'.. string.lower(name) ..'/card.png', name..'.png')
	card.img_attack = Image:load_from_url('http://localhost:9000/cards/'.. string.lower(name) ..'/attack.png', name..'.png')

	return card
end

function Spell:new(name, type, cooldown, damage, life, speed, attack_range, width, height)
	local char = {
		name = name,
		type = type,
		cooldown = cooldown,
		damage = damage,
		life = life,
		speed = speed,
		attack_range = attack_range,
		frame_width = width,
		frame_height = height
	}

	char = self:load_images(char)

	setmetatable(char, self)
	self.__index = self

	return char
end

return Spell
