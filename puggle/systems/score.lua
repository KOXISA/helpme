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
local Score = class( "Score" )

--- Required libraries.

--- Localised functions.

--- Initiates a new Score object.
-- @param params Paramater table for the object.
-- @return The new object.
function Score:initialize( params )

	-- Set the name of this manager
	self.name = "score"

	self._scoreboards = {}

	self._baseURL = "http://dreamlo.com/lb/"

end

--- Add a new scoreboard. This uses a private and public key of a Dreamlo scoreboard - http://dreamlo.com/
-- @param name The name of the board.
-- @param private The private code.
-- @param public The public code.
function Score:addScoreboard( name, private, public )

	self._scoreboards[ name ] =
	{
		name = name,
		private = private,
		public = public
	}

end

--- Get some scores.
-- @param name The name of the scoreboard.
-- @param onComplete Listener function for the scores.
-- @param ascending True if you want to get the scores sorted in ascending order. Optional, defaults to false.
-- @param sortedBySeconds True if you want to get the scores sorted by seconds. Optional, defaults to false.
-- @param sortedByDate True if you want to get the scores sorted by date. Optional, defaults to false.
-- @param countOrStart The total scores to get. Or, if using a range then the start of the range. Optional, defaults to all of them.
-- @param range The total number of rows to get if doing a range. Optional.
function Score:getScores( scoreboard, onComplete, ascending, sortedBySeconds, sortedByDate, countOrStart, range )

	if self._scoreboards[ scoreboard ] then

		local url = self._baseURL .. self._scoreboards[ scoreboard ].public .. "/json"

		if sortedBySeconds then
			url = url .. "-seconds"
		end

		if sortedByDate then
			url = url .. "-date"
		end

		if ascending then
			url = url .. "-asc"
		end

		if countOrStart then
			url = url .. "/" .. countOrStart
		end

		if range then
			url = url .. "/" .. range
		end

		local listener = function( event )

            if ( event.isError ) then
                print( "Network error: ", event.response )
            else
				local response = puggle.utils:jsonDecode( event.response )

				local scores = response[ "dreamlo" ][ "leaderboard" ][ "entry" ]

				if onComplete then
					onComplete( scores )
				end

            end
        end

        network.request( url, "GET", listener )

	end

end

--- Get a specific player's score.
-- @param name The name of the scoreboard.
-- @param onComplete Listener function for the scores.
-- @param playerName The name of a player.
function Score:getPlayerScore( scoreboard, onComplete, playerName )

	local url = self._baseURL .. self._scoreboards[ scoreboard ].public .. "/pipe-get/" .. playerName

	local listener = function( event )

		if ( event.isError ) then
			print( "Network error: ", event.response )
		else

			local data = puggle.utils:splitString( event.response, "|" )

			local entry = {}
			entry.player = data[ 1 ]
			entry.score = data[ 2 ]
			entry.seconds = data[ 3 ]
			entry.text = data[ 4 ]
			entry.date = data[ 5 ]
			entry.position = data[ 6 ]

			if onComplete then
				onComplete( entry )
			end

		end
	end

	network.request( url, "GET", listener )

end

--- Add a new score to a scoreboard.
-- @param scoreboard The name of the board for the score.
-- @param playerName The name of the player. If the same name is added twice, we use the higher score.
-- @param score The score to add.
-- @param seconds The number of seconds it took for the score to be achieved. Optional.
-- @param text Arbritary text you'd like appended to the listing. Optional.
function Score:newScore( scoreboard, playerName, score, seconds, text )

	if self._scoreboards[ scoreboard ] then

		local url = self._baseURL .. self._scoreboards[ scoreboard ].private .. "/add/" .. playerName .. "/" .. score .. "/" .. ( seconds or 0 ) .. "/" .. ( text or "-" )

		local listener = function( event )

            if ( event.isError ) then
                print( "Network error: ", event.response )
            else
                print( "Score of " .. score .. " in " .. ( seconds or "NIL" ) .. " seconds with the text '" .. ( text or "" ) .. "' added for '" .. playerName .. "' on '" .. scoreboard .. "'"  )
            end
        end

        network.request( url, "GET", listener )

	end

end

--- Delete the score for a certain player.
-- @param scoreboard The name of the board that the score is on.
-- @param playerName The name of the player.
function Score:deleteScore( scoreboard, playerName )

	if self._scoreboards[ scoreboard ] then

		local url = self._baseURL .. self._scoreboards[ scoreboard ].private .. "/delete/" .. playerName

		local listener = function( event )

            if ( event.isError ) then
                print( "Network error: ", event.response )
            else
                print( "Scores deleted for '" .. playerName .. "' on '" .. scoreboard .. "'" )
            end
        end

        network.request( url, "GET", listener )

	end

end

--- Clears all scores on a scoreboard.
-- @param scoreboard The name of the board that the scores are on.
function Score:clearScores( scoreboard )

	if self._scoreboards[ scoreboard ] then

		local url = self._baseURL .. self._scoreboards[ scoreboard ].private .. "/clear"

		local listener = function( event )

            if ( event.isError ) then
                print( "Network error: ", event.response )
            else
                print( "Scores cleared for '" .. scoreboard .. "'" )
            end
        end

        network.request( url, "GET", listener )

	end

end

--- Destroys this Score object.
function Score:destroy()
	self._scoreboards = nil
end

--- Return the Score class definition.
return Score
