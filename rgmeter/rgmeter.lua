-- =============================================================
-- Copyright Roaming Gamer, LLC. 2009-2013
-- =============================================================
local relDate = "(2014.02.11)"
local relVer  = "v2.1"
local easyPush = require "rgmeter.RGEasyPush"
local easyMeter = require "rgmeter.RGEasyMeter"

local newImage			= easyPush.newImage
local newRect			= easyPush.newRect
local newCircle			= easyPush.newCircle
local easyPushButton 	= easyPush.easyPushButton
local isInBounds 		= easyPush.isInBounds
local easyFlyIn 		= easyPush.easyFlyIn
local easyFlyIn2		= easyPush.easyFlyIn2
local easySqueeze 		= easyPush.easySqueeze
local comma_value 		= easyPush.comma_value
local easyInflate 		= easyPush.easyInflate
local round 			= easyPush.round
local fnn 				= easyPush.fnn
local quickLabel 		= easyPush.quickLabel

local newMeter 			= easyMeter.newMeter

local getTimer 			= system.getTimer
local sysGetInfo		= system.getInfo
local strMatch 			= string.match
local strFormat 		= string.format


if( not string.split ) then
	function string:split(tok)
		local str = self
		local t = {}  -- NOTE: use {n = 0} in Lua-5.0
		local ftok = "(.-)" .. tok
		local last_end = 1
		local s, e, cap = str:find(ftok, 1)
		while s do
			if s ~= 1 or cap ~= "" then
				table.insert(t,cap)
			end
			last_end = e+1
			s, e, cap = str:find(ftok, last_end)
		end
		if last_end <= #str then
			cap = str:sub(last_end)
			table.insert(t, cap)
		end
		return t
	end
end

local function ternary( test, a, b  )
  if(test) then
    return a
  else
    return b 
  end  
end

local function compare( a, b )
	return a:lower() < b:lower()
end

local directionForAngle = function( angle )
	local text

	if ( angle <= 22 or angle > 337 ) then
		text = "N"
	elseif ( angle > 22 and angle <= 67 ) then
		text = "NE"
	elseif ( angle > 67 and angle <= 112 ) then
		text = "E"
	elseif ( angle > 112 and angle <= 157 ) then
		text = "SE"
	elseif ( angle > 157 and angle <= 202 ) then
		text = "S"
	elseif ( angle > 202 and angle <= 247 ) then
		text = "SW"
	elseif ( angle > 247 and angle <= 292 ) then
		text = "W"
	elseif ( angle > 292 and angle <= 337 ) then
		text = "NW"
	end
	
	return text
end

local w = display.contentWidth
local h = display.contentHeight

local centerX = w/2
local centerY = h/2

local scaleX = 1/display.contentScaleX
local scaleY = 1/display.contentScaleY

local displayWidth        = (display.contentWidth - display.screenOriginX*2)
local displayHeight       = (display.contentHeight - display.screenOriginY*2)

local unusedWidth    = displayWidth - w
local unusedHeight   = displayHeight - h

local deviceWidth  = math.floor((displayWidth/display.contentScaleX) + 0.5)
local deviceHeight = math.floor((displayHeight/display.contentScaleY) + 0.5)

local luaVersion = _VERSION
local onSimulator = sysGetInfo( "environment" ) == "simulator"
local platformVersion = sysGetInfo( "platformVersion" ) or 0
local olderVersion = tonumber(string.sub( platformVersion, 1, 1 )) < 4

local oniOS = ( sysGetInfo("platformName") == "iPhone OS") 
local onAndroid = ( sysGetInfo("platformName") == "Android") 
local onOSX = ( sysGetInfo("platformName") == "Mac OS X")
local onWin = ( sysGetInfo("platformName") == "Win")

local _TRANSPARENT_ = {0, 0, 0, 0}

local _WHITE_ = {1, 1, 1, 1}
local _BLACK_ = {  0,   0,   0, 1}
local _GREY_      = {0.5, 0.5, 0.5, 1}
local _DARKGREY_  = { 0.25,  0.25,  0.25, 1}
local _DARKERGREY_  = { 0.125,  0.125,  0.125, 1}
local _LIGHTGREY_ = {0.753, 0.753, 0.753, 1}

local _RED_   = {1, 0, 0, 1}
local _GREEN_ = {0, 1, 0, 1}
local _BLUE_  = {0, 0, 1, 1}
local _CYAN_  = {0, 1, 1, 1}

local _YELLOW_       = {1, 1, 0, 1}
local _ORANGE_       = {1, 0.398, 0, 1}
local _BRIGHTORANGE_ = {1, 0.598, 0, 1}
local _PURPLE_       = {0.625, 0.125, 0.938, 1}
local _PINK_         = {1, 0.430, 0.777, 1}

local leftBuffer  = 20 - unusedWidth/2
local rightBuffer = w - 20 + unusedWidth/2
local topBuffer   = 20 - unusedHeight/2
local botBuffer   = h - 20 + unusedHeight/2

local function onDrag( self, event )
	if(event.phase == "began") then
		display.getCurrentStage():setFocus(event.target, event.id)
		self.x0 = self.x
		self.y0 = self.y
		self.inDrag = true

	elseif(event.phase == "moved" and self.inDrag ) then
		if( event.x < leftBuffer or event.x  > rightBuffer or event.y < topBuffer or event.y > botBuffer ) then
			return true
		end
		self.x = self.x0 + event.x - event.xStart
		self.y = self.y0 + event.y - event.yStart

	elseif(event.phase == "ended" and self.inDrag ) then
		display.getCurrentStage():setFocus(event.target, nil)

		if( event.x < leftBuffer or event.x  > rightBuffer or event.y < topBuffer or event.y > botBuffer ) then
			return true
		end
		self.x = self.x0 + event.x - event.xStart
		self.y = self.y0 + event.y - event.yStart
		
		self.inDrag = false
	end
	return true
end

local infoValues = {}
local infoStrings = {		
	"androidAppVersionCode", "androidAppPackageName",  "androidDisplayApproximateDpi", "androidDisplayDensityName", 
	"androidDisplayWidthInInches", "androidDisplayHeightInInches", "androidDisplayXDpi", "androidDisplayYDpi",
	"appName", "appVersionString", "architectureInfo", "build",  "deviceID", "environment", "gpuSupportsHighPrecisionFragmentShaders",
	"GL_VENDOR", "GL_RENDERER", "GL_VERSION", "GL_SHADING_LANGUAGE_VERSION", "GL_EXTENSIONS",
	"iosAdvertisingIdentifier", "iosAdvertisingTrackingEnabled", "iosIdentifierForVendor",
	"model", "name", "platformName", "platformVersion", "maxTextureSize", "maxTextureUnits", 
	"targetAppStore",  "textureMemoryUsed","version",
}

for i = 1, #infoStrings do
	local tmp = infoStrings[i]
	infoValues[tmp] = sysGetInfo(tmp)
	if(not infoValues[tmp]) then
		infoValues[tmp] = "n/a"
	end
end


infoEnable = {}
infoEnable["GEN"] = true
infoEnable["ARC"] = true
infoEnable["RES"] = true
infoEnable["OST"] = true
infoEnable["OGI"] = true
infoEnable["OGE"] = true
infoEnable["AND"] = true
infoEnable["IOS"] = true
infoEnable["PKG"] = true
infoEnable["DIR"] = true
infoEnable["FNT"] = true
infoEnable["MED"] = true
infoEnable["POP"] = true
infoEnable["SYE"] = true
infoEnable["SFX"] = true

dbgEnable = {}
dbgEnable["PHY"] = true
dbgEnable["CAP"] = true


local defaultEmail
local currentAppName = "My App"
local numTicks = 30
local averageWindow = 30
local updatePeriod = 11
local allowCollect = false
local includeVideoToo = false

local maxMainMem = 0x1000 * 4
local maxVidMem = 0x1000  * 4

local fontSM = 1
if(onOSX) then 
	fontSM = 0.92
elseif(oniOS) then 
	fontSM = 1
end

local function createFPSMeter( group, width, height )
	-- ==
	--    FPS Meter
	-- ==
	local fpsFrame = display.newGroup()
	group:insert( fpsFrame )
	--local fpsFrameBack = display.newImageRect( fpsFrame, "rgmeter/back2.png", width, height)
	--fpsFrameBack.anchorX = 0
	--fpsFrameBack.anchorY = 0

	local fpsMeter = newMeter( fpsFrame, 6, 6, 240, 100, numTicks, { suffix = " FPS", tickColor = _RED_, fontSM = fontSM } )
	fpsMeter:setMinMaxDiv( 0, display.fps * 1.5 )
	fpsMeter:redraw()
	fpsFrame.meter = fpsMeter

	local minFPS = 999
	local maxFPS = 0
	local fpsUpdateCount = 0
	local lastFPSTime = -1
	local fps = {}
	local fpsIndex = 1

	local function onFPSFrame( self, event )

		local curTime = event.time
		local delta = curTime - lastFPSTime
		local curFPS 

		if(lastFPSTime ~= -1  ) then
			curFPS = 1000/delta
			if(fpsIndex > averageWindow) then
				fpsIndex = 1
			end
			fps[fpsIndex] = curFPS
			fpsIndex = fpsIndex + 1
		end


		lastFPSTime = curTime

		fpsUpdateCount = fpsUpdateCount + 1

		if( fpsUpdateCount % updatePeriod ~= 0) then return false end
		local avgFPS = 0

		if( #fps > 0 ) then
			for i = 1, #fps do
				avgFPS = avgFPS + fps[i]
			end
			avgFPS = avgFPS / #fps
		end

		if( avgFPS < minFPS ) then
			minFPS = avgFPS
		end 

		if( avgFPS > maxFPS ) then
			maxFPS = avgFPS
		end 
		
		if( #fps > 0 ) then
			local tmpAvg = round(avgFPS)
			fpsMeter:addValue( avgFPS )
			fpsMeter:redraw( minFPS, maxFPS, avgFPS )
		end

		return false
	end

	fpsFrame.enterFrame = onFPSFrame

	Runtime:addEventListener( "enterFrame", fpsFrame )

	return fpsFrame
end


local function createMainMemMeter( group, width, height )
	-- ==
	--    Main Mem Meter
	-- ==
	local mmFrame = display.newGroup()
	group:insert( mmFrame )
	--local mmFrameBack = display.newImageRect( mmFrame, "rgmeter/back2.png", width, height)
	--mmFrameBack.anchorX = 0
	--mmFrameBack.anchorY = 0

	local mmMeterV = newMeter( mmFrame, 6, 6, 240, 100, numTicks, { suffix = " KB", div = 1024, suffix2 = " MB", tickColor = _BLUE_, fontSM = fontSM  } )
	mmMeterV:redraw()
	mmFrame.meter2 = mmMeterV
	mmMeterV.isVisible = false


	local mmMeter = newMeter( mmFrame, 6, 6, 240, 100, numTicks, { suffix = " KB", div = 1024, suffix2 = " MB", tickColor = _GREEN_, linkedMeter = mmMeterV, fontSM = fontSM   } )
	mmMeter:setMinMaxDiv( 0, maxMainMem, 1024 )
	mmMeter:redraw()
	mmFrame.meter = mmMeter
	--mmMeter.isVisible = true

	local minMM = 0xF000000
	local maxMM = 0
	local mmUpdateCount = 0
	local lastMMTime = -1
	local mm = {}
	local mmIndex = 1

	local minMMV = 0xF000000
	local maxMMV = 0
	local lastMMVTime = -1
	local mmv = {}
	local mmvIndex = 1

	local collectToggleButton
	local includeVideoMemory

	local function onMMFrame( self, event )

		if( allowCollect ) then
			collectgarbage()
			collectToggleButton:setFillColor(  unpack(_GREEN_) )
		else
			collectToggleButton:setFillColor( unpack(_RED_) )
		end

		local curMM = collectgarbage("count")  

		if( curMM < minMM ) then
			minMM = curMM
		end 

		if( curMM > maxMM ) then
			maxMM = curMM
		end 

		if(mmIndex > averageWindow) then
			mmIndex = 1
		end
		mm[mmIndex] = curMM
		mmIndex = mmIndex + 1

		mmUpdateCount = mmUpdateCount + 1

 
		local videoMemToo =  0
		
		if( includeVideoToo ) then
			videoMemToo = sysGetInfo( "textureMemoryUsed" ) / 1024
			includeVideoMemory:setFillColor(  unpack(_GREEN_) )
			mmMeterV.isVisible = true
			mmMeter:showLabels( false )
		else
			includeVideoMemory:setFillColor( unpack(_RED_) )
			mmMeterV.isVisible = false
			mmMeter:showLabels( true )
		end

		local curMMV = collectgarbage("count") + videoMemToo

		if( curMMV < minMMV ) then
			minMMV = curMMV
		end 

		if( curMMV > maxMMV ) then
			maxMMV = curMMV
		end 

		if(mmvIndex > averageWindow) then
			mmvIndex = 1
		end
		mmv[mmvIndex] = curMMV
		mmvIndex = mmvIndex + 1

		if( mmUpdateCount % updatePeriod ~= 0) then return false end

		local avgMM = 0

		if( #mm > 0 ) then
			for i = 1, #mm do
				avgMM = avgMM + mm[i]
			end
			avgMM = avgMM / #mm
		end

		if( avgMM < minMM ) then
			minMM = avgMM
		end 

		if( avgMM > maxMM ) then
			maxMM = avgMM
		end 
		
		if( #mm > 0 ) then
			local tmpAvg = round(avgMM)
			mmMeter:addValue( avgMM )
			mmMeter:redraw( minMM, maxMM, avgMM )
		end

		local avgMMV = 0

		if( #mmv > 0 ) then
			for i = 1, #mmv do
				avgMMV = avgMMV + mmv[i]
			end
			avgMMV = avgMMV / #mmv
		end

		if( avgMMV < minMMV ) then
			minMMV = avgMMV
		end 

		if( avgMMV > maxMMV ) then
			maxMMV = avgMMV
		end 
		
		if( #mmv > 0 ) then
			local tmpAvg = round(avgMMV)
			mmMeterV:addValue( avgMMV )
			mmMeterV:redraw( minMMV, maxMMV, avgMMV )
		end

		return false
	end


	-- 
	-- Toggle Allow Collect
	--
	local function onToggle( self, event )
		if(event.phase == "ended") then
			allowCollect = not allowCollect
		end
		return true
	end

	collectToggleButton = newImage( mmMeter, "rgmeter/c.png", mmMeter.frame.x + mmMeter.frame.contentWidth + 62, mmMeter.frame.y + 80, { w = 54, h = 49, scale = 0.4 })
	easyPushButton( collectToggleButton, onToggle, { normalScale = 0.4, pressedScale = 0.38 } )
	collectToggleButton:setFillColor(unpack(_RED_))

	-- 
	-- Toggle Include Video Too
	--
	local function onToggle2( self, event )
		if(event.phase == "ended") then
			includeVideoToo = not includeVideoToo
		end
		return true
	end
		

	includeVideoMemory = newImage( mmMeter, "rgmeter/u.png", collectToggleButton.x, collectToggleButton.y + collectToggleButton.contentHeight + 4, { w = 54, h = 49, scale = 0.4 })
	easyPushButton( includeVideoMemory, onToggle2, { normalScale = 0.4, pressedScale = 0.38 } )
	includeVideoMemory:setFillColor(unpack(_RED_))

	mmFrame.enterFrame = onMMFrame

	Runtime:addEventListener( "enterFrame", mmFrame )

	return mmFrame
end

local function createVideoMemMeter( group, width, height )
	-- ==
	--    Main Mem Meter
	-- ==
	local vmFrame = display.newGroup()
	group:insert( vmFrame )
	--local vmFrameBack = display.newImageRect( vmFrame, "rgmeter/back2.png", width, height)
	--vmFrameBack.anchorX = 0
	--vmFrameBack.anchorY = 0

	local vmMeter = newMeter( vmFrame, 6, 6, 240, 100, numTicks, { suffix = " KB", div = 1024, suffix2 = " MB", tickColor = _BLUE_, fontSM = fontSM   } )
	vmMeter:setMinMaxDiv( 0, maxVidMem, 1024 )
	vmMeter:redraw()
	vmFrame.meter = vmMeter

	local minVM = 0xF000000
	local maxVM = 0
	local vmUpdateCount = 0
	local lastVMTime = -1
	local vm = {}
	local vmIndex = 1

	local collectToggleButton

	local function onVMFrame( self, event )

		local curVM = sysGetInfo( "textureMemoryUsed" ) / 1024

		if( curVM < minVM ) then
			minVM = curVM
		end 

		if( curVM > maxVM ) then
			maxVM = curVM
		end 

		if(vmIndex > averageWindow) then
			vmIndex = 1
		end
		vm[vmIndex] = curVM
		vmIndex = vmIndex + 1

		vmUpdateCount = vmUpdateCount + 1

		if( vmUpdateCount % updatePeriod ~= 0) then return false end

		local avgVM = 0

		if( #vm > 0 ) then
			for i = 1, #vm do
				avgVM = avgVM + vm[i]
			end
			avgVM = avgVM / #vm
		end

		if( avgVM < minVM ) then
			minVM = avgVM
		end 

		if( avgVM > maxVM ) then
			maxVM = avgVM
		end 
		
		if( #vm > 0 ) then
			local tmpAvg = round(avgVM)
			vmMeter:addValue( avgVM )
			vmMeter:redraw( minVM, maxVM, avgVM )
		end

		return false
	end

	vmFrame.enterFrame = onVMFrame

	Runtime:addEventListener( "enterFrame", vmFrame )

	return vmFrame
end



local function createinfoMeter( group, width, height )
	-- ==
	--    Main Mem Meter
	-- ==
	local infoFrame = display.newGroup()
	group:insert( infoFrame )

	local infoFrames = {}

	local aFrame

	local meterFontSize = 9 * fontSM
	
	local ySep = 14
	local y0 = 9
	local y1 = 30
	local y2 = y1 + ySep
	local y3 = y2 + ySep
	local y4 = y3 + ySep
	local y5 = y4 + ySep
	local y6 = y5 + ySep
	local y7 = y6 + ySep
	local y8 = y7 + ySep

	local x1 = 157.5
	local x2 = x1 + 5
	local x3 = 220
	local x4 = 315

	local editFrame = 0

	local tmp =	quickLabel( infoFrame, "RG Super Meter " .. relVer .. " " .. relDate, 4, y0, nil, 9 * fontSM, _GREY_, 0 )

	--
	-- General Info
	--
	if( infoEnable["GEN"]) then
		editFrame = editFrame+1
		infoFrames[#infoFrames+1] = display.newGroup()
		infoFrame:insert( infoFrames[#infoFrames] )
		aFrame = infoFrames[editFrame]
		local title =	quickLabel( aFrame, "General Info (GEN)", x3, y0, nil, meterFontSize * 1.1, _ORANGE_, 0.5 )
		local lineWidth = title.contentWidth + 5
		local tmp = display.newLine( aFrame, -lineWidth/2 + title.x, 0, lineWidth/2 + title.x, 0 )
		tmp:setStrokeColor( unpack(_ORANGE_) )
		tmp.y = title.y + title.contentHeight/2

		quickLabel( aFrame, "App Name:" , x1, y1, nil, meterFontSize, _ORANGE_, 1 )
		if(string.len(infoValues.appVersionString) > 0 ) then
			quickLabel( aFrame, "'" .. infoValues.appName .. "' ( version: " .. infoValues.appVersionString .. " )", x2, y1, nil, meterFontSize, _WHITE_, 0 )
		else
			quickLabel( aFrame, "'" .. infoValues.appName .. "'" , x2, y1, nil, meterFontSize, _WHITE_, 0 )
		end
		
		quickLabel( aFrame, "Environment: ", x1, y2, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, infoValues.environment, x2, y2, nil, meterFontSize, _WHITE_, 0 )
		
		quickLabel( aFrame, "Corona Build:", x1, y3, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, infoValues.build, x2, y3, nil, meterFontSize, _WHITE_, 0 )
		
		quickLabel( aFrame, "Target:", x1, y4, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, infoValues.targetAppStore, x2, y4, nil, meterFontSize, _WHITE_, 0 )

		quickLabel( aFrame, "UI Language:", x1, y5, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, system.getPreference( "ui", "language"), x2, y5, nil, meterFontSize, _WHITE_, 0 )

		quickLabel( aFrame, "Locale Info:", x1, y6, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, system.getPreference( "locale", "country") .. " : " .. 
			                system.getPreference( "locale", "identifier") .. "\n" .. 
			                system.getPreference( "locale", "language"),
							x2, y6, nil, meterFontSize * 0.85, _WHITE_, 0 )
	end
	--
	-- Architecture Info
	--
	if( infoEnable["ARC"]) then
		editFrame = editFrame+1
		infoFrames[#infoFrames+1] = display.newGroup()
		infoFrame:insert( infoFrames[#infoFrames] )

		aFrame = infoFrames[editFrame]
		local title =	quickLabel( aFrame, "Architecture Info (ARC)", x3, y0, nil, meterFontSize * 1.1, _ORANGE_, 0.5 )
		local lineWidth = title.contentWidth + 5
		local tmp = display.newLine( aFrame, -lineWidth/2 + title.x, 0, lineWidth/2 + title.x, 0 )
		tmp:setStrokeColor( unpack(_ORANGE_) )
		tmp.y = title.y + title.contentHeight/2
		
		quickLabel( aFrame, "Architecture: ", x1, y1, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, infoValues.architectureInfo, x2, y1, nil, meterFontSize, _WHITE_, 0 )
		
		quickLabel( aFrame, "Model: ", x1, y2, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, infoValues.model, x2, y2, nil, meterFontSize, _WHITE_, 0 )
		
		quickLabel( aFrame, "Platform:", x1, y3, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, infoValues.platformName .. " " .. infoValues.platformVersion, x2, y3, nil, meterFontSize, _WHITE_, 0 )
		
		quickLabel( aFrame, "Max Texture Size:", x1, y4, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, infoValues.maxTextureSize, x2, y4, nil, meterFontSize, _WHITE_, 0 )
		
		quickLabel( aFrame, "Max Texture Units:", x1, y5, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, infoValues.maxTextureUnits, x2, y5, nil, meterFontSize, _WHITE_, 0 )

		quickLabel( aFrame, "HP Shaders:", x1, y6, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, tostring(infoValues.gpuSupportsHighPrecisionFragmentShaders), x2, y6, nil, meterFontSize, _WHITE_, 0 )

		quickLabel( aFrame, "Image Suffix:", x1, y7, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, ternary(display.imageSuffix == nil, "none", display.imageSuffix), x2, y7, nil, meterFontSize, _WHITE_, 0 )
	end
	--
	-- Resolutions
	--
	if( infoEnable["RES"]) then
		editFrame = editFrame+1
		infoFrames[#infoFrames+1] = display.newGroup()
		infoFrame:insert( infoFrames[#infoFrames] )
		aFrame = infoFrames[editFrame]
		local title =	quickLabel( aFrame, "Resolutions (RES)", x3, y0, nil, meterFontSize * 1.1, _ORANGE_, 0.5 )
		local lineWidth = title.contentWidth + 5
		local tmp = display.newLine( aFrame, -lineWidth/2 + title.x, 0, lineWidth/2 + title.x, 0 )
		tmp:setStrokeColor( unpack(_ORANGE_) )
		tmp.y = title.y + title.contentHeight/2
		
		quickLabel( aFrame, "Design Size: ", x1, y1, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, "< " .. w .. ", " .. h .. " >", x2, y1, nil, meterFontSize, _WHITE_, 0 )
		
		quickLabel( aFrame, "Display Size: ", x1, y2, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, "< " .. displayWidth .. ", " .. displayHeight .. " >", x2, y2, nil, meterFontSize, _WHITE_, 0 )
		
		quickLabel( aFrame, "Excess Size:", x1, y3, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, "< " .. unusedWidth .. ", " .. unusedHeight .. " >" .. " " .. infoValues.platformVersion, x2, y3, nil, meterFontSize, _WHITE_, 0 )
		
		quickLabel( aFrame, "Scaling:", x1, y4, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, "< " .. round(scaleX,3) .. ", " .. round(scaleY,3) .. " >", x2, y4, nil, meterFontSize, _WHITE_, 0 )
		
		quickLabel( aFrame, "Device Size:", x1, y5, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, "< " .. deviceWidth .. ", " .. deviceHeight .. " >", x2, y5, nil, meterFontSize, _WHITE_, 0 )

		quickLabel( aFrame, "Screen Origin:", x1, y6, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, "< " .. display.screenOriginX .. ", " .. display.screenOriginY .. " >", x2, y6, nil, meterFontSize, _WHITE_, 0 )
	end

	--
	-- OS
	--
	if( infoEnable["OST"]) then
		editFrame = editFrame+1
		infoFrames[#infoFrames+1] = display.newGroup()
		infoFrame:insert( infoFrames[#infoFrames] )
		aFrame = infoFrames[editFrame]
		local title =	quickLabel( aFrame, "OS & Timer (OST)", x3, y0, nil, meterFontSize * 1.1, _ORANGE_, 0.5 )
		local lineWidth = title.contentWidth + 5
		local tmp = display.newLine( aFrame, -lineWidth/2 + title.x, 0, lineWidth/2 + title.x, 0 )
		tmp:setStrokeColor( unpack(_ORANGE_) )
		tmp.y = title.y + title.contentHeight/2

		quickLabel( aFrame, "OS Clock: ", x1, y1, nil, meterFontSize, _ORANGE_, 1 )
		local clock = quickLabel( aFrame, 0, x2, y1, nil, meterFontSize, _WHITE_, 0 )
		
		quickLabel( aFrame, "OS Date: ", x1, y2, nil, meterFontSize, _ORANGE_, 1 )
		local date = quickLabel( aFrame, 0, x2, y2, nil, meterFontSize, _WHITE_, 0 )
		
		quickLabel( aFrame, "OS Time (since 1970):", x1, y3, nil, meterFontSize, _ORANGE_, 1 )
		local time = quickLabel( aFrame, 0, x2, y3, nil, meterFontSize * 0.9, _WHITE_, 0 )

		quickLabel( aFrame, "System Timer (since start):", x1, y4, nil, meterFontSize, _ORANGE_, 1 )
		local aTimer = quickLabel( aFrame, "0", x2, y4, nil, meterFontSize, _WHITE_, 0 )

		aFrame.timer = function( )
			clock.text = os.clock()
			date.text = os.date("%c")
			time.text = os.time() .. " seconds"
			aTimer.text = getTimer() .. "ms / " .. round(getTimer()/1000,2) .. "s"
		end
		aFrame.timer()
		timer.performWithDelay( 200, aFrame, -1)
	end
	--
	-- OpenGL Info
	--
	if( infoEnable["OGI"]) then
		editFrame = editFrame+1
		infoFrames[#infoFrames+1] = display.newGroup()
		infoFrame:insert( infoFrames[#infoFrames] )
		aFrame = infoFrames[editFrame]

		local title =	quickLabel( aFrame, "OpenGL Info (OGI)", x3, y0, nil, meterFontSize * 1.1, _ORANGE_, 0.5 )
		local lineWidth = title.contentWidth + 5
		local tmp = display.newLine( aFrame, -lineWidth/2 + title.x, 0, lineWidth/2 + title.x, 0 )
		tmp:setStrokeColor( unpack(_ORANGE_) )
		tmp.y = title.y + title.contentHeight/2
		
		quickLabel( aFrame, "Vendor: ", x1, y1, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, infoValues.GL_VENDOR, x2, y1, nil, meterFontSize, _WHITE_, 0 )
		
		quickLabel( aFrame, "Renderer: ", x1, y2, nil, meterFontSize, _ORANGE_, 1 )
		--quickLabel( aFrame, infoValues.GL_RENDERER, x2, y2, nil, meterFontSize, _WHITE_, 0 )
		local tmp = display.newText( aFrame, infoValues.GL_RENDERER, x2, y2-4, 100, 30, native.systemFontBold, meterFontSize )
		tmp.anchorX = 0
		tmp.anchorY = 0
		
		quickLabel( aFrame, "Version:", x1, y4, nil, meterFontSize, _ORANGE_, 1 )
		--quickLabel( aFrame, infoValues.GL_VERSION .. " " .. infoValues.platformVersion, x2, y3, nil, meterFontSize, _WHITE_, 0 )
		local tmp = display.newText( aFrame, infoValues.GL_VERSION, x2, y4-4, 100, 30, native.systemFontBold, meterFontSize )
		tmp.anchorX = 0
		tmp.anchorY = 0
		
		quickLabel( aFrame, "Shading Lang. Version:", x1, y6, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, infoValues.GL_SHADING_LANGUAGE_VERSION, x2, y6, nil, meterFontSize, _WHITE_, 0 )
	end

	--
	-- OpenGL Extensions
	--
	if( infoEnable["OGE"]) then
		local maxSetLen = 380
		local tmpList = infoValues.GL_EXTENSIONS
		tmpList = tmpList:split( ' ' )

		local allElements = {}
		local elementSets = 1
		allElements[elementSets] = ""
		table.sort( tmpList, compare )
		for i=1, #tmpList do
			if(string.len( allElements[elementSets] ) == 0 ) then
				allElements[elementSets] = tmpList[i]
			else
				allElements[elementSets] = allElements[elementSets] ..", " .. tmpList[i]
			end	
			if( string.len(allElements[elementSets]) >= maxSetLen )	 then
				allElements[elementSets] = allElements[elementSets] .." ... "
				elementSets = elementSets + 1
				allElements[elementSets] = ""
			end	
		end	
		allElements[elementSets] = allElements[elementSets] .. "\n\nTotal: " .. #tmpList

		for i = 1, #allElements do
			editFrame = editFrame+1
			infoFrames[#infoFrames+1] = display.newGroup()
			infoFrame:insert( infoFrames[#infoFrames] )
			aFrame = infoFrames[editFrame]
			local title =	quickLabel( aFrame, "OpenGL Extenstions " .. i .. " of " .. #allElements .. " (OGE)", x3, y0, nil, meterFontSize * 0.8, _ORANGE_, 0.5 )
			local lineWidth = title.contentWidth + 5
			local tmp = display.newLine( aFrame, -lineWidth/2 + title.x, 0, lineWidth/2 + title.x, 0 )
			tmp:setStrokeColor( unpack(_ORANGE_) )
			tmp.y = title.y + title.contentHeight/2
			
			local tmp = display.newText( aFrame, allElements[i], 160, 155/2, 250, 95, native.systemFontBold, meterFontSize )
		end
	end


	--
	-- OS Specific Info
	--	
	if( onAndroid) then
		if( infoEnable["AND"]) then
			editFrame = editFrame+1
			infoFrames[#infoFrames+1] = display.newGroup()
			infoFrame:insert( infoFrames[#infoFrames] )
			aFrame = infoFrames[editFrame]
			local title =	quickLabel( aFrame, "Android Info 1 of 2 (AND)", x3, y0, nil, meterFontSize * 1.1, _ORANGE_, 0.5 )
			local lineWidth = title.contentWidth + 5
			local tmp = display.newLine( aFrame, -lineWidth/2 + title.x, 0, lineWidth/2 + title.x, 0 )
			tmp:setStrokeColor( unpack(_ORANGE_) )
			tmp.y = title.y + title.contentHeight/2

			quickLabel( aFrame, "App Version Code: ", x1, y1, nil, meterFontSize, _ORANGE_, 1 )
			quickLabel( aFrame, infoValues.androidAppVersionCode, x2, y1, nil, meterFontSize, _WHITE_, 0 )
			
			quickLabel( aFrame, "App Package Name: ", x1, y2, nil, meterFontSize, _ORANGE_, 1 )
			quickLabel( aFrame, infoValues.androidAppPackageName, x2, y2, nil, meterFontSize, _WHITE_, 0 )
			
			quickLabel( aFrame, "Display Approximate DPI:", x1, y3, nil, meterFontSize, _ORANGE_, 1 )
			quickLabel( aFrame, infoValues.androidDisplayApproximateDpi, x2, y3, nil, meterFontSize, _WHITE_, 0 )
			
			quickLabel( aFrame, "Display Density Name:", x1, y4, nil, meterFontSize, _ORANGE_, 1 )
			quickLabel( aFrame, infoValues.androidDisplayDensityName, x2, y4, nil, meterFontSize, _WHITE_, 0 )
			
			quickLabel( aFrame, "Display Width In Inches:", x1, y5, nil, meterFontSize, _ORANGE_, 1 )
			quickLabel( aFrame, round(infoValues.androidDisplayWidthInInches,3), x2, y5, nil, meterFontSize, _WHITE_, 0 )

			quickLabel( aFrame, "Display Height In Inches:", x1, y6, nil, meterFontSize, _ORANGE_, 1 )
			quickLabel( aFrame, round(infoValues.androidDisplayHeightInInches,3), x2, y6, nil, meterFontSize, _WHITE_, 0 )

			editFrame = editFrame+1
			infoFrames[#infoFrames+1] = display.newGroup()
			infoFrame:insert( infoFrames[#infoFrames] )
			aFrame = infoFrames[editFrame]
			local title =	quickLabel( aFrame, "Android Info 2 of 2 (AND)", x3, y0, nil, meterFontSize * 1.1, _ORANGE_, 0.5 )
			local lineWidth = title.contentWidth + 5
			local tmp = display.newLine( aFrame, -lineWidth/2 + title.x, 0, lineWidth/2 + title.x, 0 )
			tmp:setStrokeColor( unpack(_ORANGE_) )
			tmp.y = title.y + title.contentHeight/2

			quickLabel( aFrame, "Display X-DPI: ", x1, y1, nil, meterFontSize, _ORANGE_, 1 )
			quickLabel( aFrame, infoValues.androidDisplayXDpi, x2, y1, nil, meterFontSize, _WHITE_, 0 )
			
			quickLabel( aFrame, "Display Y-DPI: ", x1, y2, nil, meterFontSize, _ORANGE_, 1 )
			quickLabel( aFrame, infoValues.androidDisplayYDpi, x2, y2, nil, meterFontSize, _WHITE_, 0 )
			
		end
	elseif( oniOS ) then
		if( infoEnable["IOS"]) then
			editFrame = editFrame+1
			infoFrames[#infoFrames+1] = display.newGroup()
			infoFrame:insert( infoFrames[#infoFrames] )
			aFrame = infoFrames[editFrame]
			local title =	quickLabel( aFrame, "iOS Info (IOS)", x3, y0, nil, meterFontSize * 1.1, _ORANGE_, 0.5 )
			local lineWidth = title.contentWidth + 5
			local tmp = display.newLine( aFrame, -lineWidth/2 + title.x, 0, lineWidth/2 + title.x, 0 )
			tmp:setStrokeColor( unpack(_ORANGE_) )
			tmp.y = title.y + title.contentHeight/2

			quickLabel( aFrame, "Advertising Identifier: ", x1, y1, nil, meterFontSize, _ORANGE_, 1 )
			quickLabel( aFrame, infoValues.iosAdvertisingIdentifier, x2, y1, nil, meterFontSize * 0.8, _WHITE_, 0 )
			
			quickLabel( aFrame, "Advertising Tracking Enabled: ", x1, y2, nil, meterFontSize, _ORANGE_, 1 )
			quickLabel( aFrame, tostring(infoValues.iosAdvertisingTrackingEnabled), x2, y2, nil, meterFontSize, _WHITE_, 0 )
			
			quickLabel( aFrame, "Identifier for Vendor:", x1, y3, nil, meterFontSize, _ORANGE_, 1 )
			quickLabel( aFrame, infoValues.iosIdentifierForVendor, x2, y3, nil, meterFontSize * 0.8, _WHITE_, 0 )
		end		
	end

	-- Loaded Packages
	--	
	if( infoEnable["PKG"]) then
		local maxSetLen = 380
		local tmpList = {}
		for k,v in pairs(package.loaded) do
			tmpList[#tmpList+1] = k
		end	

		local allElements = {}
		local elementSets = 1
		allElements[elementSets] = ""
		table.sort( tmpList, compare )
		for i=1, #tmpList do
			if(string.len( allElements[elementSets] ) == 0 ) then
				allElements[elementSets] = tmpList[i]
			else
				allElements[elementSets] = allElements[elementSets] ..", " .. tmpList[i]
			end	
			if( string.len(allElements[elementSets]) >= maxSetLen )	 then
				allElements[elementSets] = allElements[elementSets] .." ... "
				elementSets = elementSets + 1
				allElements[elementSets] = ""
			end	
		end	
		allElements[elementSets] = allElements[elementSets] .. "\n\nTotal: " .. #tmpList

		for i = 1, #allElements do
			editFrame = editFrame+1
			infoFrames[#infoFrames+1] = display.newGroup()
			infoFrame:insert( infoFrames[#infoFrames] )
			aFrame = infoFrames[editFrame]
			local title =	quickLabel( aFrame, "Loaded Packages" .. i .. " of " .. #allElements .. " (PKG)", x3, y0, nil, meterFontSize * 0.9, _ORANGE_, 0.5 )
			local lineWidth = title.contentWidth + 5
			local tmp = display.newLine( aFrame, -lineWidth/2 + title.x, 0, lineWidth/2 + title.x, 0 )
			tmp:setStrokeColor( unpack(_ORANGE_) )
			tmp.y = title.y + title.contentHeight/2
			
			local tmp = display.newText( aFrame, allElements[i], 160, 155/2, 250, 95, native.systemFontBold, meterFontSize )
		end
	end

	--
	-- Directories
	--
	if( infoEnable["DIR"]) then
		editFrame = editFrame+1
		infoFrames[#infoFrames+1] = display.newGroup()
		infoFrame:insert( infoFrames[#infoFrames] )
		aFrame = infoFrames[editFrame]
		local title =	quickLabel( aFrame, "Directories (DIR)", x3, y0, nil, meterFontSize * 1.1, _ORANGE_, 0.5 )
		local lineWidth = title.contentWidth + 5
		local tmp = display.newLine( aFrame, -lineWidth/2 + title.x, 0, lineWidth/2 + title.x, 0 )
		tmp:setStrokeColor( unpack(_ORANGE_) )
		tmp.y = title.y + title.contentHeight/2

		local tmp = system.pathForFile( "", system.ResourceDirectory)
		if(tmp) then
			tmp = "present"
		else
			tmp = "not present"
		end
		quickLabel( aFrame, "Resource Directory: ", x1, y1, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, tmp, x2, y1, nil, meterFontSize, _WHITE_, 0 )


		local tmp = system.pathForFile( "", system.DocumentsDirectory)
		if(tmp) then
			tmp = "present"
		else
			tmp = "not present"
		end
		quickLabel( aFrame, "Documents Directory: ", x1, y2, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, tmp, x2, y2, nil, meterFontSize, _WHITE_, 0 )
		
		local tmp = system.pathForFile( "", system.CachesDirectory)
		if(tmp) then
			tmp = "present"
		else
			tmp = "not present"
		end
		quickLabel( aFrame, "Caches Directory:", x1, y3, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, tmp, x2, y3, nil, meterFontSize, _WHITE_, 0 )
		
		local tmp = system.pathForFile( "", system.DocumentsDirectory)
		if(tmp) then
			tmp = "present"
		else
			tmp = "not present"
		end
		quickLabel( aFrame, "Temporary Directory:", x1, y4, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, tmp, x2, y4, nil, meterFontSize, _WHITE_, 0 )
	end

	--
	-- Font Names
	if( infoEnable["FNT"]) then
		local maxSetLen = 380
		local tmpList = native.getFontNames()
		local tmpList2 = {}
		for i = 1, #tmpList do
			if( not strMatch( tmpList[i], "@") ) then 
				tmpList2[#tmpList2+1] = tmpList[i]

			end
		end
		tmpList = tmpList2
		local allElements = {}
		local elementSets = 1
		allElements[elementSets] = ""
		table.sort( tmpList, compare )
		for i=1, #tmpList do
			if(string.len( allElements[elementSets] ) == 0 ) then
				allElements[elementSets] = tmpList[i]
			else
				allElements[elementSets] = allElements[elementSets] ..", " .. tmpList[i]
			end	
			if( string.len(allElements[elementSets]) >= maxSetLen )	 then
				allElements[elementSets] = allElements[elementSets] .." ... "
				elementSets = elementSets + 1
				allElements[elementSets] = ""
			end	
		end	
		allElements[elementSets] = allElements[elementSets] .. "\n\nTotal: " .. #tmpList

		for i = 1, #allElements do
			editFrame = editFrame+1
			infoFrames[#infoFrames+1] = display.newGroup()
			infoFrame:insert( infoFrames[#infoFrames] )
			aFrame = infoFrames[editFrame]
			local title =	quickLabel( aFrame, "Fonts " .. i .. " of " .. #allElements .. " (FNT)", x3, y0, nil, meterFontSize * 1.1, _ORANGE_, 0.5 )
			local lineWidth = title.contentWidth + 5
			local tmp = display.newLine( aFrame, -lineWidth/2 + title.x, 0, lineWidth/2 + title.x, 0 )
			tmp:setStrokeColor( unpack(_ORANGE_) )
			tmp.y = title.y + title.contentHeight/2
			
			local tmp = display.newText( aFrame, allElements[i], 160, 155/2, 250, 95, native.systemFontBold, meterFontSize )
		end
	end

	--
	-- Media
	--
	if( infoEnable["MED"]) then
		local hasPhotoLibrary = ternary(media.hasSource( media.PhotoLibrary ), "Found", "Not Found")
		local hasCamera = ternary(media.hasSource( media.Camera ), "Found", "Not Found")
		local hasSavedPhotosAlbum = ternary(media.hasSource( media.SavedPhotosAlbum ), "Found", "Not Found")

		editFrame = editFrame+1
		infoFrames[#infoFrames+1] = display.newGroup()
		infoFrame:insert( infoFrames[#infoFrames] )
		aFrame = infoFrames[editFrame]
		local title =	quickLabel( aFrame, "Media (MED)", x3, y0, nil, meterFontSize * 1.1, _ORANGE_, 0.5 )
		local lineWidth = title.contentWidth + 5
		local tmp = display.newLine( aFrame, -lineWidth/2 + title.x, 0, lineWidth/2 + title.x, 0 )
		tmp:setStrokeColor( unpack(_ORANGE_) )
		tmp.y = title.y + title.contentHeight/2

		quickLabel( aFrame, "Camera: ", x1, y1, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, hasCamera, x2, y1, nil, meterFontSize, _WHITE_, 0 )
		
		quickLabel( aFrame, "Photo Library: ", x1, y2, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, hasPhotoLibrary, x2, y2, nil, meterFontSize, _WHITE_, 0 )
		
		quickLabel( aFrame, "Saved Photo Album:", x1, y3, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, hasSavedPhotosAlbum, x2, y3, nil, meterFontSize, _WHITE_, 0 )
	end
		

	--
	--  Native
	--
	if( infoEnable["POP"]) then
		local canShowPopupMail = ternary(native.canShowPopup("mail"), "Yes", "No")
		local canShowPopupAppStore = ternary(native.canShowPopup("appStore"), "Yes", "No")
		local canShowPopupRateApp = ternary(native.canShowPopup("rateApp"), "Yes", "No")
		local canShowPopupTwitter = ternary(native.canShowPopup("twitter"), "Yes", "No")
		local canShowPopupSMS = ternary(native.canShowPopup("sms"), "Yes", "No")
		local canShowPopupFacebook = ternary(native.canShowPopup("facebook"), "Yes", "No")

		editFrame = editFrame+1
		infoFrames[#infoFrames+1] = display.newGroup()
		infoFrame:insert( infoFrames[#infoFrames] )
		aFrame = infoFrames[editFrame]
		local title =	quickLabel( aFrame, "Native Popups (POP)", x3, y0, nil, meterFontSize * 1.1, _ORANGE_, 0.5 )
		local lineWidth = title.contentWidth + 5
		local tmp = display.newLine( aFrame, -lineWidth/2 + title.x, 0, lineWidth/2 + title.x, 0 )
		tmp:setStrokeColor( unpack(_ORANGE_) )
		tmp.y = title.y + title.contentHeight/2

		quickLabel( aFrame, "Mail: ", x1, y1, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, canShowPopupMail, x2, y1, nil, meterFontSize, _WHITE_, 0 )
		
		quickLabel( aFrame, "Facebook:", x1, y2, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, canShowPopupFacebook, x2, y2, nil, meterFontSize, _WHITE_, 0 )

		quickLabel( aFrame, "Twitter:", x1, y3, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, canShowPopupTwitter, x2, y3, nil, meterFontSize, _WHITE_, 0 )

		quickLabel( aFrame, "App Store: ", x1, y4, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, canShowPopupAppStore, x2, y4, nil, meterFontSize, _WHITE_, 0 )
		
		quickLabel( aFrame, "Rate App:", x1, y5, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, canShowPopupRateApp, x2, y5, nil, meterFontSize, _WHITE_, 0 )	
		
		quickLabel( aFrame, "SMS:", x1, y6, nil, meterFontSize, _ORANGE_, 1 )
		quickLabel( aFrame, canShowPopupSMS, x2, y6, nil, meterFontSize, _WHITE_, 0 )
	end

	--
	--  System Events
	--
	if( infoEnable["SYE"]) then
		local sysAccel = ternary(system.hasEventSource( "accelerometer" ), "Supported", "Not Supported")
		local sysGyro = ternary(system.hasEventSource( "gyroscope" ), "Supported", "Not Supported")
		local sysHeading = ternary(system.hasEventSource( "heading" ), "Supported", "Not Supported")
		local sysLocation = ternary(system.hasEventSource( "location" ), "Supported", "Not Supported")
		local sysMultitouch = ternary(system.hasEventSource( "multitouch" ), "Supported", "Not Supported")
		local sysOrient = ternary(system.hasEventSource( "orientation" ), "Supported", "Not Supported")

		-- All systems have these, no need to display:
		--local sysCollision = ternary(system.hasEventSource( "collision" ), "Yes", "No")
		--local sysPreCollision = ternary(system.hasEventSource( "preCollision" ), "Yes", "No")
		--local sysPreCollision = ternary(system.hasEventSource( "postCollision" ), "Yes", "No")	

		editFrame = editFrame+1
		infoFrames[#infoFrames+1] = display.newGroup()
		infoFrame:insert( infoFrames[#infoFrames] )

		aFrame = infoFrames[editFrame]
		local title =	quickLabel( aFrame, "System Events 1 of 2 (SYE)", x3, y0, nil, meterFontSize * 1.1, _ORANGE_, 0.5 )
		local lineWidth = title.contentWidth + 5
		local tmp = display.newLine( aFrame, -lineWidth/2 + title.x, 0, lineWidth/2 + title.x, 0 )
		tmp:setStrokeColor( unpack(_ORANGE_) )
		tmp.y = title.y + title.contentHeight/2

		quickLabel( aFrame, "Accelerometer Event:", x1, y1, nil, meterFontSize, _ORANGE_, 1 )
		local accelerometer = quickLabel( aFrame, sysAccel, x2, y1, nil, meterFontSize, _WHITE_, 0 )

		quickLabel( aFrame, "Gyroscope Event:", x1, y2, nil, meterFontSize, _ORANGE_, 1 )
		local gyroscope = quickLabel( aFrame, sysGyro, x2, y2, nil, meterFontSize, _WHITE_, 0 )
		
		quickLabel( aFrame, "Heading Event:", x1, y3, nil, meterFontSize, _ORANGE_, 1 )
		local heading = quickLabel( aFrame, sysHeading, x2, y3, nil, meterFontSize, _WHITE_, 0 )
		
		quickLabel( aFrame, "Multi-touch Event:", x1, y4, nil, meterFontSize, _ORANGE_, 1 )
		local multitouch = quickLabel( aFrame, sysMultitouch, x2, y4, nil, meterFontSize, _WHITE_, 0 )

		quickLabel( aFrame, "Orientation Event:", x1, y5, nil, meterFontSize, _ORANGE_, 1 )
		local orientation = quickLabel( aFrame, sysOrient, x2, y5, nil, meterFontSize, _WHITE_, 0 )

		aFrame.accelerometer = function( self, event )
			if(sysAccel == "Supported" ) then 
				accelerometer.text = "< " .. round(event.xInstant,2) .. ", ".. round(event.yInstant,2) .. ", " .. round(event.zInstant,2) .. ", ".. round(event.xGravity,2) .. " >"
			end
		end
		Runtime:addEventListener( "accelerometer", aFrame )


		aFrame.gyroscope = function( self, event )
			if(sysGyro == "Supported" ) then 
				gyroscope.text = "< " .. round(event.xRotation,2) .. ", ".. round(event.yRotation,2) .. ", " .. round(event.zRotation,2) ..  " >"
			end		
		end
		Runtime:addEventListener( "gyroscope", aFrame )
		

		local compassMode = "geo"
		aFrame.heading = function( self, event )
			if(sysHeading ~= "Supported") then return end
			local angleMag, angleGeo
			angleMag = event.magnetic
			if (not onAndroid ) then
				angleGeo = event.geographic
			else
				angleGeo = angleMag
			end
			
			if ( "geo" == compassMode ) then
				dstRotation = -angleGeo
			else
				dstRotation = -angleMag
			end
			
			-- Format strings as whole numbers
			local valueGeo = strFormat( '%.0f', angleGeo )
			local valueMag = strFormat( '%.0f', angleMag )

			heading.text  = "Geo:" .. valueGeo .. "°" .. " : "
							.. directionForAngle( angleGeo ) .. " || " ..
							"Mag:" .. valueMag .. "°" .. " : "
							.. directionForAngle( angleMag )
		end
		Runtime:addEventListener( "heading", aFrame )

		aFrame.orientation = function( self, event )
			if(sysOrient == "Supported" ) then orientation.text = system.orientation end
		end
		aFrame.orientation()
		Runtime:addEventListener( "orientation", aFrame )


		editFrame = editFrame+1
		infoFrames[#infoFrames+1] = display.newGroup()
		infoFrame:insert( infoFrames[#infoFrames] )

		aFrame = infoFrames[editFrame]
		local title =	quickLabel( aFrame, "System Events 2 of 2 (SYE)", x3, y0, nil, meterFontSize * 1.1, _ORANGE_, 0.5 )
		local lineWidth = title.contentWidth + 5
		local tmp = display.newLine( aFrame, -lineWidth/2 + title.x, 0, lineWidth/2 + title.x, 0 )
		tmp:setStrokeColor( unpack(_ORANGE_) )
		tmp.y = title.y + title.contentHeight/2

		quickLabel( aFrame, "Location Event:", x1, y1, nil, meterFontSize, _ORANGE_, 1 )
		--local location = quickLabel( aFrame, sysLocation, x1, y4, nil, meterFontSize, _WHITE_, 0.5 )
		local location = display.newText( aFrame, sysLocation, x1, y2, 160, 100, native.systemFontBold, meterFontSize * 0.9 )
		location.anchorY = 0
		location.anchorX = 0

		aFrame.location = function( self, event )
			if(sysLocation ~= "Supported") then return end
			-- Check for error (user may have turned off Location Services)
			if event.errorCode then
				location.text = "GPS Location Error: " .. tostring(event.errorMessage)
			else
			
				local latitudeText = strFormat( '%.4f', event.latitude )
				local longitudeText = strFormat( '%.4f', event.longitude )
				local altitudeText = strFormat( '%.3f', event.altitude )
				local accuracyText = strFormat( '%.3f', event.accuracy )
				local speedText = strFormat( '%.3f', event.speed )
				local directionText = strFormat( '%.3f', event.direction )
				location.text = "lattitude: " .. latitudeText ..	"\nlongitude: ".. longitudeText .. 
								"\naltitude: ".. altitudeText .. 
								"\nspeed: ".. speedText .. "\ndirection: ".. directionText .. 
								"\naccuracy: ".. accuracyText
			end
		end
		Runtime:addEventListener( "location", aFrame )
	end


	--
	-- Suffix Test
	--
	if( infoEnable["SFX"]) then
		local hasPhotoLibrary = ternary(media.hasSource( media.PhotoLibrary ), "Found", "Not Found")
		local hasCamera = ternary(media.hasSource( media.Camera ), "Found", "Not Found")
		local hasSavedPhotosAlbum = ternary(media.hasSource( media.SavedPhotosAlbum ), "Found", "Not Found")

		editFrame = editFrame+1
		infoFrames[#infoFrames+1] = display.newGroup()
		infoFrame:insert( infoFrames[#infoFrames] )
		aFrame = infoFrames[editFrame]
		local title =	quickLabel( aFrame, "Suffix Test (SFX)", x3, y0, nil, meterFontSize * 1.1, _ORANGE_, 0.5 )
		local lineWidth = title.contentWidth + 5
		local tmp = display.newLine( aFrame, -lineWidth/2 + title.x, 0, lineWidth/2 + title.x, 0 )
		tmp:setStrokeColor( unpack(_ORANGE_) )
		tmp.y = title.y + title.contentHeight/2

		local tmp = display.newImageRect( aFrame, "rgmeter/imageSuffix.png", 64, 64)
		tmp.x = x1
		tmp.y = y5

	end
		



	--
	-- Set visibility of frames.  Default to first frame.
	--
	for i = 1, #infoFrames do
		infoFrames[i].isVisible = false
		local tmp =	quickLabel( infoFrames[i], "(" .. i .. "/" .. #infoFrames .. ")", x4, y0, nil, 9 * fontSM, _GREY_, 1 )
	end
	local curFrame = 1 
	aFrame = infoFrames[curFrame]
	if(aFrame) then aFrame.isVisible = true end

	local function onTouch( self, event )
		aFrame = infoFrames[curFrame] 
		if(aFrame) then aFrame.isVisible = false end
		curFrame = curFrame + self.dir
		if(curFrame < 1) then curFrame = 1 end
		if(curFrame > #infoFrames) then curFrame = #infoFrames end
		aFrame = infoFrames[curFrame] 
		if(aFrame) then aFrame.isVisible = true end
		return false
	end

	local left = newImage( infoFrame, "rgmeter/-.png",  17, 155/2, { w = 54, h = 49, scale = 0.5 })
	left.dir = -1
	easyPushButton( left, onTouch, { normalScale = 0.5, pressedScale = 0.48, scaleTime = 50 } )

	local right = newImage( infoFrame, "rgmeter/+.png",  320 - 15, 155/2, { w = 54, h = 49, scale = 0.5 })
	right.dir = 1
	easyPushButton( right, onTouch, { normalScale = 0.5, pressedScale = 0.48, scaleTime = 50 } )

	return infoFrame
end



local function createDbgMeter( group, width, height )

	-- ==
	--    Main Mem Meter
	-- ==
	local dbgFrame = display.newGroup()
	group:insert( dbgFrame )

	local totalDebugMeters = 2
	
	local infoFrames = {}
	local aFrame

	local meterFontSize = 9 * fontSM
	
	local ySep = 15.5
	local y0 = 9
	local y1 = 32
	local y2 = y1 + ySep
	local y3 = y2 + ySep
	local y4 = y3 + ySep
	local y5 = y4 + ySep
	local y6 = y5 + ySep
	local y7 = y6 + ySep
	local y8 = y7 + ySep

	local x1 = 157.5
	local x2 = x1 + 5
	local x3 = 220
	local x4 = 315

	local editFrame = 0

	local bFontSize = 10
	local bWidth = 40
	local bHeight = 22
	local bWidth2 = bWidth/2
	local bHeight2 = bHeight/2
	local hsep = 10
	local hsep2 = hsep/2
	local vsep = 5

	--
	-- Physics
	--
	if(  dbgEnable["PHY"]) then

		local physics 	= require "physics"
		local pstart 	= physics.start
		local pstop 	= physics.stop 
		local ppause 	= physics.pause
		local pdraw 	= physics.setDrawMode 
		local psetg 	= physics.setGravity

		local currentDrawMode = "normal"
		local currentPhysicsState = "off"

		local tmp =	quickLabel( dbgFrame, "RG Super Meter " .. relVer .. " " .. relDate, 4, y0, nil, 9 * fontSM, _GREY_, 0 )

		editFrame = editFrame+1
		infoFrames[#infoFrames+1] = display.newGroup()
		dbgFrame:insert( infoFrames[#infoFrames] )
		aFrame = infoFrames[editFrame]
		local title =	quickLabel( aFrame, "Physics Control (PHY)", x3, y0, nil, meterFontSize * 1.1, _ORANGE_, 0.5 )
		local lineWidth = title.contentWidth + 5
		local tmp = display.newLine( aFrame, -lineWidth/2 + title.x, 0, lineWidth/2 + title.x, 0 )
		tmp:setStrokeColor( unpack(_ORANGE_) )
		tmp.y = title.y + title.contentHeight/2
		local tmp =	quickLabel( aFrame, "(" .. editFrame .. "/" .. totalDebugMeters .. ")", x4, y0, nil, 9 * fontSM, _GREY_, 1 )

		quickLabel( aFrame, "Physics State:" , x1, y1, nil, meterFontSize, _ORANGE_, 1 )
		local physicsState = quickLabel( aFrame, "Off", x2, y1, nil, meterFontSize, _WHITE_, 0 )
		
		quickLabel( aFrame, "Draw Mode: ", x1, y2, nil, meterFontSize, _ORANGE_, 1 )
		local physicsDrawMode = quickLabel( aFrame, "Off", x2, y2, nil, meterFontSize, _WHITE_, 0 )
		
		quickLabel( aFrame, "Gravity:", x1, y3, nil, meterFontSize, _ORANGE_, 1 )
		local gravity = quickLabel( aFrame, "Off", x2, y3, nil, meterFontSize, _WHITE_, 0 )

		-- 
		-- Physics buttons
		--
		local startStopButton
		local pauseButton
		local drawButton
		local function onTouch( self, event )
			if(self.label.text == "Start") then				
				physics.start()
			
			elseif(self.label.text == "Stop") then
				physics.stop()
			
			elseif(self.label.text == "Pause" ) then
				physics.pause()
			
			elseif(self.label.text == "normal") then
				physics.setDrawMode( "normal" )
			
			elseif(self.label.text == "hybrid") then
				physics.setDrawMode( "hybrid" )
			end
			return true
		end

		startStopButton = newImage( aFrame, "rgmeter/blank.png", 85,  90, { w = 129, h = 49, scale = 0.5, label = "Start", labelSize = 20 })
		easyPushButton( startStopButton, onTouch, { normalScale = 0.5, pressedScale = 0.48, scaleTime = 50 } )

		pauseButton = newImage( aFrame, "rgmeter/blank.png", startStopButton.x + startStopButton.contentWidth + hsep,  startStopButton.y, { w = 129, h = 49, scale = 0.5, label = "Pause", labelSize = 20 })
		easyPushButton( pauseButton, onTouch, { normalScale = 0.5, pressedScale = 0.48, scaleTime = 50 } )

		drawButton = newImage( aFrame, "rgmeter/blank.png", pauseButton.x + pauseButton.contentWidth + hsep,  startStopButton.y, { w = 129, h = 49, scale = 0.5, label = "hybrid", labelSize = 20 })
		easyPushButton( drawButton, onTouch, { normalScale = 0.5, pressedScale = 0.48, scaleTime = 50 } )


		physics.start = function()
			pstart()
			currentPhysicsState = "on"
			physicsState.text = "On"
			startStopButton.label.text = "Stop"
			physicsDrawMode.text = currentDrawMode
			local gx,gy = physics.getGravity()
			gravity.text = "< " .. round(gx,2) .. ", " .. round(gy,2) .. " >"
			return true
		end

		physics.stop = function()
			pstop()
			currentPhysicsState = "off"
			physicsState.text = "Off"
			startStopButton.label.text = "Start"
			gravity.text = "Off"
			return true
		end

		physics.pause = function()
			if( currentPhysicsState ~= "on" ) then 
				print( "WARNING!!! - Please (re-) start physics before pausing.")
				return false 
			end
			ppause()
			currentPhysicsState = "paused"
			physicsState.text = "Paused"
			physicsDrawMode.text = "Paused"
			startStopButton.label.text = "Start"
			gravity.text = "Paused"
			return true
		end

		physics.setDrawMode = function( mode )
			if( currentPhysicsState ~= "on" ) then 
				print( "WARNING!!! - Please start physics before changing draw mode.")
				return false 
			end
			if( mode == "debug" ) then
				print( "WARNING!!! physics.setDrawMode('debug') not supported while using RG Super meter. Changing to 'hybrid'")
				mode = "hybrid"
			end
			pdraw(mode)
			currentDrawMode = mode
			physicsDrawMode.text = currentDrawMode
			if( mode  == "normal" ) then
				drawButton.label.text = "hybrid"
			else
				drawButton.label.text = "normal"
			end
			return true
		end

		physics.setGravity = function(x,y)
			if( currentPhysicsState ~= "on" ) then 
				print( "WARNING!!! - Please (re-) start physics before setting gravity.")
				return false 
			end
			psetg(x,y)
			local gx,gy = physics.getGravity()
			gravity.text = "< " .. round(gx,2) .. ", " .. round(gy,2) .. " >"
			return true
		end
	end


	--
	-- Snapshot
	--
	if(  dbgEnable["CAP"]) then

		local tmp =	quickLabel( dbgFrame, "RG Super Meter " .. relVer .. " " .. relDate, 4, y0, nil, 9 * fontSM, _GREY_, 0 )

		editFrame = editFrame+1
		infoFrames[#infoFrames+1] = display.newGroup()
		dbgFrame:insert( infoFrames[#infoFrames] )
		aFrame = infoFrames[editFrame]
		local title =	quickLabel( aFrame, "Capture (CAP)", x3, y0, nil, meterFontSize * 1.1, _ORANGE_, 0.5 )
		local lineWidth = title.contentWidth + 5
		local tmp = display.newLine( aFrame, -lineWidth/2 + title.x, 0, lineWidth/2 + title.x, 0 )
		tmp:setStrokeColor( unpack(_ORANGE_) )
		tmp.y = title.y + title.contentHeight/2
		local tmp =	quickLabel( aFrame, "(" .. editFrame .. "/" .. totalDebugMeters .. ")", x4, y0, nil, 9 * fontSM, _GREY_, 1 )

		quickLabel( aFrame, "Press 'Full' to capture full screen." , 40, 25, nil, meterFontSize, _ORANGE_, 0 )
		quickLabel( aFrame, "Press 'Bounded', then drag-and-release to capture partial-screen." , 40, 120, nil, meterFontSize, _ORANGE_, 0 )

		-- 
		-- Snapshot buttons
		--
		local canShowPopupMail = ternary(native.canShowPopup("mail"), "Yes", "No")
		local lastSnap
		local previewWidth = 100
		local previewHeight = 60
		local fullScreenSnap
		local boundedSnap
		local emailSnapButton
		local deleteSnapButton
		local theRGMeter = aFrame.parent.parent

		local function captureBoundedWithDelay()			
			theRGMeter.isVisible = false
			local dragCatcher = display.newRect( 0, 0, w * 2, h * 2)
			dragCatcher.x = centerX
			dragCatcher.y = centerY
			dragCatcher.alpha =  0.005
			dragCatcher.touch = function( self, event )			
				if( event.phase == "began") then
				elseif( event.phase == "moved") then
					if( self.selRect ) then
						display.remove( self.selRect )
					end
					self.selRect = display.newRect( event.xStart, event.yStart, event.x-event.xStart, event.y-event.yStart )
					self.selRect.anchorX = 0
					self.selRect.anchorY= 0
					self.selRect:setFillColor( unpack( _TRANSPARENT_ ))
					self.selRect:setStrokeColor( unpack( _RED_ ))
					self.selRect.strokeWidth = 2

				elseif( event.phase == "ended") then
					display.remove(self.selRect)
					timer.performWithDelay(50, function () display.remove(self) end )

					display.remove(lastSnap)
					lastSnap = nil
				    lastSnap = display.captureBounds( { xMin = event.xStart, xMax = event.x, yMin = event.yStart, yMax = event.y }, true)
				    if( lastSnap ) then
				    	lastSnap.x = 1000000
				    	lastSnap.y = 1000000
				    	timer.performWithDelay(50, function()
							lastSnap.x = centerX
				    		lastSnap.y = centerY
				    		display.save( lastSnap, "rgScreenGrab.jpg", system.DocumentsDirectory )
						    local scale = previewWidth/lastSnap.contentWidth
						    local scale2 = previewHeight/lastSnap.contentHeight
						    if( scale > scale2 ) then
						    	lastSnap:scale(scale2,scale2)
						    else
						    	lastSnap:scale(scale,scale)
						    end
						    aFrame:insert( lastSnap )
						    lastSnap.x = 200
						    lastSnap.y = 155/2
			    		end )
					else
						lastSnap = quickLabel( aFrame, "Bounds too small. Try again." , 0, 0, nil, meterFontSize, _RED_, 0.5 )
					    lastSnap.x = 200
					    lastSnap.y = 155/2
					end
				    --lastSnap.strokeWidth = 8
				    --lastSnap:setStrokeColor( unpack( _LIGHTGREY_ ) )
				    theRGMeter.isVisible = true

				end
				return true
			end
			dragCatcher:addEventListener( "touch", dragCatcher)
		end


		local function captureWithDelay()			
			theRGMeter.isVisible = false
			display.remove(lastSnap)
			lastSnap = nil
		    lastSnap = display.captureScreen( true )
	    	lastSnap.x = 1000000
	    	lastSnap.y = 1000000
	    	lastSnap:scale(0.25,0.25)
	    	timer.performWithDelay(50, function()
				lastSnap.x = centerX
	    		lastSnap.y = centerY
	    		display.save( lastSnap, "rgScreenGrab.jpg", system.DocumentsDirectory )
			    local scale = previewWidth/lastSnap.contentWidth
			    lastSnap:scale(scale,scale)
			    aFrame:insert( lastSnap )
			    lastSnap.x = 200
			    lastSnap.y = 155/2
			    --lastSnap.strokeWidth = 8
			    --lastSnap:setStrokeColor( unpack( _LIGHTGREY_ ) )
	    		end )
		    theRGMeter.isVisible = true
		end

		local function onTouch( self, event )
			if(self.label.text == "Full") then										
				timer.performWithDelay( 100, captureWithDelay )
				if(canShowPopupMail) then 
					emailSnapButton.isVisible = true 
					emailSnapButton.label.isVisible = true 
				end
				deleteSnapButton.isVisible = true
				deleteSnapButton.label.isVisible = true

			elseif(self.label.text == "Bounded") then
				timer.performWithDelay( 100, captureBoundedWithDelay )
				if(canShowPopupMail) then 
					emailSnapButton.isVisible = true 
					emailSnapButton.label.isVisible = true 
				end
				deleteSnapButton.isVisible = true
				deleteSnapButton.label.isVisible = true

			elseif(self.label.text == "e-mail") then
				local options =
				{
				   to = { defaultEmail },
				   subject = "Screen Capture: " .. currentAppName,
				   isBodyHtml = false,
				   body = "This image captured " .. os.date("%c"),
				   attachment =
				   {
				      { baseDir=system.DocumentsDirectory, filename="rgScreenGrab.jpg", type="image" },
				   },
				}
				native.showPopup("mail", options)

			elseif(self.label.text == "Delete") then
				display.remove(lastSnap)
				lastSnap = nil
				if(canShowPopupMail) then 
					emailSnapButton.isVisible = false 
					emailSnapButton.label.isVisible = false 
				end
				deleteSnapButton.isVisible = false
				deleteSnapButton.label.isVisible = false

			end
			return true
		end

		fullScreenSnap = newImage( aFrame, "rgmeter/blank.png", 85,  45, { w = 129, h = 49, scale = 0.4, label = "Full", labelSize = 20 })
		easyPushButton( fullScreenSnap, onTouch, { normalScale = 0.4, pressedScale = 0.38, scaleTime = 50 } )
		
		boundedSnap = newImage( aFrame, "rgmeter/blank.png", 85, fullScreenSnap.y + fullScreenSnap.contentHeight, { w = 129, h = 49, scale = 0.4, label = "Bounded", labelSize = 20 })
		easyPushButton( boundedSnap, onTouch, { normalScale = 0.4, pressedScale = 0.38, scaleTime = 50 } )

		emailSnapButton = newImage( aFrame, "rgmeter/blank.png", 85, boundedSnap.y + boundedSnap.contentHeight, { w = 129, h = 49, scale = 0.4, label = "e-mail", labelSize = 20 })
		easyPushButton( emailSnapButton, onTouch, { normalScale = 0.4, pressedScale = 0.38, scaleTime = 50 } )
		emailSnapButton.isVisible = false
		emailSnapButton.label.isVisible = false

		deleteSnapButton = newImage( aFrame, "rgmeter/blank.png", 85, emailSnapButton.y + emailSnapButton.contentHeight, { w = 129, h = 49, scale = 0.4, label = "Delete", labelSize = 20 })
		easyPushButton( deleteSnapButton, onTouch, { normalScale = 0.4, pressedScale = 0.38, scaleTime = 50 } )
		deleteSnapButton.isVisible = false
		deleteSnapButton.label.isVisible = false

	end


	--
	-- Set visibility of frames.  Default to first frame.
	--
	for i = 1, #infoFrames do
		infoFrames[i].isVisible = false
	end
	local curFrame = 1
	aFrame = infoFrames[curFrame] 
	if(aFrame) then aFrame.isVisible = true end


	local function onTouch2( self, event )
		aFrame = infoFrames[curFrame] 
		if(aFrame) then aFrame.isVisible = false end
		curFrame = curFrame + self.dir
		if(curFrame < 1) then curFrame = 1 end
		if(curFrame > #infoFrames) then curFrame = #infoFrames end
		aFrame = infoFrames[curFrame] 
		if(aFrame) then aFrame.isVisible = true end
		return false
	end

	local left = newImage( dbgFrame, "rgmeter/-.png",  17, 155/2, { w = 54, h = 49, scale = 0.5 })
	left.dir = -1
	easyPushButton( left, onTouch2, { normalScale = 0.5, pressedScale = 0.48, scaleTime = 50 } )

	local right = newImage( dbgFrame, "rgmeter/+.png",  320 - 15, 155/2, { w = 54, h = 49, scale = 0.5 })
	right.dir = 1
	easyPushButton( right, onTouch2, { normalScale = 0.5, pressedScale = 0.48, scaleTime = 50 } )

	return dbgFrame
end




local function createRGMeter( x, y, width, refUL, startMinimized )
	local x = x or centerX 
	local y = y or centerY
	local refUL = refUL or false
	local width = width or 320
	local scale = width/320

	local meterWidth = 320
	local meterHeight = 155

	local meterList = {}
	local buttonList = {}


	local allMeters = display.newGroup()

	local back1 = display.newImageRect( allMeters, "rgmeter/back.png", meterWidth, meterHeight)
	back1.anchorX = 0
	back1.anchorY = 0

	local back2 = display.newImageRect( allMeters, "rgmeter/back2.png", meterWidth, meterHeight)
	back2.anchorX = 0
	back2.anchorY = 0


	local fpsMeter = createFPSMeter( allMeters, meterWidth, meterHeight)
	meterList[fpsMeter] = fpsMeter
	fpsMeter.myBack = back2
	fpsMeter.name = "fpsMeter"

	local mmMeter = createMainMemMeter( allMeters, meterWidth, meterHeight)
	meterList[mmMeter] = mmMeter
	mmMeter.myBack = back2
	mmMeter.name = "mmMeter"

	local vmMeter = createVideoMemMeter( allMeters, meterWidth, meterHeight)
	meterList[vmMeter] = vmMeter
	vmMeter.myBack = back2
	vmMeter.name = "vmMeter"

	local infoMeter = createinfoMeter( allMeters, meterWidth, meterHeight)
	meterList[infoMeter] = infoMeter
	infoMeter.myBack = back1
	infoMeter.name = "infoMeter"

	local dbgMeter = createDbgMeter( allMeters, meterWidth, meterHeight)
	meterList[dbgMeter] = dbgMeter
	dbgMeter.myBack = back1
	dbgMeter.name = "dbgMeter"

	for k,v in pairs( meterList ) do
		v.isVisible = false
		v.myBack.isVisible = false
	end
	fpsMeter.isVisible = true
	fpsMeter.myBack.isVisible = true
	--mmMeter.isVisible = true
	--mmMeter.myBack.isVisible = true
	--infoMeter.isVisible = true
	--infoMeter.myBack.isVisible = true
	--dbgMeter.isVisible = true
	--dbgMeter.myBack.isVisible = true

	-- 
	-- Meter Buttons
	--
	local bFontSize = 10
	local bWidth = 30
	local bHeight = 22
	local bWidth2 = bWidth/2
	local bHeight2 = bHeight/2
	local hsep = 2
	local hsep2 = hsep/2
	local vsep = 1.5

	local function onTouch( self, event )
		for k,v in pairs(meterList) do
			v.isVisible = false
			v.myBack.isVisible = false
		end

		for k,v in pairs(buttonList) do
			v:setFillColor(unpack(_GREY_))
		end

		self.myMeter.myBack.isVisible = true

		self:setFillColor(unpack(_WHITE_))
		self.myMeter.isVisible = true
		return true
	end


	local shrinkToX = w - 40
	local shrinkToY = h - 40

	local function onShrink( self, event )
		if(event.phase == "ended") then
			allMeters.xScaleStart = allMeters.xScale
			allMeters.yScaleStart = allMeters.yScale

			allMeters.xHideStart = allMeters.x
			allMeters.yHideStart = allMeters.y

			local xScale = 40 / (allMeters.w0/allMeters.xScale)
			local yScale = 40 / (allMeters.h0/allMeters.yScale)
			transition.to(allMeters, {x = shrinkToX, y = shrinkToY, xScale = xScale, yScale = yScale, time = 250 } )
			transition.to(allMeters.icon, { alpha = 1, time = 250 } )

			allMeters.icon.touch = function(self, event)
				if(event.phase == "began") then
					display.getCurrentStage():setFocus(event.target, event.id)
					allMeters.x0 = allMeters.x
					allMeters.y0 = allMeters.y				

				elseif(event.phase == "moved" ) then
					if( event.x < leftBuffer or event.x  > rightBuffer or event.y < topBuffer or event.y > botBuffer ) then
						return true
					end

					if( not self.inDrag ) then
						local dx = event.x - event.xStart
						local dy = event.y - event.yStart

						if(dx * dx + dy * dy >= 100) then	
							self.inDrag = true
						end
					end

					if( self.inDrag ) then
						allMeters.x = allMeters.x0 + event.x - event.xStart
						allMeters.y = allMeters.y0 + event.y - event.yStart
					end

				elseif(event.phase == "ended" ) then
					display.getCurrentStage():setFocus(event.target, nil)

					if( not self.inDrag ) then
						shrinkToX = allMeters.x
						shrinkToY = allMeters.y
						self:removeEventListener( "touch", allMeters.icon )
						transition.to(allMeters, { x = allMeters.xHideStart, y = allMeters.yHideStart, xScale = allMeters.xScaleStart, yScale = allMeters.yScaleStart, time = 250 } )
						transition.to(allMeters.icon, { alpha = 0, time = 250 } )
					end

					self.inDrag = false
				end
				return true		
			end
			allMeters.icon:addEventListener( "touch", allMeters.icon )

		end

		return true
	end
	local function onExpand( self, event )		


		if( allMeters.xScale == allMeters.xScale0 ) then
			local myWidth = allMeters.contentWidth
			local scale = displayWidth/myWidth
			allMeters.x1 = allMeters.x
			allMeters.y1 = allMeters.y
			allMeters.xScale = scale
			allMeters.yScale = scale

			if(refUL) then
				allMeters.x = 0 
				allMeters.y = 0 
			else
				allMeters.x = centerX - allMeters.contentWidth/2
				allMeters.y = centerY - allMeters.contentHeight/2
			end
		else
			allMeters.xScale = allMeters.xScale0
			allMeters.yScale = allMeters.yScale0
			allMeters.x = allMeters.x1
			allMeters.y = allMeters.y1
		end
		return true
	end

	local fpsButton = newImage( allMeters, "rgmeter/fps.png", hsep + 1, meterHeight - vsep, { w = 106, h = 49, scale = 0.4, anchorX = 0, anchorY = 1 })
	buttonList[fpsButton] = fpsButton
	fpsButton.myMeter = fpsMeter
	easyPushButton( fpsButton, onTouch, { normalScale = 0.4, pressedScale = 0.38, scaleTime = 50 } )

	local mainMemButton = newImage( allMeters, "rgmeter/mem.png", fpsButton.x + fpsButton.contentWidth + hsep2, fpsButton.y, { w = 120, h = 49, scale = 0.4, anchorX = 0, anchorY = 1 })
	buttonList[mainMemButton] = mainMemButton
	mainMemButton.myMeter = mmMeter
	easyPushButton( mainMemButton, onTouch, { normalScale = 0.4, pressedScale = 0.38, scaleTime = 50 } )
	mainMemButton:setFillColor(unpack(_GREY_))

	local videoMemButton = newImage( allMeters, "rgmeter/vmem.png", mainMemButton.x + mainMemButton.contentWidth + hsep2, fpsButton.y, { w = 148, h = 49, scale = 0.4, anchorX = 0, anchorY = 1 })
	buttonList[videoMemButton] = videoMemButton
	videoMemButton.myMeter = vmMeter
	easyPushButton( videoMemButton, onTouch, { normalScale = 0.4, pressedScale = 0.38, scaleTime = 50 } )
	videoMemButton:setFillColor(unpack(_GREY_))

	local infoButton = newImage( allMeters, "rgmeter/info.png", videoMemButton.x + videoMemButton.contentWidth + hsep2, fpsButton.y, { w = 126, h = 49, scale = 0.4, anchorX = 0, anchorY = 1 })
	buttonList[infoButton] = infoButton
	infoButton.myMeter = infoMeter
	easyPushButton( infoButton, onTouch, { normalScale = 0.4, pressedScale = 0.38, scaleTime = 50 } )
	infoButton:setFillColor(unpack(_GREY_))

	local dbgButton = newImage( allMeters, "rgmeter/dbg.png", infoButton.x + infoButton.contentWidth + hsep2, fpsButton.y, { w = 138, h = 49, scale = 0.4, anchorX = 0, anchorY = 1 })
	buttonList[dbgButton] = dbgButton
	dbgButton.myMeter = dbgMeter
	easyPushButton( dbgButton, onTouch, { normalScale = 0.4, pressedScale = 0.38, scaleTime = 50 } )
	dbgButton:setFillColor(unpack(_GREY_))

	local hideButton = newImage( allMeters, "rgmeter/hide.png", dbgButton.x + dbgButton.contentWidth + hsep * 1.5, fpsButton.y, { w = 54, h = 49, scale = 0.5, anchorX = 0, anchorY = 1 })
	easyPushButton( hideButton, onShrink, { normalScale = 0.5, pressedScale = 0.48, scaleTime = 50 } )

	local expandButton = newImage( allMeters, "rgmeter/expand.png", hideButton.x + hideButton.contentWidth + hsep, fpsButton.y, { w = 54, h = 49, scale = 0.5, anchorX = 0, anchorY = 1 })
	easyPushButton( expandButton, onExpand, { normalScale = 0.5, pressedScale = 0.48, scaleTime = 50 } )


	allMeters:scale(scale, scale)
	
	if(refUL) then
		allMeters.x = x 
		allMeters.y = y 
	else
		allMeters.x = x - allMeters.contentWidth/2
		allMeters.y = y - allMeters.contentHeight/2
	end

	allMeters.xScale0 = allMeters.xScale
	allMeters.yScale0 = allMeters.yScale

	allMeters.w0 = allMeters.contentWidth
	allMeters.h0 = allMeters.contentWidth

	local tmp = display.newImageRect( allMeters, "rgmeter/icon.png", meterWidth, meterHeight)
	tmp.x = meterWidth/2
	tmp.y = meterHeight/2
	tmp.alpha = 0
	allMeters.icon = tmp

	allMeters.touch = onDrag
	allMeters:addEventListener( "touch", allMeters )

	allMeters.enterFrame = function()
		allMeters:toFront()
	end
	Runtime:addEventListener( "enterFrame", allMeters )

	if(startMinimized) then
		onShrink( hideButton, { phase = "ended"})
	end

	return allMeters
end



local public = {}
public.create = createRGMeter

public.setNumTicks = function( ticks )
	if(not ticks or ticks < 1) then	
		numTicks = 30
	else
		numTicks = size
	end
end

public.setAverageWindow = function( size )
	if(not size or size < 1) then	
		averageWindow = 30
	else
		averageWindow = size
	end
end

public.setUpdatePeriod = function( period )
	if(not period or period < 1) then	
		updatePeriod = 1
	else
		updatePeriod = period
	end
end

public.setMaxMainMem = function( size )
	if(not size or size < 1) then	
		maxMainMem = 2048 -- KB ( i.e. 2MB)
	else
		maxMainMem = size
	end

	targetMainMem = maxMainMem
end

public.setMaxVidMem = function( size )
	if(not size or size < 1) then	
		maxVidMem = system.getInfo( "maxTextureSize" )
	else
		maxVidMem = size
	end

	targetVidMem = maxVidMem
end

public.enableCollection = function( enable )
	allowCollect = enable or false
end

public.setFontScale = function( scale )
	fontSM = fnn( scale, fontSM, 1)
end


public.enableInfo = function( name, enable )
	infoEnable[name] = enable 
end

public.minimizeInfo = function( )
	infoEnable["GEN"] = true
	infoEnable["ARC"] = true
	infoEnable["RES"] = true
	infoEnable["OST"] = false
	infoEnable["OGI"] = false
	infoEnable["OGE"] = false
	infoEnable["AND"] = false
	infoEnable["IOS"] = false
	infoEnable["PKG"] = false
	infoEnable["DIR"] = false
	infoEnable["FNT"] = false
	infoEnable["MED"] = false
	infoEnable["POP"] = false
	infoEnable["SYE"] = false
	infoEnable["SFX"] = false
end

public.enableDbg = function( name, enable )
	dbgEnable[name] = enable 
end

public.setDefaultEmail = function( emailURL )
	defaultEmail = emailURL
end

public.setAppName = function( name )
	currentAppName = name
end


return public



