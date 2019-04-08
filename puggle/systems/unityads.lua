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
local UnityAds = class( "UnityAds" )

--- Required libraries.
local unityads = require( "plugin.unityads" )

--- Localised functions.

--- Initiates a new UnityAds object.
-- @param params Paramater table for the object.
-- @return The new object.
function UnityAds:initialize( params )

	-- Set the name of this manager
	self.name = "unityads"

    -- Flag to tell us if we're initiated in or not
    self._initiated = false

end

--- Initiates UnityAds.
-- @param params Paramater table for the initialisation.
function UnityAds:init( params )

	self._gameId = params.gameId
    self._testMode = params.testMode

    -- listener function
    local listener = function( event )

        local phase = event.phase
        local type = event.type

        if phase == "init" then  -- Successful initialization
            self._initiated = true
        elseif phase == "loaded" then

        elseif phase == "displayed" then

        elseif phase == "skipped" then

        elseif phase == "completed" then

        elseif phase == "failed" then

        elseif phase == "placementStatus" then

        end

		event.name = "advert"
		Runtime:dispatchEvent( event )

    end

    -- Initialize the UnityAds plugin
    if unityads then
        if self._gameId then
            unityads.init( listener, { gameId = self._gameId, testMode = self._testMode } )
        end
    end

end

--- Shows an advert.
-- @param placementId One of the placement IDs you've configured in the Unity Ads dashboard.
function UnityAds:show( placementId )
    if unityads then
        if self:isInitiated() then
            unityads.show( placementId )
        end
    end
end

--- Checks if an advert is loaded or not.
-- @param placementId One of the placement IDs you've configured in the Unity Ads dashboard.
-- @returns True if it is, false otherwise.
function UnityAds:isLoaded( placementId )
	if unityads then
        return unityads.isLoaded( placementId )
    end
end

--- Checks if we're currently initiated.
-- @returns True if we are, false otherwise.
function UnityAds:isInitiated()
	return self._initiated
end

--- Destroys this UnityAds object.
function UnityAds:destroy()

end

--- Return the UnityAds class definition.
return UnityAds
