local yui = require("lib.yui")
local img = require("src.helpers.image")

local Card = {
    card_bottom_padding = 20,
    card_side_padding = 20,
    card_height = 96,
    card_width = 64,
    card_scale = 1.25
};

function Card:new(card)

    return yui.Button {
        w = self.card_width,
        h = self.card_height,
        image = img:load_from_url(card.img_card, 'preview'),
        use_image_as_background = true,
        scale = self.card_scale,
        theme = nil,
        mode = "line",
        onHit = function() print(card.name) end,

        yui.Label({
            w = 80,
            h = 10,
            text = card.name,
            size = 10,
            theme = {color = {normal = {fg = {1, 1, 1}}}}
        }),
        yui.Spacer({w = 100, h = 440}),
        yui.Label({
            w = 80,
            h = 10,
            text = card.cooldown .. "s",
            size = 20,
            theme = {color = {normal = {fg = {1, 1, 1}}}}
        })

    }

end
return Card
