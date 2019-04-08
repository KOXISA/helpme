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
local Transition = class( "Transition" )

--- Required libraries.

--- Localised functions.

--- Initiates a new Transition object.
-- @param params Paramater table for the object.
-- @return The new object.
function Transition:initialize( params )

	self.name = "transition"

    -- Table to store all transitions.
    self._transitions = {}

end

--- Transitions a given display object ( or table ) using an optional easing algorithm.
-- @param target Any object that behaves like a table, for example display objects.
-- @param params A table that specifies the properties of the transition.
-- @param name Name to call the transition. Optional, defaults to a random string.
-- @return The created transition object as well as its name.
function Transition:to( target, params, name )

    -- Create the transition
    local t = transition.to( target, params )

    -- Give it a name
    local name = name or puggle.random:string( 12 )

    -- Add it to the system
    self._transitions[ name ] = t

    -- Then return it, and its name
    return t, name

end

--- Transitions a given display object ( or table ) using an optional easing algorithm.
-- @param target Any object that behaves like a table, for example display objects.
-- @param params A table that specifies the properties of the transition.
-- @param name Name to call the transition. Optional, defaults to a random string.
-- @return The created transition object as well as its name.
function Transition:from( target, params, name )

    -- Create the transition
    local t = transition.from( target, params )

    -- Give it a name
    local name = name or puggle.random:string( 12 )

    -- Add it to the system
    self._transitions[ name ] = t

    -- Then return it, and its name
    return t, name

end

--- Update handler for this system.
-- @param dt The delta time of the game.
function Transition:update( dt )

end

--- Adds a transition to the system.
-- @param transition The transition to add.
-- @param name The name for the transition. Optional, but allows you to act on a specific transition.
function Transition:add( transition, name )
    if transition then
        self._transitions[ transition.name or name ] = transition
    end
end

--- Gets a managed transition.
-- @param name The name of the transition.
-- @return The retrieved transition object.
function Transition:get( name )
    return self._transitions[ name ]
end

--- Pause a managed transition.
-- @param name The name of the transition. Optional, if left out then all transitions will be paused.
function Transition:pause( name )
    if name then
        local t = self:get( name )
        if t then
            transition.pause( t )
        end
    else
        if self._transitions then
			for k, _ in pairs( self._transitions ) do
            	self:pause( k )
        	end
		end
    end
end

--- Resumes a managed transition.
-- @param name The name of the transition. Optional, if left out then all transitions will be resumed.
function Transition:resume( name )
    if name then
        local t = self:get( name )
        if t then
            transition.resume( t )
        end
    else
        if self._transitions then
			for k, _ in pairs( self._transitions ) do
            	self:resume( k )
        	end
		end
    end
end

--- Cancel a managed transition.
-- @param name The name of the transition. Optional, if left out then all transitions will be cancelled.
function Transition:cancel( name )
    if name then
        local t = self:get( name )
        if t then
            transition.cancel( t )
        end
        t = nil
        self._transitions[ name ] = nil
    else
        if self._transitions then
			for k, _ in pairs( self._transitions ) do
            	self:cancel( k )
        	end
		end
    end
end

--- Called when Puggle is paused.
function Transition:onPause()
    self:pause()
end

--- Called when Puggle is resumed.
function Transition:onResume()
    self:resume()
end

--- Destroys this Transition object.
function Transition:destroy()
    self:cancel()
    self._transitions = nil
end

--- Return the Transition class definition.
return Transition
