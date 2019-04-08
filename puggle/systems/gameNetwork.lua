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
local GameNetwork = class( "GameNetwork" )

--- Required libraries.

--- Localised functions.

--- Initiates a new GameNetwork object.
-- @param params Paramater table for the object.
-- @return The new object.
function GameNetwork:initialize( params )

	-- Set the name of this manager
	self.name = "gameNetwork"

end

function GameNetwork:login( userInitiated, onComplete )

    if puggle.system:isIOS() then
		puggle.gameCentre:login( onComplete )
	elseif puggle.system:isKindle() then
		puggle.gameCircle:login( onComplete )
	elseif puggle.system:isAndroid() then
	    puggle.gpgs:login( userInitiated, onComplete  )
	end

end

function GameNetwork:isLoggedIn()

	if puggle.system:isIOS() then
		return puggle.gameCentre:isLoggedIn()
	elseif puggle.system:isKindle() then
		return puggle.gameCircle:isLoggedIn()
	elseif puggle.system:isAndroid() then
	    return puggle.gpgs:isLoggedIn()
	end

end

function GameNetwork:logout()

    if puggle.system:isIOS() then

	elseif puggle.system:isKindle() then

	elseif puggle.system:isAndroid() then
	    puggle.gpgs:logout()
	end

end

function GameNetwork:showSettings()

	if puggle.system:isIOS() then

	elseif puggle.system:isKindle() then

	elseif puggle.system:isAndroid() then
	    puggle.gpgs:showSettings()
	end

end

--- Destroys this GameNetwork object.
function GameNetwork:destroy()

end

--- Return the GameNetwork class definition.
return GameNetwork
