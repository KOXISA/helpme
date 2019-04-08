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
local Utils = class( "Utils" )

--- Required libraries.
local json = require( "json" )
local base64 = require( "puggle.ext.base64" )
local uuid4 = require( "puggle.ext.uuid4" )
local lfs = require( "lfs" )

--- Localised functions.
local pathForFile = system.pathForFile
local open = io.open
local close = io.close
local encode = json.encode
local decode = json.decode
local b64 = base64.encode
local unb64 = base64.decode
local remove = os.remove
local getUUID = uuid4.getUUID
local time = os.time
local save = display.save
local floor = math.floor
local format = string.format
local random = math.random

--- Initiates a new Utils object.
-- @param params Paramater table for the object.
-- @return The new object.
function Utils:initialize( params )
	self.name = "utils"
end

--- Reads in a file from disk.
-- @param path The path to the file.
-- @param baseDir The directory that the file resides in. Optional, defaults to system.ResourceDirectory.
-- @return The contents of the file, or an empty string if the read failed.
function Utils:readInFile( path, baseDir )

	local path = pathForFile( path, baseDir or system.ResourceDirectory )

	if path then

		local file = open( path, "r" )

		if file then

			local contents = file:read( "*a" ) or ""

			close( file )

			file = nil

			return contents

		end

	end

end

--- Writes out a string to a file.
-- @param contents The string to write.
-- @param path The path to the file.
-- @param baseDir The directory that the file resides in. Optional, defaults to system.DocumentsDirectory.
-- @return True if the write succeeded, false otherwise.
function Utils:writeOutFile( contents, path, baseDir )

	local file = open( pathForFile( path, baseDir or system.DocumentsDirectory ), "w" )

	if file then

		file:write( contents )

		close( file )

		file = nil

		return true

	end

	return false

end

--- Deletes a file from disk.
-- @param path The path to the file.
-- @param baseDir The directory that the file resides in. Optional, defaults to system.DocumentsDirectory.
-- @return True if the file was deleted, false and a reason why otherwise.
function Utils:deleteFile( path, baseDir )
	return remove( pathForFile( path, baseDir or system.DocumentsDirectory ) )
end

--- Checks if a file exists.
-- @param path The path to the file.
-- @param baseDir The directory that the file should reside in. Optional, defaults to system.DocumentsDirectory.
-- @return True if it does, false otherwise.
function Utils:fileExists( path, baseDir )

	local path = system.pathForFile( path, baseDir or system.DocumentsDirectory )

	if not path then
		return false
	end

	if puggle.system:isAndroid() and path then

		local handle = io.open( path, "r" )

		if handle then

			io.close( handle )

			handle = nil

			return true

		end

		handle = nil

	end

	return lfs.attributes ( path, "mode" ) == "file"

end

--- Sets the iCloud backup setting for a file.
-- @param path The path to the file.
-- @param baseDir The directory that the file resides in. Optional, defaults to system.DocumentsDirectory.
-- @param enabled True if you want the file to sync, false otherwise.
function Utils:setFileSync( path, baseDir, enabled )
	setSync( pathForFile( path, baseDir or system.DocumentsDirectory ), { iCloudBackup = enabled } )
end

--- Sets the iCloud backup setting for a file.
-- @param path The path to the file.
-- @param baseDir The directory that the file resides in. Optional, defaults to system.DocumentsDirectory.
-- @return True if the file is set to sync, false otherwise.
function Utils:getFileSync( path, baseDir )
	return getSync( pathForFile( path, baseDir or system.DocumentsDirectory ), { key = "iCloudBackup" } )
end

--- Encodes a string into Base64.
-- @param string The string to encode.
-- @return The encoded string.
function Utils:b64Encode( string )
	return b64( string )
end

--- Decodes a Base64 encoded string.
-- @param string The string to decode.
-- @return The decoded string.
function Utils:b64Decode( string )
	return unb64( string )
end

--- Encodes a table into a Json string.
-- @param table The table to encode.
-- @return The encoded string.
function Utils:jsonEncode( table )
	return encode( table )
end

--- Decodes a Json string into a table.
-- @param string The string to decode.
-- @return The decoded table.
function Utils:jsonDecode( string )
	return decode( string or "" )
end

--- Decodes the contents of a file that has been encoded as json.
-- @param path The path to the file.
-- @param baseDir The directory that the file resides in. Optional, defaults to system.DocumentsDirectory.
-- @return The decoded file as a table.
function Utils:decodeFile( path, baseDir )
	return self:jsonDecode( self:readInFile( path, baseDir ) )
end

--- Decodes a table into json and saves it out.
-- @param table The table to encode.
-- @param path The path to the file.
-- @param baseDir The directory that the file resides in. Optional, defaults to system.DocumentsDirectory.
function Utils:encodeFile( table, path, baseDir )
	self:writeOutFile( self:jsonEncode( table ), path, baseDir )
end

--- Generates a UUID string.
-- @return The UUID.
function Utils:generateUUID()
	return getUUID()
end

--- Counts the total number of elements in an associative array.
-- @return The total.
function Utils:countArray( array )

	if array then

		local count = 0

		for _, _ in pairs( array ) do
		    count = count + 1
		end

		return count

	end

end

--- Formats a number into a pretty way of showing thousands. For instance '4500' becomes '4,500'.
-- @param number The number to format.
-- @returns The formatted number.
function Utils:seperateThousands( number )
	local formatted = number
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
			break
		end
	end
	return formatted
end

--- Converts a frame count into a table consisting of hours, minutes, and seconds.
-- @param frames The frame count.
-- @param neat If true then the numbers will be formatted to have preceeding zeroes. Optional, defaults to false.
-- @returns The converted time.
function Utils:framesToTime( frames, neat )

	local seconds = frames / display.fps

	local time = {}

	if seconds == 0 then
		time.hours = "00"
		time.minutes = "00"
		time.seconds = "00"
		time.milliseconds = "00"
	else
		time.hours = floor( frames / 60 / 60 / display.fps )
		time.minutes = floor( ( frames - time.hours * 60 * 60 * display.fps ) / 60 / display.fps )
		time.seconds = floor( ( frames - time.hours * 60 * 60 * display.fps - time.minutes * 60 * display.fps ) / display.fps )
		time.milliseconds = floor( frames - time.hours * 60 * 60 * display.fps - time.minutes * 60 * display.fps - time.seconds * display.fps )
	end

	if neat then
		time.hours = format( "%02.f", time.hours )
		time.minutes = format( "%02.f", time.minutes )
		time.seconds = format( "%02.f", time.seconds )
		time.milliseconds = format( "%02.f", time.milliseconds )
	end

	return time

end

--- Splits a string based on a seperator character.
-- @param str The string to split.
-- @param seperator The character to split on.
-- @returns Table containing the seperated strings.
function Utils:splitString( str, seperator )
	local seperator, fields = seperator or ":", {}
	local pattern = string.format( "([^%s]+)", seperator )
	str:gsub( pattern, function( c ) fields[ #fields + 1 ] = c end )
	return fields
end

--- Counts the number of words in a string.
-- @param str The string to check.
-- @returns The count.
function Utils:countWords( str )
	local _, n = str:gsub("%S+","")
	return n
end

--- Extracts a filename from a path.
-- @param path The path to use.
-- @returns The extracted filename.
function Utils:getFilenameFromPath( path )

	local splitPath = self:splitString( path, "/" )

	return splitPath[ #splitPath ]

end

--- Removes a filename from a path string.
-- @param path The path to use.
-- @returns New path without the filename.
function Utils:removeFilenameFromPath( path )

	local splitPath = self:splitString( path, "/" )

	return splitPath[ 1 ]

end

--- Extracts an extension from a filename.
-- @param filename The filename to use.
-- @returns The extracted extension.
function Utils:getExtensionFromFilename( filename )

	local splitFilename = {}
	local pattern = string.format("([^%s]+)", ".")
	filename:gsub( pattern, function( c ) splitFilename[ #splitFilename + 1 ] = c end )

	return splitFilename[ 2 ]

end

--- Extracts the file from a filename.
-- @param filename The filename to use.
-- @returns The extracted file.
function Utils:getFileFromFilename( filename )

	local splitFilename = {}
	local pattern = string.format("([^%s]+)", ".")
	filename:gsub( pattern, function( c ) splitFilename[ #splitFilename + 1 ] = c end )

	return splitFilename[ 1 ]

end

--- Checks if a table contains a value.
-- @param table The table to check.
-- @param value The value to look for.
-- @returns True if it does, false otherwise.
function Utils:tableContains( table, value )

	for _, v in pairs( table ) do
		if v == value then
			return true
		end
	end

	return false

end

--- Reverses a table.
-- @param table The table to reverse.
-- @returns The reversed table.
function Utils:reverseTable( table )
	for i = 1, floor( #table / 2 ) do
		table[ i ], table[ #table - i + 1 ] = table[ #table - i + 1 ], table[ i ]
	end
	return table
end

--- Shuffles a table.
-- @param table The table to shuffle.
-- @returns The shuffled table.
function Utils:shuffleTable( table )

    local j

    for i = #table, 2, -1 do
        j = random( i )
        table[ i ], table[ j ] = table[ j ], table[ i ]
    end

	return table

end

--- Drags a display object.
-- @param object The display object to drag.
-- @param event The touch event.
function Utils:dragObject( object, event )

    if event.phase == "began" then

        object._x0 = object.x
        object._y0 = object.y

		event.target.isFocus = true
		display.getCurrentStage():setFocus( event.target, event.id )

    elseif event.target.isFocus then

    	if event.phase == "moved" then

	        local x = ( event.x - event.xStart ) + object._x0
	        local y = ( event.y - event.yStart ) + object._y0

	        object.x, object.y = x, y

	    else

	    	event.target.isFocus = false
			display.getCurrentStage():setFocus( nil, event.id )

	    end

    end

    return true

end

--- Converts a Hex colour to RGB.
-- @param hex The hex colour.
-- @returns A table containing the indexed values.
function Utils:hexToRGB( hex )
    hex = hex:gsub( "#","" )
    return { tonumber("0x" .. hex:sub( 1, 2 ) ) / 255, tonumber( "0x".. hex:sub( 3, 4 ) ) / 255, tonumber( "0x" .. hex:sub( 5, 6 ) ) / 255 }
end

--- Prints out a table.
-- @param table The table to print.
-- @param stringPrefix Prefix for each string that is printed. Optional, defaults to '### '.
function Utils:printTable( table, stringPrefix )
   if not stringPrefix then
      stringPrefix = "### "
   end
   if type( table ) == "table" then
      for key, value in pairs(table) do
         if type( value ) == "table" then
            print( stringPrefix .. tostring( key ) )
            print( stringPrefix .. "{" )
            self:printTable( value, stringPrefix .. "   " )
            print( stringPrefix .. "}" )
         else
            print( stringPrefix .. tostring( key ) .. ": " .. tostring( value ) )
         end
      end
   end
end

--- Calculates the new x and y scale for a display object so that it fits certain bounds.
-- @param object The display object to use for the scale.
-- @param width The width to fit. Optional, if left out then it will use just the height value and keep the aspect ratio the same.
-- @param width The height to fit. Optional, if left out then it will use just the width value and keep the aspect ratio the same.
-- @returns The new x and y scales.
function Utils:calculateScaleToFit( object, width, height )

	local xScale, yScale = 1, 1
	local newWidth, newHeight

	if width then
		xScale = width / object.width
	end

	if height then
		yScale = height / object.height
	end

	return xScale or yScale, yScale or xScale

end

function Utils:windowsToUnixTime( windowsTime )

	local windowsTicks = 10000000
	local secondsToUnixEpoch = 11644473600

	return string.sub( windowsTime / windowsTicks - secondsToUnixEpoch, 1, 10 )

end

--- Destroys this Utils object.
function Utils:destroy()

end

--- Return the Utils class definition.
return Utils
