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
local Playlist = class( "Playlist" )

--- Required libraries.

--- Localised functions.

--- Initiates a new Playlist object.
-- @param params Paramater table for the object.
-- @return The new object.
function Playlist:initialize( params )

    self._tracks = {}

    self._originalChannel = params.channel
    self._onTrackChange = params.onTrackChange

    self:setName( params.name or puggle.random:string( 10 ) )

    if params and params.tracks then
        self._tracks = params.tracks
        for i = 1, #self._tracks, 1 do
            if type( self._tracks[ i ] ) == "string" then
                self._tracks[ i ] = { name = self._tracks[ i ], isSound = false }
            end
        end
    end

    self._index = 1

    self.onComplete = function( event )
        if event.completed and not self:isPaused() then
            self:next()
            self:play()
            if self._onTrackChange and type( self._onTrackChange ) == "function" then
                self._onTrackChange()
            end
        end
    end

end

--- Adds a track to this playlist.
-- @param name The name of the pre-added song or sound file.
-- @param isSound True if the track is a sound, false if it is a stream. Defaults to false.
function Playlist:add( name, isSound, format )
    self._tracks[ #self._tracks + 1 ] = { name = name, isSound = isSound, format = format }
end

--- Gets the number of tracks in this playlist.
-- @return The count.
function Playlist:count()
    return #self._tracks
end


--- Plays this playlist.
-- @param volume The volume to start this playlist at. Optional, defaults to the current for the channel.
function Playlist:play( volume )

    local track = self._tracks[ self:getTrack() ]

    if track then
        if track.isSound then
            self._channel, self._handle = puggle.sound:play( track.name, { channel = self._originalChannel, onComplete = self.onComplete, volume = volume }, track.format )
        else
            self._channel, self._handle = puggle.music:play( track.name, { channel = self._originalChannel, onComplete = self.onComplete, volume = volume } )
        end
    end

    self._isPlaying = self._channel and self._channel ~= 0

end

--- Pauses this playlist.
function Playlist:pause()

    local track = self._tracks[ self:getTrack() ]
    if track.isSound then

    else
        puggle.music:pause( track.name )
    end

    self._isPaused = true

end

--- Resumes this playlist.
function Playlist:resume()

    local track = self._tracks[ self:getTrack() ]
    if track.isSound then
        self:next()
        self:play()
    else
        puggle.music:resume( track.name )
    end

    self._isPaused = false

end

--- Stops this playlist.
function Playlist:stop()

    local track = self._tracks[ self:getTrack() ]
    if track.isSound then

    else
        puggle.music:stop( track.name )
    end

    self._channel = nil
    self._handle = nil

    self._isPlaying = false

end

--- Rewinds this playlist.
function Playlist:rewind()

    local track = self._tracks[ self:getTrack() ]
    if track.isSound then

    else
        puggle.music:rewind( track.name )
    end

end

--- Moves to the next track in this playlist.
-- @param dontRewindTrack Setting this to true will mean the current track isn't rewound when the next track is started. Optional, defaults to false.
function Playlist:next( dontRewindTrack )

    local index

    if self:isRandom() then

        index = puggle.random:inRange( 1, self:count() )

        while self:getTrack() and self:getTrack() == index do
            index = puggle.random:inRange( 1, self:count() )
        end

    else
        index = self:getTrack() + 1
        if index > self:count() then
            index = 1
        end
    end

    if index then
        if not dontRewindTrack then
            self:rewind()
        end
        self:setTrack( index )
    end

end

--- Moves to the previous track in this playlist.
-- @param dontRewindTrack Setting this to true will mean the current track isn't rewound when the previous track is started. Optional, defaults to false.
function Playlist:previous( dontRewindTrack )

    local index

    if self:isRandom() then

        index = puggle.random:inRange( 1, self:count() )

        while self:getTrack() and self:getTrack() == index do
            index = puggle.random:inRange( 1, self:count() )
        end

    else
        index = self:getTrack() - 1
        if index < 1 then
            index = self:count()
        end
    end

    if index then
        if not dontRewindTrack then
            self:rewind()
        end
        self:setTrack( index )
    end

end

--- Shuffles this playlist.
function Playlist:shuffle()
    puggle.utils:shuffleTable( self._tracks )
end

--- Sets the current track index. Will stop the current one but not automatically start playing again.
-- @param index The index to set the playlist to.
-- @param dontStopTrack Setting this to true will mean the current track isn't stopped when the new index is set. Optional, defaults to false.
function Playlist:setTrack( index, dontStopTrack )
    if index > 0 and index <= self:count() then
        if not dontStopTrack then
            self:stop()
        end
        self._index = index
    end
end

--- Gets the current track index.
-- @return The track index.
function Playlist:getTrack()
    return self._index
end

--- Checks if this playlist is playing.
-- @return True if it has, false otherwise.
function Playlist:isPlaying()
    return self._isPlaying
end

--- Checks if this playlist has been paused.
-- @return True if it has, false otherwise.
function Playlist:isPaused()
    return self._isPaused
end

--- Enables random mode for this playlist.
function Playlist:enableRandom()
    self._isRandom = true
end

--- Disable random mode for this playlist.
function Playlist:disableRandom()
    self._isRandom = false
end

--- Checks if this playlist has been set to random.
-- @return True if it has, false otherwise.
function Playlist:isRandom()
    return self._isRandom
end

--- Gets the tracklist.
-- @return The tracks in this playlist.
function Playlist:getTracks()
    return self._tracks
end

--- Sets the name of the playlist.
-- @param name The name to set.
function Playlist:setName( name )
    self._name = name
end

--- Gets the name of the playlist.
-- @return The name.
function Playlist:getName()
    return self._name
end

--- Gets the channel number of the playlist.
-- @return The channel number.
function Playlist:getChannel()
    return self._channel
end

--- Gets the handle for the currently playing track.
-- @return The handle.
function Playlist:getHandle()
    return self._handle
end

--- Sets the volume of this playlist.
-- @param volume The value to set the volume to.
function Playlist:setVolume( volume )
    if self:getChannel() and self:getChannel() ~= 0 then
        audio.setVolume( volume, { channel = self:getChannel() } )
    end
end

--- Gets the volume of this playlist.
-- @return The volume.
function Playlist:getVolume()
    if self:getChannel() and self:getChannel() ~= 0 then
        return audio.getVolume{ channel = self:getChannel() }
    end
end

--- Destroys this Playlist object.
function Playlist:destroy()
    self:stop()
end

--- Return the Playlist class definition.
return Playlist
