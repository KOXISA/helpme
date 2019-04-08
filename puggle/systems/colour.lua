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
local Colour = class( "Colour" )

--- Required libraries.

--- Localised functions.

--- Initiates a new Colour object.
-- @param params Paramater table for the object.
-- @return The new object.
function Colour:initialize( params )

	-- Set the name of this manager
	self.name = "colour"

	-- Initiate the required data
	self._palettes = {}
	self._colours = {}

end

--- Adds a named colour to the system.
-- @param name The name of the colour.
-- @param values Indexed Table containing red, green, blue values. Alpha value optional, defaults to 1.
function Colour:add( name, values )
	if type( values ) == "string" then
		values = puggle.utils:hexToRGB( values )
	end
	self._colours[ name ] = values
end

--- Gets a named colour from the system.
-- @param name The name of the colour.
-- @param palette The name of the palette. Optional, defaults to nil.
-- @param asTable True if you want the colours back as a table rather than multiple return values. Optional, defaults to false.
-- @return The colour values, or as a table if desired.
function Colour:get( name, palette, asTable )

	local colour

	if palette then
		colour = self:get( self._palettes[ palette ][ name ], nil, true )
	else
		colour = self._colours[ name ]
	end

	if asTable then
		colour[ 4 ] = colour[ 4 ] or 1
		return colour
	else
		return colour[ 1 ], colour[ 2 ], colour[ 3 ], colour[ 4 ] or 1
	end

end

--- Gets all named colours from the system.
-- @param palette The name of the palette if you'd just like those colours. Optional, defaults to nil.
-- @return The colour names.
function Colour:getColours( palette )
	if palette then
		return self._palettes[ palette ] or {}
	else
		return self._colours or {}
	end
end

--- Gets a named colour from the system.
-- @param palette The name of the palette. Optional, defaults to nil.
-- @param asTable True if you want the colours back as a table rather than multiple return values. Optional, defaults to false.
-- @return The colour values, or as a table if desired.
function Colour:getRandom( palette, asTable )
	return puggle.colour:get( puggle.random:fromList( puggle.colour:getColours( palette ) ) )
end

--- Creates a colour palette.
-- @param name The name for the palette.
function Colour:createPalette( name )
	self._palettes[ name ] = {}
end

--- Adds a named colour to a palette.
-- @param name The palette-specific name of the colour.
-- @param colour The name of the colour that was originally added to the system.
function Colour:addToPalette( palette, name, colour )
	self._palettes[ palette ][ name ] = colour
end

--- Destroys this Colour object.
function Colour:destroy()
	self._colours = nil
	self._palettes = nil
end

--- Return the Colour class definition.
return Colour
