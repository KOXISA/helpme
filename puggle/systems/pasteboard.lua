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

--- Pasteboard creation.
local Pasteboard = class( "Pasteboard" )

--- Required libraries.
local pasteboard = nil

--- Localised functions.
local execute = os.execute
local gsub = string.gsub
local time = os.time
local date = os.date
local lfs = require( "lfs" )
local chdir = lfs.chdir
local open = io.open
local popen = io.popen
local close = io.close
local remove = os.remove

--- Initiates a new Pasteboard object.
-- @param params Paramater table for the object.
-- @return The new object.
function Pasteboard:initialize( params )

	-- Set the name of this manager
	self.name = "pasteboard"

end

function Pasteboard:postInit()

    if not puggle.system:isDesktop() then
        if not puggle.system:isAppleTV() then
            pasteboard = require( "plugin.pasteboard" )
        end
    end

end

function Pasteboard:copy( copyType, stringUrlFilename, baseDir )
	if pasteboard then
		pasteboard.copy( copyType, stringUrlFilename, baseDir )
	else
		if puggle.system:isOSX() then

			if copyType == "string" and type( stringUrlFilename ) == "string" then
		        execute( [[echo ']] .. gsub( stringUrlFilename, "'", "'\\''" ) .. [[' | pbcopy]] )
		    end

		elseif puggle.system:isWindows() then

			if copyType == "string" and type( stringUrlFilename ) == "string" then

				local clip = popen( "clip" )

				if clip then
				 	clip:write( stringUrlFilename )
				 	clip:close()
				end

			end

		end

	end
end

function Pasteboard:paste( onPaste )
	if pasteboard then
		pasteboard.paste( onPaste )
	else
		if puggle.system:isOSX() then

			local stamp = time( date('*t') )
		    local filename = "pb_" .. stamp .. ".txt"

		    local current_dir = lfs.currentdir()
		    chdir( system.pathForFile( "", system.CachesDirectory ) )
		    execute( "pbpaste > " .. filename )

		    local file, errorString, content = open( system.pathForFile( filename, system.CachesDirectory ), "r" )
		    if file then
		        content = file:read( "*a" )
		        close( file )
		    end
		    file = nil

		    remove( system.pathForFile( filename, system.CachesDirectory ) )
		    lfs.chdir ( current_dir )

			if onPaste and type( onPaste ) == "function" then
				onPaste{ string = content, url = content }
			end

		elseif puggle.system:isWindows() then

			local clip = popen( "clip" )

			if clip then

				local content = clip:read()
				clip:close()

				if onPaste and type( onPaste ) == "function" then
					onPaste{ string = content, url = content }
				end

			end

		end

	end
end

function Pasteboard:clear()
	if pasteboard then
		pasteboard.clear()
	end
end

function Pasteboard:getType()
	if pasteboard then
		return pasteboard.getType()
	end
end

function Pasteboard:setAllowedTypes( allowedTypes )
	if pasteboard then
		pasteboard.setAllowedTypes( allowedTypes )
	end
end

--- Destroys this Pasteboard object.
function Pasteboard:destroy()

end

--- Return the Pasteboard class definition.
return Pasteboard
