
-- =============================================================
-- Copyright Roaming Gamer, LLC. 2009-2016
-- =============================================================
-- RG Files Module Library - Loader and Initializer
-- =============================================================
-- 								License
-- =============================================================
--[[
	> SSK is free to use.
	> SSK is free to edit.
	> SSK is free to use in a free or commercial game.
	> SSK is free to use in a free or commercial non-game app.
	> SSK is free to use without crediting the author (credits are still appreciated).
	> SSK is free to use without crediting the project (credits are still appreciated).
	> SSK is NOT free to sell for anything.
	> SSK is NOT free to credit yourself with.
]]
-- =============================================================
local lfs 			= require "lfs"
local json        = require "json"

local strGSub		= string.gsub
local strSub		= string.sub
local strFormat 	= string.format
local strFind     = string.find

local pathSep = ( onWin ) and "\\" or "/"

local RGFiles = {}

-- =====================================================
-- Utility methods
-- =====================================================
require("ssk.RGFiles.RGFiles_util").attach( RGFiles )

-- OSX Discovery Utility
local function getUserName()
  -- 1. Try the $USER variable
  local user = os.getenv("USER")  
  if( user ) then 
    print("Found $USER == " .. tostring( user ) )
    return user
  end
  -- 2. Try extracting it from the $HOME path
  local user = os.getenv("HOME")
  if( user ) then 
    print("Found $HOME == ", user )
    user = string.split(user, "/")
    user = user[#user]
    if( user ) then 
      print("Got USER from $HOME == " .. tostring( user ) )
      return user
    end
  end
  -- 3. Try the $LOGNAME variable
  local user = os.getenv("LOGNAME")  
  if( user ) then 
    print("Got USER from $LOGNAME == " .. tostring( user ) )
    return user
  end
  return nil
end

-- =====================================================
-- Discover full root paths to:
-- =====================================================
--
-- system.DocumentsDirectory
--
RGFiles.documentsRoot = system.pathForFile('', system.DocumentsDirectory) .. pathSep
--
-- system.ResourceDirectory
--
do
	local tmp = system.pathForFile('main.lua', system.ResourceDirectory)
	RGFiles.resourceRoot = (tmp) and tmp:sub(1, -9) or ""
end
--
-- system.TemporaryDirectory
--
RGFiles.temporaryRoot = system.pathForFile('', system.TemporaryDirectory)  .. pathSep
--
-- OS My Documents Folder
--
RGFiles.myDocumentsRoot = ""
if( onWin ) then
	RGFiles.myDocumentsRoot = os.getenv("appdata")
	local appDataStart = string.find( RGFiles.myDocumentsRoot, "AppData" )
	if( appDataStart ) then
		RGFiles.myDocumentsRoot = string.sub( RGFiles.myDocumentsRoot, 1, appDataStart-1 )
      if( RGFiles.util.isFolder(RGFiles.myDocumentsRoot .. "Documents") ) then         
         RGFiles.myDocumentsRoot = RGFiles.myDocumentsRoot .. "Documents"
      else
         RGFiles.myDocumentsRoot = RGFiles.myDocumentsRoot .. "My Documents" -- EFM - is this right?  Win 7 and before?
      end
	end
elseif( onOSX ) then
	RGFiles.myDocumentsRoot = getUserName()
	if( not RGFiles.myDocumentsRoot ) then
		RGFiles.myDocumentsRoot = "TBD"
	else
		RGFiles.myDocumentsRoot = "/Users/" .. RGFiles.myDocumentsRoot .. "/" .. "Documents"		
	end
end
RGFiles.myDocumentsRoot = RGFiles.myDocumentsRoot .. pathSep
--
-- OS Desktop
--
RGFiles.desktopRoot = ""
if( onWin ) then
	RGFiles.desktopRoot = os.getenv("appdata")
	local appDataStart = string.find( RGFiles.desktopRoot, "AppData" )
	if( appDataStart ) then
		RGFiles.desktopRoot = string.sub( RGFiles.desktopRoot, 1, appDataStart-1 )
		RGFiles.desktopRoot = RGFiles.desktopRoot .. "Desktop"
	end
elseif( onOSX ) then
	RGFiles.desktopRoot = getUserName()
	if( not RGFiles.desktopRoot ) then
		RGFiles.desktopRoot = "TBD"
	else
		RGFiles.desktopRoot = "/Users/" .. RGFiles.desktopRoot .. "/" .. "Desktop"
	end
end
RGFiles.desktopRoot = RGFiles.desktopRoot .. pathSep 


-- =====================================================
-- Attach OS Dependent features
-- =====================================================
require("ssk.RGFiles.RGFiles_systemDocuments").attach( RGFiles )
require("ssk.RGFiles.RGFiles_systemResource").attach( RGFiles )
require("ssk.RGFiles.RGFiles_systemTemporary").attach( RGFiles )
require("ssk.RGFiles.RGFiles_desktop").attach( RGFiles )
require("ssk.RGFiles.RGFiles_tests").attach( RGFiles )

--table.dump( RGFiles.desktop )
----------------------------------------------------------------------
--	Attach To SSK and return
----------------------------------------------------------------------
if( _G.ssk ) then
	ssk.RGFiles = RGFiles
else 
	_G.ssk = { RGFiles = RGFiles }
end

return RGFiles


