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
local Instagram = class( "Instagram" )

--- Required libraries.

--- Localised functions.

--- Initiates a new Instagram object.
-- @param params Paramater table for the object.
-- @return The new object.
function Instagram:initialize( params )

	-- Set the name of this manager
	self.name = "instagram"

end

function Instagram:getFeed( user, onComplete )

	local filename = "feed-" .. user .. ".cache"
	local baseDir = system.CachesDirectory
	local path = system.pathForFile( filename, baseDir )
	local file = io.open( path, "w" )

 	local networkListener = function( event )

		 if event.isError then

		 elseif event.phase == "ended" then

			 -- Read in the complete scraped data
			 local contents = puggle.utils:readInFile( filename, baseDir )

			 -- Strip out everything bar the json data
			 local strippedContents = string.match( contents, '<script type="text\/javascript">window\._sharedData = (.*)<\/script>' )

			 -- Decode the data into a table
			 local data = puggle.utils:jsonDecode( strippedContents )

			 -- Get the feed
			 local feed = data.entry_data.ProfilePage[ 1 ].graphql

			 if onComplete then
				 onComplete( feed )
             end

			 puggle.utils:deleteFile( filename, baseDir )

		 end
 	end

	local params = {}
	params.progress = "download"

	params.response =
	{
		filename = filename,
		baseDirectory = baseDir
	}

	network.request( "https://www.instagram.com/" .. user .. "/", "GET", networkListener,  params )

end

--- Return the Instagram class definition.
return Instagram
