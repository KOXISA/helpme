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
local Social = class( "Social" )

--- Required libraries.

--- Localised functions.

--- Initiates a new Social object.
-- @param params Paramater table for the object.
-- @return The new object.
function Social:initialize( params )

	-- Set the name of this manager
	self.name = "social"

end

--- Checks if a social popup can be shown.
-- @param service The service to check for. Supported platforms are 'twitter', 'facebook', and 'sinaWeibo'.
-- @return True if it can be shown, false otherwise.
function Social:canShowPopup( service )
    return native.canShowPopup( "social", service )
end

--- Shows a social popup.
-- @param service The service to use. Supported platforms are 'twitter', 'facebook', and 'sinaWeibo'.
-- @param message The message to send.
-- @param images Table containing subtables for 'filename' and 'baseDir' for any images you wish to submit. Optional.
-- @param urls Table containing any URLs to submit with the message. Optional.
-- @param onComplete Callback function for the popup event. Optional.
function Social:showPopup( service, message, images, urls, onComplete )

    if self:canShowPopup( service ) then

        local listener = {}

        function listener:popup( event )
			if onComplete then
				onComplete( event )
			end
        end

        native.showPopup( "social",
            {
                service = service,
                message = message,
                listener = listener,
                image = images,
                url = urls
            }
        )

    end

end

--- Destroys this Social object.
function Social:destroy()

end

--- Return the Social class definition.
return Social
