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
local Time = class( "Time" )

--- Required libraries.

--- Localised functions.
local getTimer = system.getTimer
local time = os.time

--- Initiates a new Time object.
-- @param params Paramater table for the object.
-- @return The new object.
function Time:initialize( params )

	self.name = "time"

	self._dt = 0
	self._previousTime = 0
	self._fpsFactor = 1000 / display.fps
	self._frames = 0
	self._start = time()

end

--- Updates the Time object.
-- @param event The enterFrame event table.
function Time:enterFrame( event )

	self._frames = self._frames + 1

	local timer = getTimer()
	self._dt = ( timer - self._previousTime ) / self._fpsFactor
	self._previousTime = timer

	self._fps = self._frames / ( time() - self._start ) or 0

end

--- Gets the delta time for the game.
-- @return The delta time.
function Time:delta()
	return self._dt
end

--- Gets the fps for the game.
-- @return The fps.
function Time:fps()
	return self._fps
end

--- Destroys this Time object.
function Time:destroy()
	self._dt = nil
	self._previousTime = nil
	self._fpsFactor = nil
end

--- Return the Time class definition.
return Time
