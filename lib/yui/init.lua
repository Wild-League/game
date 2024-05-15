--- Yui is Yet another User Interface library
--
-- @module yui
-- @copyright 2022, The DoubleFourteen Code Forge
-- @author Lorenzo Cogotti, Andrea Pasquini
--
-- This module exposes every module in Yui,
-- except the local @{yui.core} module and the
-- global @{yui.theme} (still accessible from @{yui.Ui}).
-- Refer to each module documentation.

local BASE = (...)..'.'

return {
    Button = require(BASE..'button'),
    Checkbox = require(BASE..'checkbox'),
    Choice = require(BASE..'choice'),
    Columns = require(BASE..'columns'),
    Input = require(BASE..'input'),
    Label = require(BASE..'label'),
    Layout = require(BASE..'layout'),
    Rows = require(BASE..'rows'),
    Slider = require(BASE..'slider'),
    Spacer = require(BASE..'spacer'),
    Ui = require(BASE..'ui'),
    Widget = require(BASE..'widget'),
}
