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
local UUID = class( "UUID" )

--- Required libraries.
local udid
pcall( function() udid = require( "plugin.openudid" ) end )

--- Localised functions.

--- Initiates a new UUID object.
-- @param params Paramater table for the object.
-- @return The new object.
function UUID:initialize( params )

	-- Set the name of this manager
	self.name = "uuid"

end

--- Gets the UDID value.
-- @return The value.
function UUID:get()
    if udid then
		return udid.getValue()
	end
end

--- Enables the UDID tracking.
function UUID:enable()
    if udid then
		return udid.setOptOut( true )
	end
end

--- Disables the UDID tracking.
function UUID:disable()
    if udid then
		return udid.setOptOut( false )
	end
end

--- Return the UUID class definition.
return UUID
