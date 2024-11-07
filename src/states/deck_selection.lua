local DeckApi = require('src.api.deck')
local FriendsSidebar = require('src.ui.friends-sidebar')
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

    love.graphics.setColor(0.1, 0.1, 0.1, 0.8)
    love.graphics.rectangle('fill', love.graphics.getWidth() / 10,
                            love.graphics.getHeight() / 1.3,
                            love.graphics.getWidth() / 1.3,
                            love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1, 1)
    FriendsSidebar.draw(Suit, Fonts, DeckSelection)

end

return DeckSelection
