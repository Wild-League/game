--- Local drawing helpers
--
-- @module yui.core
-- @copyright 2022, The DoubleFourteen Code Forge
-- @author Lorenzo Cogotti, Andrea Pasquini

local core = {}

-- Helpers for drawing
function core.verticalOffsetForAlign(valign, font, h)
    if valign == 'top' then
        return 0
    elseif valign == 'bottom' then
        return h - font:getHeight()
    end
    -- else: 'middle'
    return (h - font:getHeight()) / 2
end

function core.themeForWidget(widget)
    local uiTheme = widget.ui.theme
    local theme = widget.theme or uiTheme

    local color = theme.color or uiTheme.color
    local font = theme.font or uiTheme.font or love.graphics.getFont()
    local cornerRadius = theme.cornerRadius or uiTheme.cornerRadius

    return color, font, cornerRadius
end

function core.colorForWidgetState(widget, color)
    color = color or widget.theme.color or widget.ui.theme.color

    if widget.active then
        return color.active
    elseif widget:isFocused() then
        return color.hovered
    else
        return color.normal
    end
end

function core.drawBox(x,y,w,h, color, cornerRadius)
    w = math.max(cornerRadius/2, w)
    if h < cornerRadius/2 then
        y,h = y - (cornerRadius - h), cornerRadius/2
    end

    love.graphics.setColor(color.bg)
    love.graphics.rectangle('fill', x,y, w,h, cornerRadius)
end

return core
