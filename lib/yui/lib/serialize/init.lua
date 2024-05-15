--- Brainless serialization library.
--
-- Takes Lua tables and turns them into their string
-- representation. Also takes a Lua table string representation
-- and turns it back into its corresponding table.
-- That is all.
--
-- @module serialize
-- @copyright 2022 The DoubleFourteen Code Forge
-- @author Lorenzo Cogotti

local math = require 'math'

local serialize = {}


local dopack  -- forward declare for mutual recursion

local function isfinite(x)
    return x ~= math.huge and x ~= -math.huge and x == x
end

local function keys(k, i, mode)
    local t = type(k)

    if t == 'boolean' then
        return k and "[true]" or "[false]"
    elseif t == 'string' then
        local f = ("%q"):format(k)
        if k:find(" ") or f ~= '"'..k..'"' then
            return "["..f.."]"
        else
            return k
        end
    elseif t == 'number' then
        if not isfinite(k) then
            error("Can't serialize.pack() table with non-finite key `"..k.."'.")
        end

        return "["..k.."]"
    elseif t == 'table' then
        return "["..dopack(k, i+1, mode).."]"
    else
        error("Can't serialize.pack() table with key `"..tostring(k).."'.")
    end
end

local function vals(v, i, mode)
    local t = type(v)

    if t == 'boolean' then
        return v and 'true' or 'false'
    elseif t == 'string' then
        return ("%q"):format(v)
    elseif t == 'number' then
        if not isfinite(v) then
            error("Can't serialize.pack() table with non-finite value `"..v.."'.")
        end

        return tostring(v)
    elseif t == 'table' then
        return dopack(v, i+1, mode)
    else
        error("Can't serialize.pack() table with value `"..tostring(v).."'.")
    end
end

-- local
function dopack(o, i, mode)
    local fields = {}
    local seen = {}
    local is = ("    "):rep(i)
    local lastis = ("    "):rep(i-1)

    -- Attempt to encode as array.
    for k,v in ipairs(o) do
        if mode == 'skip-functions' and type(v) == 'function' then
            goto skip
        end

        fields[#fields + 1] = ("%s%s"):format(is, vals(v, i, mode))

    ::skip:: seen[k] = true
    end

    -- Process leftover fields.
    for k,v in pairs(o) do
        if seen[k] or (mode == 'skip-functions' and type(v) == 'function') then
            goto skip
        end

        local f = ("%s%s = %s"):format(is, keys(k, i, mode), vals(v, i, mode))

        fields[#fields + 1] = f

    ::skip::
    end

    return "{\n"..table.concat(fields, ",\n").."\n"..lastis.."}"
end

--- Construct string recreating a Lua table.
--
-- @param o (table) a Lua table.
-- @param indent (number|nil) optional initial indent.
-- @param mode (string|nil) one of two modes: 'strict' (default), where
--             attempt to serialize a function is an error, or
--             'skip-functions', where functions are ignored.
--
-- @return string recreating the table, use serialize.unpack() to do so.
function serialize.pack(o, indent, mode)
    if type(o) ~= 'table' then
        error("Can't serialize.pack() a `"..type(o).."'.")
    end

    return dopack(o, indent or 1, mode)
end

--- Reconstruct Lua table from string.
--
-- @param s (string) Lua table in its string form.
-- @param chunk (string|nil) optional string providing a chunk's name
--              for better diagnostics, if left nil a default value
--              of "<serialize.unpack>" is used.
--
-- @return the reconstructed table and an error string, on success
--         the error value is nil, on failure the table is nil.
function serialize.unpack(s, chunk)
    if type(s) ~= 'string' then
        error("Can only serialize.unpack() strings.")
    end

    chunk = chunk or "<serialize.unpack>"

    local fun, res = load("return "..s, chunk, 't', {})
    if not fun then
        return nil, res
    end

    local ok, o = pcall(fun)
    if not ok then
        return nil, o  -- o is now pcall()'s error message
    end
    if type(o) ~= 'table' then
        return nil, "[string \""..chunk.."\"] resulted in a `"..type(o).."'."
    end

    return o
end

return serialize
