local DeckApi = require('src.api.deck')
local FriendListSidebar = require('src.ui.friend-list-sidebar')
local Suit = require('lib.suit')
local Fonts = require('src.ui.fonts')

local DeckSelection = {
    friends = {},
    show_add_friend_input = false,
    friend_input = {text = ""}
}

function DeckSelection:load()
    local decks;
    -- decks = DeckApi:get_list()

    if decks == nil then return; end

    print(#decks)

    for _, deck in ipairs(decks) do print(deck.name) end
end

function DeckSelection:update(dt) end

function DeckSelection:draw()

    local cards = {0, 1, 2, 3, 4, 5, 6}

    self.card_area(.5, cards)
    self.card_area(3, cards)
    FriendListSidebar.draw(Suit, Fonts, DeckSelection)

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
        print("index: ", index)
        print("card: ", card)
        love.graphics.rectangle('fill',
                                ((love.graphics.getWidth() / 10) + 20) +
                                    (20 * index), (height * y) + 20, card_width,
                                card_height)

        love.graphics.setColor(1, 1, 1, 1)
    end

end

return DeckSelection
