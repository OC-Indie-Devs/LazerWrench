----------------------------------------------------------
-- Summary: Module to handle multiple game networks.
-- 
-- Description: Handles all Game Center, GameCircle and Google Play networks.
-- Requires gamenet_gamecircle, gamenet_gamecenter and gamenet_googleplay modules. 
-- 
-- @author Tony Godfrey (tonygod@sharkappsllc.com)
-- @copyright 2015-2016 shark apps, LLC
-- @license all rights reserved.
----------------------------------------------------------

local tiles = {}

tiles.sheets = {
    square = "sheet_square",
    player = "sheet_player"
}

tiles.wall = "spr_walltile1"
tiles.topWall = "spr_walltile_top"
tiles.cornerWall = "spr_walltile_corner"
tiles.bg = "spr_bg"
tiles.wrench = "LAZER_WRENCH"

tiles.robots = {
    robot1 = {
        top = {
            { image="ROBOT/CORNER", rotation=90 },
            { image="ROBOT/BLOCK" },
            { image="ROBOT/CORNER", rotation=180 }
        },
        bottom = {
            { image="ROBOT/CORNER" },
            { image="ROBOT/CORE" },
            { image="ROBOT/CORNER", rotation=-90 }
        }
    }
}

tiles.robotCore = tiles.robots.robot1.bottom[2]

tiles.player = { image="STAND_000", sheet="player" }

tiles.size = 96

--- loads an image frame from an imageSheet
function tiles.getTile( tileName, options )
    local o = options or {}
    
    local img
    if ( o.sheet ) then
        local sheet = tiles.sheets[o.sheet]
        local si = require( sheet )
        local frameIndex = si:getFrameIndex( tileName )
        local numImgs = #si.sheet.frames
        local fName = "images/" .. sheet .. ".png"
        local imageSheet = graphics.newImageSheet( fName, system.ResourceDirectory, si:getSheet() )
        img = display.newImageRect( imageSheet, frameIndex, tiles.size, tiles.size )
    else
        local fn = "images/" .. tileName .. ".png"
        img = display.newImageRect( fn, system.ResourceDirectory, tiles.size, tiles.size )
    end
    if ( o.x ) then
        img.x = o.x
    end
    if ( o.y ) then
        img.y = o.y
    end
    if ( o.xScale ) then
        img.xScale = o.xScale
    end
    if ( o.rotation ) then
        img.rotation = o.rotation
    end
    return img
end


--- gets the name of the image for the given frame index
function tiles.getTileName( sheet, index )
    local si = require( sheet )
    for k, v in pairs( si.frameIndex ) do
        if ( v == index ) then
            return k
        end
    end
    return nil
end

return tiles

