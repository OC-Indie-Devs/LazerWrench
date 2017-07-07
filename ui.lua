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

local ui = {}


function ui.onButtonTouch( self, event )
    dbg.out( "ui.onButtonTouch: phase=" .. event.phase )
    if ( event.phase == "began" ) then
        display.getCurrentStage():setFocus( self )
        self.isFocus = true
    
    elseif ( self.isFocus ) then
        
        if ( event.phase == "moved" ) then
            
        elseif ( event.phase == "ended" ) or ( event.phase == "cancelled" ) then
            if ( self.action ) then
                dbg.out( "ui.onButtonTouch: calling button action" )
                self.action()
            end
            display.getCurrentStage():setFocus( nil )
            self.isFocus = nil
        end
    end
    return true
end


function ui.newButton( options )
    local o = options or {}
    o.x = o.x or _G.CX
    o.y = o.y or _G.CY
    o.width = o.width or 200
    o.height = o.height or 200
    o.fill = o.fill or { 0.7, 0.7, 0.7, 1 }
    
    local button = display.newGroup()
    if ( o.parent ) then
        o.parent:insert( button )
    end
    button.x = o.x
    button.y = o.y
    button.box = display.newRect( button, 0, 0, o.width, o.height )
    button.box.fill = o.fill
    button.box.strokeWidth = o.height / 10
    
    if ( o.text ) then
        local textOpts = {
            parent = button,
            text = o.text,
            x = 0,
            y = 0,
            width = o.width * 0.9,
            font = o.font or native.systemFont,
            fontSize = o.fontSize or 36,
            align = o.textAlign or "center"
        }
        button.text = display.newText( textOpts )
        o.textColor = o.textColor or { 0, 0, 0, 1 }
        button.text:setFillColor( unpack( o.textColor ) )
    end
    
    button.touch = o.touch or ui.onButtonTouch
    button:addEventListener( "touch" )
    
    if ( o.action ) then
        button.action = o.action
    end
    
    button.finalize = function( self, event )
        if ( button.touch ) then
            button:removeEventListener( "touch" )
        end
    end
    return button
end


return ui

