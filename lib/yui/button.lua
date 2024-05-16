--- Implements a clickable button widget
--
-- @classmod yui.Button
-- @copyright 2022, The DoubleFourteen Code Forge
-- @author Lorenzo Cogotti, Andrea Pasquini
--
--
-- Button widget receives the following callbacks: @{yui.Widget.WidgetCallbacks|onEnter}(), @{yui.Widget.WidgetCallbacks|onHit}(), @{yui.Widget.WidgetCallbacks|onLeave}().
local BASE = (...):gsub('button$', '')

local Widget = require(BASE .. 'widget')
local core = require(BASE .. 'core')

local shadowtext = require 'lib.yui.lib.gear.shadowtext'
local T = require('lib.yui.lib.moonspeak').translate

local Button = setmetatable({
    __call = function(cls, args) return cls:new(args) end
}, Widget)
Button.__index = Button

--- Attributes accepted by the @{Button} widget beyond the standard @{yui.Widget.WidgetAttributes|attributes}
-- and @{yui.Widget.WidgetCallbacks|callbacks}.
--
-- and @{yui.Widget.WidgetCallbacks|callbacks}.
-- @field text (string) text displayed inside the button
-- @field[opt='center'] valign (string) vertical alignment 'top', 'bottom', 'center'
-- @field[opt='center'] align (string) horizontal alignment, 'left', 'center', 'right'
-- @field cornerRadius (number) radius for rounded corners
-- @field notranslate (boolean) don't translate text
-- @table ButtonAttributes

--- Button constructor
-- @param args (@{ButtonAttributes}) widget attributes
function Button:new(args)
    self = setmetatable(args, self)

    self.text = self.text or ""
    self.align = self.align or 'center'
    self.valign = self.valign or 'center'
    self.active = false
    self.image = self.image or nil
    self.use_image_as_background = self.use_image_as_background or false
    self.scale = self.scale or 1
    self.mode = self.mode or "fill"

    if not self.notranslate then self.text = T(self.text) end
    return self
end

local function hit(button)
    if not button.active then
        button.active = true
        button:onHit()

        button.ui.timer:after(0.15, function() button.active = false end)
    end
end

function Button:onPointerInput(_, _, clicked)
    self:grabFocus()
    if clicked then hit(self) end
end

function Button:onActionInput(action) if action.confirm then hit(self) end end

local i = 0

function Button:draw()
    local x, y, w, h = self.x, self.y, self.w, self.h
    local color, font, cornerRadius = core.themeForWidget(self)
    local c = core.colorForWidgetState(self, color)

    if self.image then
        love.graphics.draw(self.image, x, y, 0, self.scale, self.scale);

        if (self:isFocused() and self.drawBox == true) or
            self.use_image_as_background == false then
            love.graphics.setColor(1, 1, 1, 0.5)
            love.graphics.rectangle(self.mode, x / self.scale, y / self.scale,
                                    self.image:getWidth() * self.scale,
                                    self.image:getHeight() * self.scale)
            love.graphics.setColor(1, 1, 1)
        end
    else
        core.drawBox(x / self.scale, y / self.scale, w * self.scale,
                     h * self.scale, c, cornerRadius)
        love.graphics.setColor(c.fg)
        love.graphics.setFont(font)
        y = y + core.verticalOffsetForAlign(self.valign, font, h * self.scale)
        shadowtext.printf(self.text, x + 2, y, (w - 4) * self.scale, self.align)
    end
end

return Button
