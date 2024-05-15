--- Row layout for widgets
--
-- @classmod yui.Rows
-- @copyright 2022, The DoubleFourteen Code Forge
-- @author Lorenzo Cogotti, Andrea Pasquini
--
-- A widget container, lays down its child widgets into multiple rows.

local BASE = (...):gsub('rows$', '')

local Layout = require(BASE..'layout')

-- Advance position to next row,
-- given current position, widget dimensions and padding.
local function rowadvance(x,y, _,wh, padding)
    return x, y + wh + padding
end

local Rows = setmetatable({
    advance = rowadvance,
    __call = function(cls, args) return cls:new(args) end
}, Layout)
Rows.__index = Rows


function Rows:new(args) return setmetatable(Layout:new(args), self) end

return Rows
