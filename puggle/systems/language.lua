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
local Language = class( "Language" )

--- Required libraries.

--- Localised functions.

--- Initiates a new Language object.
-- @param params Paramater table for the object.
-- @return The new object.
function Language:initialize( params )

	-- Set the name of this manager
	self.name = "language"

	-- Initiate the required data
	self._languages = {}

end

--- Gets a named string from the system.
-- @param name The name of the string.
-- @param language The name of the language. Optional, defaults to the system default.
-- @return The found string, or the name of the string if none found.
function Language:get( name, language )

	local language = self._languages[ language or self:getDefault() ]

	if language then
		return language[ name ] or name
	end

end

--- Loads a language into the system.
-- @param name The name of the language.
-- @param path The path to the language file. Optional, defaults to 'name.language' located in the root of the game.
function Language:load( name, path )

	-- Adjust the path if needed
	path = ( path or "" ) .. name .. "." .. "language"

	-- Load the strings in
	self._languages[ name ] = puggle.utils:decodeFile( path, system.ResourceDirectory )

	-- If no default has been set, then make it the first that gets loaded
	self:setDefault( self:getDefault() or name )

end

--- Sets the default language.
-- @param name The name of the language.
function Language:setDefault( name )
	self._default = name
end

--- Gets the default language.
-- @return The name of the language.
function Language:getDefault()
	return self._default
end

--- Destroys this Language object.
function Language:destroy()
	self._languages = nil
end

--- Return the Language class definition.
return Language
