--- Implements a multi-choice widget
--
-- @classmod yui.Choice
-- @copyright 2022, The DoubleFourteen Code Forge
-- @author Lorenzo Cogotti, Andrea Pasquini
--
-- Multi-choice widget receives the following callbacks: @{yui.Widget.WidgetCallbacks|onEnter}(), @{yui.Widget.WidgetCallbacks|onChange}(), @{yui.Widget.WidgetCallbacks|onLeave}().

local BASE = (...):gsub('choice$', '')

local Widget = require(BASE..'widget')
local core = require(BASE..'core')

local clamp = require('lib.yui.lib.gear.mathx').clamp
local shadowtext = require 'lib.yui.lib.gear.shadowtext'
local T = require('lib.yui.lib.moonspeak').translate

local Choice = setmetatable({
    __call = function(cls, args) return cls:new(args) end
}, Widget)
Choice.__index = Choice

--- Attributes accepted by the @{Choice} widget beyond the standard @{yui.Widget.WidgetAttributes|attributes}
-- and @{yui.Widget.WidgetCallbacks|callbacks}.
--
-- @field choices (table) available choices list
-- @field nowrap (boolean) disable choices wrapping
-- @field[opt='center'] valign (string) vertical alignment 'top', 'bottom', 'center'
-- @field[opt='center'] align (string) horizontal alignment, 'left', 'center', 'right'
-- @field notranslate (boolean) don't translate text
-- @table ChoiceAttributes


--- Choice constructor
-- @param args (@{ChoiceAttributes}) widget attributes
function Choice:new(args)
    self = setmetatable(args, self)

    self.align = self.align or 'center'
    self.valign = self.valign or 'center'
    self.hovered = false
    self.choices = self.choices or { "" }
    self.nowrap = self.nowrap or #self.choices < 2
    self.index = 1  -- by default

    for i,choice in ipairs(self.choices) do
        -- Expand shorthands
        if type(choice) ~= 'table' then
            choice = {
                text = tostring(choice),
                notranslate = type(choice) ~= 'string',
                value = choice
            }

            self.choices[i] = choice
        end
        -- Mark default choice if needed
        if choice.value == self.default then
            self.index = i
        end
        -- Translate choice
        if not (self.notranslate or choice.notranslate) then
            choice.text = T(choice.text)
        end
    end
    return self
end

function Choice:checkIndex()
    if self.nowrap then
        self.index = clamp(self.index, 1, #self.choices)
    else
        if self.index < 1 then
            self.index = #self.choices
        end
        if self.index > #self.choices then
            self.index = 1
        end
    end
end

function Choice:onActionInput(action)
    local oldindex = self.index
    local handled = false

    -- Change choice
    if action.left then
        self.index = oldindex - 1
        handled = true
    end
    if action.right then
        self.index = oldindex + 1
        handled = true
    end
    if not handled then
        return false
    end

    -- Apply wrapping
    self:checkIndex()

    -- Fire event if necessary
    if oldindex ~= self.index then
        self:onChange(self.choices[self.index])
    end
    return true
end

function Choice:onPointerInput(px,_, clicked)
    self:grabFocus()
    if not clicked then
        return
    end

    local mx = px - self.x
    local oldindex = self.index

    -- Test whether arrows are hit
    -- NOTE: don't care about arrows being disabled, checkIndex() will fix that.
    if mx <= self.h+2 then
        self.index = self.index - 1
    elseif mx >= self.w - self.h-2 then
        self.index = self.index + 1
    end

    self:checkIndex()
    if oldindex ~= self.index then
        self:onChange(self.choices[self.index])
    end
end

function Choice:draw()
    local x,y,w,h = self.x,self.y,self.w,self.h
    local color, font, cornerRadius = core.themeForWidget(self)
    local c = core.colorForWidgetState(self, color)

    core.drawBox(x,y,w,h, c, cornerRadius)

    if self.ui.focused == self then
        -- draw < and > arrows, desaturate color if arrow is disabled
        local cc = color.hovered

        love.graphics.setLineStyle('smooth')
        love.graphics.setLineWidth(3)
        love.graphics.setLineJoin('bevel')

        local r, g, b = cc.fg[1], cc.fg[2], cc.fg[3]
        local a = (self.nowrap and self.index == 1) and 0.4 or 1

        love.graphics.setColor(r,g,b,a)
        love.graphics.line(x+h*.8,y+h*.2, x+h*.5,y+h*.5, x+h*.8,y+h*.8)

        a = (self.nowrap and self.index == #self.choices) and 0.4 or 1

        love.graphics.setColor(r,g,b,a)
        love.graphics.line(x+w-h*.8,y+h*.2, x+w-h*.5,y+h*.5, x+w-h*.8,y+h*.8)
    end

    -- draw text
    local text = self.choices[self.index].text

    y = y + core.verticalOffsetForAlign(self.valign, font, h)

    love.graphics.setColor(c.fg)
    love.graphics.setFont(font)
    shadowtext.printf(text, x+h+2, y, w-2*(h + 2), self.align)
end

return Choice
