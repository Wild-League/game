local yui = require("lib.yui")
local img = require("src.helpers.image")

local Card = {
    cardBottomPadding = 20,
    cardSidePadding = 20,
    cardHeight = 200,
    cardWidth = 200
};

function Card:new(card)

    return yui.Button {
        w = self.cardWidth,
        h = self.cardHeight,
        image = img:load_from_url(card.img_card, 'preview'),
        drawBox = true,
        theme = nil,
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
