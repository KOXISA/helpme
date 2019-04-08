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
local AdID = class( "AdID" )

--- Required libraries.
local adID
pcall( function() adID = require( "plugin.advertisingId" ) end )

--- Localised functions.

--- Initiates a new AdID object.
-- @param params Paramater table for the object.
-- @return The new object.
function AdID:initialize( params )

	-- Set the name of this manager
	self.name = "adid"

end

--- Gets the advertising identifier.
-- @return The retrieved identifier.
function AdID:get()
    if adID then
        return adID.getAdvertisingId()
    end
end

--- Checks if tracking is enabled or not.
-- @return True if it is, false otherwise.
function AdID:isTrackingEnabled()
    if adID then
        return adID.isTrackingEnabled()
    end
end

--- Return the AdID class definition.
return AdID
