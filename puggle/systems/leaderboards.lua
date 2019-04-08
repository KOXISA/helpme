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
local Leaderboards = class( "Leaderboards" )

--- Required libraries.

--- Localised functions.

--- Initiates a new Leaderboards object.
-- @param params Paramater table for the object.
-- @return The new object.
function Leaderboards:initialize( params )

	-- Set the name of this manager
	self.name = "leaderboards"

	-- Table to store leaderboards
	self._leaderboards = {}

end

--- Adds a leaderboard to the system.
-- @param name The name of the leaderboard.
-- @param ids Table of service specific ids for platforms.
function Leaderboards:add( name, ids )
	self._leaderboards[ name ] = self._leaderboards[ name ] or {}
	for k, v in pairs( ids or {} ) do
		self._leaderboards[ name ][ k ] = v
	end
end

--- Gets the service specific name of a registered leaderboard.
-- @param name The registered name of the leaderboard.
-- @param platform The name of the platform. Optional, defaults to the current one.
function Leaderboards:get( name, platform )
	if self._leaderboards[ name ] then
		return self._leaderboards[ name ][ platform or puggle.system:getPlatform() ]
	end
end

function Leaderboards:setHighScore( name, score )
	if puggle.system:isIOS() then
		puggle.gameCentre:setHighScore( self:get( name ), score )
	elseif puggle.system:isAndroid() then

	    puggle.gpgs:submit
		{
			leaderboardId = self:get( name ),
			score = score
		}

	end
end

--- Shows a specific leaderboard.
-- @param name The name of the leaderboard. Optional, will default to showing all of them.
function Leaderboards:show( name )

	if puggle.system:isIOS() then

		if name then
			name = self:get( name )
		end

	    puggle.gameCentre:showLeaderboards( name )

	elseif puggle.system:isKindle() then

	elseif puggle.system:isAndroid() then

		local params = {}

		if name then
			params.leaderboardId = self:get( name )
		else
			params = nil
		end

	    puggle.gpgs:showLeaderboards( params )

	end

end

function Leaderboards:getPlayerScore( name, onComplete )

	if puggle.system:isIOS() then

	elseif puggle.system:isKindle() then

	elseif puggle.system:isAndroid() then

		local listener = function( event )
			if onComplete and type( onComplete ) == "function" then
				if event.isError then
					onComplete( nil )
				else
					onComplete( event.scores[ 1 ] )
				end
			end
		end

		if name then

			local params = {}

			params.leaderboardId = self:get( name )
			params.position = "single"
			params.reload = true
			params.listener = listener

			puggle.gpgs:loadScores( params )

		end

	end

end

--- Destroys this Leaderboards object.
function Leaderboards:destroy()

end

--- Return the Leaderboards class definition.
return Leaderboards
