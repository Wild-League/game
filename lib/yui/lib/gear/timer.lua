--- Timer utilities.
--
-- This is a reworked implementation of the original timer module
-- from the hump library (https://github.com/vrld/hump).
-- See README.ACKNOWLEDGEMENT for detailed information.
--
-- It offers functionality to schedule tasks for delayed or periodic
-- execution, as well as tweening.
--
-- @module gear.timer
-- @copyright 2010-2013 Matthias Richter
-- @copyright 2022 The DoubleFourteen Code Forge
-- @author Matthias Richter, Lorenzo Cogotti

local Timer = {}
Timer.__index = Timer

local function _nothing_() end

local function updateTimerHandle(handle, dt)
    -- handle: {
    --   time = <number>,
    --   after = <function>,
    --   during = <function>,
    --   limit = <number>,
    --   count = <number>,
    -- }
    handle.time = handle.time + dt
    handle.during(dt, math.max(handle.limit - handle.time, 0))

    while handle.time >= handle.limit and handle.count > 0 do
        if handle.after(handle.after) == false then
            handle.count = 0
            break
        end
        handle.time = handle.time - handle.limit
        handle.count = handle.count - 1
    end
end

function Timer:update(dt)
    -- timers may create new timers, which leads to undefined behavior
    -- in pairs() - so we need to put them in a different table first
    local to_update = {}
    for handle in pairs(self.functions) do
        to_update[handle] = handle
    end

    for handle in pairs(to_update) do
        if self.functions[handle] then
            updateTimerHandle(handle, dt)
            if handle.count == 0 then
                self.functions[handle] = nil
            end
        end
    end
end

function Timer:during(delay, during, after)
    local handle = {
        time = 0,
        during = during,
        after = after or _nothing_,
        limit = delay,
        count = 1
    }

    self.functions[handle] = true
    return handle
end

function Timer:after(delay, func)
    return self:during(delay, _nothing_, func)
end

function Timer:every(delay, after, count)
    count = count or math.huge -- exploit below: math.huge - 1 = math.huge
    local handle = {
        time = 0,
        during = _nothing_,
        after = after,
        limit = delay,
        count = count
    }

    self.functions[handle] = true
    return handle
end

function Timer:cancel(handle)
    if handle then
        self.functions[handle] = nil
    end
end

function Timer:clear()
    self.functions = {}
end

function Timer:script(f)
    local co = coroutine.wrap(f)
    co(function(t)
        self:after(t, co)
        coroutine.yield()
    end)
end

Timer.tween = setmetatable({
    -- helper functions
    out = function(f) -- 'rotates' a function
        return function(s, ...) return 1 - f(1-s, ...) end
    end,
    chain = function(f1, f2) -- concatenates two functions
        return function(s, ...) return (s < .5 and f1(2*s, ...) or 1 + f2(2*s-1, ...)) * .5 end
    end,

    -- useful tweening functions
    linear = function(s) return s end,
    quad   = function(s) return s*s end,
    cubic  = function(s) return s*s*s end,
    quart  = function(s) return s*s*s*s end,
    quint  = function(s) return s*s*s*s*s end,
    sine   = function(s) return 1-math.cos(s*math.pi/2) end,
    expo   = function(s) return 2^(10*(s-1)) end,
    circ   = function(s) return 1 - math.sqrt(1-s*s) end,

    back = function(s,bounciness)
        bounciness = bounciness or 1.70158
        return s*s*((bounciness+1)*s - bounciness)
    end,

    bounce = function(s) -- magic numbers ahead
        local a,b = 7.5625, 1/2.75
        return math.min(a*s^2, a*(s-1.5*b)^2 + .75, a*(s-2.25*b)^2 + .9375, a*(s-2.625*b)^2 + .984375)
    end,

    elastic = function(s, amp, period)
        amp, period = amp and math.max(1, amp) or 1, period or .3
        return (-amp * math.sin(2*math.pi/period * (s-1) - math.asin(1/amp))) * 2^(10*(s-1))
    end,
}, {

-- register new tween
__call = function(tween, self, len, subject, target, method, after, ...)
    -- recursively collects fields that are defined in both subject and target into a flat list
    local function tween_collect_payload(subject, target, out)
        for k,v in pairs(target) do
            local ref = subject[k]
            assert(type(v) == type(ref), 'Type mismatch in field "'..k..'".')
            if type(v) == 'table' then
                tween_collect_payload(ref, v, out)
            else
                local ok, delta = pcall(function() return (v-ref)*1 end)
                assert(ok, 'Field "'..k..'" does not support arithmetic operations')
                out[#out+1] = {subject, k, delta}
            end
        end
        return out
    end

    method = tween[method or 'linear'] -- see __index
    local payload, t, args = tween_collect_payload(subject, target, {}), 0, {...}

    local last_s = 0
    return self:during(len, function(dt)
        t = t + dt
        local s = method(math.min(1, t/len), unpack(args))
        local ds = s - last_s
        last_s = s
        for _, info in ipairs(payload) do
            local ref, key, delta = unpack(info)
            ref[key] = ref[key] + delta * ds
        end
    end, after)
end,

-- fetches function and generated compositions for method `key`
__index = function(tweens, key)
    if type(key) == 'function' then return key end

    assert(type(key) == 'string', 'Method must be function or string.')
    if rawget(tweens, key) then return rawget(tweens, key) end

    local function construct(pattern, f)
        local method = rawget(tweens, key:match(pattern))
        if method then return f(method) end
        return nil
    end

    local out, chain = rawget(tweens,'out'), rawget(tweens,'chain')
    return construct('^in%-([^-]+)$', function(...) return ... end)
           or construct('^out%-([^-]+)$', out)
           or construct('^in%-out%-([^-]+)$', function(f) return chain(f, out(f)) end)
           or construct('^out%-in%-([^-]+)$', function(f) return chain(out(f), f) end)
           or error('Unknown interpolation method: ' .. key)
end})

-- Timer instancing
function Timer:new(args)
    self = setmetatable(args or {}, self)
    self.functions = {}

    return self
end

return Timer
