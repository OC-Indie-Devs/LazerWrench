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

local images = {}

function images.getTile( imageName, options )
    local o = options or {}
    
    if ( o.sheet ) then
        local sheet = tiles.sheets.square
        local si = require( o.sheet )
        local numImgs = #si.sheet.frames
        local imageSheet = graphics.newImageSheet( o.sheet .. ".png", system.ResourceDirectory, si:getSheet() )
        local img = display.newImageRect( imageSheet, frameIndex, tiles.size, tiles.size )
        img.x = tiles.size / 1.5
        img.y = y

    end
end

return images

