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
local Timer = class( "Timer" )

--- Required libraries.

--- Localised functions.

--- Initiates a new Timer object.
-- @param params Paramater table for the object.
-- @return The new object.
function Timer:initialize( params )

	self.name = "timer"

    -- Table to store all timers.
    self._timers = {}

end

--- Calls a specified function after a delay.
-- @param delay The delay in milliseconds.
-- @param listener The function to call after the delay.
-- @param iterations Specifies the number of times to call the function. Optional, defaults to 1. Pass 0 or -1 if you want to loop the timer forever.
-- @param name Name to call the timer. Optional, defaults to a random string.
-- @return The created timer object as well as its name.
function Timer:performWithDelay( delay, listener, iterations, name )

    -- Create the timer
    local t = timer.performWithDelay( delay, listener, iterations )

    -- Give it a name
    local name = name or puggle.random:string( 12 )

    -- Add it to the system
    self._timers[ name ] = t

    -- Then return it, and its name
    return t, name

end

--- Update handler for this system.
-- @param dt The delta time of the game.
function Timer:update( dt )

end

--- Adds a timer to the system.
-- @param timer The timer to add.
-- @param name The name for the timer. Optional, but allows you to act on a specific timer.
function Timer:add( timer, name )
    if timer then
        self._timers[ timer.name or name ] = timer
    end
end

--- Gets a managed timer.
-- @param name The name of the timer.
-- @return The retrieved timer object.
function Timer:get( name )
    return self._timers[ name ]
end

--- Pause a managed timer.
-- @param name The name of the timer. Optional, if left out then all timers will be paused.
function Timer:pause( name )
    if name then
        local t = self:get( name )
        if t then
            timer.pause( t )
        end
    else
        if self._timers then
			for k, _ in pairs( self._timers ) do
            	self:pause( k )
        	end
		end
    end
end

--- Resumes a managed timer.
-- @param name The name of the timer. Optional, if left out then all timers will be resumed.
function Timer:resume( name )
    if name then
        local t = self:get( name )
        if t then
            timer.resume( t )
        end
    else
        if self._timers then
			for k, _ in pairs( self._timers ) do
            	self:resume( k )
        	end
		end
    end
end

--- Cancel a managed timer.
-- @param name The name of the timer. Optional, if left out then all timers will be cancelled.
function Timer:cancel( name )
    if name then
        local t = self:get( name )
        if t then
            timer.cancel( t )
        end
        t = nil
        self._timers[ name ] = nil
    else
        if self._timers then
			for k, _ in pairs( self._timers ) do
            	self:cancel( k )
        	end
		end
    end
end

--- Called when Puggle is paused.
function Timer:onPause()
    self:pause()
end

--- Called when Puggle is resumed.
function Timer:onResume()
    self:resume()
end

--- Destroys this Timer object.
function Timer:destroy()
    self:cancel()
    self._timers = nil
end

--- Return the Timer class definition.
return Timer
