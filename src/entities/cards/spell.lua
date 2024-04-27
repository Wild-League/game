local Spell = {
	current_action = 'attack',
	actions = {}
}

function Spell:preview(x, y)
	love.graphics.circle("line", x, y, self.attack_range or 50)
end

return Spell
