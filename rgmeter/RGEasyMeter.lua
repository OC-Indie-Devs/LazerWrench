-- =============================================================
-- Copyright Roaming Gamer, LLC. 2009-2014 
-- =============================================================
-- Core Library Extentions (Loader)
-- =============================================================
-- Note: Modify code below if you put libraries in alternate folder.
-- =============================================================
local easyPush = require "rgmeter.RGEasyPush"

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

local getTimer 			= system.getTimer
local sysGetInfo		= system.getInfo
local strMatch 			= string.match
local strFormat 		= string.format


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


local function newMeter( group, x, y, w, h, ticks, params ) -- suffix, div, suffix2  )
	local group = group or display.currentStage
	local x = x or 0
	local y = y or 0
	local w = w or 240
	local h = h or 100
	local ticks = ticks or 60
	local tickSep = w/ticks
	local tickWidth = tickSep/2
	local suffix = params.suffix or ""
	local suffix2 = params.suffix2 or ""
	local div = params.div or 0
	local fontSM = params.fontSM or 1
	local tickColor = params.tickColor or _WHITE_
	local showLabels = fnn(params.showLabels,true)
	local linkedMeter = params.linkedMeter

	local meter = display.newGroup()
	group:insert( meter )

	local startX 	= x+ tickSep/2 	
	local startY 	= y + h  
	local endY		= y + 0  
	local curX 		= startX

	meter.tickValues = {}	
	meter.ticks = {}

	meter.sideLabels = {}

	meter.min = 0
	meter.max = 0
	meter.maxTicks = ticks

	for i = ticks, 1, -1 do
		--meter.ticks[i] = display.newLine( meter, curX, startY, curX, endY )
		meter.ticks[i] = display.newImageRect( meter, "rgmeter/tick.png", tickWidth, startY - endY )
		meter.ticks[i].x = curX
		meter.ticks[i].y = startY
		curX = curX + tickSep	
		meter.ticks[i].anchorY = 1
		meter.ticks[i].y0  = meter.ticks[i].y
		meter.ticks[i]:setFillColor( unpack(tickColor) )
	end

	local frame = display.newRect( meter, 0, 0, w, h)	
	meter.frame = frame
	frame.anchorX = 0
	frame.anchorY = 0
	frame.x = x 
	frame.y = y + 1
	frame:setFillColor( unpack( _TRANSPARENT_ ))
	frame:setStrokeColor( unpack( _LIGHTGREY_ ))
	frame.strokeWidth = 2

	local tmp = display.newText( meter, "Min: ", 14, frame.y + frame.contentHeight + 8, native.systemFont, 8  * fontSM )
	meter.curMinLabel = display.newText( meter, tostring(0) .. suffix, tmp.x + tmp.contentWidth/2 + 2, tmp.y, native.systemFont, 8  * fontSM )
	meter.curMinLabel.anchorX = 0

	local tmp = display.newText( meter, "Max: ", meter.curMinLabel.x + 65, frame.y + frame.contentHeight + 8, native.systemFont, 8  * fontSM )
	meter.curMaxLabel = display.newText( meter, tostring(0) .. suffix, tmp.x + tmp.contentWidth/2 + 2, tmp.y, native.systemFont, 8  * fontSM )
	meter.curMaxLabel.anchorX = 0

	local tmp = display.newText( meter, "Avg: ", meter.curMaxLabel.x + 65, frame.y + frame.contentHeight + 8, native.systemFont, 8  * fontSM )
	meter.curAvgLabel = display.newText( meter, tostring(0) .. suffix, tmp.x + tmp.contentWidth/2 + 2, tmp.y, native.systemFont, 8  * fontSM )
	meter.curAvgLabel.anchorX = 0


	meter.sideLabels[1] = display.newText( meter, "---" .. suffix, frame.x + frame.contentWidth + 5, frame.y, native.systemFont, 7  * fontSM )
	meter.sideLabels[1].anchorX = 0

	meter.sideLabels[2] = display.newText( meter, "---" .. suffix, frame.x + frame.contentWidth + 5, frame.y + frame.contentHeight/3, native.systemFont, 7  * fontSM )
	meter.sideLabels[2].anchorX = 0

	meter.sideLabels[3] = display.newText( meter, "---" .. suffix, frame.x + frame.contentWidth + 5, frame.y + 2 * frame.contentHeight/3, native.systemFont, 7  * fontSM )
	meter.sideLabels[3].anchorX = 0

	meter.sideLabels[4] = display.newText( meter, "---" .. suffix, frame.x + frame.contentWidth + 5, frame.y + frame.contentHeight, native.systemFont, 7  * fontSM )
	meter.sideLabels[4].anchorX = 0

	meter.showLabels = function( self, show )
		showLabels = show

		self.curMinLabel.isVisible = showLabels
		self.curMaxLabel.isVisible = showLabels
		self.curAvgLabel.isVisible = showLabels
		meter.sideLabels[1].isVisible = showLabels
		meter.sideLabels[2].isVisible = showLabels
		meter.sideLabels[3].isVisible = showLabels
		meter.sideLabels[4].isVisible = showLabels

	end

	meter.setMinMaxDiv = function( self, min, max, newdiv )
		local min = round(min)
		local max = round(max)
		self.min = min
		self.max = max
		
		if(newdiv) then div = newdiv end

		local delta = max - min

		if( div == 0 ) then
			meter.sideLabels[1].text = tostring(max) .. suffix
			meter.sideLabels[2].text = tostring( round(min + 2 * delta/ 3,2)) .. suffix
			meter.sideLabels[3].text = tostring( round(min + 1 * delta/ 3,2)).. suffix
			meter.sideLabels[4].text = tostring(min) .. suffix
		else
			meter.sideLabels[1].text = tostring( round(max/div,2)) .. suffix2
			meter.sideLabels[2].text = tostring( round( (min + 2 * delta/ 3)/div,2)) .. suffix2
			meter.sideLabels[3].text = tostring( round( (min + 1 * delta/ 3)/div,2)).. suffix2
			meter.sideLabels[4].text = tostring(round(min/div,2)) .. suffix2
		end

		if( linkedMeter ) then 
			linkedMeter:setMinMaxDiv( min, max, newdiv )
		end
	end


	meter.redraw = function( self, min, max, avg )
		local min = min or self.min
		local max = max or self.max
		local avg = avg or self.min
		for i = 1, #self.ticks do
			local aTick = self.ticks[i]
			aTick.yScale = 0.01
		end

		for i = 1, #self.tickValues do
			local value = self.tickValues[i]
			local scale = 0.01
			local color = tickColor
			if( value < self.min ) then 
				scale = 0.01
			elseif( value > self.max ) then
				color = _PINK_
				scale = 1
			else
				scale = (value - self.min) / (self.max - self.min)
			end

			if( scale <= 0 ) then
				scale = 0.01
			end
			local aTick = self.ticks[i]
			aTick.yScale = scale
			aTick:setFillColor( unpack( color ) )
			aTick.y = aTick.y0
		end

		local scale = 0.01
		if( avg < self.min ) then 
			scale = 0.01
		elseif( avg > self.max ) then
			scale = 1
		else
			scale = (avg - self.min) / (self.max - self.min)
		end

		if( div == 0 ) then
			self.curMinLabel.text = tostring(round(min,1)) .. suffix
			self.curMaxLabel.text = tostring(round(max,1)) .. suffix
			self.curAvgLabel.text = tostring(round(avg,1)) .. suffix
		else
			self.curMinLabel.text = tostring(round(min/div,2)) .. suffix2
			self.curMaxLabel.text = tostring(round(max/div,2)) .. suffix2
			self.curAvgLabel.text = tostring(round(avg/div,2)) .. suffix2
		end	

	end

	meter.addValue = function( self, newValue )
		table.insert( self.tickValues, 1,  newValue )
		while(#self.tickValues > self.maxTicks ) do
			table.remove( self.tickValues, self.maxTicks + 1 )
		end
	end

	--if( showLabels ) then

		local function onTouch( self, event )
			if(self.dir == 1) then
				local newMax = round(meter.max * 1.25,0)
				meter:setMinMaxDiv( meter.min, newMax )
			else
				local newMax = round(meter.max * 0.8,0)
				if( newMax == 0 ) then newMax = meter.Max end
				meter:setMinMaxDiv( meter.min, newMax )
			end
			return false
		end

		local incrButton = newImage( meter, "rgmeter/+.png", frame.x + frame.contentWidth + 60, frame.y + 25, { w = 54, h = 49, scale = 0.5 })
		incrButton.dir = 1
		easyPushButton( incrButton, onTouch, { normalScale = 0.5, pressedScale = 0.48, scaleTime = 50 } )

		local decrButton = newImage( meter, "rgmeter/-.png", frame.x + frame.contentWidth + 60, incrButton.y + 25, { w = 54, h = 49, scale = 0.5 })
		decrButton.dir = -1
		easyPushButton( decrButton, onTouch, { normalScale = 0.5, pressedScale = 0.48, scaleTime = 50 } )
	--end

	meter:showLabels( showLabels )

	meter:setMinMaxDiv( 0, 100 )

	frame.contentHeight0 = frame.contentHeight

	return meter
end

public = {}
public.newMeter = newMeter
return public