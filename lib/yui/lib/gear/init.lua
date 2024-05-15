--- LÖVE Utility Gear
--
-- General purpose functions and utilities.
-- Provides various basic functionality, including: general utility
-- algorithms, linear algebra and simple bounds checking functions.
-- Code is reasonably optimized for speed.
--
-- @module gear
-- @copyright 2022 The DoubleFourteen Code Forge
-- @author Lorenzo Cogotti

local BASE = (...)..'.'


return {
    algo = require(BASE..'algo'),
    mathx = require(BASE..'mathx'),
    meta = require(BASE..'meta'),
    rect = require(BASE..'rect'),
    shadowtext = require(BASE..'shadowtext'),
    strings = require(BASE..'strings'),
    vec = require(BASE..'vec'),

    Signal = require(BASE..'signal'),
    Timer = require(BASE..'timer')
}
