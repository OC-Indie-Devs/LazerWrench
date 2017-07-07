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

_G.VERSION = "1.0.2"
-- 1.0.2
-- fixed Jason's last name spelling in title credits
-- 1.0.1 
-- added spawn point to editor
-- fixed more editor bugs
-- added effects when robot core is hit by wrench
-- added top and corner borders
-- aadded 2 levels and re-arranged levels


_G.CX = display.contentCenterX
_G.CY = display.contentCenterY
_G.CW = display.contentWidth
_G.CH = display.contentHeight

dbg = require( "dbg" )

_G.audioFormat = "wav"
_G.musicFormat = "wav"
_G.MUSICVOLUME = 0.75
_G.FXVOLUME = 1

local sound = require( "sounds" )
sound.init()


--local ls = require( "loadsave" )
--ls.copyDataFiles()
-- not needed, done in getSavedGrids in game and gridMaker modules

-- go to main game scene
local composer = require( "composer" )
composer.gotoScene( "title", {} )
