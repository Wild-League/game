--- Implements a checkbox widget with a binary tick selection
--
-- @classmod yui.Checkbox
-- @copyright 2022, The DoubleFourteen Code Forge
-- @author Lorenzo Cogotti, Andrea Pasquini
--
-- Checkbox widget receives the following callbacks: @{yui.Widget.WidgetCallbacks|onEnter}(), @{yui.Widget.WidgetCallbacks|onChange}(), @{yui.Widget.WidgetCallbacks|onLeave}().

local BASE = (...):gsub('checkbox$', '')

local Widget = require(BASE..'widget')
local core = require(BASE..'core')

local shadowtext = require 'lib.yui.lib.gear.shadowtext'
local T = require('lib.yui.lib.moonspeak').translate

local Checkbox = setmetatable({
    __call = function(cls, args) return cls:new(args) end
}, Widget)
Checkbox.__index = Checkbox


--- Attributes accepted by the @{Checkbox} widget beyond the standard @{yui.Widget.WidgetAttributes|attributes}
-- and @{yui.Widget.WidgetCallbacks|callbacks}.
--
-- @field checked (boolean) to set it checked by default
-- @field text (string) text displayed inside the Checkbox
-- @field[opt='center'] valign (string) vertical alignment 'top', 'bottom', 'center'
-- @field[opt='center'] align (string) horizontal alignment, 'left', 'center', 'right'
-- @field notranslate (boolean) don't translate text
-- @table CheckboxAttributes


--- Checkbox constructor
-- @param args (@{CheckboxAttributes}) widget attributes
function Checkbox:new(args)
    self = setmetatable(args, self)

    self.text = self.text or ""
    self.text = self.notranslate and self.text or T(self.text)
    self.align = self.align or 'left'
    self.valign = self.valign or 'center'
    self.checked = self.checked or false
    return self
end

function Checkbox:onPointerInput(_,_, clicked)
    self:grabFocus()
    if clicked then
        self.checked = not self.checked
        self:onChange(self.checked)
    end
end

function Checkbox:onActionInput(action)
    if action.confirm then
        self.checked = not self.checked
        self:onChange(self.checked)
    end
end

function Checkbox:draw()
    local x,y,w,h = self.x,self.y,self.w,self.h
    local color, font, cornerRadius = core.themeForWidget(self)
    local c = core.colorForWidgetState(self, color)

    -- Draw checkbox
    core.drawBox(x+h/10,y+h/10,h*.8,h*.8, c, cornerRadius)
    love.graphics.setColor(c.fg)
    if self.checked then
        love.graphics.setLineStyle('smooth')
        love.graphics.setLineWidth(5)
        love.graphics.setLineJoin('bevel')
        love.graphics.line(x+h*.2,y+h*.55, x+h*.45,y+h*.75, x+h*.8,y+h*.2)
    end

    -- Most checkboxes have no text, so test for performance
    if self.text ~= "" then
        love.graphics.setFont(font)
        y = y + core.verticalOffsetForAlign(self.valign, font, self.h)
        shadowtext.printf(self.text, x + h, y, w - h, self.align)
    end
end

return Checkbox
