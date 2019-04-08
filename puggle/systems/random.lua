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
local Random = class( "Random" )

--- Required libraries.
local randomlua = require( "puggle.ext.randomlua" )

--- Localised functions.
local random = math.random
local char = string.char
local randomseed = math.randomseed
local time = os.time
local pairs = pairs

--- Initiates a new Random object.
-- @param params Paramater table for the object.
-- @return The new object.
function Random:initialize( params )
	self.name = "random"
	self._generator = mwc( 0 )
end

--- Sets the seed for the random number generator.
-- @param value The seed to set. Optional, defaults to os.time().
function Random:seed( value )
	randomseed( value or time() )
	self._generator = mwc( value or time() )
end

--- Gets a random number within a range.
-- @param min The minimum value of the range. Optional, defaults to 0.
-- @param max The maximum value of the range.
-- @return The random value.
function Random:inRange( min, max )

	if not max then
		max = min
		min = 0
	end

	return self._generator:random( min, max )

end

--- Gets a random value from a list.
-- @param list The list of values to choose from.
-- @return The randomly selected value.
function Random:fromList( list )

	local count = puggle.utils:countArray( list )
	local index = self:inRange( 1, count )

	local i = 1
	for _, v in pairs( list ) do
		if i == index then
			return v
		end
		i = i + 1
	end

	return nil

end

--- Generates a random string.
-- @param length The desired length of the string to generate.
-- @param options Table containing options for the generation. Supported options are; 'includeSymbols', 'includeNumbers', 'includeLowercase', 'includeUppercase', 'includeSpaces', 'excludeSimilar', 'excludeAmbiguous', 'excludeSequential', 'excludeDuplicates', 'beginWithALetter'. Table is optional, leaving it out will include everything.
-- @return The randomly generated string.
function Random:string( length, options )

	if not length or length < 1 then
		return nil
	end

	local validChars = {}

	if options then

		if options.includeSymbols then

			for i = 33, 47, 1 do
				validChars[ #validChars + 1 ] = i
			end

			for i = 58, 64, 1 do
				validChars[ #validChars + 1 ] = i
			end

			for i = 123, 126, 1 do
				validChars[ #validChars + 1 ] = i
			end

		end

		if options.includeNumbers then

			for i = 48, 57, 1 do
				validChars[ #validChars + 1 ] = i
			end

		end

		if options.includeLowercase then

			for i = 97, 122, 1 do
				validChars[ #validChars + 1 ] = i
			end

		end

		if options.includeUppercase then

			for i = 65, 90, 1 do
				validChars[ #validChars + 1 ] = i
			end

		end

		if options.includeSpaces then

			validChars[ #validChars + 1 ] = 32

		end

		if options.excludeSimilar then
			--TODO puggle.random:string - excludeSimilar
		end

		if options.excludeAmbiguous then
			--TODO puggle.random:string - excludeAmbiguous
		end

		if options.excludeSequential then
			--TODO puggle.random:string - excludeSequential
		end

	else

		for i = 32, 126, 1 do
			validChars[ #validChars + 1 ] = i
		end

	end

	local s = ""
	for i = 1, length, 1 do
		if validChars and #validChars > 0 then
			s = s .. char( puggle.random:fromList( validChars ) )
		end
	end

	if options then

		if options.beginWithALetter then

			local validChars = {}

			if options.includeLowercase then

				for i = 97, 122, 1 do
					validChars[ #validChars + 1 ] = i
				end

			end

			if options.includeUppercase then

				for i = 65, 90, 1 do
					validChars[ #validChars + 1 ] = i
				end

			end

			s = char( puggle.random:fromList( validChars ) ) .. s

		end

		if options.excludeDuplicates then

			local chars = {}
			local included = {}
			local newS = ""

			for i = 1, #s do
			    chars[ i ] = s:sub( i, i )
			end

			for k, v in ipairs( chars ) do

			   if not included[ v ] then
			      newS = newS .. v
			       included[ v ] = true
			   end

			end

			s = newS

		end

	end

	return s

end

--- Flips a coin.
-- @return A true or false value.
function Random:coinFlip()
	return self:inRange( 0, 1 ) == 1
end

--- Destroys this Random object.
function Random:destroy()

end

--- Return the Random class definition.
return Random
