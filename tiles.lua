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
    square = "sheet_square"
}

tiles.wall = "spr_walltile1"
tiles.bg = "spr_bg"

tiles.size = 96

--- loads an image frame from an imageSheet
function tiles.getTile( tileName, options )
    local o = options or {}
    
    if ( o.sheet ) then
        local sheet = tiles.sheets[o.sheet]
        local si = require( sheet )
        local frameIndex = si:getFrameIndex( tileName )
        local numImgs = #si.sheet.frames
        local fName = "images/" .. sheet .. ".png"
        local imageSheet = graphics.newImageSheet( fName, system.ResourceDirectory, si:getSheet() )
        local img = display.newImageRect( imageSheet, frameIndex, tiles.size, tiles.size )
        if ( o.x ) then
            img.x = o.x
        end
        if ( o.y ) then
            img.y = o.y
        end
        return img
    else
        local fn = "images/" .. tileName .. ".png"
        local img = display.newImageRect( fn, system.ResourceDirectory, tiles.size, tiles.size )
        if ( o.x ) then
            img.x = o.x
        end
        if ( o.y ) then
            img.y = o.y
        end
        return img
    end
    return nil
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

