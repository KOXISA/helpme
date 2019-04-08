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
local Admob = class( "Admob" )

--- Required libraries.
local admob
pcall( function() admob = require( "plugin.admob" ) end )

--- Localised functions.

--- Initiates a new Admob object.
-- @param params Paramater table for the object.
-- @return The new object.
function Admob:initialize( params )

	-- Set the name of this manager
	self.name = "admob"

    -- Flag to tell us if we're initiated in or not
    self._initiated = false

end

--- Initiates Admob.
-- @param params Paramater table for the initialisation.
function Admob:init( params )

	if params[ puggle.system:getPlatform() ] then

    	self._appId = params[ puggle.system:getPlatform() ].appId

	    self._testMode = params.testMode

	    -- listener function
	    local listener = function( event )

	        local phase = event.phase
	        local type = event.type

	        if phase == "init" then  -- Successful initialization
	            self._initiated = true
			--	puggle.adverts:loadAll( self.name )
	        elseif phase == "loaded" then

	        end

			event.name = "advert"
			Runtime:dispatchEvent( event )

	    end

	    -- Initialize the Admob plugin
	    if admob then
	        if self._appId then
	            admob.init( listener, { appId = self._appId, testMode = self._testMode } )
	        end
	    end

	end

end

--- Loads an advert so that it can be shown.
-- @param adType One of the following values; 'interstitial', 'banner'.
-- @param params Table containing additional paramaters for the specified ad type. Optional.
function Admob:load( adType, params )
    if admob then
        if self:isInitiated() then
            admob.load( adType, params )
        end
    end
end

--- Shows an advert that has been loaded.
-- @param adType One of the following values; 'interstitial', 'banner'.
-- @param params Table containing additional paramaters for the specified ad type. Optional.
function Admob:show( adType, params )
    if admob then
        if self:isInitiated() then
            admob.show( adType, params )
        end
    end
end

--- Hides the current banner ad.
function Admob:hide()
    if admob then
        admob.hide()
    end
end

--- Gets the height of a pre-loaded banner advert.
-- @returns The height in content coordinates.
function Admob:height( adType )
	if admob then
        return admob.height()
    end
end

--- Checks if an advert is loaded or not.
-- @param adType One of the following values; 'interstitial', 'banner'.
-- @returns True if it is, false otherwise.
function Admob:isLoaded( adType )
	if admob then
        return admob.isLoaded( adType )
    end
end

--- Checks if we're currently initiated.
-- @returns True if we are, false otherwise.
function Admob:isInitiated()
	return self._initiated
end

--- Destroys this Admob object.
function Admob:destroy()

end

--- Return the Admob class definition.
return Admob
