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
local GPGS = class( "GPGS" )

--- Required libraries.
local gpgs = require( "plugin.gpgs" )

--- Localised functions.

--- Initiates a new GPGS object.
-- @param params Paramater table for the object.
-- @return The new object.
function GPGS:initialize( params )

	-- Set the name of this manager
	self.name = "gpgs"

	self._initiated = false

	local listener = function( event )

		if event.isError then

		else
			self._initiated = true
		end

	end

	-- Ensure we have the gpgs plugin
	if gpgs then

		-- Try to initiate
		gpgs.init( listener )

	end

end

--- Initiates a new GPGS object.
-- @param params Paramater table for the object.
-- @return The new object.
function GPGS:login( userInitiated, onComplete )

	local listener = function( event )

		if event.phase == "logged in" then

		elseif event.phase == "logged out" then

		end

		if onComplete and type( onComplete ) then
			onComplete( self:isLoggedIn() )
		end

	end

	if gpgs then
		gpgs.login
		{
			userInitiated = userInitiated,
			listener = listener
		}
	end


end

--- Logs the current user out of gpgs.
function GPGS:logout()
	if gpgs and self:isLoggedIn() then
		gpgs.logout()
	end
end

--- Gets the current google play app id.
-- @returns The id.
function GPGS:getAppId()
	if gpgs then
		return gpgs.getAppId()
	end
end

--- Requests the current player's account name.
-- @param onComplete Listener function that will be called with 'accountName' as the only argument when it has been retrieved.
function GPGS:getAccountName( onComplete )
	if gpgs then

		local listener = function( event )

			if event.isError then

			else
				if onComplete and type( onComplete ) == "function" then
					onComplete( event.accountName )
				end
			end

		end

	end
end


--- Checks if we're currently logged into gpgs.
-- @returns True if we are, false otherwise.
function GPGS:isLoggedIn()
	if gpgs then
		return gpgs.isConnected()
	end
end

--- Enables extra debug information logging while using the plugin.
function GPGS:enableDebug()
	if gpgs then
		gpgs.enableDebug()
	end
end

--- Opens the Google Play Games Services settings windows for the current app.
function GPGS:showSettings()
	if gpgs then
		gpgs.showSettings()
	end
end

function GPGS:showLeaderboards( params )
	if gpgs then
		gpgs.leaderboards.show( params )
	end
end

--- Shows all achievements.
function GPGS:showAchievements()
	if gpgs then
		gpgs.achievements.show()
	end
end

--- Unlocks an achievement.
-- @param params Contains parameters for the call.
function GPGS:unlockAchievement( params )
	if gpgs then
		gpgs.achievements.unlock( params )
	end
end

--- Reveals a hidden achievement.
-- @param params Contains parameters for the call.
function GPGS:revealAchievement( params )
	if gpgs then
		gpgs.achievements.reveal( params )
	end
end

--- Sets an incremental achievement to tge specified number of steps.
-- @param params Contains parameters for the call.
function GPGS:setAchievementSteps( params )
	if gpgs then
		gpgs.achievements.setSteps( params )
	end
end

--- Increments an incremental achievement by the specified number of steps.
-- @param params Contains parameters for the call.
function GPGS:incrementAchievement( params )
	if gpgs then
		gpgs.achievements.increment( params )
	end
end

--- Retrieves information about all achievements available in the game.
-- @param params Contains parameters for the call.
function GPGS:loadAchievements( params )
	if gpgs then
		gpgs.achievements.load( params )
	end
end

--- Retrieves scores from a specified leaderboard.
-- @param params Contains parameters for the call.
function GPGS:loadScores( params )
	if gpgs then
		gpgs.leaderboards.loadScores( params )
	end
end

--- Submits a score to a specific leaderboard.
-- @param params Contains parameters for the call.
function GPGS:submit( params )
	if gpgs then
		gpgs.leaderboards.submit( params )
	end
end

--- Destroys this GPGS object.
function GPGS:destroy()

end

--- Return the GPGS class definition.
return GPGS
