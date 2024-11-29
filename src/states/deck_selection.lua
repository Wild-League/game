local DeckApi = require('src.api.deck')
local Fonts = require('src.ui.fonts')
local Suit = require('lib.suit')
local FriendListSidebar = require('src.ui.friend-list-sidebar')
local HeaderBar = require('src.ui.header-bar')
local DeckSelection = {
    friends = {},
    show_add_friend_input = false,
    friend_input = { text = "" }
}

function DeckSelection:load()
    FriendListSidebar:load()
    local teste = DeckApi:get_current_deck()
end

function DeckSelection:draw()
    love.graphics.setBackgroundColor(10 / 255, 16 / 255, 115 / 255)

    HeaderBar:draw("Lobby", 'lobby')

    local cards = { 0, 1, 2, 3, 4, 5, 6 }
    self.card_area(.5, cards)
    FriendListSidebar:draw(self)
end

function DeckSelection:update(dt)

end

function DeckSelection.card_area(y, cards)
    love.graphics.setColor(0.1, 0.1, 0.1, 0.8)

    local height = love.graphics.getHeight() / 6;

    love.graphics.rectangle('fill', love.graphics.getWidth() / 10, height * y,
        love.graphics.getWidth() / 1.5,
        love.graphics.getHeight() / 3)
    love.graphics.setColor(1, 1, 1, 1)

    if cards.length == 0 then return end

    local card_width, card_height = ((love.graphics.getWidth() / 1.5) - 40) / 6,
        (love.graphics.getHeight() / 3) - 40

    for index, card in pairs(cards) do
        -- print("index: ", index)
        -- print("card: ", card)
        love.graphics.rectangle('fill',
            ((love.graphics.getWidth() / 10) + 20) +
            (20 * index), (height * y) + 20, card_width,
            card_height)

        love.graphics.setColor(1, 1, 1, 1)
    end
end

return DeckSelection
