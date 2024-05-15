--- Camera management class.
--
-- This is a reworked implementation of the original camera module
-- from the hump library (https://github.com/vrld/hump).
-- See README.ACKNOWLEDGEMENT for detailed information.
--
-- @module gear.camera
-- @copyright 2010-2013 Matthias Richter
-- @copyright 2022 The DoubleFourteen Code Forge
-- @author Matthias Richter, Lorenzo Cogotti

local Camera = { smooth = {} }
Camera.__index = Camera


function Camera.smooth.none()
    return function (dx, dy) return dx, dy end
end

function Camera.smooth.linear(speed)
    if type(speed) ~= 'number' then
        error("Invalid parameter: speed = "..tostring(speed))
    end

    local getDelta = love.timer.getDelta
    local min = math.min
    local sqrt = math.sqrt

    return function (dx,dy, s)
        -- normalize direction
        local d = sqrt(dx*dx + dy*dy)
        local dts = min((s or speed) * getDelta(), d)  -- prevent overshooting the goal

        if d > 0 then
            dx,dy = dx/d, dy/d
        end

        return dx*dts, dy*dts
    end
end

function Camera.smooth.damped(stiffness)
    if type(stiffness) ~= 'number' then
        error("Invalid parameter: stiffness = "..tostring(stiffness))
    end

    local getDelta = love.timer.getDelta

    return function (dx,dy, s)
        local dts = (s or stiffness) * getDelta()

        return dx*dts, dy*dts
    end
end

function Camera:new(args)
    self = setmetatable(args or {}, self)
    self.x = self.x or love.graphics.getWidth()/2
    self.y = self.y or love.graphics.getHeight()/2
    self.rot = self.rot or 0
    self.scale = self.scale or 1
    self.smoother = self.smoother or self.smooth.none() -- for locking, see below

    return self
end

function Camera:move(dx, dy)
    self.x, self.y = self.x + dx, self.y + dy
end

function Camera:zoom(mul)
    self.scale = self.scale * mul
end

function Camera:attach(x,y,w,h, noclip)
    x, y = x or 0, y or 0
    w, h = w or love.graphics.getWidth(), h or love.graphics.getHeight()

    self._sx,self._sy,self._sw,self._sh = love.graphics.getScissor()
    if not noclip then
        love.graphics.setScissor(x, y, w, h)
    end

    local cx, cy = x + w/2, y + h/2

    love.graphics.push()
    love.graphics.translate(cx, cy)
    love.graphics.scale(self.scale)
    love.graphics.rotate(self.rot)
    love.graphics.translate(-self.x, -self.y)
end

function Camera:detach()
    love.graphics.pop()
    love.graphics.setScissor(self._sx,self._sy,self._sw,self._sh)
end

local cos, sin = math.cos, math.sin

-- world coordinates to Camera coordinates
function Camera:tocamera(x,y, ox,oy,w,h)
    ox, oy = ox or 0, oy or 0
    w, h = w or love.graphics.getWidth(), h or love.graphics.getHeight()

    -- x,y = ((x,y) - (self.x, self.y)):rotated(self.rot) * self.scale + center
    local c, s = cos(self.rot), sin(self.rot)

    x, y = x - self.x, y - self.y
    x, y = c*x - s*y, s*x + c*y
    return x*self.scale + w/2 + ox, y*self.scale + h/2 + oy
end

-- Camera coordinates to world coordinates
function Camera:toworld(x,y, ox,oy,w,h)
    ox, oy = ox or 0, oy or 0
    w, h = w or love.graphics.getWidth(), h or love.graphics.getHeight()

    -- x,y = (((x,y) - center) / self.scale):rotated(-self.rot) + (self.x,self.y)
    local c,s = cos(-self.rot), sin(-self.rot)

    x,y = (x - w/2 - ox) / self.scale, (y - h/2 - oy) / self.scale
    x,y = c*x - s*y, s*x + c*y
    return x+self.x, y+self.y
end

function Camera:mousepos(ox,oy,w,h)
    local mx, my = love.mouse.getPosition()

    return self:toworld(mx,my, ox,oy,w,h)
end

-- Camera scrolling utilities
function Camera:lockx(x, smoother, ...)
    local dx, dy = (smoother or self.smoother)(x - self.x, self.y, ...)

    self.x = self.x + dx
end

function Camera:locky(y, smoother, ...)
    local dx, dy = (smoother or self.smoother)(self.x, y - self.y, ...)

    self.y = self.y + dy
end

function Camera:lockpos(x,y, smoother, ...)
    return self:move((smoother or self.smoother)(x - self.x, y - self.y, ...))
end

function Camera:lockwindow(x, y, xmin, xmax, ymin, ymax, smoother, ...)
    -- Figure out displacement in Camera coordinates
    x, y = self:tocamera(x,y)

    local dx, dy = 0,0

    if x < xmin then
        dx = x - xmin
    elseif x > xmax then
        dx = x - xmax
    end
    if y < ymin then
        dy = y - ymin
    elseif y > ymax then
        dy = y - ymax
    end

    -- Transform displacement to movement in world coordinates
    local c, s = cos(-self.rot), sin(-self.rot)

    dx, dy = (c*dx - s*dy) / self.scale, (s*dx + c*dy) / self.scale

    -- Move
    self:move((smoother or self.smoother)(dx,dy,...))
end

return Camera
