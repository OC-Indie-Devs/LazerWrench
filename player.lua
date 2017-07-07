 ----------------------------------------------------------
-- Summary: Player class.
-- 
-- Description: Tables and functions for the player. 
-- 
-- @author Tony Godfrey (tonygod@sharkappsllc.com)
-- @copyright 2015-2016 shark apps, LLC
-- @license all rights reserved.
----------------------------------------------------------

local player = {}

local playerSheet = "images/sheet_player.png"
local playerSheetInfo = require( "sheet_player" )

local jumpForce = -60
local moveForce = 120
local jumpLimit = 1

player._height = 144
player._width = 96

player.seqData = {
    {
        name = "idle",
        start = playerSheetInfo:getFrameIndex( "STAND_000" ),
        count = 1,
        time = 100,
        loopCount = 1,   -- Optional ; default is 0 (loop indefinitely)
        loopDirection = "forward"    -- Optional ; values include "forward" or "bounce"
    },
    {
        name="walking",
        start = playerSheetInfo:getFrameIndex( "RUN_000" ),
        count = 6,
        time = 500,
        loopCount = 0,   -- Optional ; default is 0 (loop indefinitely)
        loopDirection = "forward"    -- Optional ; values include "forward" or "bounce"
    },
    {
        name = "jumping", -- last fram is "in the air"
        start = playerSheetInfo:getFrameIndex( "JUMP_000" ),
        count = 1,
        time = 100,
        loopCount = 1,   -- Optional ; default is 0 (loop indefinitely)
        loopDirection = "forward"    -- Optional ; values include "forward" or "bounce"
    },
    {
        name = "falling",
        start = playerSheetInfo:getFrameIndex( "JUMP_002" ),
        count = 1,
        time = 100,
        loopCount = 1,   -- Optional ; default is 0 (loop indefinitely)
        loopDirection = "forward"    -- Optional ; values include "forward" or "bounce"
    },
    {
        name = "throwing",
        start = playerSheetInfo:getFrameIndex( "THROW_000" ),
        count = 4,
        time = 100,
        loopCount = 1,   -- Optional ; default is 0 (loop indefinitely)
        loopDirection = "forward"    -- Optional ; values include "forward" or "bounce"
    },
    {
        name = "airattack",
        start = playerSheetInfo:getFrameIndex( "JUMP_000" ),
        count = 1,
        time = 100,
        loopCount = 0,   -- Optional ; default is 0 (loop indefinitely)
        loopDirection = "forward"    -- Optional ; values include "forward" or "bounce"
    },
    {
        name = "walljump",
        start = playerSheetInfo:getFrameIndex( "WALL_000" ),
        count = 1,
        time = 100,
        loopCount = 1,   -- Optional ; default is 0 (loop indefinitely)
        loopDirection = "forward"    -- Optional ; values include "forward" or "bounce"
    },
    {
        name = "sliding",
        start = playerSheetInfo:getFrameIndex( "SLIDE_000" ),
        count = 1,
        time = 100,
        loopCount = 1,   -- Optional ; default is 0 (loop indefinitely)
        loopDirection = "forward"    -- Optional ; values include "forward" or "bounce"
    },
}


function player.new()
    local newPlayer = display.newGroup()
    newPlayer.name = "player"
    newPlayer.imageSheet = graphics.newImageSheet( playerSheet, system.ResourceDirectory, playerSheetInfo:getSheet() )
    newPlayer.seq = player.seqData
    newPlayer.sprite = display.newSprite( newPlayer, newPlayer.imageSheet, newPlayer.seq )
    newPlayer.sprite.xScale = 96 / newPlayer.sprite.contentWidth 
    newPlayer.sprite.yScale = 144 / newPlayer.sprite.contentHeight 
    newPlayer.setAnim = function( self, animName )
        if ( self.sprite ) then
            dbg.out( "player.setAnim: animation set to " .. animName )
            self.sprite:setSequence( animName )
            self.sprite:play()
        end
    end
    newPlayer.jump = function( self, direction )
        if ( self.isJumping == nil ) then
            self.isJumping = 0
        end
        if ( self.isJumping < jumpLimit ) then
            self:setAnim( "jumping" )
            local xForce = 0
            if ( direction ) then
                if ( direction == "left" ) then
                    xForce = -moveForce / 10
                    self.xScale = -1 * math.abs( self.xScale )
                else
                    xForce = moveForce / 10
                    self.xScale = math.abs( self.xScale )
                end
            end
            self:applyLinearImpulse( xForce, jumpForce, 0, 0 )
--            self:applyForce( 0, jumpForce, 0, 0 )
            self.isJumping = self.isJumping + 1
            self.isWalking = nil
            self.onGround = nil
            self.onWall = nil
        end
    end
    newPlayer.move = function( self, direction )
        if ( self.onGround == nil ) then
            return
        end
        local force = moveForce
        if ( direction == "left" ) then
            force = -force
        end
        if ( force < 0 ) then
            self.xScale = -1 * math.abs( self.xScale )
        else
            self.xScale = math.abs( self.xScale )
        end
        if ( self.onGround ) then
            if not self.isWalking then
                self:setAnim( "walking" )
            end
        end
        self.isWalking = direction
--        self:applyForce( force, 0, 0, 0 )
        self:applyLinearImpulse( force, 0, 0, 0 )
        local vx, vy = self:getLinearVelocity()
        if ( math.abs( vx ) > moveForce ) then
            self:setLinearVelocity( force, vy )
        end
    end
    newPlayer.collision = function( self, event )
        local other = event.other
        dbg.out( "player.collision: name=" .. other.name .. ", phase=" .. event.phase )
        if ( event.phase == "began" ) then
            if ( other.name == "platform" ) then
                if ( self.fallTimer ) then
                    timer.cancel( self.fallTimer )
                    self.fallTimer = nil
                end
                if not ( self.onGround ) then
                    dbg.out( "player.collision: landed on platform" )
                    self.onGround = true
                    self:setAnim( "idle" )
                end
                if ( self.isJumping ) then
                    self.isJumping = nil
                end
                if ( self.groundRefs == nil ) then
                    self.groundRefs = 0
                end
                self.groundRefs = self.groundRefs + 1
            
            elseif ( other.name == "wall" ) then
                if ( self.fallTimer ) then
                    timer.cancel( self.fallTimer )
                    self.fallTimer = nil
                end
                if ( self.onWall == nil ) then
                    self:setAnim( "walljump" )
                    self.onWall = true
                    self.isJumping = nil
                    self.isWalking = nil
                end
                dbg.out( "player.collision: wall jumping" )
                if ( self.wallRefs == nil ) then
                    self.wallRefs = 0
                end
                self.wallRefs = self.wallRefs + 1
            end
        
        elseif ( event.phase == "ended" ) then
            if ( other.name == "platform" ) then
                self.groundRefs = self.groundRefs - 1
                if ( self.groundRefs == 0 ) then
                    local leftPlatform = function()
                        self.fallTimer = nil
                        dbg.out( "player.collision: left platform" )
                        self.onGround = nil
                        if ( self.isWalking ) then
                            self.isWalking = nil
                        end
                    end
                    self.fallTimer = timer.performWithDelay( 200, leftPlatform )
                end
                
            elseif ( other.name == "wall" ) then
                self.wallRefs = self.wallRefs - 1
                if ( self.wallRefs == 0 ) then
                    dbg.out( "player.collision: left wall" )
                    self.onWall = nil
                end
            end
        end
    end
    newPlayer:addEventListener( "collision" )
        
    return newPlayer
end


return player

