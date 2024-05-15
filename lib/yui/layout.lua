--- Layout container widget
--
-- Implements a layout widget
--
-- @classmod yui.Layout
-- @copyright 2022, The DoubleFourteen Code Forge
-- @author Lorenzo Cogotti, Andrea Pasquini
--
-- @{Layout} is an internal class, serving as a container of widgets and
-- defining their organization and display order.
-- It is useful for arrangement customization.


local BASE = (...):gsub('layout$', '')

local Widget = require(BASE..'widget')

local gear = require 'lib.yui.lib.gear'

local isinstance = gear.meta.isinstance
local rectunion = gear.rect.union
local pointinrect = gear.rect.pointinside

local Layout = setmetatable({
    __call = function(cls, args) return cls:new(args) end
}, Widget)
Layout.__index = Layout


-- Calculate initial widget size.
local function calcsize(sizes, widget)
    local w, h = widget.w, widget.h
    if w == nil then
        assert(#sizes > 0, "Default width is undefined!")
        w = sizes[#sizes].w
    end
    if h == nil then
        assert(#sizes > 0, "Default height is undefined!")
        h = sizes[#sizes].h
    end

    if w == 'max' then
        w = 0
        for _,v in ipairs(sizes) do
            if v.w > w then
                w = v.w
            end
        end
    elseif w == 'median' then
        w = 0
        for _,v in ipairs(sizes) do
            w = w + v.w
        end
        w = math.ceil(w / #sizes)
    elseif w == 'min' then
        w = math.huge
        for _,v in ipairs(sizes) do
            if v.w < w then
                w = v.w
            end
        end
    else
        assert(type(w) == 'number')
    end

    if h == 'max' then
        h = 0
        for _,v in ipairs(sizes) do
            if v.h > h then
                h = v.h
            end
        end
    elseif h == 'median' then
        h = 0
        for _,v in ipairs(sizes) do
            h = h + v.h
        end
        h = math.ceil(h / #sizes)
    elseif h == 'min' then
        h = math.huge
        for _,v in ipairs(sizes) do
            if v.h < h then
                h = v.h
            end
        end
    else
        assert(type(h) == 'number')
    end

    sizes[#sizes+1] = { w = w, h = h }

    widget.w, widget.h = w, h
    return w, h
end

-- Lay down container widgets according to Layout type.
function Layout:layoutWidgets()
    local nx,ny = self.x,self.y
    local sizes = {}
    local stack = self.stack
    local pad = self.padding

    -- Container bounds, empty
    local rx,ry,rw,rh = nx,ny,-1,-1

    -- Layout container children
    for _,widget in ipairs(self) do
        widget.x, widget.y = nx, ny
        widget.ui = self.ui
        widget.parent = self

        if isinstance(widget, Layout) then
            widget:layoutWidgets()
        end

        local w,h = calcsize(sizes, widget)
        rx,ry,rw,rh = rectunion(rx,ry,rw,rh, nx,ny,w,h)

        nx,ny = self.advance(nx,ny, w,h, pad)

        stack[#stack+1] = widget
    end

    self.x = rx
    self.y = ry
    self.w = math.max(rw, 0)
    self.h = math.max(rh, 0)

    -- A Layout ignores focus if empty or containing only nofocus widgets
    self.nofocus = true
    for _,w in ipairs(self) do
        if not w.nofocus then
            self.nofocus = false
            break
        end
    end
end

-- Find layout's child containing the provided widget.
local function childof(layout, widget)
    local parent = widget.parent
    while not rawequal(parent, layout) do
        widget = parent
        parent = widget.parent
    end
    return widget
end
local function scanforward(layout, from)
    from = from or 1

    for i = from,#layout do
        local w = layout[i]

        if not w.nofocus then
            return isinstance(w, Layout) and scanforward(w) or w
        end
    end
end
local function scanbackwards(layout, from)
    from = from or #layout

    for i = from,1,-1 do
        local w = layout[i]

        if not w.nofocus then
            return isinstance(w, Layout) and scanforward(w) or w
        end
    end
end

--- Attributes accepted by the Layout widget
--
-- @field padding (number) number of pixels between two elements
-- @table LayoutAttributes


--- Layout constructor
-- @param args (@{LayoutAttributes}) widget attributes
function Layout:new(args)
    self = setmetatable(args, self)

    self.padding = self.padding or 0
    self.stack = {}
    return self
end

--- Find the first widget in the layout accepting focus.
function Layout:first()
    return scanforward(self)
end

--- Find the last widget in the layout accepting focus.
function Layout:last()
    return scanbackwards(self)
end

--- Find the next focusable widget after the provided one.
function Layout:after(widget)
    widget = childof(self, widget)

    for i = 1,#self do
        if rawequal(self[i], widget) then
            -- Search to the right/down
            return scanforward(self, i+1)
        end
    end
end

--- Find the previous focusable widget before the provided one.
function Layout:before(widget)
    widget = childof(self, widget)

    for i = 1,#self do
        if rawequal(self[i], widget) then
            -- Search to the left/up
            return scanbackwards(self, i-1)
        end
    end
end

function Layout:onPointerInput(px,py, clicked, down)
    local stack = self.stack

    -- Propagate pointer event from topmost widget to bottom
    for i = #stack,1,-1 do
        local widget = stack[i]
        local x,y,w,h = widget.x,widget.y,widget.w,widget.h

        if pointinrect(px,py, x,y,w,h) then
            widget:onPointerInput(px,py, clicked, down)
            break
        end
    end
end

function Layout:update(dt)
    for _,widget in ipairs(self.stack) do
        widget:update(dt)
    end
end

function Layout:draw()
    -- Draw all children according to their order (topmost last)
    for _,widget in ipairs(self.stack) do
        widget:draw()
    end
end

return Layout
