--[[
The MIT License (MIT)
Copyright (c) 2017 Graham Ranson - www.grahamranson.co.uk / @GrahamRanson

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

-- Safe require function
require( "puggle.ext.saferequire" )

-- Middleclass library.
local class = require( "puggle.ext.middleclass" )

--- Class creation.
local Core = class( "Core" )

--- Required libraries.

--- Localised functions.
local remove = table.remove

--- Initiates a new Core object.
-- @param params Paramater table for the object.
-- @return The new object.
function Core:initialize( params )

	display.setStatusBar( display.HiddenStatusBar )

	-- Table to hold all loaded systems
	self._systems = {}

	-- Load a system.
	local loadSystem = function( name )
		self[ name ] = require( "puggle.systems." .. name ):new()
		self._systems[ #self._systems + 1 ] = self[ name ]
	end

	-- Puggle systems
	loadSystem( "utils" )
	loadSystem( "data" )

	loadSystem( "achievements" )
	loadSystem( "adid" )
	loadSystem( "adverts" )
	loadSystem( "analytics" )
	loadSystem( "audio" )
	loadSystem( "battery" )
	loadSystem( "cloud" )
	loadSystem( "collision" )
	loadSystem( "colour" )
	loadSystem( "config" )
	loadSystem( "cursor" )
	loadSystem( "encryption" )
	loadSystem( "facebook" )
	loadSystem( "file" )
	loadSystem( "font" )
	loadSystem( "gameNetwork" )
	loadSystem( "input" )
	loadSystem( "instagram" )
	loadSystem( "language" )
	loadSystem( "leaderboards" )
	loadSystem( "maths" )
	loadSystem( "mouse" )
	loadSystem( "music" )
	loadSystem( "network" )
	loadSystem( "pasteboard" )
	loadSystem( "promocode" )
	loadSystem( "random" )
	loadSystem( "score" )
	loadSystem( "sound" )
	loadSystem( "steam" )
	loadSystem( "store" )
	loadSystem( "social" )
	loadSystem( "system" )
	loadSystem( "time" )
	loadSystem( "timer" )
	loadSystem( "transition" )
	loadSystem( "twitter" )
	loadSystem( "udid" )
	loadSystem( "uuid" )
	loadSystem( "worldtime" )
	loadSystem( "zip" )

	if self.system:isIOS() then
		loadSystem( "gameCentre" )
	elseif self.system:isKindle() then
		loadSystem( "gameCircle" )
	elseif self.system:isAndroid() then
		loadSystem( "gpgs" )
	end

	self.GameObject = require( "puggle.gameObject" )
	self.class = class

	self.Playlist = require( "puggle.playlist" )
	self.Shaker = require( "puggle.shaker" )
	self.Map = require( "puggle.map" )

	self._gameObjects = {}

	self._cameras = {}

	if self.system:isTV() then
		system.setIdleTimer( false )
	end

	if self.system:isAndroid() then
		local licensing = require( "licensing" )
		licensing.init( "google" )
	end

	if self.system:isMobile() then
		loadSystem( "admob" )
	end

	Runtime:addEventListener( "enterFrame", self )

end

--- Call 'postInit' on all managers.
function Core:postInit()

	for i = 1, #self._systems, 1 do
		if self._systems[ i ][ "postInit" ] then
			self._systems[ i ]:postInit()
		end
	end

	self:setPrimaryCamera( self:createCamera() )

	for i = 1, #self._cameras, 1 do
		--self._cameras[ i ]:postInit()
	end

end

--- Handler for the 'enterFrame' event.
-- @param event The event table.
function Core:enterFrame( event )

	self.time:enterFrame( event )

	if self.system:isSimulator() and self.input:isButtonPressed( "screenshot" ) then
		if self._justTookScreenshot then
			self._justTookScreenshot = false
		else
			self._justTookScreenshot = true
			display.remove( display.captureScreen( true ) )
		end
	end

	if self:isPaused() then
		self.input:update( self.time:delta() )
		self.mouse:update( self.time:delta() )
	else

		for i = 1, #self._systems, 1 do

			-- Increment the lifetime frames of this system
			self._systems[ i ]._lifetimeFrames = ( self._systems[ i ]._lifetimeFrames or 0 ) + 1

			if self._systems[ i ][ "update" ] then
				self._systems[ i ]:update( self.time:delta() )
			end

		end

		for i = #self._cameras, 1, -1 do

			-- Has this camera been destroyed?
			if self._cameras[ i ]._destroyed then

				local c = remove( self._cameras, i )
				c = nil

			else -- If not then update away!

				-- Increment the lifetime frames of this system
				self._cameras[ i ]._lifetimeFrames = ( self._cameras[ i ]._lifetimeFrames or 0 ) + 1

				-- Update the camera
				self._cameras[ i ]:update( self.time:delta() )

			end

		end

		for i = #self._gameObjects, 1, -1 do
			if self._gameObjects[ i ] and self._gameObjects[ i ][ "markedForRemoval" ] then
				if self._gameObjects[ i ]:markedForRemoval() then
					local ob = remove( self._gameObjects, i )
					ob:destroy()
					ob = nil
				else
					if self._gameObjects[ i ][ "update" ] then
						self._gameObjects[ i ]:update( self.time:delta() )
					end
				end
			else
				remove( self._gameObjects, i )
			end
		end

	end

	collectgarbage()

end

function Core:createCamera()
	self._cameras[ #self._cameras + 1 ] = require( "puggle.systems.camera" ):new()
	self._cameras[ #self._cameras ]:postInit()
	return self._cameras[ #self._cameras ]
end

function Core:setPrimaryCamera( camera )
	self.camera = camera
end

--- Add a GameObject to the system.
-- @param object The object to add.
function Core:addGameObject( object )
	self._gameObjects[ #self._gameObjects + 1 ] = object
end

--- Destroy all game objects that have been added to the system.
function Core:destroyAllGameObjects()
	for i = #self._gameObjects, 1, -1 do
		local ob = remove( self._gameObjects, i )
		ob:destroy()
		ob = nil
	end
end

function Core:zSortGroup( displayGroup )

	--local displayGroup = display.getCurrentStage()

	local objects = {}

	for i = 1, displayGroup.numChildren, 1 do
		objects[ #objects + 1 ] = { displayGroup[ i ].y + displayGroup[ i ].height / 2, displayGroup[ i ] }
	end

	self:insertionSort( objects )

	for i = 1, #objects, 1 do
		displayGroup:insert( objects[ i ][ 2 ] )
	end

end

function Core:insertionSort( array )

	local len = #array
	local j

	for j = 2, len, 1 do

		local key = {}

		key = array[ j ]

		local i = j - 1

		while i > 0 and array[ i ][ 1 ] > key[ 1 ] + 1 do
			array[ i + 1 ] = array[ i ]
			i = i - 1
		end

		array[ i + 1 ] = key

	end

	return array

end

-- Pause the puggle library.
function Core:pause()
	self._isPaused = true
	if physics then
		physics.pause()
	end
	for i = 1, #self._systems, 1 do
		if self._systems[ i ][ "onPause" ] then
			self._systems[ i ]:onPause()
		end
	end
end

-- Resume the puggle library.
function Core:resume()
	self._isPaused = false
	if physics then
		physics.start()
	end
	for i = 1, #self._systems, 1 do
		if self._systems[ i ][ "onResume" ] then
			self._systems[ i ]:onResume()
		end
	end
end

-- Checks if the puggle library is paused.
-- @return True if it is, false otherwise.
function Core:isPaused()
	return self._isPaused
end

-- Toggles the pausing/resuming the puggle library.
function Core:togglePause()
	if self:isPaused() then
		self:resume()
	else
		self:pause()
	end
end

--- Destroys this Core object.
function Core:destroy()

	Runtime:removeEventListener( "enterFrame", self )

	for i = 1, #self._systems, 1 do
		local system = remove( self._systems, i )
		system:destroy()
		system = nil
	end

	self._systems = nil

end

--- Return the Core class definition.
puggle = Core:new()

-- Call the postInit function automatically
puggle:postInit()
