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
local Config = class( "Config" )

--- Required libraries.

--- Localised functions.

--- Initiates a new Config object.
-- @param params Paramater table for the object.
-- @return The new object.
function Config:initialize( params )

	-- Set the name of this manager
	self.name = "config"

end

--- Post init function for the Config manager.
function Config:postInit()

	-- Load up all the config items
    self._items = puggle.utils:decodeFile( "puggle.cfg", system.ResourceDirectory ) or {}

	-- Store out all the items directly onto the system for easier access
	for k, v in pairs( self._items ) do
		self[ k ] = v
	end

end

--- Gets a config item.
-- @param name The name of the item.
-- @param value The name key in the item if the item is a table. Optional.
-- @return The retrieved item.
function Config:get( name, value )

	-- Get the item
    local item = self[ name ]

	-- Do we have a value name and is the item a table?
    if value and item and type( item ) == "table" then
        item = item[ value ]
    end

	-- Return the item
    return item

end

--- Sets a config item.
-- @param name The name of the item.
-- @param value The name key in the item if the item is a table. Optional.
-- @param newValue The new value to set.
-- @return True if it was set, false otherwise.
function Config:set( name, value, newValue )

	if self:has( name, value ) then
		if value then
			if type( self:get( name ) ) == "table" then
				self[ name ][ value ] = newValue
				return true
			end
		else
			self[ name ] = newValue
			return true
		end
	end

	return false

end

--- Checks if a config item exists.
-- @param name The name of the item.
-- @param value The name key in the item if the item is a table. Optional.
-- @return True if it does, false otherwise.
function Config:has( name, value )
	return self:get( name, value ) ~= nil
end

--- Resets the config items back to their loaded in states.
function Config:reset()
	for k, v in pairs( self._items ) do
		self[ k ] = v
	end
end

--- Return the Config class definition.
return Config
