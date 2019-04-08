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
local Battery = class( "Battery" )

--- Required libraries.
local batteryState
pcall( function() batteryState = require( "plugin.batteryState" ) end )

--- Localised functions.

--- Initiates a new Battery object.
-- @param params Paramater table for the object.
-- @return The new object.
function Battery:initialize( params )

	-- Set the name of this manager
	self.name = "battery"

    -- Table to store state listeners.
    self._listeners = {}

    -- Main state listener
    local listener = function( event )

        -- Loop through all registered listeners and call them
        for i = 1, #self._listeners, 1 do
            self._listeners[ i ]( event )
        end

    end

    -- If we have a batter state object then initialise it
    if batteryState then
        batteryState.init( listener )
    end

end

-- Adds a state listener to get notified on changes.
-- @param listener The listener to add.
function Battery:addListener( listener )
    self._listeners[ #self._listeners + 1 ] = listener
end

-- Gets the current battery state.
-- @return A table with the following properties; 'level', 'state', and 'isError'.
function Battery:get()
    if batteryState then
        return batteryState.getState()
    end
end

--- Return the Battery class definition.
return Battery
