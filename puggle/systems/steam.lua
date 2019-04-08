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
local Steam = class( "Steam" )

--- Required libraries.
local steamworks
pcall( function() steamworks = require( "plugin.steamworks" ) end )

--- Localised functions.

--- Static values
Steam.AvatarType = {}
Steam.AvatarType.Small = { name = "smallAvatar", size = 32 }
Steam.AvatarType.Medium = { name = "mediumAvatar", size = 64 }
Steam.AvatarType.Large = { name = "largeAvatar", size = 184 }

Steam.StatType = {}
Steam.StatType.Int = "int"
Steam.StatType.Float = "float"
Steam.StatType.AverageRate = "averageRate"

Steam.NotificationPosition = {}
Steam.NotificationPosition.TopLeft = "topLeft"
Steam.NotificationPosition.TopRight = "topRight"
Steam.NotificationPosition.BottomLeft = "bottomLeft"
Steam.NotificationPosition.BottomRight = "bottomRight"

Steam.PlayerScope = {}
Steam.PlayerScope.Global = "Global"
Steam.PlayerScope.GlobalAroundUser = "GlobalAroundUser"
Steam.PlayerScope.FriendsOnly = "FriendsOnly"

--- Initiates a new Steam object.
-- @param params Paramater table for the object.
-- @return The new object.
function Steam:initialize( params )

	-- Set the name of this manager
	self.name = "steam"

	if steamworks then
		self.appId = steamworks.appId
		self.appOwnerSteamId = steamworks.appOwnerSteamId
		self.userSteamId = steamworks.userSteamId
		self.isLoggedOn = steamworks.isLoggedOn
		self.canShowOverlay = steamworks.canShowOverlay
	end

end

--- Gets the user info for a certain user.
-- @param userSteamId The unique string ID of the user. Optional, defaults to the current user.
-- @return The user info.
function Steam:getUserInfo( userSteamId )
	if steamworks then
		return steamworks.getUserInfo( userSteamId )
	end
end

--- Gets the user info for a certain user.
-- @param type The type of image you want. Can be puggle.steam.AvatarType.Small, 'puggle.steam.AvatarType.Medium, or puggle.steam.AvatarType.Large.
-- @param userSteamId The unique string ID of the user. Optional, defaults to the current user.
-- @return The user image info.
function Steam:getUserImageInfo( type, userSteamId )
	if steamworks then
		return steamworks.getUserImageInfo( type.name, userSteamId )
	end
end

--- Gets the a stat for a certain user.
-- @param name The name of the stat.
-- @param type The type of stat you want. Can be puggle.steam.StatType.Int, puggle.steam.StatType.Float, or puggle.steam.StatType.AverageRate.
-- @param userSteamId The unique string ID of the user. Optional, defaults to the current user.
-- @return The stat value.
function Steam:getUserStatValue( name, type, userSteamId )
	if steamworks then
		steamworks.getUserStatValue
		{
			statName = name,
			type = type,
			userSteamId = userSteamId
		}
	end
end

--- Gets the information for a certain achievement.
-- @param name The name of the achievement.
-- @param userSteamId The unique string ID of the user. Optional, defaults to the current user.
-- @return The achievement info.
function Steam:getAchievementInfo( name, userSteamId )
	if steamworks then
		return steamworks.getAchievementInfo( name, userSteamId )
	end
end

--- Gets the image information for a certain achievement.
-- @param name The name of the achievement.
-- @return The achievement image info.
function Steam:getAchievementImageInfo( name )
	if steamworks then
		return steamworks.getAchievementImageInfo( name )
	end
end

--- Gets the information for a certain achievement.
-- @return A list of achievement names.
function Steam:getAchievementNames()
	if steamworks then
		return steamworks.getAchievementNames()
	end
end

--- Gets the progress made on a certain achievement.
-- @param name The name of the achievement.
-- @return The current progress as a table containing 'current', 'max', and 'percentage'.
function Steam:getAchievementProgress( name )
	if steamworks then
		return puggle.data:get( "steam-achievementProgress-" .. name )
	end
end

--- Sets the user info for a certain user.
-- @param arrayOfStats An array containing tables of stat details. Each table can contain 'statName', a 'type' that can be puggle.steam.StatType.Int, puggle.steam.StatType.Float, or puggle.steam.StatType.AverageRate, a numeric 'value', and a numeric 'sessionTimeLength' that is only required if the stat is a 'averageRate' type.
function Steam:setUserStatValues( arrayOfStats )
	if steamworks then
		steamworks.setUserStatValues( arrayOfStats )
	end
end

--- Sets the progress made on a certain achievement.
-- @param name The name of the achievement.
-- @param value Integer representing the current progress made towards te achievement. Ranging between 0 and maxValue.
-- @param maxValue Integer defining the maximum progression value until the achievement will be unlocked.
-- @return True if the progress was updated, false otherwise.
function Steam:setAchievementProgress( name, value, maxValue )
	if steamworks then
		puggle.data:set( "steam-achievementProgress-" .. name, { current = value, max = maxValue, percentage = puggle.maths:calculatePercentage( value, maxValue ) } )
		steamworks.setAchievementProgress( name, value, maxValue )
	end
end

--- Unlocks an achievement.
-- @param name The name of the achievement.
-- @return True if it was unlocked, false otherwise.
function Steam:setAchievementUnlocked( name )
	if steamworks then
		return steamworks.setAchievementUnlocked( name )
	end
end

-- Sets where Steam's notification popups will appear within the application window.
-- @param The position for the notifications. Must be puggle.steam.NotificationPosition.TopLeft, puggle.steam.NotificationPosition.TopRight, puggle.steam.NotificationPosition.BottomLeft, or puggle.steam.NotificationPosition.BottomRight.
function Steam:setNotificationPosition( position )
	if steamworks then
		steamworks.setNotificationPosition( position )
	end
end

-- Displays a Steam image by its unique imageHandle property.
-- @param parent Display group in which to insert the image. Optional.
-- @param imageHandle Unique identifier of the Steam image to load and display.
-- @param width The content width at which to scale the Steam image.
-- @param height The content height at which to scale the Steam image.
-- @return A display object.
function Steam:newImageRect( parent, imageHandle, width, height )
	if steamworks then
		return steamworks.newImageRect( parent, imageInfo.imageHandle, width, height )
	end
end

-- Loads a Steam image to a texture by its unique imageHandle.
-- @param imageHandle Unique identifier of the Steam image to load and display.
-- @return A texture object.
function Steam:newTexture( imageHandle )
	if steamworks then
		return steamworks.newTexture( imageHandle )
	end
end

-- Clears all stat data to nil for the current user.
-- @return True if the reset request was successful, false otherwise.
function Steam:resetUserStats()
	if steamworks then
		return steamworks.resetUserStats()
	end
end

-- Clears all stat data to nil and re-locks all unlocked achievements for the current user. Warning, this should not be used for non-debug purposes.
-- @return True if the reset request was successful, false otherwise.
function Steam:resetUserProgress()
	if steamworks then
		return steamworks.resetUserProgress()
	end
end

-- Displays a Steam overlay on top of the application window for another user.
-- @param userSteamId The id of the user for the overlay.
-- @param overlayName Unique name of the overlay to be displayed from among the following options; 'steamid', 'chat', 'jointrade', 'stats', 'achievements', 'friendadd', 'friendremove', 'friendrequestaccept', and 'friendrequestignore'.
-- @return True if it was shown, false otherwise.
function Steam:showUserOverlay( userSteamId, overlayName )
	if steamworks then
		return steamworks.showUserOverlay( userSteamId, overlayName )
	end
end

-- Displays a Steam overlay on top of the application window using the Steam browser.
-- @param url The url to open.
-- @return True if it was shown, false otherwise.
function Steam:showWebOverlay( url )
	if steamworks then
		return steamworks.showWebOverlay( url )
	end
end

-- Displays a Steam overlay on top of the application window to show information about another app.
-- @param appId The id of the other app.
-- @return True if it was shown, false otherwise.
function Steam:showStoreOverlay( appId )
	if steamworks then
		return steamworks.showStoreOverlay( appId )
	end
end

-- Displays a Steam overlay on top of the application window related to the game currently being played.
-- @param overlayName The name of the overlay. Can be either 'Achievements', 'Community', 'Friends', 'OfficialGameGroup', 'Players', 'Settings', or 'Stats'.
-- @return True if it was shown, false otherwise.
function Steam:showGameOverlay( overlayName )
	if steamworks then
		return steamworks.showGameOverlay( overlayName )
	end
end

-- Asynchronously fetches game progression data such as achievements and stats for one user from Steam's server.
-- @param userSteamId The unique string ID of the user. Optional, defaults to the current user.
-- @return True if the request was successfully sent to Steam, false otherwise.
function Steam:requestUserProgress( userSteamId )
	if steamworks then
		return steamworks.requestUserProgress( userSteamId )
	end
end

-- Set a high score on a leaderboard. Internet access is required and requests won't be cached.
-- @param leaderboardName The name of the leaderboard.
-- @param value The new high score.
-- @param listener Function which will receive the result of the request via a setHighScore event.
function Steam:requestSetHighScore( leaderboardName, value, listener )
	if steamworks then
		steamworks.requestSetHighScore
		{
		    leaderboardName = leaderboardName,
		    value = value,
		    listener = listener
		}
	end
end

-- Asynchronously fetches information about one leaderboard such as its entry count, display/value type, sort order, etc.
-- @param leaderboardName The name of the leaderboard.
-- @param listener Function which will receive the result of the request via a leaderboardInfo event.
function Steam:requestLeaderboardInfo( leaderboardName, listener )
	if steamworks then
		steamworks.requestLeaderboardInfo
		{
		    leaderboardName = leaderboardName,
		    listener = listener
		}
	end
end

-- Asynchronously fetches entries from one leaderboard.
-- @param leaderboardName The name of the leaderboard.
-- @param startIndex Optional integer value specifying the first entry to fetch from the leaderboard.
-- @param endIndex Optional integer value specifying the last entry to fetch from the leaderboard.
-- @param playerScope Optional parameter providing a way to filter the entries based on friends or nearby players: Steam.PlayerScope.Global, Steam.PlayerScope.GlobalAroundUser, or Steam.PlayerScope.FriendsOnly.
-- @param listener Function which will receive the result of the request via a leaderboardEntries event.
function Steam:requestLeaderboardEntries( leaderboardName, startIndex, endIndex, playerScope, listener )
	if steamworks then
		steamworks.requestLeaderboardEntries
		{
		    leaderboardName = leaderboardName,
		    playerScope = playerScope,
		    startIndex = startIndex,
		    endIndex = endIndex,
			listener = listener,
		}

	end
end

-- Asynchronously fetches the number of people running the application globally from Steam's server, not counting the currently logged in user.
-- @param listener Function which will receive the result of the request via an activePlayerCount event.
function Steam:requestActivePlayerCount( listener )
	if steamworks then
		steamworks.requestActivePlayerCount( listener )
	end
end

-- Adds an event listener.
-- @param name The name of the event.
-- @param listener The listener to be invoked when the plugin dispatches an event with the correct name.
-- @return True if it was successfully added, false otherwise.
function Steam:addEventListener( name, listener )
	if steamworks then
		steamworks.addEventListener( name, listener )
	end
end

-- Removes a listener that was previously added.
-- @param name The name of the event.
-- @param listener Reference to the same listener that was originally added.
-- @return True if it was successfully removed, false otherwise.
function Steam:removeEventListener( name, listener )
	if steamworks then
		return steamworks.removeEventListener( name, listener )
	end
end

--- Updated handler for this system.
-- @param dt The delta time of the game.
function Steam:update( dt )

	if steamworks then
		self.appId = steamworks.appId
		self.appOwnerSteamId = steamworks.appOwnerSteamId
		self.userSteamId = steamworks.userSteamId
		self.isLoggedOn = steamworks.isLoggedOn
		self.canShowOverlay = steamworks.canShowOverlay
	end

end

--- Destroys this Steam object.
function Steam:destroy()

end

--- Return the Steam class definition.
return Steam
