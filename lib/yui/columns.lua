--- Columns layout for widgets
--
-- @classmod yui.Columns
-- @copyright 2022, The DoubleFourteen Code Forge
-- @author Lorenzo Cogotti, Andrea Pasquini
--
-- A widget container, lays down its child widgets into multiple columns.

local BASE = (...):gsub('columns$', '')

local Layout = require(BASE..'layout')

-- Advance position to next column
-- given current position, widget dimensions and padding
local function columnadvance(x,y, ww,_, padding)
    return x + ww + padding, y
end

local Columns = setmetatable({
    advance = columnadvance,
    __call = function(cls, args) return cls:new(args) end
}, Layout)
Columns.__index = Columns


function Columns:new(args) return setmetatable(Layout:new(args), self) end

return Columns
