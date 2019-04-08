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
local Chartboost = class( "Chartboost" )

--- Required libraries.
local chartboost = require( "plugin.chartboost" )

--- Localised functions.

--- Initiates a new Chartboost object.
-- @param params Paramater table for the object.
-- @return The new object.
function Chartboost:initialize( params )

	-- Set the name of this manager
	self.name = "chartboost"

    -- Flag to tell us if we're initiated in or not
    self._initiated = false

    -- Listener for key events
    Runtime:addEventListener( "key", self )

end

--- Initiates Chartboost.
-- @param params Paramater table for the initialisation.
function Chartboost:init( params )

    self._appId = params.appId
    self._appSig = params.appSig
    self._autoCacheAds = params.autoCacheAds
    self._customId = params.customId

    -- listener function
    local listener = function( event )

        local phase = event.phase
        local type = event.type
		local data = event.data
		local response = event.response
		local isError = event.isError
		local location = data.location

        if phase == "init" then  -- Successful initialization
            self._initiated = true
        elseif phase == "loaded" then

		elseif phase == "displayed" then

		elseif phase == "closed" then

		elseif phase == "clicked" then

		elseif phase == "failed" then

		elseif phase == "reward" then

        end

		event.name = "advert"
		Runtime:dispatchEvent( event )

    end

    -- Initialize the Chartboost plugin
    if chartboost then
        if self._appId and self._appSig then
            chartboost.init( listener, { appId = self._appId, appSig = self._appSig, autoCacheAds = self._autoCacheAds, customId = self._customId } )
        end
    end

end

--- Loads an advert so that it can be shown.
-- @param adType One of the following values; 'interstitial', 'rewardedVideo', 'moreApps'.
-- @param namedLocation The named location for the advert. Optional, defaults to 'Default'. These are the recommended options - https://docs.coronalabs.com/plugin/chartboost/show.html#locations
function Chartboost:load( adType, namedLocation )
    if chartboost then
        if self:isInitiated() then
            chartboost.load( adType, namedLocation )
        end
    end
end

--- Shows an advert that has been loaded.
-- @param adType One of the following values; 'interstitial', 'rewardedVideo', 'moreApps'.
-- @param namedLocation The named location for the advert. Optional, defaults to 'Default'. These are the recommended options - https://docs.coronalabs.com/plugin/chartboost/show.html#locations
function Chartboost:load( adType, namedLocation )
    if chartboost then
        if self:isInitiated() then
            chartboost.show( adType, namedLocation )
        end
    end
end

--- Checks if an advert is loaded or not.
-- @param adType One of the following values; 'interstitial', 'rewardedVideo', 'moreApps'.
-- @returns True if it is, false otherwise.
function Chartboost:isLoaded( adType )
	if chartboost then
        return chartboost.isLoaded( adType )
    end
end

--- Key event handler.
-- @param event The table for the key event.
function Chartboost:key( event )

    if chartboost then
        if event.keyName == "back" and event.phase == "up" then
            if puggle.system:isAndroid() then
                if chartboost.onBackPressed() then
                    -- Chartboost closed an active ad
                    return true  -- Don't pass the event down the responder chain
                end
            end
        end
    end

    -- We're good, nothing to see here. Carry on as normal.
    return false

end

--- Checks if we're currently initiated.
-- @returns True if we are, false otherwise.
function Chartboost:isInitiated()
	return self._initiated
end

--- Destroys this Chartboost object.
function Chartboost:destroy()
    Runtime:removeEventListener( "key", self )
end

--- Return the Chartboost class definition.
return Chartboost
