local yui = require('lib.yui')
local Layout = require('src.helpers.layout')
local Map = require('src.entities.new_map')
local Tower = require('src.entities.tower')
local Deck = require('src.entities.deck')
local MatchEvents = require('src.config.match_events')
local EnemyDeck = require('src.entities.enemy_deck')
local Timer = require('src.helpers.timer')
local Constants = require('src.constants')
local Utils = require('src.helpers.utils')
local nakama = require('lib.nakama.nakama')
local socket = require('lib.nakama.socket')
local PlayerStatus = require('src.ui.player-status')
local json = require('lib.json')

local Game = {
    timer = Timer:new(),
    cards = {},
    -- enemy_cards = {}

    me_status = PlayerStatus:new('2d618372-1220-49b3-b22e-00f6ca0c12a5'),
    enemy_status = PlayerStatus:new('2d618372-1220-49b3-b22e-00f6ca0c12a5')
}

function Game:load()
    local cursor = love.mouse.newCursor('assets/cursor.png', 0, 0)
    love.mouse.setCursor(cursor)

    Map:load()
end

function Game:update(dt)
    Map:update(dt)

    -- self.timer:update(dt)

end

function Game:draw()
    Game:draw_background();
    Game:draw_bottom_panel()
    Map:draw()

    -- Deck:draw()
    -- self:draw_player_status()

    -- for _, card in pairs(self.cards[Constants.USER_ID]) do card:draw() end

    -- for _, card in pairs(self.cards[Constants.ENEMY_ID]) do
    -- 	card:draw()
    -- end

    -- if Deck.card_selected then
    -- Deck.card_selected:preview(love.mouse.getX(), love.mouse.getY())
    -- end

    -- self:draw_timer()
end

-- UI FUNCTIONS

function Game:draw_background()

    love.graphics.setColor(255, 255, 255, 1)

    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(),
                            love.graphics.getHeight())

    love.graphics.setColor(255, 255, 255, 1)

end

function Game:draw_bottom_panel()

    love.graphics.setColor(255, 255, 0, 1)

    love.graphics.rectangle("fill", 0, Map.image_height + 32,
                            love.graphics.getWidth(),
                            love.graphics.getHeight() - Map.image_height)

    love.graphics.setColor(255, 255, 255, 1)

end

return Game
