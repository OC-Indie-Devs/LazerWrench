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

local tiles = require( "tiles" )
local ui = require( "ui" )
local ls = require( "loadsave" )

local grp = {}
local buildMenu
local gridSaveFile = "gridsave"
local gridID = 0
local gridText

local backButton
local nextButton
local prevButton


local function addShape( shape, blockID )
    local tileImg
    
    local g = grp.grid[blockID]
    
    local lx, ly = g:localToContent( 0, 0 )
    dbg.out( "addShape: add " .. shape .. " to grid " .. blockID .. " x=" .. lx .. " y=" .. ly )
    if ( shape == "circle" ) then
        tileImg = display.newCircle( g, 0, 0, tiles.size * 1.5 )
    
    elseif ( shape == "square" ) then
        tileImg = display.newRect( g, 0, 0, tiles.size * 3, tiles.size * 3 )
    
    elseif ( shape == "triangle" ) then
        local vertices = { 
            0, -tiles.size * 1.5,
            tiles.size * 1.5, tiles.size * 1.5,
            -tiles.size * 1.5, tiles.size * 1.5
        }
        tileImg = display.newPolygon( g, 0, 0, vertices )
    end
    tileImg.gridInfo = {
        name = shape,
        blockID = blockID,
        shape = shape,
        rotation = tileImg.rotation
    }
    return tileImg
end


local function addImage( image, blockID )
    local g = grp.grid[blockID]
    
    local lx, ly = g:localToContent( 0, 0 )
    dbg.out( "addShape: add " .. image .. " to grid " .. blockID .. " x=" .. lx .. " y=" .. ly )
    local fn = "images/" .. image .. ".png"
    local tileImg = display.newImageRect( g, fn, system.ResourceDirectory, 288, 288 )
    tileImg.gridInfo = {
        name = "platform",
        blockID = blockID,
        image = image,
        rotation = tileImg.rotation
    }
    return tileImg
end


-- iterates through grp.grid children (and their children)
-- puts them all into a table and then saves the table to
-- the documents directory and also updates teh savedGrids table
-- and saves that table to the documents directory
local function saveGrid()
    local g = grp.grid
    
    local sg = {}
    local numPieces = 0
    for i = 1, g.numChildren do
        local block = g[i]
        local nc = block.numChildren
        if ( nc > 1 ) then -- first piece is the semi-transparent background and is not saved
            for j = 2, nc do
                local piece = block[j]
--                table.insert( sg, piece.gridInfo )
                numPieces = numPieces + 1
                sg[numPieces] = piece.gridInfo
            end
        end
    end
    if ( numPieces > 0 ) then
        local fn = gridSaveFile .. gridID .. ".json"
        ls.saveTable( sg, fn, system.DocumentsDirectory )
        dbg.out( "saveGrid: " .. numPieces .. " pieces saved to " .. system.pathForFile( fn, system.DocumentsDirectory ) )
        if ( savedGrids == nil ) then
            savedGrids = {}
        end
        savedGrids[gridID] = fn
        ls.saveTable( savedGrids, "savedgrids.json", system.DocumentsDirectory )
    end
end


-- removes everything from grp.grid except the semi-transparent blocks
local function clearGrid()
    local numBlocks = grp.grid.numChildren
    for i = 1, numBlocks do
        local block = grp.grid[i]
        if ( block.numChildren > 1 ) then
            for j = block.numChildren, 2, -1 do
                block[j]:removeSelf()
            end
        end
    end
    dbg.out( "clearGrid: cleared" )
end


local function addToGrid( blockID, options )
    local o = options or {}
    
    local block = grp.grid[blockID]
    local newImg
    if ( o.image ) then
        if ( o.sheet ) then
            dbg.out( "addToGrid: image=" .. o.image .. ", sheet=" .. o.sheet )
            newImg = tiles.getTile( o.image, { sheet=o.sheet } )
            block:insert( newImg )
        else
            dbg.out( "addToGrid: image=" .. o.image )
            local fn = "images/" .. o.image .. ".png"
            newImg = display.newImageRect( block, fn, system.ResourceDirectory, 288, 288 )
        end
    elseif ( o.shape ) then
        newImg = addShape( o.shape, blockID )
    end
    newImg.gridInfo = {}
    for k, v in pairs( options ) do
        newImg.gridInfo[k] = v
    end
    if ( o.yOffset ) then
        dbg.out( "addToGrid: yOffset=" .. o.yOffset )
        newImg.y = newImg.y + o.yOffset
    end
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



-- loads a specific grid
local function loadGrid()
    clearGrid()
    local g = grp.grid
    
    savedGrids = getSavedGrids()
    if ( gridID == 0 ) then
        gridID = #savedGrids
    end
    
    if ( gridID == 0 ) then
        dbg.out( "loadGrid: There are 0 saved grids" )
        gridID = 1
        gridText.text = gridID
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
    gridText.text = gridID
end


local function createTouchPad()
    touchPad = display.newRect( grp.bg, _G.CX, _G.CY, _G.CW, _G.CH )
    touchPad.fill = { 0.5, 0, 0, 1 }
    touchPad.touch = function( self, event ) 
        dbg.out( "touchPad.touch: phase=" .. event.phase )
        if ( event.phase == "began" ) then
            display.getCurrentStage():setFocus( self )
            self.isFocus = true
            grp.grid.yStart = grp.grid.y
        
        elseif ( self.isFocus ) then
            if ( event.phase == "moved" ) then
                local yDiff = event.y - event.yStart
--                dbg.out( "yDiff=" .. yDiff )
                grp.grid.y = grp.grid.yStart + yDiff
                if ( grp.grid.y < grp.grid.yMin ) then
                    grp.grid.y = grp.grid.yMin
                elseif ( grp.grid.y > grp.grid.yMax ) then
                    grp.grid.y = grp.grid.yMax
                end
--                dbg.out( "grp.grid.y=" .. grp.grid.y )
            elseif ( event.phase == "ended" ) or ( event.phase == "cancelled" ) then
                display.getCurrentStage():setFocus( nil )
                self.isFocus = nil
            end
        end
        return true
    end
    touchPad:addEventListener( "touch" )
end



local function deleteTile( blockID )
    local g = grp.grid[blockID]
    if ( g.numChildren > 1 ) then
        g[g.numChildren]:removeSelf()
    end
end


local function removeBuildMenu()
    if ( buildMenu ) then
        if ( buildMenu.itemList ) then
            buildMenu.itemList:removeSelf()
        end
        -- delay to prevent tap on grid block from launching new buildMenu
        timer.performWithDelay( 
            100, 
            function()
                if ( buildMenu ) then
                    dbg.out( "removeBuildMenu: removing build menu" )
                    buildMenu:removeSelf()
                    buildMenu = nil
                end
            end
            )
    end
end


local function showBuildMenu( blockID )
    buildMenu = display.newGroup()
    buildMenu.x = _G.CX
    buildMenu.y = _G.CY
    
    local bgBox = display.newRect( buildMenu, 0, 0, 1000, 900 )
    bgBox:setFillColor( 0.5, 0.2, 0.2, 1 )
    
    local btnOpts = {
        parent = buildMenu,
        text = "Cancel",
        width = 200,
        height = 100,
        x = 350,
        y = 400,
        action = removeBuildMenu
    }
    local cancelButton = ui.newButton( btnOpts )
    
    btnOpts.text = "DELETE"
    btnOpts.x = -350
    btnOpts.action = function()
        deleteTile( blockID )
        removeBuildMenu()
    end
    btnOpts.fill = { 1, 0.2, 0.2, 1 }
    btnOpts.textColor = { 1, 1, 1, 1 }
    local deleteButton = ui.newButton( btnOpts )
    
    local svOpts = {
        x = _G.CX,
        y = _G.CY,
        width = 800,
        height = 600,
    }
    local widget = require( "widget" )
    local itemList  = widget.newScrollView( svOpts )
    buildMenu.itemList = itemList
        
    local shapes = { "circle", "square", "triangle" }
    local shapeImages = { "spr_shapes_no3d_03", "spr_shapes_no3d_05", "spr_shapes_no3d_07" }
    
    local itemHeight = tiles.size + 20
    local y = itemHeight / 2
    for i = 1, #shapeImages do
        local item = display.newGroup()
        item.y = y
--        item.y = i * itemHeight - itemHeight / 2
        local bg = display.newRect( item, 400, 0, 800, itemHeight )
        if ( i % 2 == 0 ) then
            bg.fill = { 0.5, 0.5, 0.5, 1 }
        else
            bg.fill = { 0.8, 0.8, 0.8, 1 }
        end
        bg.id = i
        bg.tap = function( self, event )
            dbg.out( "menu item " .. bg.id .. " tapped" )
            addImage( shapeImages[i], blockID )
            removeBuildMenu()
            return true
        end
        bg:addEventListener( "tap" )
        
        local fn = "images/" .. shapeImages[i] .. ".png"
        local tileImg = display.newImageRect( item, fn, system.ResourceDirectory, tiles.size, tiles.size )
        tileImg.x = tiles.size / 1.5

--        if ( shapes[i] == "circle" ) then
--            tileImg = display.newCircle( item, tiles.size / 1.5, 0, tiles.size / 2 )
--            
--        elseif ( shapes[i] == "square" ) then
--            tileImg = display.newRect(item, tiles.size / 1.5, 0, tiles.size, tiles.size )
--            
--        elseif ( shapes[i] == "triangle" ) then
--            local vertices = { 
--                0, -tiles.size / 2,
--                tiles.size /2, tiles.size / 2,
--                -tiles.size / 2, tiles.size / 2
--            }
--            tileImg = display.newPolygon( item, tiles.size / 1.5, 0, vertices )
--        end
        local txtOpts = {
            parent = item,
            x = tileImg.x + tiles.size + 300,
            text = shapeImages[i],
            width = 600,
            font = native.systemFont,
            fontSize = 48,
            align = "left",
        }
        local txt = display.newText( txtOpts )
        txt:setFillColor( 0 )
        itemList:insert( item )
        y = y + itemHeight
    end
    
--    local sheet = tiles.sheets.square
--    local fName = "images/" .. sheet .. ".png"
--    local si = require( sheet )
--    local numImgs = #si.sheet.frames
--    
--    for i = 1, numImgs do
--        local item = display.newGroup()
--        item.y = y
----        item.y = i * itemHeight - itemHeight / 2
--        local bg = display.newRect( item, 400, 0, 800, itemHeight )
--        local row = i + #shapes
--        if ( row % 2 == 0 ) then
--            bg.fill = { 0.5, 0.5, 0.5, 1 }
--        else
--            bg.fill = { 0.8, 0.8, 0.8, 1 }
--        end
--        bg.id = i + #shapes
--        bg.tap = function( self, event )
--            dbg.out( "menu item " .. bg.id .. " tapped" )
--            removeBuildMenu()
--            return true
--        end
--        bg:addEventListener( "tap" )
--        bg.finalize = function( self, event )
--            if ( bg.tap ) then
--                bg:removeEventListener( "tap" )
--                bg.tap = nil
--            end
--        end
--        
--        local imageSheet = graphics.newImageSheet( fName, system.ResourceDirectory, si:getSheet() )
--        local tileImg = display.newImageRect( item, imageSheet, i, tiles.size, tiles.size )
--        tileImg.x = tiles.size / 1.5
--        tileImg.y = 0
--        local txtOpts = {
--            parent = item,
--            x = tileImg.x + tiles.size + 300,
--            text = tiles.getTileName( sheet, i ),
--            width = 600,
--            font = native.systemFont,
--            fontSize = 48,
--            align = "left",
--        }
--        local txt = display.newText( txtOpts )
--        txt:setFillColor( 0 )
--        itemList:insert( item )
--        y = y + itemHeight
--    end
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


local function gotoGame()
    composer.gotoScene( "game", {} )
end


local function init()
    loadGrid()
    grp.grid.y = grp.grid.yMin
end


-- Called when the scene's view does not exist:
function scene:create( event )
    local sceneGroup = self.view
    params = event.params
    scene.name = composer.getSceneName( "current" )
    
    grp.bg = display.newGroup()
    sceneGroup:insert( grp.bg )
    
    grp.grid = display.newGroup()
    sceneGroup:insert( grp.grid )
    grp.grid.yMin = -_G.CH * 2
    grp.grid.yMax = 0
    createTouchPad()
    createGrid()
    
    grp.ui = display.newGroup()
    sceneGroup:insert( grp.ui )
    
    local btnOpts = {
        parent = grp.ui,
        x = 200,
        y = 100,
        text = "Done",
        font = native.systemFont,
        fontSize = 36,
        width = 200,
        height = 100,
        action = function()
            saveGrid()
            gotoGame()
        end
    }
    backButton = ui.newButton( btnOpts )
    
    btnOpts.text = "<"
    btnOpts.x = btnOpts.x + 250
    btnOpts.action = function()
        gridID = gridID - 1
        if ( gridID < 1 ) then
            gridID = 1
        end
        loadGrid()
    end
    prevButton = ui.newButton( btnOpts )
    
    btnOpts.text = ">"
    btnOpts.x = btnOpts.x + 250
    btnOpts.action = function()
        gridID = gridID + 1
        loadGrid()
    end
    nextButton = ui.newButton( btnOpts )
    
    local textOpts = {
        parent = grp.ui,
        x = 50,
        y = 50,
        text = "GRID " .. gridID,
        font = native.systemFont,
        fontSize = 48
    }
    gridText = display.newText( textOpts )
end


function scene:show( event )
    local phase = event.phase
    params = event.params or {}
    dbg.out( scene.name .. ":show " .. phase )
    
    if ( "will" == phase ) then
        init()
    end

    if "did" == phase then
    end

end

function scene:hide( event )
    local phase = event.phase
    dbg.out( scene.name .. ":hide " .. phase )

    if "will" == phase then
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

