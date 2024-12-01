--- Implements a clickable Card widget
--
-- @classmod yui.Card
-- @copyright 2022, The DoubleFourteen Code Forge
-- @author Lorenzo Cogotti, Andrea Pasquini
--
--
-- Card widget receives the following callbacks: @{yui.Widget.WidgetCallbacks|onEnter}(), @{yui.Widget.WidgetCallbacks|onHit}(), @{yui.Widget.WidgetCallbacks|onLeave}().
local BASE = (...):gsub('card$', '')

local Widget = require(BASE .. 'widget')
local core = require(BASE .. 'core')

local shadowtext = require 'lib.yui.lib.gear.shadowtext'
local T = require('lib.yui.lib.moonspeak').translate

local Card = setmetatable({
    __call = function(cls, args) return cls:new(args) end
}, Widget)
Card.__index = Card

--- Attributes accepted by the @{Card} widget beyond the standard @{yui.Widget.WidgetAttributes|attributes}
-- and @{yui.Widget.WidgetCallbacks|callbacks}.
--
-- and @{yui.Widget.WidgetCallbacks|callbacks}.
-- @field text (string) text displayed inside the card
-- @field[opt='center'] valign (string) vertical alignment 'top', 'bottom', 'center'
-- @field[opt='center'] align (string) horizontal alignment, 'left', 'center', 'right'
-- @field cornerRadius (number) radius for rounded corners
-- @field notranslate (boolean) don't translate text
-- @table CardAttributes

--- Card constructor
-- @param args (@{CardAttributes}) widget attributes
function Card:new(args)
    self = setmetatable(args, self)

    self.text = self.text or ""
    self.align = self.align or 'center'
    self.valign = self.valign or 'bottom'
    self.active = false
    self.image = self.image or nil
    self.scale = self.scale or 1
    self.text_margin = self.text_margin or 0
    self.show_text = self.show_text or false;
    if not self.notranslate then self.text = T(self.text) end
    return self
end

function Card:draw()
    local x, y, w, h = self.x, self.y, self.w, self.h
    local color, font, cornerRadius = core.themeForWidget(self)
    local c = core.colorForWidgetState(self, color)
    local scale = { x = 1, y = 1 }

    if self.scale == 1 then
        scale = {
            x = w / self.image:getWidth(),
            y = h / self.image:getHeight()
        }
    end

    if self.image then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(self.image, x, y, 0, scale.x, scale.y);
    end

    if not self.text then return end

    y = y + core.verticalOffsetForAlign('bottom', font, h)
    shadowtext.printf(self.text, x, y, w, 'center')
end

return Card
