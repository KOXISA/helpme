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
local Network = class( "Network" )

--- Required libraries.
local socket = require( "socket" )

--- Localised functions.

--- Initiates a new Network object.
-- @param params Paramater table for the object.
-- @return The new object.
function Network:initialize( params )

	-- Set the name of this manager
	self.name = "network"

end

--- Checks for a valid internet connection.
-- @return True if there is a valid internet connection, false otherwise.
function Network:checkForConnection()

    -- Create a socket connection
    local conn = socket.tcp()

    -- Set the timeout for 1 second as to not hold up the game
    conn:settimeout( 1000 )

    -- Make the actual connection
    local result = conn:connect( "www.google.com", 80 )

    -- Close and nil out the connection object
    conn:close()
    conn = nil

    -- If the result is not nil then there is a valid connection
    return result ~= nil

end

--- Return the Network class definition.
return Network
