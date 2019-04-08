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
local Data = class( "Data" )

--- Required libraries.

--- Localised functions.

--- Initiates a new Data object.
-- @param params Paramater table for the object.
-- @return The new object.
function Data:initialize( params )

	-- Set the name of this manager
	self.name = "data"

	-- Initiate the required data
	self._contents = {}
	self._path = "puggle.io"

	-- Enable autosave by default
	self:enableAutosave()

	-- Disable preference storage by default
	self:disablePreferenceStorage()

	-- Add the 'system' event listener
	Runtime:addEventListener( "system", self )

end

--- Post init function for the Data manager.
function Data:postInit()

	-- Load the data
	self:load()

	-- Immediately save it out so that the first version is created
	self:save()

end

--- Loads the data.
-- @return True if it was loaded, false otherwise.
function Data:load()

	-- Create a blank contents table
	self._contents = {}

	-- Load te encoded data from preferences
	local encodedPreferenceData = system.getPreference( "app", "encodedData", "string" )

	-- Do we have some data?
	if encodedPreferenceData then

		-- Now binary 64 decode it
		local data = puggle.utils:b64Decode( encodedPreferenceData )

		-- Decode the data from json into a table
		local jsonData = puggle.utils:jsonDecode( data ) or {}

		for k, v in pairs( jsonData ) do
			self._contents[ k ] = v
		end
	end


	-- Pre declare the encoded data
	local encodedData

	-- Check that a path is set and that the file exists
	if self._path and puggle.utils:fileExists( self._path, system.DocumentsDirectory ) then

		-- Load the encoded data from a file
		encodedData = puggle.utils:readInFile( self._path, system.DocumentsDirectory )

	end

	if encodedData then

		-- Now binary 64 decode it
		local data = puggle.utils:b64Decode( encodedData )

		-- Decode the data from json into a table
		local jsonData = puggle.utils:jsonDecode( data ) or {}

		for k, v in pairs( jsonData ) do
			self._contents[ k ] = v
		end

		return true

	end

	return false

end

--- Saves the data.
-- @return True if it was saved, false otherwise.
function Data:save()

	-- Encode the data into json format
	local data = puggle.utils:jsonEncode( self._contents )

	-- Now binary 64 encode it
	data = puggle.utils:b64Encode( data )

	-- Save out the data to preferences
	local preferenceSaveResult = system.setPreferences( "app", { encodedData = data } )

	-- Check that we have a path set
	if self._path then

		-- Save it out to the file
		puggle.utils:writeOutFile( data, self._path, system.DocumentsDirectory )

		return true

	end

	return preferenceSaveResult

end

--- Sets a value. Calling this will automatically save the data out, if this causes issues then diable the autosave via puggle.data:disableAutosave()
-- @param name The name of the value.
-- @param value The value to set.
function Data:set( name, value )

	-- Set the value
	self._contents[ name ] = value

	-- Automatically save the data out
	if self:isAutosaveEnabled() then
		self:save()
	end

end

--- Gets a value.
-- @param name The name of the value. If none specified then all values will be retrieved.
-- @return The retrieved value, or values if no name specified.
function Data:get( name )

	-- If a name is specified then return that value, if not then return all of them
	if name then
		return self._contents[ name ]
	else
		return self._contents
	end

end

--- Deletes a value.
-- @param name The name of the value.
function Data:delete( name )
	self._contents[ name ] = nil
end

--- Sets a value if it is higher than the already existing one, or if the existing one isn't set.
-- @param name The name of the value.
-- @param value The value to set.
-- @return True if it was set, false otherwise.
function Data:setIfHigher( name, value )

	if not self:isSet( name ) or self:isSet( name ) and self:isHigher( name, value ) then

		self:set( name, value )

		return true

	end

	return false

end

--- Sets a value if it is higher than the already existing one, or if the existing one isn't set.
-- @param name The name of the value.
-- @param value The value to set.
-- @return True if it was set, false otherwise.
function Data:setIfLower( name, value )

	if not self:isSet( name ) or self:isSet( name ) and self:isLower( name, value ) then

		self:set( name, value )

		return true

	end

	return false

end

--- Sets a value if it hasn't been set before.
-- @param name The name of the value.
-- @param value The value to set.
-- @return True if it was set, false otherwise.
function Data:setIfNew( name, value )

	if not self:isSet( name ) then

		self:set( name, value )

		return true

	end

	return false

end

--- Increments a value.
-- @param name The name of the saved value.
-- @param amount The amount to increment it by. Optional, defaults to 1.
-- @return True if it was incremented, false otherwise.
function Data:increment( name, amount )

	if self:isNumber( name ) or not self:isSet( name ) then

		self:set( name, ( self:get( name ) or 0 ) + ( amount or 1 ) )

		return true

	end

	return false

end

--- Decrements a value.
-- @param name The name of the saved value.
-- @param amount The amount to decrement it by. Optional, defaults to 1.
-- @return True if it was incremented, false otherwise.
function Data:decrement( name, amount )

	if self:isNumber( name ) or not self:isSet( name ) then

		self:set( name, ( self:get( name ) or 0 ) - ( amount or 1 ) )

		return true

	end

	return false

end

--- Checks if a value is a number.
-- @param name The name of the saved value.
-- @return True if the value is a number, false otherwise.
function Data:isNumber( name )

	if self:isSet( name ) and type( tonumber( self:get( name ) ) ) == "number" then
		return true
	end

	return false

end

--- Checks if a value has been set.
-- @param name The name of the saved value.
-- @return True if the value is set, false otherwise.
function Data:isSet( name )
	return self:get( name ) ~= nil
end

--- Checks if a value is higher than an already saved value.
-- @param name The name of the saved value.
-- @param value The value to check.
-- @return True if the value is higher than the saved value, false otherwise.
function Data:isHigher( name, value )

	if self:isSet( name ) and self:isNumber( name ) and value > self:get( name ) then
		return true
	end

	return false

end

--- Checks if a value is lower than an already saved value.
-- @param name The name of the saved value.
-- @param value The value to check.
-- @return True if the value is lower than the saved value, false otherwise.
function Data:isLower( name, value )

	if self:isSet( name ) and self:isNumber( name ) and value < self:get( name ) then
		return true
	end

	return false

end

-- Wipes all stored data.
function Data:wipe()

	-- Clear the contents
	self._contents = {}

	-- Save the newly empty file out
	if self:isAutosaveEnabled() then
		self:save()
	end

end

--- Disables autosave.
function Data:disableAutosave()
	self._autosaveEnabled = false
end

--- Enables autosave.
function Data:enableAutosave()
	self._autosaveEnabled = true
end

--- Checks if autosave is enabled.
-- @return True if it is, false otherwise.
function Data:isAutosaveEnabled()
	return self._autosaveEnabled
end

--- Disables preference storage.
function Data:disablePreferenceStorage()
	self._preferenceStorageEnabled = false
end

--- Enables preference storage.
function Data:enablePreferenceStorage()
	self._preferenceStorageEnabled = true
end

--- Checks if preference storage is enabled.
-- @return True if it is, false otherwise.
function Data:isPreferenceStorageEnabled()
	return self._preferenceStorageEnabled
end

--- The 'system' event handler.
-- @param event The 'system' event.
function Data:system( event )

	if event.type == "applicationExit" or event.type == "applicationSuspend" then
		self:save()
	end

end

--- Destroys this Data object.
function Data:destroy()

	self._contents = nil
	self._path = nil

	-- Add the 'system' event listener
	Runtime:removeEventListener( "system", self )

end

--- Return the Data class definition.
return Data
