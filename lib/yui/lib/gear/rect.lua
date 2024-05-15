--- Axis-aligned rectangles.
--
-- Function for basic bounding rectangles building and testing.
--
-- @module gear.rect
-- @copyright 2022 The DoubleFourteen Code Forge
-- @author Lorenzo Cogotti

local rotatesincos = require((...):gsub('rect$', '')..'vec').rotatesincos

local min, max = math.min, math.max
local abs = math.abs

local rect = {}


--- Extend rectangle to include a point.
function rect.expand(x,y,w,h, px,py)
    if w < 0 or h < 0 then
        return px,py,0,0
    end

    local xw, yh
    x  = min(x, px)
    y  = min(y, py)
    xw = max(x+w, px)
    yh = max(y+h, py)

    return x, y, xw-x, yh-y
end

--- Calculate and return the union of two rectangles.
function rect.union(x1,y1,w1,h1, x2,y2,w2,h2)
    local xw1,yh1, xw2,yh2

    if w1 < 0 or h1 < 0 then
        local huge = math.huge

        x1,y1,xw1,yh1 = huge,huge,-huge,-huge
    else
        xw1,yh1 = x1 + w1,y1 + h1
    end
    if w2 < 0 or h2 < 0 then
        local huge = math.huge

        x2,y2,xw2,yh2 = huge,huge,-huge,-huge
    else
        xw2,yh2 = x2 + w2,y2 + h2
    end

    x1  = min(x1, x2)
    y1  = min(y1, y2)
    xw1 = max(xw1, xw2)
    yh1 = max(yh1, yh2)

    return x1, y1, xw1 - x1, yh1 - y1
end

--- Calculate and return the intersection between two rectangles.
function rect.intersection(x1,y1,w1,h1, x2,y2,w2,h2)
    if w1 < 0 or h1 < 0 then
        return x1,y1,w1,h1
    elseif w2 < 0 or h2 < 0 then
        return x2,y2,w2,h2
    end

    local xw1,yh1 = x1+w1, y1+h1
    local xw2,yh2 = x2+w2, y2+h2

    x1  = max(x1, x2)
    y1  = max(y1, y2)
    xw1 = min(xw1, xw2)
    yh1 = min(yh1, yh2)
    return x1,y1, xw1-x1,yh1-y1
end

--- Rotate rectangle around (ox,oy) about rot radians,
--  and return the result's minimum enclosing
--  axis-aligned rectangle.
--
-- NOTE: This causes precision loss, possibly generating
--       larger bounds than needed for the rotated geometry
--       Don't use this function repeatedly on the same bounds.
function rect.rotate(rx,ry,rw,rh, rot, ox,oy)
    if rw < 0 or rh < 0 then
        return rx,ry,rw,rh
    end

    ox = ox or 0
    oy = oy or 0

    local sina,cosa = sin(rot),cos(rot)

    local x1,y1 = rotatesincos(rx,    ry,    sina,cosa, ox,oy)
    local x2,y2 = rotatesincos(rx+rw, ry,    sina,cosa, ox,oy)
    local x3,y3 = rotatesincos(rx+rw, ry+rh, sina,cosa, ox,oy)
    local x4,y4 = rotatesincos(rx,    ry+rh, sina,cosa, ox,oy)

    local rxw, rxh
    rx  = min(min(min(x1, x2), x3), x4)
    ry  = min(min(min(y1, y2), y3), y4)
    rxw = max(max(max(x1, x2), x3), x4)
    ryh = max(max(max(y1, y2), y3), y4)

    return rx,ry, rxw-rx,ryh-ry
end

--- Test whether point (x,y) lies inside a rectangle.
function rect.pointinside(x,y, rx,ry,rw,rh)
    return x >= rx and y >= ry and x-rx <= rw and y-ry <= rh
end

--- Test whether the first rectangle lies inside the second.
function rect.rectinside(x1,y1,w1,h1, x2,y2,w2,h2)
    return (x1 >= x2 and y1 >= y2 and w1 <= w2 and h1 <= h2 and w2 >= 0 and h2 >= 0)
        or ((w1 < 0 or h1 < 0) and (w2 >= 0 and h2 >= 0))
end

--- Test two rectangles for equality with optional epsilon.
function rect.eq(x1,y1,w1,h1, x2,y2,w2,h2, eps)
    eps = eps or 0.007

    return (abs(x1 - x2) <= eps and
            abs(y1 - y2) <= eps and
            abs(w1 - w2) <= eps and
            abs(h1 - h2) <= eps)
        or ((w1 < 0 or h1 < 0) and (w2 < 0 or h2 < 0))
end

--- Test whether a rectangle is empty.
function rect.isempty(x,y,w,h)
    return w < 0 or h < 0
end

return rect
