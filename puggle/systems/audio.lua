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
local Audio = class( "Audio" )

--- Required libraries.

--- Localised functions.

--- Initiates a new Audio object.
-- @param params Paramater table for the object.
-- @return The new object.
function Audio:initialize( params )

	-- Set the name of this manager
	self.name = "audio"

end

--- Post init function for the Audio manager.
function Audio:postInit()

	-- If the volume has been set before, then set it back to that now
	if puggle.data:isSet( "puggle-audio-volume" ) then
		self:setVolume( puggle.data:get( "puggle-audio-volume" ) )
	end

	-- If the game was muted on last play, then mute now on startup
	if self:isMuted() then
		self:mute()
	end

end

--- Mutes all audio.
function Audio:mute()

	-- Only store out the pre-mute volume if the game isn't already muted
	if not puggle.data:get( "puggle-audio-muted" ) then
		puggle.data:set( "puggle-audio-preMuteVolume", self:getVolume() )
	end

	-- Set the master volume to 0
	self:setVolume( 0 )

	-- Mark the audio as muted
	puggle.data:set( "puggle-audio-muted", true )

end

--- Unmutes all audio.
function Audio:unmute()

	-- Set the master volume back to the pre-mute level
	self:setVolume( puggle.data:get( "puggle-audio-preMuteVolume" ) or 1 )

	-- Remove the pre-mute volume level
	puggle.data:set( "puggle-audio-preMuteVolume", nil )

	-- Mark the audio as unmuted
	puggle.data:set( "puggle-audio-muted", false )

end

--- Checks if the audio is muted.
-- @return True if it is muted, false otherwise.
function Audio:isMuted()
	return puggle.data:get( "puggle-audio-muted" )
end

--- Toggles the audio from mute to unmute and vice-versa.
-- @return True if it is now muted, false otherwise.
function Audio:toggleMute()

	if self:isMuted() then
		self:unmute()
	else
		self:mute()
	end

	return self:isMuted()

end

--- Sets the master volume for all audio.
-- @param level The volume level.
function Audio:setVolume( level )

	-- Set the volume on all channels
	audio.setVolume( level )

	-- Save out the volume level
	puggle.data:set( "puggle-audio-volume", level )

end

--- Gets the volume for sounds.
-- @return The volume.
function Audio:getVolume()
	return audio.getVolume()
end

--- Destroys this Audio object.
function Audio:destroy()

end

--- Return the Audio class definition.
return Audio
