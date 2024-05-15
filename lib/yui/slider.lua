--- Implements a scrollable slider widget
--
-- @classmod yui.Slider
-- @copyright 2022, The DoubleFourteen Code Forge
-- @author Lorenzo Cogotti, Andrea Pasquini
--
-- Slider widget receives the following callbacks: @{yui.Widget.WidgetCallbacks|onEnter}(), @{yui.Widget.WidgetCallbacks|onChange}(), @{yui.Widget.WidgetCallbacks|onLeave}().

local BASE = (...):gsub('slider$', '')

local Widget = require(BASE..'widget')
local core = require(BASE..'core')

local Slider = setmetatable({
    __call = function(cls, args) return cls:new(args) end
}, Widget)
Slider.__index = Slider

--- Attributes accepted by the @{Slider} widget beyond the standard @{yui.Widget.WidgetAttributes|attributes}
-- and @{yui.Widget.WidgetCallbacks|callbacks}.
--
-- @field min (number) min value of the slider
-- @field max (number) max value of the slider
-- @field vertical (boolean) true for vertical slider, false or nil for horizontal slider
-- @field value (number) default value
-- @field step (number) number of slider's steps
-- @table SliderAttributes


--- Slider constructor
-- @param args (@{SliderAttributes}) widget attributes
function Slider:new(args)
    self = setmetatable(args, self)

    self.vertical = self.vertical or false
    self.min = self.min or 0
    self.max = self.max or 1
    self.value = self.value or self.min
    self.step = self.step or (self.max - self.min) / 10
    return self
end

function Slider:onPointerInput(px,py, _, down)
    self:grabFocus()
    if not down then
        return
    end

    local x,y,w,h = self.x,self.y,self.w,self.h

    local fraction
    if self.vertical then
        fraction = math.min(1, math.max(0, (y+h - py) / h))
    else
        fraction = math.min(1, math.max(0, (px - x) / w))
    end

    local v = fraction*(self.max - self.min) + self.min
    if v ~= self.value then
        self.value = v
        self:onChange(v)
    end
end

function Slider:onActionInput(action)
    local up = self.vertical and 'up' or 'right'
    local down = self.vertical and 'down' or 'left'

    local handled = false
    if action[up] then
        self.value = math.min(self.max, self.value + self.step)
        handled = true
    elseif action[down] then
        self.value = math.max(self.min, self.value - self.step)
        handled = true
    end
    if handled then
        self:onChange(self.value)
    end

    return handled
end

function Slider:draw()
    local x,y,w,h = self.x,self.y,self.w,self.h
    local r = math.min(w,h) / 2.1
    local color, _, cornerRadius = core.themeForWidget(self)
    local c = core.colorForWidgetState(self, color)
    local fraction = (self.value - self.min) / (self.max - self.min)

    local xb, yb, wb, hb  -- size of the progress bar
    if self.vertical then
        x, w = x + w*.25, w*.5
        xb, yb, wb, hb = x, y+h*(1-fraction), w, h*fraction
    else
        y, h = y + h*.25, h*.5
        xb, yb, wb, hb = x,y, w*fraction, h
    end

    core.drawBox(x,y,w,h, c, cornerRadius)
    core.drawBox(xb,yb,wb,hb, { bg = c.fg }, cornerRadius)

    if self:isFocused() then
        love.graphics.setColor(c.fg)
        if self.vertical then
            love.graphics.circle('fill', x+wb/2, yb, r)
        else
            love.graphics.circle('fill', x+wb, yb+hb/2, r)
        end
    end
end

return Slider
