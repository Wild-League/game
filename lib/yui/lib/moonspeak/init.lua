--- LÖVE Localization Library
--
-- Basic localization utilities, providing message translation
-- to multiple languages with fallback to English.
-- When package is first require()d, a default dictionary
-- is loaded from: assets/dict.lua
--
-- A dictionary may also be loaded explicitly via loadDictFile().
--
-- @module moonspeak
-- @copyright 2022 The DoubleFourteen Code Forge
-- @author Lorenzo Cogotti

local serialize = require 'lib.yui.lib.serialize'

local moonspeak = {
    --- (string) current locale language.
    lang = "english",
    --- (table|nil) current raw dictionary contents, as loaded by last loadDictFile().
    dict = nil
}

--- Attempts to set a locale based on the current system settings.
--
-- Fallbacks to 'english'.
function moonspeak.setDefaultLocale()
    moonspeak.lang = "english"  -- by default

    local lang = os.getenv("LANG")

    if lang ~= nil then

        local function startswith(s, p) return s:sub(1, #p) == p end

        if startswith(lang, "ja_") then
            moonspeak.lang = "japanese"
        elseif startswith(lang, "it_") then
            moonspeak.lang = "italian"
        elseif startswith(lang, "fr_") then
            moonspeak.lang = "french"
        end
    end
end

--- Load dictionary from file and set it as the current message source.
--
-- In general there is no need to call this function explicitly, as a
-- default dictionary file is automatically loaded upon require().
--
-- A dictionary file is a file containing a regular Lua table containing
-- key-message pairs.
--
-- @usage
-- -- Dictionary file example:
-- {
--   ["Hello, World!"] = {
--     english = "Hello, World!",  -- this can be omitted, as it's identical to key.
--     italian = "Ciao, Mondo!"
--     -- more translations...
--   },
--   ["Hello, %s!"] = {  -- message with string.format() arguments.
--     -- english = ...,  -- not necessary, key is used as a fallback anyway.
--     italian = "Ciao, %s!"
--   },
--   ["I am %d years old."] = {
--     -- english = ...,  -- ditto.
--     italian = "Ho %d anni."
--   }
-- }
--
-- @param name (string) dictionary file name.
function moonspeak.loadDictFile(name)
    local data = assert(love.filesystem.read(name))
    local dict = assert(serialize.unpack(data, name))

    moonspeak.dict = dict
end

--- Translate message.
--
-- A message is looked up inside dictionary using key 'id'.
-- If such message provides a translation string in the current locale, then
-- that translation is used, otherwise the 'id' itself is used as the default message string.
--
-- The selected string is then format()ted, as if by string.format(),
-- forwarding any argument.
--
-- @param id (string) key to be used for locale message lookup.
-- @param ... optional additional string.format() arguments.
--
-- @return localized and formatted string.
function moonspeak.translate(id, ...)
    local dict = moonspeak.dict
    local lang = moonspeak.lang
    local msg  = dict and dict[id] or nil

    if msg ~= nil and msg[lang] then
        -- Found localized string.
        return msg[lang]:format(...)
    end

    return id:format(...)  -- fallback to default
end

-- Load default dictionary
if love.filesystem.getInfo("assets/dict.lua") then
    moonspeak.loadDictFile("assets/dict.lua")
end

return moonspeak
