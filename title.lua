----------------------------------------------------------
-- Summary: The main game composer scene.
-- 
-- Description: Handles all of the game mechanics, displaying
-- of appropriate menu buttons.  Calls mainMenu and optionsMenu
-- scenes when requested. 
-- 
-- @author Tony Godfrey (tonygod@sharkappsllc.com)
-- @copyright 2015-2016 shark apps, LLC
-- @license all rights reserved.
----------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local params

local ui = require( "ui" )

local btns = {}

local function play()
    composer.gotoScene( "game", { params = params } )
end

local function edit()
    composer.gotoScene( "gridMaker", { params = params} )
end


-- Called when the scene's view does not exist:
function scene:create( event )
    local sceneGroup = self.view
    params = event.params
    scene.name = composer.getSceneName( "current" )
    
    local bg = display.newImageRect( sceneGroup, "images/TITLE_SCREEN.png", system.ResourceDirectory, display.contentWidth, display.contentHeight )
    bg.x = _G.CX
    bg.y = _G.CY
    
    local btnOpts = {
        parent = sceneGroup,
        text = "PLAY",
        x = _G.CX - 200,
        y = _G.CY,
        action = play
    }
    btns.play = ui.newButton( btnOpts )
    
    btnOpts.x = _G.CX + 200
    btnOpts.text = "EDIT"
    btnOpts.action = edit
    btns.edit = ui.newButton( btnOpts )
    
    local txtOpts = {
        parent = sceneGroup,
        text = "Build " .. _G.VERSION .. " (post-jam) for Ludum Dare 35 \"Shapeshift\" by OC Indie Developers",
        x = _G.CX,
        y = _G.CH - 100,
        fontSize = 36
    }
    local credits = {}
    credits.main = display.newText( txtOpts )
    
    txtOpts.text = "Jason Schuck - Sound & Visuals"
    txtOpts.x = 300
    txtOpts.y = _G.CH - 50
    txtOpts.align = "left"
    credits.sound = display.newText( txtOpts )
    
    txtOpts.text = "Kurt Deniz - Art"
    txtOpts.x = _G.CX
    txtOpts.align = "center"
    credits.sound = display.newText( txtOpts )
    
    txtOpts.text = "Tony Godfrey - Development"
    txtOpts.x = _G.CW - 300
    txtOpts.align = "right"
    credits.sound = display.newText( txtOpts )
end


function scene:show( event )
    local phase = event.phase
    params = event.params or {}
    dbg.out( scene.name .. ":show " .. phase )
    
    if ( "will" == phase ) then
    end

    if "did" == phase then
    end

end

function scene:hide( event )
    local phase = event.phase
    dbg.out( scene.name .. ":hide " .. phase )

    if "will" == phase then
    end
end

function scene:destroy( event )
    dbg.out( scene.name .. ":destroy" )
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene

