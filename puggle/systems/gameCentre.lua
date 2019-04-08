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
local GameCentre = class( "GameCentre" )

--- Required libraries.
local gameNetwork = require( "gameNetwork" )

--- Localised functions.

--- Initiates a new GameCentre object.
-- @param params Paramater table for the object.
-- @return The new object.
function GameCentre:initialize( params )

	-- Set the name of this manager
	self.name = "gameCentre"

	-- Flag to tell us if we're logged in or not
	self._loggedIn = false

	-- Register a system event handler
	Runtime:addEventListener( "system", self )

end

--- Logs the user into game centre.
function GameCentre:login()

	local callback = function( event )

		-- If the sign in window is shown then pause the game
	    if event.type == "showSignIn" then
	        puggle:pause()
	    elseif event.data then -- Other wise we logged in fine, make sure to resume the game
			puggle:resume()
	        self._loggedIn = true
	    end
	end

	-- Ensure we have the gameNetwork plugin
	if gameNetwork then

		-- Try to initiate
		gameNetwork.init( "gamecenter", callback )

	end

end

--- Checks if we're currently logged into game centre.
-- @returns True if we are, false otherwise.
function GameCentre:isLoggedIn()
	return self._loggedIn
end

--- System event handler for the GameCentre system.
-- @param event Event table for this event.
function GameCentre:system( event )

	-- If the application just started, try to login to game centre
	if event.type == "applicationStart" then
        self:login()
        return true
    end

end

function GameCentre:show( command, params )

	if gameNetwork then
		gameNetwork.show( command, params )
	end

end

function GameCentre:request( command, params )

	if gameNetwork then
		gameNetwork.request( command, params )
	end

end

function GameCentre:showLeaderboards( category )
	self:show( "leaderboards", { leaderboard = { category = category }, listener = listener } )
end

function GameCentre:showAchievements( listener )
	self:show( "achievements", { listener = listener } )
end

function GameCentre:setHighScore( category, value, listener )
	self:request( "setHighScore", { localPlayerScore = { category = category, value = value }, listener = listener } )
end

function GameCentre:unlockAchievement( params, onComplete )
	local listener = function( event )
		if onComplete and type( onComplete ) == "function" then
			onComplete( event.data )
		end
	end
	self:request( "unlockAchievement", { achievement = params, listener = listener } )
end

--- Destroys this GameCentre object.
function GameCentre:destroy()

	-- Remove the system event handler
	Runtime:removeEventListener( "system", self )

end

--- Return the GameCentre class definition.
return GameCentre
