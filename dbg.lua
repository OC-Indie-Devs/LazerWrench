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

local dbg = {}

function dbg.out( ... )
    print( string.format( ... ) )
end

return dbg

