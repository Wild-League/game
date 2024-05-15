--- Implements a spacer widget
--
-- @classmod yui.Spacer
-- @copyright 2022, The DoubleFourteen Code Forge
-- @author Lorenzo Cogotti, Andrea Pasquini
--
-- Spacer widget insert a space between two widget.

local BASE = (...):gsub('spacer$', '')

local Widget = require(BASE..'widget')

-- Spacers don't accept focus
local Spacer = setmetatable({
    nofocus = true,
    __call = function(cls, args) return cls:new(args) end
}, Widget)
Spacer.__index = Spacer


--- Attributes accepted by the @{Spacer} widget @{yui.Widget.WidgetAttributes|attributes}.
--
-- @param args @{yui.Widget.WidgetAttributes|Widgetattributes} widget attributes
function Spacer:new(args) return setmetatable(args, self) end

return Spacer
