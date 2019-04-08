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
local Achievements = class( "Achievements" )

--- Required libraries.

--- Localised functions.

--- Initiates a new Achievements object.
-- @param params Paramater table for the object.
-- @return The new object.
function Achievements:initialize( params )

	-- Set the name of this manager
	self.name = "achievements"

	-- Table to store achievements
	self._achievements = {}

end

--- Adds an achievement to the system.
-- @param name The name of the achievement.
-- @param ids Table of service specific ids for platforms.
function Achievements:add( name, ids )
	self._achievements[ name ] = self._achievements[ name ] or {}
	for k, v in pairs( ids or {} ) do
		self._achievements[ name ][ k ] = v
	end
end

--- Gets the service specific name of a registered achievement.
-- @param name The registered name of the achievement.
-- @param platform The name of the platform. Optional, defaults to the current one.
-- @return The achievement name.
function Achievements:get( name, platform )
	if self._achievements[ name ] then
		return self._achievements[ name ][ platform or puggle.system:getPlatform() ]
	end
end

--- Shows the achievements for this game.
function Achievements:show()

	if puggle.system:isIOS() then
		puggle.gameCentre:showAchievements()
	elseif puggle.system:isKindle() then

	elseif puggle.system:isAndroid() then
	    puggle.gpgs:showAchievements()
	end

end

--- Unlocks a registered achievement.
-- @param name The name of the achievement.
-- @param params Additional paramaters for the call.
function Achievements:unlock( name, params )

	local id = self:get( name )

	local params = params or {}

	if puggle.system:isIOS() then

		local onComplete = function( event )
			self[ "_triedToUnlock" .. name ] = false
			puggle.data:set( "puggle-achievements-" .. name .. "unlocked", event.isCompleted )
		end

		if not puggle.data:get( "puggle-achievements-" .. name .. "unlocked" ) and not self[ "_triedToUnlock" .. name ] then
			self[ "_triedToUnlock" .. name ] = true
			params.identifier = id
			params.showsCompletionBanner = params.showsCompletionBanner == nil and true or params.showsCompletionBanner
			puggle.gameCentre:unlockAchievement( params, onComplete )
		end

	elseif puggle.system:isKindle() then

	elseif puggle.system:isAndroid() then
	    puggle.gpgs:unlockAchievement
		{
			achievementId = id
		}
	end

end

--- Increments an incremental achievement.
-- @param name The name of the achievement.
-- @param steps The number of steps. Optional, defaults to 1.
function Achievements:increment( name, steps )

	local id = self:get( name )

	if puggle.system:isIOS() then

	elseif puggle.system:isKindle() then

	elseif puggle.system:isAndroid() then
		puggle.gpgs:incrementAchievement
		{
			achievementId = id,
			steps = steps or 1
		}
	end

end

--- Sets the number of steps on an incremental achievement.
-- @param name The name of the achievement.
-- @param steps The number of steps.
function Achievements:setSteps( name, steps )

	local id = self:get( name )

	if puggle.system:isIOS() then

	elseif puggle.system:isKindle() then

	elseif puggle.system:isAndroid() then
		puggle.gpgs:setAchievementSteps
		{
			achievementId = id,
			steps = steps
		}
	end

end

--- Reveals a hidden achievement.
-- @param name The name of the achievement.
function Achievements:reveal( name )

	local id = self:get( name )

	if puggle.system:isIOS() then

	elseif puggle.system:isKindle() then

	elseif puggle.system:isAndroid() then
		puggle.gpgs:revealAchievement
		{
			achievementId = id
		}
	end

end

--- Destroys this Achievements object.
function Achievements:destroy()

end

--- Return the Achievements class definition.
return Achievements
