--- A user interface element
-- @classmod yui.Widget
-- @copyright 2022, The DoubleFourteen Code Forge
-- @author Lorenzo Cogotti, Andrea Pasquini

--- Functions accepted by all the Widget classes
-- @field onEnter function is called when the widget gets entered (e.g. hovered by pointer/mouse cursor)
-- @field onHit function is called when the widget is hit (e.g. clicked)
-- @field onChange function is called when the widget value is changed (e.g. checkbox is ticked)
-- @field onLeave function is called when the widget is left (e.g. another widget acquires focus, mouse leaves the widget area)
-- @table WidgetCallbacks

--- Attributes accepted by all the Widget classes
-- @field w (number) widget width
-- @field h (number) widget height
-- @field theme (@{yui.theme.Theme|Theme}) widget specific theme
-- @field color (@{yui.theme.ColorPalette|ColorPalette}) widget color
-- @table WidgetAttributes
local rectunion = require('lib.yui.lib.gear.rect').union

local Widget = {
    __call = function(cls, args) return cls:new(args) end
}
Widget.__index = Widget


local function raise(widget)
    local parent = widget.parent

    -- A parent of a widget is necessarily a Layout
    while parent ~= nil do
        local stack = parent.stack

        -- Move widget at the end of the stack, so it is rendered last.
        for i,w in ipairs(stack) do
            if w == widget then
                table.remove(stack, i)
                stack[#stack+1] = widget
                break
            end
        end

        -- Focus widget's container, if any
        widget = parent
        parent = widget.parent
    end
end

function Widget:grabFocus()
    local ui = self.ui
    local focused = ui.focused

    if focused == self then
        return
    end
    if focused ~= nil then
        -- Notify leave
        focused.hovered = false
        -- Widget specific focus loss
        focused:loseFocus()
        -- Event handler
        focused:onLeave()

        if focused.grabkeyboard then
            -- If focused widget stole input,
            -- then drop current input snapshot, since
            -- those events should have been already
            -- managed directly
            ui.device:snapshot()
        end
    end

    local wasHovered = self.hovered

    self.hovered = true
    if not wasHovered then
        -- First time hovered, notify enter
        self:gainFocus()
        self:onEnter()
    end

    -- Raise widget
    ui.focused = self
    raise(self)
end

function Widget:isFocused()
    return self.ui.focused == self
end

function Widget:recalculateBounds()
    local widget = self.parent
    while widget ~= nil do
        local rx,ry,rw,rh = widget.x,widget.y,-1,-1

        for _,w in ipairs(widget) do
            rx,ry,rw,rh = rectunion(rx,ry,rw,rh, w.x,w.y,w.w,w.h)
        end

        widget.x = rx
        widget.y = ry
        widget.w = rw
        widget.h = rh

        widget = widget.parent
    end
end

-- NOP hooks for UI internal use
function Widget:loseFocus() end
function Widget:gainFocus() end

-- NOP event handlers, publicly overridable

function Widget:onHit() end
function Widget:onEnter() end
function Widget:onLeave() end
function Widget:onChange() end

-- NOP input event handlers
function Widget:onActionInput(action) end
function Widget:onPointerInput(x,y, clicked) end

-- NOP UI event handlers
function Widget:update(dt) end
function Widget:draw() end

return Widget
