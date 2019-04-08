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
local RevMob = class( "RevMob" )

--- Required libraries.
local revmob = require( "plugin.revmob" )

--- Localised functions.

--- Initiates a new RevMob object.
-- @param params Paramater table for the object.
-- @return The new object.
function RevMob:initialize( params )

	-- Set the name of this manager
	self.name = "revmob"

    -- Flag to tell us if we're initiated in or not
    self._initiated = false

    Runtime:addEventListener( "system", self )

end

--- Initiates RevMob.
-- @param params Paramater table for the initialisation.
function RevMob:init( params )

    if params[ puggle.system:getPlatform() ] then

    	self._appId = params[ puggle.system:getPlatform() ].appId

        -- listener function
        local listener = function( event )

            local phase = event.phase
            local type = event.type
            local isError = event.isError

            if phase == "init" then  -- Successful initialization
                if not isError then
                    self._initiated = true
                end
            end

    		event.name = "advert"
    		Runtime:dispatchEvent( event )

        end

        -- Initialize the RevMob plugin
        if revmob then
            if self._appId then
                revmob.init( listener, { appId = self._appId } )
            end
        end
    else

    end

end

--- Shows an advert.
-- @param placementId One of the placement IDs you've configured in the RevMob dashboard.
-- @param prams Table containing placement customization values, optional.
function RevMob:show( placementId, params )
    if revmob then
        if self:isInitiated() then
            params = params or {}
            params.yAlign = params.yAlign or "top"
            revmob.show( placementId, params )
        end
    end
end

--- Hides an advert.
-- @param placementId One of the placement IDs you've configured in the RevMob dashboard.
function RevMob:hide( placementId )
    if revmob then
        revmob.hide( placementId )
    end
end

--- Preloads an advert.
-- @param adUnitType The type of ad to load. Valid values are "banner", "interstitial", "video", or "rewardedVideo".
-- @param placementId One of the placement IDs you've configured in the RevMob dashboard.
function RevMob:load( adUnitType, placementId )
	if revmob then
        revmob.load( adUnitType, placementId )
    end
end

--- Checks if an advert is loaded or not.
-- @param placementId One of the placement IDs you've configured in the RevMob dashboard.
-- @returns True if it is, false otherwise.
function RevMob:isLoaded( placementId )
	if revmob then
        return revmob.isLoaded( placementId )
    end
end

--- Checks if we're currently initiated.
-- @returns True if we are, false otherwise.
function RevMob:isInitiated()
	return self._initiated
end

--- Starts a session.
function RevMob:startSession()
	if revmob then
        return revmob.startSession()
    end
end

--- Event handler for system events.
-- @param event The table of the event.
function RevMob:system( event )
    if event.type == "applicationResume" then
        self:startSession()
    end
end

--- Destroys this RevMob object.
function RevMob:destroy()
    Runtime:removeEventListener( "system", self )
end

--- Return the RevMob class definition.
return RevMob
