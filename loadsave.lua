----------------------------------------------------------
-- Summary: File load and save functions.
-- 
-- Description: Helper functions for loading and saving tables.
-- 
-- @author Tony Godfrey (tonygod@sharkappsllc.com)
-- @copyright 2016 shark apps, LLC
-- @license all rights reserved.
----------------------------------------------------------

local _M = {}

local json = require("json")
local DefaultLocation = system.DocumentsDirectory
local RealDefaultLocation = DefaultLocation
local ValidLoadLocations = {
   [system.DocumentsDirectory] = true,
   [system.CachesDirectory] = true,
   [system.TemporaryDirectory] = true,
   [system.ResourceDirectory] = true
}
local ValidSaveLocations = {
   [system.DocumentsDirectory] = true,
   [system.CachesDirectory] = true,
   [system.TemporaryDirectory] = true
}


function _M.doesExist( filename, location )
    if ( location ) then
        local path = system.pathForFile( filename, location )
        local f = io.open( path, "r" )
        if f then
            io.close( f )
            return true
        else
            return false
        end
    end
end


function _M.copyDataFiles()
    local srcFiles = {
        "gridsave1.json",
        "savedgrids.json"
    }
    for i = 1, #srcFiles do
        -- Path for the file to write
        local srcPath = system.pathForFile( "data/" .. srcFiles[i], system.ResourceDirectory )
        -- Open the file handle
        local file, errorString = io.open( srcPath, "r" )

        if not file then
            -- Error occurred; output the cause
            dbg.out( "File error: " .. errorString )
        else
            local srcData = file:read( "*a" )
            io.close( file )
            
            local destPath = system.pathForFile( srcFiles[i], system.DocumentsDirectory )
            file, errorString = io.open( destPath, "w" )
            -- Write data to file
            file:write( srcData )
            -- Close the file handle
            io.close( file )
            dbg.out( "loadsave.copyDataFiles: copied " .. srcFiles[i] )
        end

        file = nil
    end
end



function _M.saveTable(t, filename, location)
    if location and (not ValidSaveLocations[location]) then
     dbg.out("Attempted to save a table to an invalid location", 2)
    elseif not location then
      location = DefaultLocation
    end
    
    local path = system.pathForFile( filename, location)
    local f = io.open(path, "w")
    if f then
        local contents = json.encode(t)
        f:write( contents )
        io.close( f )
        return true
    else
        return false
    end
end

 
function _M.loadTable(filename, location)
    if ( location ) and ( not ValidLoadLocations[location] ) then
        dbg.out( "loadSave.loadTable: Attempted to load from an invalid location" )
    elseif not location then
        location = DefaultLocation
    end
    local path = system.pathForFile( filename, location)
    if ( path == nil ) then
        dbg.out( "loadTable: path is nil" )
        return nil
    end
    --    path = path:gsub( "/", "\\" ) -- WP8?
    dbg.out( "loadTable: path is " .. path )
    
    local contents = ""
    local myTable = {}
    local f, reason = io.open( path, "r" )
    if ( f ) then
        -- read all contents of file into a string
        local contents = f:read( "*a" )
        myTable = json.decode(contents);
        io.close( f )
        return myTable
    else
        dbg.out( "loadTable: unable to open " .. path .. " - " .. reason )
    end
    return nil
end


function _M.loadFileAsString( filename, location )
    if ( location ) and ( not ValidLoadLocations[location] ) then
        dbg.out( "loadFileAsString: Attempted to load from an invalid location", 2)
    elseif not location then
        location = DefaultLocation
    end
    local path = system.pathForFile( filename, location )
    if ( path == nil ) then
        dbg.out( "loadFileAsString: path is nil" )
        return nil
    end
    --    path = path:gsub( "/", "\\" ) -- WP8?
    dbg.out( "loadFileAsString: path is " .. path )
    
    local contents = ""
    local myTable = {}
    local f, reason = io.open( path, "r" )
    if ( f ) then
        -- read all contents of file into a string
        local contents = f:read( "*a" )
        io.close( f )
        return contents
    else
        dbg.out( "loadFileAsString: unable to open " .. path .. " - " .. reason )
        return nil
    end
end


function _M.changeDefault(location)
	if location and (not location) then
		dbg.out("Attempted to change the default location to an invalid location", 2)
	elseif not location then
		location = RealDefaultLocation
	end
	DefaultLocation = location
	return true
end

return _M


