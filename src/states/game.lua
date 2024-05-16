local yui = require('lib.yui')
local Card = require('src.ui.cards')
local Layout = require('src.helpers.layout')
local Map = require('src.entities.map')
local Tower = require('src.entities.tower')
local Deck = require('src.entities.deck')
local Timer = require('src.helpers.timer')
local Constants = require('src.constants')
local nakama = require('lib.nakama.nakama')
local json = require('lib.json')

local deck = {
    {
        id = 1,
        name = "Caveman",
        type = "char",
        cooldown = "6.00",
        damage = "100.00",
        attack_range = "20.00",
        speed = "1.00",
        life = 100,
        img_card = "https://wild-minio.fly.dev/cards/caveman/card.png",
        img_preview = "https://wild-minio.fly.dev/cards/caveman/preview.png",
        img_attack = "https://wild-minio.fly.dev/cards/caveman/attack.png",
        img_death = "https://wild-minio.fly.dev/cards/caveman/death.png",
        img_walk = "https://wild-minio.fly.dev/cards/caveman/walk.png"
    }, {
        id = 2,
        name = "Dino",
        type = "char",
        cooldown = "10.00",
        damage = "200.00",
        attack_range = "40.00",
        speed = "0.80",
        life = 300,
        img_card = "https://wild-minio.fly.dev/cards/dino/card.png",
        img_preview = "https://wild-minio.fly.dev/cards/dino/preview.png",
        img_attack = "https://wild-minio.fly.dev/cards/dino/attack.png",
        img_death = "https://wild-minio.fly.dev/cards/dino/death.png",
        img_walk = "https://wild-minio.fly.dev/cards/dino/walk.png"
    }, {
        id = 3,
        name = "Thunder",
        type = "spell",
        cooldown = "5.00",
        damage = "70.00",
        attack_range = "20.00",
        speed = nil,
        life = nil,
        img_card = "https://wild-minio.fly.dev/cards/thunder/card.png",
        img_preview = nil,
        img_attack = "https://wild-minio.fly.dev/cards/thunder/attack.png",
        img_death = nil,
        img_walk = nil
    }
}

local Game = {timer = Timer:new(), card_selected = nil}

function Game:load()
    Map:load()
    self.ui = {}
    coroutine.resume(coroutine.create(function()
        local objects = {
            {
                collection = 'selected_deck',
                key = 'selected_deck',
                userId = Constants.USER_ID
            }
        }

        local result = nakama.read_storage_objects(Constants.NAKAMA_CLIENT,
                                                   objects)

        if result then
            local selected_deck = json.decode(result.objects[1].value)
            Deck:load(selected_deck)
        end
    end))

    -- TODO change for Deck:load() to list the cards
    for index, card in pairs(deck) do
        self.ui[index] = yui.Ui:new({
            x = (love.graphics.getWidth() / 2) - (Card.card_width * index) -
                (index * Card.card_side_padding),
            y = love.graphics.getHeight() - Card.card_height * 2,
            w = Card.card_height,
            h = Card.cardwi,
            Card:new(card)

        })

    end

end

function Game:update(dt)
    for index, cardUI in pairs(deck) do self.ui[index]:update(dt) end
    Map:update(dt)

    Deck:update(dt)
    self.card_selected = Deck.card_selected

    self.timer:update(dt)
end

function Game:draw()
    Map:draw()
    for index, cardUI in pairs(deck) do self.ui[index]:draw(); end

    -- Deck:draw()

    if self.card_selected then
        -- print(self.card_selected.preview)
        self.card_selected:preview(love.mouse.getX(), love.mouse.getY())
    end

    self:draw_timer()
end

-- private functions ---------

function Game:load_towers()
    local tower1 = Tower:load('left', 'top')

    local tower2 = Tower:load('left', 'bottom')
end

function Game:draw_timer()
    local center_background = Layout:center(100, 100)
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle('fill', center_background.width, 10, 100, 50)
    love.graphics.setColor(1, 1, 1)

    local center_timer = Layout:center(100, 100)

    love.graphics.setColor(1, 1, 1)
    self.timer:draw(center_timer.width, 35, 100, 0)
    love.graphics.setColor(1, 1, 1)
end

return Game
