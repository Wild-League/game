local Spell = {
	current_action = 'attack',

	animations = {
		attack = {},
	}
}

function Spell:update(dt)
	self.animations[self.current_action]:update(dt)
end

function Spell:draw()
	self.animations[self.current_action]:draw(self['img_'..self.current_action], self.char_x, self.char_y)
end

function Spell:preview(x, y)
	love.graphics.circle("line", x, y, self.attack_range or 50)
end

return Spell
