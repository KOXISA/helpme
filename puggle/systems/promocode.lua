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
local Promocode = class( "Promocode" )

--- Required libraries.

--- Localised functions.

--- Initiates a new Promocode object.
-- @param params Paramater table for the object.
-- @return The new object.
function Promocode:initialize( params )

	-- Set the name of this manager
	self.name = "promocode"

    self._baseURL = "http://dreamlo.com/pc/"

end

--- Registers the promocode system. This uses a private and public key of a Dreamlo promocode - http://dreamlo.com/
-- @param private The private code.
-- @param public The public code.
function Promocode:register( private, public )
    self._private = private
    self._public = public
end

--- Lists all files in a zip archive.
-- @param params A table of options for the listing.
-- @param onComplete Listener function for the redemption result.
function Promocode:redeem( code, onComplete )

    if self._public then

		local url = self._baseURL .. self._public .. "/redeem/" .. code

		local listener = function( event )

            if ( event.isError ) then
                print( "Network error: ", event.response )
            else

                local result = puggle.utils:splitString( event.response, "|" )

                if onComplete then
                    onComplete( result[ 1 ] == "OK", result[ 2 ] )
                end

            end
        end

        network.request( url, "GET", listener )

	end

end

--- Destroys this Promocode object.
function Promocode:destroy()
    self._private = nil
	self._public = nil
end

--- Return the Promocode class definition.
return Promocode
