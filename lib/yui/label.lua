--- Implements a static label widget
--
-- @classmod yui.Label
-- @copyright 2022, The DoubleFourteen Code Forge
-- @author Lorenzo Cogotti, Andrea Pasquini

local BASE = (...):gsub('label$', '')

local Widget = require(BASE .. 'widget')
local core = require(BASE .. 'core')

local shadowtext = require 'lib.yui.lib.gear.shadowtext'
local T = require('lib.yui.lib.moonspeak').translate

-- Labels don't accept focus
local Label = setmetatable({
    nofocus = true,
    __call = function(cls, args) return cls:new(args) end
}, Widget)
Label.__index = Label

--- Attributes accepted by the @{Label} widget in addition to the standard @{yui.Widget.WidgetAttributes|attributes}.
--
-- @field text (string) text displayed inside the Label
-- @field[opt='center'] valign (string) vertical alignment 'top', 'bottom', 'center'
-- @field[opt='center'] align (string) horizontal alignment, 'left', 'center', 'right'
-- @field notranslate (boolean) don't translate text
-- @table LabelAttributes

--- Label constructor
-- @param args (@{LabelAttributes}) widget attributes
function Label:new(args)
    self = setmetatable(args, self)

    self.text = self.text or ""
    self.text = self.notranslate and self.text or T(self.text)
    self.align = self.align or 'center'
    self.valign = self.valign or 'center'
    self.size = self.size or 12
    return self
end

function Label:draw()
    local x, y, w, h = self.x, self.y, self.w, self.h
    local color, font, _ = core.themeForWidget(self)

    y = y + core.verticalOffsetForAlign(self.valign, font, h)

    love.graphics.setColor(color.normal.fg)
    love.graphics.setFont(font, self.size)
    shadowtext.printf(self.text, x + 2, y, w - 4, self.align)
end

return Label
