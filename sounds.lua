----------------------------------------------------------
-- Summary: Sound module.
-- 
-- @author Tony Godfrey (tonygod@sharkappsllc.com)
-- @copyright 2015-2016 shark apps, LLC
-- @license all rights reserved.
----------------------------------------------------------

local _ = {}

_.fxList = {
    jump1 = "sfx_jump_usethisone",
    nextLevel1 = "sfx_nextlevelteleport",
    robothit1 = "sfx_robohit1",
    robotdeath1 = "sfx_robotdeath1",
    wrench1 = "sfx_wrench",
}


_.songList = {

    "LD35Jam3",
}


function _.play( soundName )
    local ret = nil
    
    if ( _.fxList[soundName] ) then
        if ( _G.PLATFORM == "Android" ) then
            ret = media.playEventSound( _.fxEvent[soundName] )
        else
            ret = audio.play( _.effect[soundName] )
        end
    end
    return ret
end


function _.init()
    dbg.out( "sound: init")
    _.songs = {}
    local s = _.songList
    for i = 1, #s do
        local sng = s[i] .. "." .. _G.musicFormat
        dbg.out( "sound: loadStream " .. sng )
        _.songs[i] = audio.loadStream( "audio/" .. sng, system.ResourceDirectory )
    end
    
    _.effect = {}
    _.fxEvent = {}
    _.fxSound = {}
    for k, v in pairs( _.fxList ) do
        local aud = v .. "." .. _G.audioFormat
        dbg.out( "sound: newEventSound: " .. aud )
        if ( _G.PLATFORM == "Android" ) then
            _.fxEvent[k] = media.newEventSound( "audio/" .. aud, system.ResourceDirectory )
        end
        _.effect[k] = audio.loadSound( "audio/" .. aud, system.ResourceDirectory )
    end
end


return _