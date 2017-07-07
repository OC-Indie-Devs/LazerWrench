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
local params = nil

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 9.8 )
physics.setAverageCollisionPositions( true )
physics.setTimeStep( 1/30 )

local ui = require( "ui" )
local tiles = require( "tiles" )
local ls = require( "loadsave" )
local sound = require( "sounds" )
local fx = require( "effects" )

local platformFriction = 0.5
local playerFriction = 0.3
local wallFriction = 0.8
local wrenchForce = -10
local gridMinY = -_G.CH * 2

local playerStart = {
    x = 1500,
    y = -gridMinY + _G.CH - 300,
}

local btns = {}
local grp = {}
local player = nil
local gridID = 1
local gridSaveFile = "gridsave"
local gridText
local outlines = {}
local lastThrow = 0
local levelRobot

local keyDown = {} -- keys that are pressed and held


local function createWalls()
    for i = 1, 34 do
        local lWall = tiles.getTile( tiles.wall )
        grp.terrain:insert( lWall )
        lWall.x = tiles.size / 2
        lWall.y = (i-1) * tiles.size + tiles.size / 2
        lWall.name = "wall"
        physics.addBody( lWall, "static", { friction=platformFriction } )
        local rWall = tiles.getTile( tiles.wall )
        grp.terrain:insert( rWall )
        rWall.x = _G.CW - tiles.size / 2
        rWall.y = (i-1) * tiles.size + tiles.size / 2
        rWall.name = "wall"
        physics.addBody( rWall, "static", { friction=platformFriction, bounce=0 } )
    end
    for i = 1, 18 do
        local tWall = tiles.getTile( tiles.topWall )
        grp.terrain:insert( tWall )
        tWall.x = i * tiles.size + tiles.size / 2
        tWall.y = -tiles.size / 2
        tWall.name = "wall"
        physics.addBody( tWall, "static", { friction=platformFriction, bounce=0 } )
    end
    local lCorner = tiles.getTile( tiles.cornerWall )
    grp.terrain:insert( lCorner )
    lCorner.x = tiles.size / 2
    lCorner.y = -tiles.size / 2
    lCorner.name = "wall"
    physics.addBody( lCorner, "static", { friction=platformFriction, bounce=0 } )
    local rCorner = tiles.getTile( tiles.cornerWall )
    grp.terrain:insert( rCorner )
    rCorner.x = _G.CW - tiles.size / 2
    rCorner.y = -tiles.size / 2
    rCorner.rotation = 90
    rCorner.name = "wall"
    physics.addBody( lCorner, "static", { friction=platformFriction, bounce=0 } )
    
end


-- removes everything from grp.grid except the semi-transparent blocks
local function clearTerrain()
    local numBlocks = grp.terrain.numChildren
    for i = numBlocks, 1, -1 do
        grp.terrain[i]:removeSelf()
    end
    dbg.out( "clearTerrain: cleared" )
    createWalls()
end


local function getOutline( options )
    local o = options or {}
    
    if ( outlines[o.image] == nil ) then
        local fn = "images/" .. o.image .. ".png"
        outlines[o.image] = graphics.newOutline( 2, fn, system.ResourceDirectory )
    end
    return outlines[o.image]
end



local function makePhysical( obj )
    if ( obj.image == "spr_shapes_no3d_03" ) then
        physics.addBody( obj, "static", { friction=platformFriction, radius=144 } )
    else
        local image_outline = getOutline( { image=obj.image } )
        physics.addBody( obj, "static", { friction=platformFriction, outline=image_outline } )
    end
end


local function addShape( shape, blockID )
    local tileImg
    
--    local g = grp.grid[blockID]
    local g = grp.terrain
    
    local lx, ly = grp.grid[blockID]:localToContent( 0, 0 )
    dbg.out( "addShape: add " .. shape .. " to grid " .. blockID .. " x=" .. lx .. " y=" .. ly )
    if ( shape == "circle" ) then
        tileImg = display.newCircle( g, lx, ly, tiles.size * 1.5 )
        physics.addBody( tileImg, "static", { friction = platformFriction, radius = tiles.size * 1.5 } )
    
    elseif ( shape == "square" ) then
        tileImg = display.newRect( g, lx, ly, tiles.size * 3, tiles.size * 3 )
        physics.addBody( tileImg, "static", { friction = platformFriction } )
    
    elseif ( shape == "triangle" ) then
        local vertices = { 
            0, -tiles.size * 1.5,
            tiles.size * 1.5, tiles.size * 1.5,
            -tiles.size * 1.5, tiles.size * 1.5
        }
        tileImg = display.newPolygon( g, lx, ly, vertices )
        physics.addBody( tileImg, "static", { friction = platformFriction, shape=vertices } )
    end
    
    tileImg.name = "platform"
    tileImg.blockID = blockID
    tileImg.shape = shape
    
    return tileImg
end


local function spawnRobot( rob, blockID, lx, ly )
    lr = {}
    lr.parts = {}
    local g = grp.terrain
    local rx = lx - 288
    local ry = ly - 288
    for i = 1, #rob.top do
        local fn = "images/" .. rob.top[i].image .. ".png"
        local robImg = display.newImageRect( g, fn, system.ResourceDirectory, 288, 288 )
        if ( rob.top[i].rotation ) then
            robImg.rotation = rob.top[i].rotation
        end
        robImg.x = rx
        robImg.y = ry
        rx = rx + 288
        robImg.image = rob.top[i].image
        robImg.name = "robot"
        robImg.blockID = blockID
        makePhysical( robImg )
        table.insert( lr.parts, robImg )
    end
    rx = lx - 288
    ry = ly
    for i = 1, #rob.bottom do
        local fn = "images/" .. rob.bottom[i].image .. ".png"
        local robImg = display.newImageRect( g, fn, system.ResourceDirectory, 288, 288 )
        if ( rob.bottom[i].rotation ) then
            robImg.rotation = rob.bottom[i].rotation
        end
        robImg.x = rx
        robImg.y = ry
        rx = rx + 288
        robImg.image = rob.bottom[i].image
        robImg.name = "robot"
        robImg.blockID = blockID
        makePhysical( robImg )
        table.insert( lr.parts, robImg )
        if ( rob.bottom[i].image == "ROBOT/CORE" ) then
            lr.core = robImg
            robImg.hit = 0
            robImg.collision = function( self, event )
                if ( self.fixed ) then
                    return true
                end
                if ( event.phase == "began" ) then
                    if ( event.other.name == "wrench" ) then
                        if not ( event.other.hit ) then
                            event.other.hit = true
                            -- play hit sound
                            sound.play( "robothit1" )
                            self.hit = self.hit + 1
                            dbg.out( "robot hits = " .. self.hit )
                            if ( self.hit == 20 ) then
                                self.fixed = true
                                dbg.out( "robot fixed!" )
                                sound.play( "robotdeath1" )
                            end
                        end
                        self.fill.effect = "filter.exposure"
                        self.fill.effect.exposure = 1.25
                        timer.performWithDelay( 200, 
                            function()
                                self.fill.effect = nil
                            end
                        )
                        fx.exposureFlash( self )
                        local opts = {
                            parent = grp.terrain,
                            x = event.other.x,
                            y = event.other.y,
                        }
                        timer.performWithDelay( 10, 
                            function()
                                fx.sparks( opts )
                            end
                        )
                    end
                end
                return true
            end
            robImg:addEventListener( "collision" )
        end
    end
    return lr
end


local function addImage( image, blockID, options )
    local o = options or {}
    local g = grp.terrain
    
    local lx, ly = grp.grid[blockID]:localToContent( 0, 0 )
    dbg.out( "addImage: add " .. image .. " to grid " .. blockID .. " x=" .. lx .. " y=" .. ly )
    local tileImg
    if ( image == "STAND_000" ) then
        playerStart.x = lx
        playerStart.y = ly
        playerStart.xScale = o.xScale or 1
        return
    end
    if ( image == "ROBOT/CORE" ) then
        dbg.out( "BUILDING A ROBOT" )
        levelRobot = spawnRobot( tiles.robots.robot1, blockID, lx, ly )
    else
        local fn = "images/" .. image .. ".png"
        tileImg = display.newImageRect( g, fn, system.ResourceDirectory, 288, 288 )
        tileImg.name = "platform"
        tileImg.image = image
        tileImg.x = lx
        tileImg.y = ly
        if ( o.xScale ) then
            tileImg.xScale = tileImg.xScale
        end
        if ( o.rotation ) then
            tileImg.rotation = tileImg.rotation
        end
        tileImg.blockID = blockID
        makePhysical( tileImg )
    end
end


local function addToGrid( blockID, options )
    local o = options or {}
    
    local block = grp.grid[blockID]
    local newImg
    if ( o.image ) then
        newImg = addImage( o.image, blockID, o )
    elseif ( o.shape ) then
        newImg = addShape( o.shape, blockID )
    end
--    newImg.gridInfo = {}
--    for k, v in pairs( block.gridInfo ) do
--        newImg.gridInfo[k] = v
--    end
--    if ( o.yOffset ) then
--        dbg.out( "addToGrid: yOffset=" .. o.yOffset )
--        newImg.y = newImg.y + o.yOffset
--    end
end
    

-- loads the savedgrids table
-- if empty, copies savegrid file from data direectory and creates new one
local function getSavedGrids()
    local sg = ls.loadTable( "savedgrids.json", system.DocumentsDirectory ) or {}
    local thisID = #sg
    dbg.out( "getSavedGrids: " .. thisID .. " saved grids")
    if ( thisID == 0 ) then
        thisID = 1
        local fn = gridSaveFile .. thisID .. ".json"
        local thisFile = "data/" .. fn
        local thisGrid = ls.loadTable( thisFile, system.ResourceDirectory )
        while ( thisGrid ~= nil ) do
            ls.saveTable( thisGrid, fn, system.DocumentsDirectory )
            sg[thisID] = fn
            thisID = thisID + 1
            fn = gridSaveFile .. thisID .. ".json"
            thisFile = "data/" .. fn
            dbg.out( "getSavedGrids: copying " .. fn )
            thisGrid = ls.loadTable( thisFile, system.ResourceDirectory )
        end
    end
    return sg
end



--- Loads a grid definition from .json file
-- loads a specific grid
local function loadGrid()
    clearTerrain()
    grp.cam.y = 0
    local g = grp.grid
    
    local savedGrids = getSavedGrids()
    if ( gridID == 0 ) then
        gridID = #savedGrids
    end
    
    if ( gridID == 0 ) then
        dbg.out( "loadGrid: There are 0 saved grids" )
        gridID = 1
        gridText.text = "LEVEL " .. gridID
        return
    end
    
    local fn = gridSaveFile .. gridID .. ".json"
    local lg = ls.loadTable( fn, system.DocumentsDirectory )
    if ( lg ) then
--        for i = 1, #lg do
        local numBlocks = 0
        for k, v in ipairs( lg ) do
            local block = grp.grid[v.blockID]
            local blockOpts = {}
            for k1, v1 in pairs( v ) do
                blockOpts[k1] = v1
            end
--            local blockOpts = {
--                name = v.name,
--                shape = v.shape,
--                image = v.image,
--                sheet = v.sheet,
--                yOffset = v.yOffset,
--            }
            addToGrid( v.blockID, blockOpts )
            numBlocks = numBlocks + 1
        end
        dbg.out( "loadGrid: " .. numBlocks .. " pieces loaded")
    else
        dbg.out( "loadGrid: " .. fn .. " could not be loaded" )
    end
    gridText.text = "LEVEL " .. gridID
    grp.cam.y = grp.grid.yMin
end


local function loadGrids()
    local ls = require( "loadsave" )
    local numGrids = 0
    for gridKey, blocks in pairs( grids ) do
        for i = 1, #blocks do
            local b = blocks[i]
            dbg.out( "loadGrids: loading " .. b.filename .. ", grid[" .. gridKey .. "]" )
            local g = ls.loadTable( b.filename, system.ResourceDirectory )
            if ( g == nil ) then
                dbg.out( "loadGrids: retrying from documents directory" )
                g = ls.loadTable( b.filename, system.DocumentsDirectory )
            end
            grids[gridKey][i].grid = g
        end
        numGrids = numGrids + 1
    end
    dbg.out( "loadGrids: " .. numGrids .. " grids loaded")
end


local function createGrid()
    local size = tiles.size
    
    local x = 0
    local y = 0
    for xCol = 1, 20 do
        x = xCol * size - size / 2
        for yRow = 1, 33 do -- 3x contentHeight
            y = yRow * size 
            local gridBox = display.newGroup()
            grp.grid:insert( gridBox )
            gridBox.name = "block"
            gridBox.x = x
            gridBox.y = y
            local box = display.newRect( gridBox, 0, 0, size * 0.9, size * 0.9 )
            box.fill = { 1, 1, 1, 0.5 }
            box.id = grp.grid.numChildren
            box.tap = function( self, event )
                if ( buildMenu ) then
                    -- ignore tap event when buildMenu is showing
                    return true
                end
                dbg.out( "grid block " .. box.id .. " tapped" )
                showBuildMenu( box.id )
                return true
            end
            box:addEventListener( "tap" ) 
            gridBox.gridInfo = {
                blockID = box.id,
                x = x,
                y = y
            }
        end
    end
end


local function gotoTitle()
    dbg.out( "gotoTitle" )
    composer.gotoScene( "title", { params={ gridID=gridID } } )
end


local function keyHandler( event )
    dbg.out( "keyHandler: key=" .. event.keyName .. ", phase=" .. event.phase )
    if ( player == nil ) then
        return true
    end
    if ( event.phase == "down" ) then
        keyDown[event.keyName] = true
        return true
    
    elseif ( event.phase == "up" ) then
        keyDown[event.keyName] = nil
        if ( event.keyName == "right" ) or ( event.keyName == "d" ) then
            player.isWalking = nil
            if ( player.onGround ) then
                player:setAnim( "idle" )
            end
            return true
        end
        if ( event.keyName == "left" ) or ( event.keyName == "a" ) then
            player.isWalking = nil
            if ( player.onGround ) then
                player:setAnim( "idle" )
            end
            return true
        end
    
    end
    
    return false
end


local function spawnPlayer()    
    if ( player ) then
        player:removeSelf()
    end
    player = require( "player").new()
    grp.terrain:insert( player )
    player.x = playerStart.x
    player.y = playerStart.y
    player.xScale = playerStart.xScale or -1
    local d = 0.5
    
    local legs = { -48, 0,   48, 0,   0, 70 }
    local torso = { -48, -1,  48, -1,  0, -72 }
    
--    physics.addBody( player, "dynamic", { density=d, friction=0.3, radius=48 } )
    physics.addBody( player, "dynamic",
        { density=d, friction=playerFriction, shape=legs }, 
        { density=d, friction=playerFriction, shape=torso }
        )
    player.isFixedRotation = true
    player.isBullet = true
end


local function updateCamera()
    local destY = -player.y + 800
--    dbg.out( "destY=" .. destY .. ", yMin=" .. grp.grid.yMin )
    if ( destY < grp.grid.yMin ) then
        destY = grp.grid.yMin
    end
    grp.cam.y = destY
end


local function cleanupTerrain()
    for i = grp.terrain.numChildren, 1, -1 do
        local obj = grp.terrain[i]
        if ( obj.y > -grp.grid.yMin + _G.CH * 2 ) then
            obj:removeSelf()
        end
    end
end


--- called every frame
local function update()
    if ( player ) and ( player.y ) then
        if ( player.y > -grp.grid.yMin + _G.CH * 2 ) then
            player:removeSelf()
            spawnPlayer()
        end
        updateCamera()
        if ( keyDown["left"] ) or ( keyDown["a"] ) then
            player:move( "left" )
        end
        if ( keyDown["right"] ) or ( keyDown["a"] )  then
            player:move( "right" )
        end
        if ( keyDown["up"] ) or ( keyDown["w"] )  then
            if ( keyDown["left"] ) then
                player:jump( "left" )
            elseif ( keyDown["right"] ) then
                player:jump( "right" )
            else
                player:jump()
            end
        end
        if ( keyDown["space"] ) or ( keyDown["z"] ) then
            local thisThrow = system.getTimer()
            if ( thisThrow - lastThrow > 250 ) then
                sound.play( "wrench1" )
                lastThrow = thisThrow
                local fn = "images/" .. tiles.wrench .. ".png"
                local wrench = display.newImageRect( grp.terrain, fn, system.ResourceDirectory, 48, 48 )
                wrench.name = "wrench"
                wrench.x = player.x
                wrench.y = player.y - player.height / 1.9
                local wo = getOutline( { image = tiles.wrench } )
                physics.addBody( wrench, "dynamic", { outline=wo } )
                player:throw()
                wrench:applyLinearImpulse( 0, wrenchForce, -24, 24 )
            end
        end
        local lx, ly = player:getLinearVelocity()
        if ( ly > 10 ) then
            if not player.isFalling then
                player:setAnim( "falling" )
                player.isFalling = true
            end
        else
            player.isFalling = nil
        end
    end
end


local function init()
    local parent = scene.view
    
    if ( params.gridID ) then
        gridID = params.gridID
    end
    loadGrid()
    spawnPlayer()
    audio.setVolume( _G.MUSICVOLUME, { channel=1 } )
    audio.play( sound.songs[1], { channel=1, loops=-1 } )
end
    

-- Called when the scene's view does not exist:
function scene:create( event )
    local sceneGroup = self.view
    params = event.params
    scene.name = composer.getSceneName( "current" )
        
    grp.cam = display.newGroup()
    sceneGroup:insert( grp.cam )
    
    grp.bg1 = display.newGroup()
    grp.cam:insert( grp.bg1 )
    
    grp.grid = display.newGroup()
    grp.cam:insert( grp.grid )
    grp.grid.yMin = gridMinY
    grp.grid.yMax = 0
    createGrid()
    grp.grid.isVisible = false
    
    grp.terrain = display.newGroup()
    grp.cam:insert( grp.terrain )
        
    grp.ui = display.newGroup()
    sceneGroup:insert( grp.ui )
    
    local btnOpts = {
        parent = grp.ui,
        x = 200,
        y = _G.CH - 100,
        text = "MENU",
        action = gotoTitle
    }
    btns.menu = ui.newButton( btnOpts )
    
    btnOpts.text = "<"
    btnOpts.x = btnOpts.x + 250
    btnOpts.action = function()
        gridID = gridID - 1
        if ( gridID < 1 ) then
            gridID = 1
        end
        loadGrid()
        spawnPlayer()
    end
    btns.prev = ui.newButton( btnOpts )
    
    btnOpts.text = ">"
    btnOpts.x = btnOpts.x + 250
    btnOpts.action = function()
        gridID = gridID + 1
        loadGrid()
        spawnPlayer()
    end
    btns.next = ui.newButton( btnOpts )
    
        
    local fn = "images/" .. tiles.bg .. ".png"
    local bgImg = display.newImageRect( grp.bg1, fn, system.ResourceDirectory, 1920, 3240 )
    bgImg.x = _G.CX
    bgImg.y = _G.CY * 3
--    local bgBox = display.newRect( grp.bg1, _G.CX, _G.CY, _G.CW, _G.CH )
--    bgBox.fill = { 0.7, 0.7, 0.7, 1 }
    
    local txtOpts = {
        parent = grp.ui,
        x = _G.CW - 300,
        y = _G.CH - 100,
        font = native.systemFont,
        fontSize = 48,
        text = "LEVEL " .. gridID,
        align = "right"
    }
    gridText = display.newText( txtOpts )

    Runtime:addEventListener( "key", keyHandler )
end


function scene:show( event )
    local phase = event.phase
    params = event.params or {}
    dbg.out( scene.name .. ":show " .. phase )
    
    if ( "will" == phase ) then
        init()
    end

    if "did" == phase then
--        physics.setDrawMode( "hybrid" )
        Runtime:addEventListener( "enterFrame", update )
    end

end

function scene:hide( event )
    local phase = event.phase
    dbg.out( scene.name .. ":hide " .. phase )

    if "will" == phase then
        Runtime:removeEventListener( "enterFrame", update )
    end
    if "did" == phase then
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

