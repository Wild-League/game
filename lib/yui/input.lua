--- Implements a text input field widget (textfield)
--
-- @classmod yui.Input
-- @copyright 2022, The DoubleFourteen Code Forge
-- @author Lorenzo Cogotti, Andrea Pasquini
--
-- Input widget receives the following callbacks: @{yui.Widget.WidgetCallbacks|onEnter}(), @{yui.Widget.WidgetCallbacks|onChange}(), @{yui.Widget.WidgetCallbacks|onLeave}().


local BASE = (...):gsub('input$', '')

local Widget = require(BASE..'widget')
local core = require(BASE..'core')

local utf8 = require 'utf8'

-- NOTE: Input manages keyboard directly.
local Input = setmetatable({
    grabkeyboard = true,
    __call = function(cls, args) return cls:new(args) end
}, Widget)
Input.__index = Input


local function split(str, pos)
    local ofs = utf8.offset(str, pos) or 0
    return str:sub(1, ofs-1), str:sub(ofs)
end

--- Attributes accepted by the @{Input} widget beyond the standard @{yui.Widget.WidgetAttributes|attributes}
-- and @{yui.Widget.WidgetCallbacks|callbacks}.
--
-- @field text (string) text displayed inside the Input
-- @table InputAttributes


--- Input constructor
-- @param args (@{InputAttributes}) widget attributes
function Input:new(args)
    self = setmetatable(args, self)

    self.text = self.text or ""
    self.cursor = math.max(1, math.min(utf8.len(self.text)+1,
                                       self.cursor or utf8.len(self.text)+1))
    self.candidate = { text = "", start = 0, length = 0 }
    self.drawofs = 0

    return self
end

-- NOTE: Input steals keyboard input on focus.
function Input:gainFocus()
    love.keyboard.setTextInput(true, self.x,self.y,self.w,self.h)
    love.keyboard.setKeyRepeat(true)
end
function Input:loseFocus()
    if love.system.getOS() == 'Android' or love.system.getOS() == 'iOS' then
        love.keyboard.setTextInput(false)
    end
    love.keyboard.setKeyRepeat(false)
end

function Input:onPointerInput(px,py, clicked)
    if clicked then
        self:grabFocus()

        -- Schedule cursor reposition for next draw()
        self.px = px
        self.py = py
    end
end

function Input:textedited(text, start, length)
    self.candidate.text = text
    self.candidate.start = start
    self.candidate.length = length
end

function Input:textinput(text)
    if text ~= "" then
        local a,b = split(self.text, self.cursor)

        self.text = table.concat {a, text, b}
        self.cursor = self.cursor + utf8.len(text)

        self:onChange(self.text)
    end
end

function Input:keypressed(key, _, isrepeat)
    if isrepeat == nil then
        -- LOVE sends 3 types of keypressed() events,
        -- 1. with isrepeat = true
        -- 2. with isrepeat = false
        -- 3. with isrepeat = nil
        --
        -- We're only interested in the first 2.
        return
    end

    if self.candidate.length == 0 then
        if key == 'backspace' and self.cursor > 1 then
            local a,b = split(self.text, self.cursor)

            self.text = table.concat { split(a, utf8.len(a)), b }
            self.cursor = self.cursor-1

            self:onChange(self.text)
        elseif key == 'delete' and self.cursor ~= utf8.len(self.text)+1 then
            local a,b = split(self.text, self.cursor)
            _,b = split(b, 2)

            self.text = table.concat { a, b }

            self:onChange(self.text)
        elseif key == 'left' then
            self.cursor = math.max(1, self.cursor-1)
        elseif key == 'right' then
            self.cursor = math.min(utf8.len(self.text)+1, self.cursor+1)
        end
    end
end

function Input:keyreleased(key)
    if self.candidate.length == 0 then
        local moveTo

        if key == 'home' then
            self.cursor = 1
        elseif key == 'end' then
            self.cursor = utf8.len(self.text)+1
        elseif key == 'up' or key == 'down' then
            moveTo = key
        elseif key == 'tab' or key == 'return' then
            moveTo = 'right'
        elseif key == 'escape' then
            moveTo = 'cancel'
        end

        if moveTo then
            self.cursor = 1  -- reset cursor position
            self.ui:navigate(moveTo)
        end
    end
end

function Input:draw()
    -- Cursor position is before the char (including EOS) i.e. in "hello":
    --   position 1: |hello
    --   position 2: h|ello
    --   ...
    --   position 6: hello|

    local x,y,w,h = self.x,self.y,self.w,self.h
    local color, font, cornerRadius = core.themeForWidget(self)
    local th = font:getHeight()
    local tw = font:getWidth(self.text)

    -- Get size of text and cursor position
    local cursor_pos = 0
    if self.cursor > 1 then
        local s = self.text:sub(1, utf8.offset(self.text, self.cursor)-1)
        cursor_pos = font:getWidth(s)
    end

    -- Calculate initial text offset
    local wm = math.max(w - 6, 0)  -- width minus margin
    if cursor_pos - self.drawofs < 0 then
        -- cursor left of input box
        self.drawofs = cursor_pos
    end
    if cursor_pos - self.drawofs > wm then
        -- cursor right of input box
        self.drawofs = cursor_pos - wm
    end
    if tw - self.drawofs < wm and tw > wm then
        -- text bigger than input box, but doesn't fill it
        self.drawofs = tw - wm
    end

    -- Handle cursor movement within the box
    if self.px ~= nil then
        -- Mouse movement
        local mx = self.px - self.x + self.drawofs

        self.cursor = utf8.len(self.text) + 1
        for c = 1,self.cursor do
            local s = self.text:sub(0, utf8.offset(self.text, c)-1)
            if font:getWidth(s) >= mx then
                self.cursor = c-1
                break
            end
        end

        self.px,self.py = nil,nil
    end

    -- Perform actual draw
    core.drawBox(x,y,w,h, color.normal, cornerRadius)

    -- Apply text margins
    x = math.min(x + 3, x + w)

    -- Set scissors
    local sx, sy, sw, sh = love.graphics.getScissor()
    love.graphics.setScissor(x-1,y,w+1,h)

    -- Move to focused text box region
    x = x - self.drawofs

    -- Text
    love.graphics.setColor(color.normal.fg)
    love.graphics.setFont(font)
    love.graphics.print(self.text, x, y + (h-th)/2)

    if self.candidate.length > 0 then
        -- Candidate text
        local ctw = font:getWidth(self.candidate.text)

        love.graphics.setColor(color.normal.fg)
        love.graphics.print(self.candidate.text, x + tw, y + (h-th)/2)

        -- Candidate text rectangle box
        love.graphics.rectangle('line', x + tw, y + (h-th)/2, ctw, th)

        self.candidate.text = ""
        self.candidate.start = 0
        self.candidate.length = 0
    end

    -- Cursor
    if self:isFocused() and (love.timer.getTime() % 1) > .5 then
        local ct = self.candidate
        local ss = ct.text:sub(1, utf8.offset(ct.text, ct.start))
        local ws = ct.start > 0 and font:getWidth(ss) or 0

        love.graphics.setLineWidth(1)
        love.graphics.setLineStyle('rough')
        love.graphics.line(x + cursor_pos + ws, y + (h-th)/2,
                           x + cursor_pos + ws, y + (h+th)/2)
    end

    -- Reset scissor
    love.graphics.setScissor(sx,sy,sw,sh)
end

return Input
