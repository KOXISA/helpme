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

--- Middleclass library.
local class = require( "puggle.ext.middleclass" )

--- Class creation.
local Sound = class( "Sound" )

--- Required libraries.

--- Localised functions.

--- Enumerated values.
Sound.Format = {}
Sound.Format.Wav = "wav"
Sound.Format.Mp3 = "mp3"
Sound.Format.Ogg = "ogg"
Sound.Format.Aac = "aac"
Sound.Format.Caf = "caf"
Sound.Format.Aif = "aif"

--- Initiates a new Sound object.
-- @param params Paramater table for the object.
-- @return The new object.
function Sound:initialize( params )

	-- Set the name of this manager
	self.name = "sound"

	-- Initiate the required data
	self._sounds = {}

	-- Set the default sound format
	self:setDefaultFormat( Sound.Format.Wav )

	-- The lowest available channel for the sounds
	self._lowestChannel = 2

	-- The highest available channel for the sounds
	self._highestChannel = 32

end

--- Post init function for the Sound manager.
function Sound:postInit()

	-- If the volume has been set before, then set it back to that now
	if puggle.data:isSet( "puggle-sound-volume" ) then
		self:setVolume( puggle.data:get( "puggle-sound-volume" ) )
	end

end

--- Adds a sound.
-- @param name The name of the sound.
-- @param path The path to the sound file.
-- @param baseDir The directory that the file resides in. Optional, defaults to system.ResourceDirectory.
-- @return True if it was added, false otherwise.
function Sound:add( name, path, baseDir, lazyLoading )

	self._sounds[ name ] = self._sounds[ name ] or {}

	local sound
	if lazyLoading then
		sound = { path = path, baseDir = baseDir, lazyLoading = lazyLoading }
	else
		sound = audio.loadSound( path, baseDir or system.ResourceDirectory )
	end
	self._sounds[ name ][ puggle.utils:getExtensionFromFilename( path ) ] = sound

end

--- Gets a sound.
-- @param name The name of the sound.
-- @return The sound handle.
function Sound:get( name, format )

	format = format or self:getDefaultFormat()

	local sound = self._sounds[ name ][ format ]

	if sound and type( sound ) == "table" and sound.lazyLoading then
		self._sounds[ name ][ format ] = audio.loadSound( sound.path, sound.baseDir or system.ResourceDirectory )
		sound = self._sounds[ name ][ format ]
	end

	return sound

end

--- Removes a sound.
-- @param name The name of the sound.
-- @param format The format to remove. Optional, defaults to all of them.
-- @return True if it was removed, false otherwise.
function Sound:remove( name, format )

	-- If a format has been set, then only remove the sound associated with that format specifically
	if format then

		if self:get( name, format ) then

			audio.dispose( self._sounds[ name ][ format ] )

			self._sounds[ name ][ format ] = nil

			return true

		end

	else -- No format has been set, so loop through all of them and remove all the sounds

		for _, format in pairs( Sound.Format ) do
			if not self:remove( name, format ) then
				return false
			end
		end

		return true

	end

	return false

end

--- Plays a sound.
-- @param name The name of the sound.
-- @param options The options for the playing. Optional, defaults to none.
-- @return True if it was played, false otherwise.
function Sound:play( name, options, format )

	local options = options or {}

	local channel, handle

	local cachedOnComplete = options.onComplete
	local onPlayComplete = function( event )

		if al then
			al.Source( handle, al.PITCH, 1 )
		end
		
		if cachedOnComplete and type( cachedOnComplete ) == "function" then
			cachedOnComplete( event )
		end

	end

	channel, handle = audio.play( self:get( name, format ), options )
	if channel and channel ~= 0 and options.volume then
		audio.setVolume( options.volume, { channel = channel } )
	end

	if al then
		al.Source( handle, al.PITCH, options.pitch or 1 )
	end

	return channel, handle

end

--- Sets the volume for sounds.
-- @param level The volume level.
function Sound:setVolume( level )

	-- Set the volume on all channels
	for i = self._lowestChannel, self._highestChannel, 1 do
		audio.setVolume( level, { channel = i } )
	end

	-- Save out the volume level
	puggle.data:set( "puggle-sound-volume", level )

end

--- Gets the volume for sounds.
-- @return The volume.
function Sound:getVolume()
	return audio.getVolume{ channel = self._lowestChannel }
end

--- Sets the default format for sounds.
-- @param format The format, options are enumerated as puggle.sound.Format.
function Sound:setDefaultFormat( format )
	self._defaultFormat = format
end

--- Gets the default format for sounds.
-- @return The format.
function Sound:getDefaultFormat()
	return self._defaultFormat
end

--- Destroys this Sound object.
function Sound:destroy()
	for name, _ in pairs( self._sounds ) do
		self:remove( name )
	end
end

--- Return the Sound class definition.
return Sound
