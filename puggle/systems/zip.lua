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
local Zip = class( "Zip" )

--- Required libraries.
local zip
pcall( function() zip = require( "plugin.zip" ) end )

--- Localised functions.

--- Initiates a new Zip object.
-- @param params Paramater table for the object.
-- @return The new object.
function Zip:initialize( params )

	-- Set the name of this manager
	self.name = "zip"

end

--- Compresses some files into a zip archive.
-- @param params A table of options for the compressing.
function Zip:compress( options )
    if zip then
        zip.compress( options )
    end
end

--- Decompresses a zip archive.
-- @param params A table of options for the decompressing.
function Zip:decompress( options )
    if zip then
        zip.uncompress( options )
    end
end

--- Lists all files in a zip archive.
-- @param params A table of options for the listing.
function Zip:list( options )
    if zip then
        zip.list( options )
    end
end

--- Return the Zip class definition.
return Zip
