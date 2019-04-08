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
local AdColony = class( "AdColony" )

--- Required libraries.
local adcolony = require( "plugin.adcolony" )

--- Localised functions.

--- Initiates a new AdColony object.
-- @param params Paramater table for the object.
-- @return The new object.
function AdColony:initialize( params )

	-- Set the name of this manager
	self.name = "adcolony"

    -- Flag to tell us if we're initiated in or not
    self._initiated = false

end

--- Initiates AdColony.
-- @param params Paramater table for the initialisation.
function AdColony:init( params )

    self._appId = params.appId
    self._adZones = params.adZones
    self._adOrientation = params.adOrientation
    self._userId = params.userId
    self._debugLogging = params.debugLogging

    -- listener function
    local listener = function( event )

        local phase = event.phase
        local type = event.type

        if phase == "init" then  -- Successful initialization
            self._initiated = true
        elseif phase == "loaded" then

        end

		event.name = "advert"
		Runtime:dispatchEvent( event )

    end

    -- Initialize the AdColony plugin
    if adcolony then
        if self._appId and self._adZones then
            adcolony.init( listener, { appId = self._appId, adZones = self._adZones, adOrientation = self._adOrientation, userId = self._userId, debugLogging = self._debugLogging } )
        end
    end

end

--- Loads an advert.
-- @param zoneName The user-defined ad zone to be loaded.
-- @param params Table containing params for rewarded videos. Optional.
function AdColony:load( zoneName, params )
    if adcolony then
        if self:isInitiated() then
            adcolony.show( zoneName, params )
        end
    end
end

--- Shows an advert.
-- @param zoneName The user-defined ad zone to be shown.
function AdColony:show( zoneName )
    if adcolony then
        if self:isInitiated() then
            adcolony.show( zoneName )
        end
    end
end

--- Checks if an advert is loaded or not.
-- @param zoneName The user-defined ad zone.
-- @returns True if it is, false otherwise.
function AdColony:isLoaded( zoneName )
	if adcolony then
        return adcolony.isLoaded( zoneName )
    end
end

--- Gets info for a zone.
-- @param zoneName The user-defined ad zone.
function AdColony:getInfoForZone()
    if adcolony then
        return adcolony.getInfoForZone( zoneName )
    end
end

--- Checks if we're currently initiated.
-- @returns True if we are, false otherwise.
function AdColony:isInitiated()
	return self._initiated
end

--- Destroys this AdColony object.
function AdColony:destroy()

end

--- Return the AdColony class definition.
return AdColony
