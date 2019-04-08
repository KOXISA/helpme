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
local Collision = class( "Collision" )

--- Required libraries.
local collisionFilters
pcall( function() collisionFilters = require( "plugin.collisionFilters" ) end )

--- Localised functions.

--- Initiates a new Collision object.
-- @param params Paramater table for the object.
-- @return The new object.
function Collision:initialize( params )

	-- Set the name of this manager
	self.name = "collision"

    -- Table used to store the filters
    self.filters = {}

end

--- Gets a named filter or all of them.
-- @param name The name of the filter. Optional, if excluded then you will get a table of all filters in a readable, but not useable, format.
-- @param humanReadableFormat If true, and a name has been provided, than the filter will be returned in a readable format. If false then the returned filter can be used in the physics.addBody() function.
-- @return The retrieved filter, or filters.
function Collision:get( name, humanReadableFormat )
    if collisionFilters then
        if name then
            return collisionFilters.getFilter( name, humanReadableFormat )
        else
            return collisionFilters.viewAllFilters()
        end
    end
end

--- Adds a new collision filter to the system.
-- @param name The name of the filter.
-- @param collidesWith Either a name of a filter this collides with, or a table containing multiple names.
function Collision:add( name, collidesWith )
    self.filters[ name ] = collidesWith
    self:setup( self.filters )
end

--- Removes a previously added collision filter from the system.
-- @param name The name of the filter, or a table containing multiple names.
function Collision:remove( name )
    if type( name ) == "table" then
        for i = 1, #name, 1 do
            self.filters[ name[ i ] ] = nil
        end
    else
        self.filters[ name ] = nil
    end
    self:setup( self.filters )
end

--- Setup the collision filters for the system. Doesn't need to be called if you've used the puggle.collision.add method.
-- @param filters The table of filters to create.
function Collision:setup( filters )
    if collisionFilters then
        self.filters = filters
        collisionFilters.setupFilters( filters )
    end
end

--- Return the Collision class definition.
return Collision
