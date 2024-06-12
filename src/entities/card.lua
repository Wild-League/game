local Image = require('src.helpers.image')
local Char = require('src.entities.cards.char')
local Spell = require('src.entities.cards.spell')
local Utils = require('src.helpers.utils')
local Animation = require('src.helpers.animation')

local Card = {
	x = 0,
	y = 0,
	char_x = 0,
	char_y = 0,
	current_cooldown = 0,
	selected = false,
	selectable = false,
	preview_card = false,
	is_card_loading = false,
	perception_range = 0
}

local Card_Types = {
	CHAR = 'char',
	SPELL = 'spell'
}

function Card:new(card, enemy)
	self.perception_range = card.attack_range * 2
	self.enemy = enemy or false

	if card.type == Card_Types.CHAR then
		local t = Utils.merge_tables(self, Char)

		setmetatable(card, t)
		t.__index = t
	end

	if card.type == Card_Types.SPELL then
		local t = Utils.merge_tables(self, Spell)

		setmetatable(card, t)
		t.__index = t
	end

	card = self:load_images(card)
	card = self:load_animations(card)

	return Utils.copy_table(card)
end

function Card:load_images(card)
	for key, value in pairs(card) do
		if string.sub(key, 1, 4) == "img_" and value ~= nil then
			local img = Image:load_from_url(value, card.name .. '-' .. key .. '-.png')
			card[key] = img
		end
	end

	return card
end

function Card:load_animations(card)
	for key, _ in pairs(card.animations) do
		card.animations[key] = Animation:new(card, key)
	end

	return card
end

function Card:draw_loading_animation()
	local x = self.x + self.img_card:getWidth() / 2
	local y = self.y + self.img_card:getHeight() / 2

	love.graphics.stencil(function()
		love.graphics.draw(self.img_card, self.x, self.y, 0, self.default_scale, self.default_scale)
	end, "replace", 1, false)

	love.graphics.setColor(1, 0, 0, 0.5)
	love.graphics.setStencilTest('equal', 1)
	love.graphics.arc("fill", x, y, 130, -math.pi / 2, -math.pi / 2 + (2 * math.pi * (self.current_cooldown / self.cooldown)), 100)
	love.graphics.setColor(1, 1, 1)

	love.graphics.setStencilTest()
end

function Card:reset_cooldown()
	self.current_cooldown = self.cooldown
end

return Card
