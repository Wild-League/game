--- User interface manager
--
-- @classmod yui.Ui
-- @copyright 2022, The DoubleFourteen Code Forge
-- @author Lorenzo Cogotti, Andrea Pasquini
--

--- An Ui manages a hierarchy of Widgets.
-- The @{Ui} draws its widgets according to their layout and position, manages input focus, and
-- dispatches events to the appropriate widgets depending on their class and activity status.
local BASE = (...):gsub('ui$', '')

local Widget = require(BASE..'widget')
local Layout = require(BASE..'layout')
local Columns = require(BASE..'columns')
local Rows = require(BASE..'rows')
local theme = require(BASE..'theme')
local gear = require 'lib.yui.lib.gear'

local Timer = gear.Timer
local isinstance = gear.meta.isinstance
local pointinrect = gear.rect.pointinside

local Ui = {
    theme = theme  -- fallback theme
}
Ui.__index = Ui


-- Scan UI for the LAST widgets with 'cancelfocus' or 'firstfocus' flags
local function resolveautofocus(widget)
    local firstfocus, cancelfocus

    if isinstance(widget, Layout) then
        for _,w in ipairs(widget) do
            local firstf, cancelf

            if not w.nofocus then
                if isinstance(w, Layout) then
                    firstf, cancelf = resolveautofocus(w)
                else
                    if w.firstfocus then
                        firstf = w
                    end
                    if w.cancelfocus then
                        cancelf = w
                    end
                end
            end

            firstfocus = firstf or firstfocus
            cancelfocus = cancelf or cancelfocus
        end

    elseif not widget.nofocus then
        if widget.firstfocus then
            firstfocus = widget
        end
        if widget.cancelfocus then
            cancelfocus = widget
        end
    end

    return firstfocus, cancelfocus
end

--- Attributes accepted by the Ui widget
--
-- @field x (number) x position of the Ui
-- @field y (number) y position of the Ui
-- @field theme (@{yui.theme.Theme|Theme}) custom global Ui theme, defaults to @{yui.theme}
-- @table UiAttributes


--- Ui constructor
-- @param args (@{UiAttributes}) widget attributes
function Ui:new(args)
    self = setmetatable(args, self)
    assert(#self == 1, "Ui:new() must have exactly one root widget.")

    self.device = self.device or require(BASE..'device.love').new()
    self.x = self.x or 0
    self.y = self.y or 0
    self.pointerActive = true
    self.timer = Timer:new()

    local root = self[1]
    if not isinstance(root, Widget) then
        error("Ui:new() bad root Widget type: "..type(root)..".")
    end

    root.x,root.y = self.x,self.y
    root.ui = self
    if isinstance(root, Layout) then
        root:layoutWidgets()
    else
        assert(type(root.w) == 'number', "Ui:new() root Widget must have a numeric width.")
        assert(type(root.h) == 'number', "Ui:new() root Widget must have a numeric height.")
        assert(not root.nofocus, "Ui:new() single root Widget can't be nofocus.")
    end

    self.w,self.h = root.w,root.h

    local firstfocus, cancelfocus = resolveautofocus(root)
    if not firstfocus then
        firstfocus = isinstance(root, Layout) and
                     root:first() or
                     root
    end

    self.cancelfocus = cancelfocus
    firstfocus:grabFocus()

    return self
end

-- Event propagators for widgets listening to keyboard input
function Ui:keypressed(key, scancode, isrepeat)
    local focused = self.focused

    if focused and focused.grabkeyboard then
        focused:keypressed(key, scancode, isrepeat)
    end
end
function Ui:keyreleased(key, scancode)
    local focused = self.focused

    if focused and focused.grabkeyboard then
        focused:keyreleased(key, scancode)
    end
end
function Ui:textinput(text)
    local focused = self.focused

    if focused and focused.grabkeyboard then
        focused:textinput(text)
    end
end
function Ui:textedited(text, start, length)
    local focused = self.focused

    if focused and focused.grabkeyboard then
        focused:textedited(text, start, length)
    end
end

local function actionpropagate(widget, action)
    while widget do
        if widget:onActionInput(action) then
            return true  -- action consumed
        end

        widget = widget.parent
    end

    return false
end

local navs = { 'cancel', 'up', 'down', 'left', 'right' }

local function globalactions(ui, snap)
    for _,nav in ipairs(navs) do
        if snap[nav] then
            ui:navigate(nav)
            break  -- discard other directions, if any
        end
    end
end

local function eventpropagate(ui, snap)
    -- Ignore event flags, in case focused widget requires direct input
    local dropPointer = ui.focused and ui.focused.grabpointer
    local dropAction = ui.focused and ui.focused.grabkeyboard

    -- 1. Pointer events
    if snap.pointer and not dropPointer then
        local root = ui[1]
        local x,y,w,h = root.x,root.y,root.w,root.h

        if snap.pointer and pointinrect(snap.px,snap.py, x,y,w,h) then
            root:onPointerInput(snap.px,snap.py, snap.clicked, snap.pointing)
        end
    end

    -- 2. Actions (keyboard/buttons)
    if snap.action and not dropAction then
        local consumed = actionpropagate(ui.focused, snap)

        if not consumed then
            -- 3. If no widget consumed action,
            --    take global actions (e.g. navigation).
            globalactions(ui, snap)
        end
    end
end

-- cls may be Rows, Columns or Layout in general
local function containerof(widget, cls)
    repeat
        widget = widget.parent
        if isinstance(widget, cls) then
            return widget
        end
    until widget == nil
end

local function findprev(ui, cls, widget)
    local child = widget

    while true do
        local container = containerof(child, cls)
        if container == nil then
            -- All the way up, either return the original
            -- widget or wraparound to the bottom
            return isinstance(child, cls) and child:last() or widget
        end

        local w = container:before(child)
        if w ~= nil then
            return w
        end

        child = container  -- move up into the hierarchy
    end
end

-- Specular to findprev()
local function findnext(ui, cls, widget)
    local child = widget

    while true do
        local container = containerof(child, cls)
        if container == nil then
            return isinstance(child, cls) and child:first() or widget
        end

        local w = container:after(child)
        if w ~= nil then
            return w
        end

        child = container
    end
end

--- Move focus to the given direction.
--
-- @param where (string) Direction to move to, one of: 'up', 'down', 'left', 'right', 'cancel'.
function Ui:navigate(where)
    local nextfocus = nil

    if where == 'cancel' then
        nextfocus = self.cancelfocus
    elseif where == 'up' then
        nextfocus = findprev(self, Rows, self.focused)
    elseif where == 'down' then
        nextfocus = findnext(self, Rows, self.focused)
    elseif where == 'left' then
        nextfocus = findprev(self, Columns, self.focused)
    elseif where == 'right' then
        nextfocus = findnext(self, Columns, self.focused)
    else
        error("Bad direction: "..tostring(where))
    end

    if nextfocus ~= nil then
        nextfocus:grabFocus()
    end
end

function Ui:update(dt)
    local root = self[1]
    local snap = self.device:snapshot()

    -- Update timer related effects
    self.timer:update(dt)

    -- Regular event propagation
    eventpropagate(self, snap)

    -- Perform regular lifetime updates
    root:update(dt)
end

function Ui:draw()
    local root = self[1]

    love.graphics.push('all')
        root:draw()
    love.graphics.pop()
end

return Ui
