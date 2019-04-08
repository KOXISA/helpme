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
local Music = class( "Music" )

--- Required libraries.

--- Localised functions.

--- Initiates a new Music object.
-- @param params Paramater table for the object.
-- @return The new object.
function Music:initialize( params )

	-- Set the name of this manager
	self.name = "music"

	-- Initiate the required data
	self._tracks = {}

	-- Reserve some channels
	audio.reserveChannels( 1 )

	-- The lowest available channel for the music
	self._lowestChannel = 1

	-- The highest available channel for the music
	self._highestChannel = 1

end

--- Post init function for the Music manager.
function Music:postInit()

	-- If the volume has been set before, then set it back to that now
	if puggle.data:isSet( "puggle-music-volume" ) then
		self:setVolume( puggle.data:get( "puggle-music-volume" ) )
	end

end

--- Adds a music track.
-- @param name The name of the track.
-- @param path The path to the track file.
-- @param baseDir The directory that the file resides in. Optional, defaults to system.ResourceDirectory.
-- @return True if it was added, false otherwise.
function Music:add( name, path, baseDir )
	self._tracks[ name ] = self._tracks[ name ] or {}
	self._tracks[ name ].path = path
	self._tracks[ name ].baseDir = baseDir or system.ResourceDirectory
	self._tracks[ name ].isLoaded = false
end

--- Loads a music track.
-- @param name The name of the track.
-- @return True if it was loaded, false otherwise.
function Music:load( name )

	-- Check that the track has been added but not yet loaded
	if self:get( name ) and not self:loaded( name ) then

		-- True to load the track
		self._tracks[ name ].handle = audio.loadStream( self._tracks[ name ].path, self._tracks[ name ].baseDir )

		-- Check to see if it was loaded
		if self._tracks[ name ].handle then
			self._tracks[ name ].isLoaded = true
			return true
		end

	end

end

--- Gets a Track.
-- @param name The name of the track.
-- @return The track handle data.
function Music:get( name )
	return self._tracks[ name ]
end

--- Checks if a Track has been loaded.
-- @param name The name of the track.
-- @return True it it has been, false otherwise.
function Music:loaded( name )
	return self:get( name ) and self:get( name ).isLoaded
end

--- Plays a track. Will automatically load it if it hasn't already been.
-- @param name The name of the track.
-- @param options Table of options for the playing.
-- @return True it it started playing, false otherwise.
function Music:play( name, options )

	-- Check if the track has been added
	if self:get( name ) then

		-- If it hasn't already been loaded, then load it
		if not self:loaded( name ) then
			self:load( name )
		end

		-- Check if the load was successful
		if self:loaded( name ) then

			-- Force the music channel
			options = options or {}
			options.channel = 1

			-- Try to play the track
			self._tracks[ name ].channel = audio.play( self:get( name ).handle, options )

			-- Check if the track was played succesfully
			if self._tracks[ name ].channel then
				return true
			end

		end

	end

end

--- Stops a currently playing track.
-- @param name The name of the track.
-- @return True it it has been stopped, false otherwise.
function Music:stop( name )

	-- Check if the track has been added
	if self:get( name ) then

		-- Check if the track has been loaded
		if self:loaded( name ) then

			-- Stop the track
			local channels = audio.stop( self._tracks[ name ].channel )

			-- Nil out the stored channel
			self._tracks[ name ].channel = nil

			return channels > 0

		end

	end

end

--- Pauses a currently playing track.
-- @param name The name of the track.
-- @return True it it has been paused, false otherwise.
function Music:pause( name )

	-- Check if the track has been added
	if self:get( name ) then

		-- Check if the track has been loaded
		if self:loaded( name ) then

			-- Pause the track
			return audio.pause( self._tracks[ name ].channel ) > 0

		end

	end

end

--- Resumes a currently playing track.
-- @param name The name of the track.
-- @return True it it has been paused, false otherwise.
function Music:resume( name )

	-- Check if the track has been added
	if self:get( name ) then

		-- Check if the track has been loaded
		if self:loaded( name ) then

			-- Resume the track
			return audio.resume( self._tracks[ name ].channel ) > 0

		end

	end

end

--- Rewinds a currently playing track.
-- @param name The name of the track.
-- @return True it it has been rewound, false otherwise.
function Music:rewind( name )

	-- Check if the track has been added
	if self:get( name ) then

		-- Check if the track has been loaded
		if self:loaded( name ) then

			-- Rewind the track
			return audio.rewind{ channel = self._tracks[ name ].channel }

		end

	end

end

--- Unload a track. Will automatically stop it for you.
-- @param name The name of the track.
-- @return True it it was unloaded, false otherwise.
function Music:unload( name )

	-- Check if the track has been added
	if self:get( name ) then

		-- Check if the track has been loaded
		if self:loaded( name ) then

			-- Stop the track first
			self:stop( name )

			-- Dispose of the track handle
			audio.dispose( self._tracks[ name ].handle )

			-- Nil out the stored handle
			self._tracks[ name ].handle = nil

			-- Mark it as unloded
			self._tracks[ name ].isLoaded = false

			return true

		end

	end

end

--- Sets the volume for music.
-- @param level The volume level.
function Music:setVolume( level )

	-- Set the volume on all channels
	for i = self._lowestChannel, self._highestChannel, 1 do
		audio.setVolume( level, { channel = i } )
	end

	-- Save out the volume level
	puggle.data:set( "puggle-music-volume", level )

end

--- Gets the volume for music.
-- @return The volume.
function Music:getVolume()
	return audio.getVolume{ channel = self._lowestChannel }
end

--- Gets the total number of tracks that have been added to the system.
-- @return The count.
function Music:count()
	local count = 0
	for k, v in pairs( self._tracks ) do
		count = count + 1
	end
	return count
end

--- Destroys this Music object.
function Music:destroy()

	for k, v in pairs( self._tracks ) do
		self:unload( k )
	end
	self._tracks = nil

end

--- Return the Music class definition.
return Music
