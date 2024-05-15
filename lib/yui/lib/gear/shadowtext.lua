--- Draw text with drop shadows.
--
-- Drop shadows improve text contrast and readability.
--
-- @module gear.shadowtext
-- @copyright 2022 The DoubleFourteen Code Forge
-- @author Lorenzo Cogotti

local shadowtext = {}


--- Print text with drop shadow, supports the same arguments as love.graphics.print(text, x, y).
function shadowtext.print(text, x, y, ...)
    local r,g,b,a = love.graphics.getColor()

    -- Draw drop shadow.
    love.graphics.setColor(0, 0, 0, a)
    love.graphics.print(text, x+2, y+2, ...)

    -- Draw text.
    love.graphics.setColor(r, g, b, a)
    love.graphics.print(text, x, y, ...)
end

--- Print text with drop shadow, supports the same arguments as love.graphics.printf(text, x, y).
function shadowtext.printf(text, x, y, ...)
    local r,g,b,a = love.graphics.getColor()

    -- Draw drop shadow.
    love.graphics.setColor(0, 0, 0, a)
    love.graphics.printf(text, x+2, y+2, ...)

    -- Draw text.
    love.graphics.setColor(r, g, b, a)
    love.graphics.printf(text, x, y, ...)
end

return shadowtext
