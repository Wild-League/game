local yui = require("lib.yui")
local ImageHelper = require("src.helpers.image")

local Card = {
	bottom_padding = 20,
	side_padding = 20,
	scale = 1.25
};

function Card:new(card)
	return yui.Button {
		w = card.img_card:getWidth(),
		h = card.img_card:getHeight(),
		image = ImageHelper:load_from_url(card.img_card, 'preview'),
		use_image_as_background = true,
		scale = self.scale,
		theme = nil,
		mode = "line",
		onHit = function() print(card.name) end,

		yui.Label({
			w = 80,
			h = 10,
			text = card.name,
			size = 10,
			theme = { color = { normal = { fg = { 1, 1, 1 }}}}
		}),

		yui.Spacer({ w = 100, h = 440 }),

		yui.Label({
			w = 80,
			h = 10,
			text = card.cooldown .. "s",
			size = 20,
			theme = { color = { normal = { fg = { 1, 1, 1 }}}}
		})
	}
end

return Card
