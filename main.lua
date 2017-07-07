----------------------------------------------------------
-- Summary: LD35 Shapeshift Game.
-- 
-- Description: A Robot Repair Technician must jump his
-- way through a shapeshifting Robot Repair Facility and
-- repair all of the malfunctioning robots.
-- 
-- @author Tony Godfrey (tonygod@sharkappsllc.com)
-- @author Jason Schuck (jasonschuck@gmail.com)
-- @author Kurt Deniz (deniz.kurt.b@gmail.com)
-- @copyright 2015-2016 shark apps, LLC
-- @license all rights reserved.
----------------------------------------------------------

io.output():setvbuf("no")
display.setStatusBar(display.HiddenStatusBar)

---- Load and Initialize SSK
--require "ssk.loadSSK"
--
--
---- Load and Start RG Super Meter
--local rgmeter = require "rgmeter.rgmeter"
--rgmeter.setMaxMainMem( 16 * 1024 ) -- 16K KB == 16 MB
--rgmeter.setMaxVidMem( 16 * 1024 ) -- 16K KB == 16 MB
--rgmeter.setAverageWindow(30)
--rgmeter.setUpdatePeriod(5)
--rgmeter.enableCollection( true )
----rgmeter.setFontScale(0.8)
--rgmeter.create( display.contentCenterX, display.contentCenterY, display.actualContentWidth, false, true )

_G.CX = display.contentCenterX
_G.CY = display.contentCenterY
_G.CW = display.contentWidth
_G.CH = display.contentHeight

dbg = require( "dbg" )

local ls = require( "loadsave" )
ls.copyDataFiles()

-- go to main game scene
local composer = require( "composer" )
composer.gotoScene( "game", {} )
