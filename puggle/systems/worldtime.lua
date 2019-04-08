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
local WorldTime = class( "WorldTime" )

--- Required libraries.

--- Localised functions.

--- Initiates a new WorldTime object.
-- @param params Paramater table for the object.
-- @return The new object.
function WorldTime:initialize( params )

	-- Set the name of this manager
	self.name = "worldtime"

end


--- Gets the current time in a specified timezone.
-- @param onComplete Listener function for the time.
-- @param timezone The timezone to use. Optional, defaults to 'utc'.
-- @param date The date to use. Optional, defaults to 'now'.
function WorldTime:get( onComplete, timezone, date )

    if puggle.network:checkForConnection() then

        local url = "http://worldclockapi.com/api/json/" .. ( timezone or "utc" ) .. "/" .. ( date or "now" )

        local listener = function( event )

            if ( event.isError ) then
                print( "Network error: ", event.response )
            else
                if onComplete then

                    -- Decode the response
                    local response = puggle.utils:jsonDecode( event.response )

                    -- Add a unix time to it
                    response.unix = puggle.utils:windowsToUnixTime( response.currentFileTime )

                    onComplete( response )

                end
            end
        end

        network.request( url, "GET", listener )

    end

end

--- Gets the current time in a specified timezone.
-- @param onComplete Listener function for the time.
-- @param timezone The timezone to use. Optional, defaults to 'utc'.
function WorldTime:now( onComplete, timezone )
    puggle.worldtime:get( onComplete, timezone )
end

--- Return the WorldTime class definition.
return WorldTime
