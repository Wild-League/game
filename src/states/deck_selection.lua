local DeckApi = require('src.api.deck')
local FriendListSidebar = require('src.ui.friend-list-sidebar')
local HeaderBar = require('src.ui.header-bar')
local yui = require('lib.yui')
local Image = require('src.helpers.image')
local Ui = yui.Ui


local DeckSelection = {
    friends = {},
    show_add_friend_input = false,
    friend_input = { text = "" },
    selected_deck = {
    },
    decks = {},
    ui = {
        size = {
            width = 0,
            height = 0
        },
        position = {
            x = 0,
            y = HeaderBar.height
        },
        card_size = {
            width = 0,
            height = 0
        },
        padding = {
            row = 0,
            column = 0
        },
        backgrounds = {}
    }
}
--#region UI Sizing

local function updateCardSize()
    DeckSelection.ui.card_size = {
        width = love.graphics.getWidth() / 10,
        height = love.graphics.getWidth() / 11
    }
end


local function updatePadding()
    DeckSelection.ui.padding = {
        row = DeckSelection.ui.card_size.width / 10,
        column = DeckSelection.ui.card_size.height / 10
    }
end

local function updateSize()
    updateCardSize()
    updatePadding()
    DeckSelection.ui.size = {
        width = love.graphics.getWidth() - FriendListSidebar.width,
        height = #DeckSelection.decks * (DeckSelection.ui.card_size.height + 2 * DeckSelection.ui.padding.row)
    }
end

local function updatePosition()
    DeckSelection.ui.position = {
        x = DeckSelection.ui.padding.column,
        y = HeaderBar.height + DeckSelection.ui.padding.row
    }
end

local function updateInterfaceSizes()
    updateSize()
    updatePosition()
end
--#endregion

local function drawCards(deck)
    local widgets = {}
    local cards = deck['cards']
    -- add botão de selecionar o deck
    local selectButton = yui.Button {
        w = DeckSelection.ui.card_size.width,
        h = DeckSelection.ui.card_size.height,
        text = 'Select',
        notranslate = true,
        onHit = function()
            DeckApi:set_selected_deck(deck['id'])
        end
    }
    table.insert(widgets, selectButton)

    for i = 1, #cards do
        local card = cards[i]

        local card = yui.Card {
            w = DeckSelection.ui.card_size.width,
            h = DeckSelection.ui.card_size.height,
            image = Image:load_from_url(card['img_card'], "image"),
            text = card['name'],
            text_margin = 0
        }

        table.insert(widgets, card)
    end

    return widgets
end

local function drawColumns()
    local rows = {}


    -- for i = 1, #DeckSelection.decks do
    for i = 1, 3 do
        -- local deck = DeckApi:get_deck_by_id(DeckSelection.decks[i]['id'])
        local deck = DeckApi:get_deck_by_id(DeckSelection.decks[1]['id'])

        DeckSelection.ui.backgrounds[i] = {
            x = DeckSelection.ui.position.x,
            y = DeckSelection.ui.position.y +
                (DeckSelection.ui.card_size.height * (i - 1)) + (DeckSelection.ui.padding.row * (i - 1)),
            -- +2 pra corrigir o background do botão :D
            w = (DeckSelection.ui.card_size.width * (#deck['cards'] + 1)) +
                (DeckSelection.ui.padding.column * (#deck['cards'] + 1)),
            h = DeckSelection.ui.card_size.height + (DeckSelection.ui.padding.row / 3) * 2
        }

        local column = yui.Columns {
            padding = DeckSelection.ui.padding.column,
            w = DeckSelection.ui.card_size.width * #deck['cards'],
            h = DeckSelection.ui.card_size.height,
            unpack(drawCards(deck))
        }

        table.insert(rows, column)
    end
    return rows
end

local function drawUI()
    DeckSelection.ui['gui'] = Ui:new {
        x = DeckSelection.ui.position.x, y = DeckSelection.ui.position.y,
        -- div com todos os decks
        yui.Rows {

            padding = DeckSelection.ui.padding.row,
            w = DeckSelection.ui.size.width, h = DeckSelection.ui.size.height,
            unpack(drawColumns())
        }
    }
end

function DeckSelection:load()
    FriendListSidebar:load()
    self.selected_deck = DeckApi:get_current_deck()
    self.decks = DeckApi:get_list()

    updateInterfaceSizes()
    drawUI()
end

function DeckSelection:draw()
    HeaderBar:draw("Lobby", 'lobby')
    love.graphics.setColor(1, 1, 1)
    for key, value in pairs(self.ui.backgrounds) do
        love.graphics.rectangle("fill", value['x'], value['y'], value['w'], value['h'])
    end

    self.ui['gui']:draw()
    updateInterfaceSizes()
    FriendListSidebar:draw(self)
end

function DeckSelection:update(dt)
    self.ui['gui']:update(dt)
end

function DeckSelection:resize()
    updateInterfaceSizes()
    drawUI()
end

return DeckSelection
