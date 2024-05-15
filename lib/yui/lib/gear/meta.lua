--- Tables and metatables general utility algorithms.
--
-- @module gear.meta
-- @copyright 2022 The DoubleFourteen Code Forge
-- @author Lorenzo Cogotti

local meta = {}


--- Test whether 'obj' is an instance of the given class 'cls'.
--
-- Note that nil is the only instance of the nil class.
--
-- @tparam table obj object instance to be tested
-- @tparam table cls class argument
-- @treturn bool
function meta.isinstance(obj, cls)
    if rawequal(cls, nil) then return rawequal(obj, nil) end

    repeat
        local m = getmetatable(obj)
        if rawequal(m, cls) then return true end

        obj = m
    until rawequal(obj, nil)

    return false
end

--- Merge table 'from' into table 'to'.
--
-- For every field in 'from', copy it to destination
-- table 'to', whenever the same field is nil in that table.
--
-- The same process is applied recursively to sub-tables.
--
-- @tparam table to table to merge into
-- @tparam table from table to merge from
-- @treturn table destination table (a reference to 'to')
function meta.mergetable(to, from)
    for k,v in pairs(from) do
        if to[k] == nil then
            to[k] = type(v) == 'table' and meta.mergetable({}, v) or v
        end
    end

    return to
end

--- Table deep copy.
--
-- Copy table 'obj', cloning any sub-table.
-- Handles cyclic references.
--
-- @tparam table obj object to be copied
-- @tparam[opt={}] table copied known copied sub-object table
-- @treturn table newly created clone of 'obj'
function meta.deepcopy(obj, copied)
    copied = copied or {}

    local r = {}

    copied[obj] = r

    for k,v in pairs(obj) do
        if type(v) == 'table' then
            local t = copied[v] or meta.deepcopy(v, copied)

            copied[v] = t  -- NOP if object was already copied
            v = t
        end

        r[k] = v
    end

    return r
end

return meta
