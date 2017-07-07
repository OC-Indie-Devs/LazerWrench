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

local _M = {}

_M.modules = {}

local isSupported = {
    ["Android"] = true,
    ["iPhone OS"] = true,
}
--[[
"Mac OS X" - OS X desktop apps and the Corona Simulator for OS X.
"Win" - Win32 desktop apps and the Corona Simulator for Windows.
"iPhone OS" - all iOS devices and the Xcode iOS Simulator.
"Android" - all Android devices and the Android emulator.
"tvOS" - Apple's tvOS (Apple TV).
"WinPhone" - all Windows Phone devices and the Windows Phone emulator.
]]--


local function loadModules()
    if ( isSupported[_G.PLATFORM] ) then
        dbg.out( "gamenet.loadModules: loading game network modules" )
        if ( _G.STORE == "amazon" ) then
            _M.modules.gamecircle = require( "gamenet_gamecircle" )
        end
        if ( _G.STORE == "apple" ) then
            _M.modules.gamecenter = require( "gamenet_gamecenter" )
        end
        if ( _G.PLATFORM == "Android" ) then
            _M.modules.googleplay = require( "gamenet_googleplay" )
        end
    else
        dbg.out( "gamenet.loadModules: game network modules not supported on this platform" )
    end
end




--- stops processing all game network requests.
function _M.stop()
    for k, v in pairs( _M.modules ) do
        v.loggedIn = false
    end
    _M.playerData = nil
    dbg.out( "gamenet: stopped" )
end


--- Shows the achievements UI.
function _M.showAchievements()
    dbg.out( "gamenet.showAchievements: store=" .. _G.STORE )
    for k, v in pairs( _M.modules ) do
        v.showAchievements()
    end
end


--- Unlocks achievement.
-- @string aID ID for the achievement to unlock 
function _M.unlockAchievement( aID )
    for k, v in pairs( _M.modules ) do
        v.unlockAchievement( aID )
    end
end


--- Shows the Leaderboards UI.
function _M.showLeaderboards()
    for k, v in pairs( _M.modules ) do
        v.showLeaderboards()
    end
end


--- Sets the high score.
-- @number score the high score to set on the leaderboard 
function _M.setHighScore( score )
    for k, v in pairs( _M.modules ) do
        v.setHighScore( score )
    end
end


--- Sets the function to pause the game when bringing up game network UI.
function _M.setPauseCallback( pause_callback )
    for k, v in pairs( _M.modules ) do
        v.pauseGame = pause_callback
    end
end


--- combines achievement tables from all loaded modules.
-- @treturn table table of combined achievements, nil if table is empty 
function _M.getAchievements()
    local t = {}
    local num = 0
    for k, v in pairs( _M.modules ) do
        if ( v.achievements ) then
            for k1, v1 in pairs( v.achievements ) do
                t[k1] = v1
                num = num + 1
            end
        end
    end
    if ( num == 0 ) then
        t = nil
    end
    return t
end


--- Get the logged in status of the game networks.  If netName parameter is nil, all networks are checked and if any modules are logged in, true is returned.
-- @treturn bool true if logged in, nil if invalid netName or networks are not logged in. 
function _M.isLoggedIn( netName )
    if ( netName ) then
        if ( _M.modules[netName] ) then
            return _M.modules[netName].loggedIn
        else
            return nil
        end
    else
        local ret = nil
        for k, v in pairs( _M.modules ) do
            if ( v.loggedIn ) then
                ret = true
            end
        end
        return ret
    end
end


--- initializes the appropriate game network plugin.
function _M.init()
    dbg.out( "gamenet.init: initializing" )
    for k, v in pairs( _M.modules ) do
        v.achievements = _M.achievements
        v.init()
    end
    return true
end

loadModules()

return _M

