--- Visual theme settings
--
-- @module yui.theme
-- @copyright 2022, The DoubleFourteen Code Forge
-- @author Lorenzo Cogotti, Andrea Pasquini

--- Defines common visual attributes and colors applied to every @{yui.Widget|Widget}.
--
-- @field cornerRadius (number) radius for rounded corners
-- @field font (love.graphics.Font) font used for text (defaults to love.graphics.getFont())
-- @field color (@{ColorPalette}) default @{yui.Widget|Widget} color theme
-- @table Theme

--- Defines which color corresponds to each @{yui.Widget|Widget} state.
--
-- @field hovered (@{Color}) color applied to hovered widgets
-- @field normal (@{Color}) color applied to widgets in their default state
-- @field active (@{Color}) color applied to active widgets
-- @table ColorPalette

--- A pair defining background and foreground colors.
--
-- @field bg (table) background color
-- @field fg (table) foreground color (typically used for text)
-- @table Color

local theme = {
    cornerRadius = 4,

    -- font = nil defaults to love.graphics.getFont()

    color = {
        normal   = {bg = { 0.25, 0.25, 0.25}, fg = {0.73, 0.73, 0.73}},
        hovered  = {bg = { 0.19, 0.6, 0.73}, fg = {1, 1, 1}},
        active   = {bg = { 1, 0.6, 0}, fg = {1, 1, 1}}
    }
}

return theme
