--- Common functions for strings.
--
-- @module gear.strings
-- @copyright 2022 The DoubleFourteen Code Forge
-- @author Lorenzo Cogotti

local strings = {}

-- Platform preferred path separator
local SEP = package.config:sub(1,1)
local DOT = string.byte('.')
local SLASH = string.byte('/')
local BACKSLASH = string.byte('\\')
local COLON = string.byte(':')

--- Find file extension within path.
--
-- @string path a file path
-- @string[opt] sep path separator pattern, any combination of '/', '\\' or ':' to support various OSes, defaults to all
-- @treturn number extension position within path if an extension is found, nil otherwise
function strings.findpathext(path, sep)
    sep = sep or '/\\:'
    for i = 1,#sep do
        local byt = sep:byte(i)
        if byt ~= SLASH and byt ~= BACKSLASH and byt ~= COLON then
            error(("Unsupported path separator pattern: %q"):format(sep))
        end
    end

    local function issep(byt)
        for i = 1,#sep do
                if byt == sep:byte(i) then return true end
        end
    end

    local pos = nil

    for i = #path,2,-1 do
        local byt = path:byte(i)

        if byt == DOT and not issep(path:byte(i-1)) then
            -- Update extension position
            pos = i
        elseif issep(byt) then
            break
        end
    end

    return pos
end

--- Set default file extension.
--
-- If path contains an extension, returns the path unaltered,
-- otherwise set extension to the specified one.
--
-- @string path a file path
-- @string ext default extension to be set
-- @string[opt] sep path separator pattern, any combination of '/', '\\' or ':' to support various OSes, defaults to all
-- @treturn string updated path, and separator position
function strings.setdefpathext(path, ext, sep)
    if ext:byte(1) ~= DOT then
        error(("Bad extension %q: must be a string starting with '.'"):format(ext))
    end

    local pos = strings.findpathext(path, sep)
    if not pos then
        -- Append default extension
        pos = #path
        path = path..ext
    end

    return path, pos
end

--- Set file extension.
--
-- @string path a file path
-- @string ext extension to be set (including '.')
-- @string[opt] sep path separator pattern, any combination of '/', '\\' or ':' to support various OSes, defaults to all
-- @treturn string updated path and separator position
function strings.setpathext(path, ext, sep)
    if ext:byte(1) ~= DOT then
        error(("Bad extension %q: must be a string starting with '.'"):format(ext))
    end

    local pos = strings.findpathext(path, sep)
    if pos then
        -- Trim existing extension
        path = path:sub(1, pos-1)
    end

    return path..ext, pos
end

--- Get file extension.
--
-- @string path a file path
-- @string[opt] sep path separator pattern, any combination of '/', '\\' or ':' to support various OSes, defaults to all
-- @treturn string file extension and position, if any is found, nil otherwise
function strings.getpathext(path, sep)
    local pos = strings.findpathext(path, sep)
    if pos then return path:sub(pos), pos end
end

--- Remove redundant slashes and resolve dot and dot-dots in path.
--
-- @string path a file path
-- @string[opt] sep separator pattern, '/' for Unix, '\\' for Windows (default)
-- @string[optchain] osep target separator pattern, '/' for Unix, '\\' for Windows, uses the platform preferred path separator by default.
-- @treturn string cleared path
function strings.clearpath(path, sep, osep)
    sep = sep or '\\' -- conservative, both / and \ as seps
    osep = osep or SEP

    local dot, dotdot, sepsub, esub
    if sep == '\\' then
        -- Windows style separator pattern
        dot, dotdot = '[\\/]+%.?[\\/]', '[^\\/]+[\\/]%.%.[\\/]?'
        sepsub, esub = '[\\/]', '[\\/]$'
    elseif sep == '/' then
        -- Unix like separators only
        dot, dotdot = '/+%.?/', '[^/]+/%.%./?'
        sepsub, esub = '/', '/$'
    else
        error("Unsupported separator pattern: "..tostring(sep))
    end
    if osep ~= '\\' and osep ~= '/' then
        error("Unsupported target separator pattern: "..tostring(osep))
    end

    local k

    repeat  -- /./ -> /
        path,k = path:gsub(dot, osep, 1)
    until k == 0

    repeat  -- A/../ -> (empty)
        path,k = path:gsub(dotdot, '', 1)
    until k == 0

    -- Make separators consistent
    path = path:gsub(sepsub, osep)
    path = path:gsub(esub, '')  -- never leave trailing separator
    return path == '' and '.' or path
end

--- Split path into components: directory, basename, extension.
--
-- @string path path to be split
-- @treturn string directory name (including separator), '' if none was found in path
-- @treturn string file name without extension, '' if none was found in path
-- @treturn string file extension including '.', '' if none was found in path
function strings.splitpath(path)
    return path:match("(.-)([^\\/]-)(%.?[^%.\\/]*)$")
end

--- Test whether the path is absolute.
--
-- @string path a path to be tested
-- @string[opt] sep separator pattern, '/' for Unix, '\\' for Windows, if none is provided, path is tested  for both
-- @treturn boolean true if path is absolute, false otherwise
function strings.isabspath(path, sep)
    if sep == nil then
        -- Conservative test, both Unix-style and Windows-style
        return strings.isabspath(path, '/') or strings.isabspath(path, '\\')
    elseif sep == '/' then
        -- Unix-style
        return #path >= 1 and path:byte(1) == SLASH
    elseif sep == '\\' then
        -- Windows-style
        return
            (#path >= 1 and path:byte(1) == BACKSLASH) or
            (#path >= 3 and path:byte(2) == COLON and path:byte(3) == BACKSLASH)
    else
        error(("Unsupported separator pattern: %q"):format(sep))
    end
end

--- Test whether a string starts with a prefix.
--
-- This is an optimized version of: return s:sub(1, #prefix) == prefix.
--
-- @string s string to be tested
-- @string prefix prefix to test for
-- @treturn bool true if prefix is found, false otherwise
function strings.startswith(s, prefix)
    for i = 1,#prefix do
        if s:byte(i) ~= prefix:byte(i) then
            return false
        end
    end
    return true
end

--- Test whether a string ends with a trailing suffix.
--
-- This is an optimized version of: return trailing == ""
-- or s:sub(-#trailing) == trailing.
--
-- @string s string to be tested
-- @string trailing suffix to test for
-- @treturn bool true if suffix is found, false otherwise
function strings.endswith(s, trailing)
    local n1,n2 = #s,#trailing

    for i = 0,n2-1 do
        if s:byte(n1-i) ~= trailing:byte(n2-i) then
            return false
        end
    end
    return true
end

return strings
