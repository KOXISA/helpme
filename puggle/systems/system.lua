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
local System = class( "System" )

--- Required libraries.

--- Localised functions.
local sub = string.sub

--- Initiates a new System object.
-- @param params Paramater table for the object.
-- @return The new object.
function System:initialize( params )

	-- Set the name of this manager
	self.name = "system"

end

--- Gets the simple tag for each platform.
-- @return The name of the platform. Either 'macos', 'win32', 'android', 'ios', 'tvos', 'winphone', or 'html5'.
function System:getPlatform()
	return system.getInfo( "platform" )
end

--- Gets the environment name.
-- @return The name of the environment. Either 'device' or 'simulator'.
function System:getEnvironment()
    return system.getInfo( "environment" )
end

--- Gets the model name.
-- @return The name of the model.
function System:getModel()
    return system.getInfo( "model" )
end

--- Gets the version string.
-- @return The version.
function System:getVersion()
	return system.getInfo( "appVersionString" )
end

--- Checks if the game is currently running on a device.
-- @return True if it is, false otherwise.
function System:isDevice()
    return self:getEnvironment() == "device"
end

--- Checks if the game is currently running in the simulator.
-- @return True if it is, false otherwise.
function System:isSimulator()
    return self:getEnvironment() == "simulator"
end

--- Checks if the game is currently running on a TV based console.
-- @return True if it is, false otherwise.
function System:isTV()
    if self:isAppleTV() or self:isAmazonTV() or self:isAndroidTV() then
        return true
    end
end

--- Checks if the game is currently running on an AppleTV.
-- @return True if it is, false otherwise.
function System:isAppleTV()
    return self:getPlatform() == "tvos"
end

--- Checks if the game is currently running on an iOS device.
-- @return True if it is, false otherwise.
function System:isIOS()
    return self:getPlatform() == "ios"
end

--- Checks if the game is currently running on an Android device.
-- @return True if it is, false otherwise.
function System:isAndroid()
    return self:getPlatform() == "android"
end

--- Checks if the game is currently running on an OSX machine.
-- @return True if it is, false otherwise.
function System:isOSX()
    return self:getPlatform() == "macos"
end

--- Checks if the game is currently running on a Windows machine.
-- @return True if it is, false otherwise.
function System:isWindows()
    return self:getPlatform() == "win32"
end

--- Checks if the game is currently running on a Linux machine.
-- @return True if it is, false otherwise.
function System:isLinux()
    return self:getPlatform() == "linux"
end

--- Checks if the game is currently running on an Amazon Kindle device.
-- @return True if it is, false otherwise.
function System:isKindle()
	return self:isDevice() and ( self:getModel() == "Kindle Fire" or self:getModel() == "WFJWI" or sub( self:getModel(), 1, 2 ) == "KF" )
end

--- Checks if the game is currently running on an Amazon FireTV.
-- @return True if it is, false otherwise.
function System:isAmazonTV()
    return self:getModel() == "AFTB"
end

--- Checks if the game is currently running on a desktop.
-- @return True if it is, false otherwise.
function System:isDesktop()
    return self:isOSX() or self:isWindows() or self:isLinux()
end

--- Checks if the game is currently running on a mobile device.
-- @return True if it is, false otherwise.
function System:isMobile()
	return self:isIOS() or self:isAndroid()
end

--- Checks if the game is currently in a browser.
-- @return True if it is, false otherwise.
function System:isWeb()
	return self:getPlatform() == "html5"
end

--- Gets the name of the store that the app was built for.
-- @return The name of the store.
function System:getTargetStore()
	return system.getInfo( "targetAppStore" )
end

--- Gets the link to the store for the current app.
-- @return The name of the store.
function System:getStoreLink()

	if self:getTargetStore() == "apple" then
		local id = self:getAppID( "ios" )
		if id then
			return "https://itunes.apple.com/us/app/" .. id.name .. "/id" .. id.id .. "?ls=1&mt=8"
		end
	elseif self:getTargetStore() == "amazon" then
		return "amzn://android?p=" .. self:getAppID( "amazon" )
	elseif self:getTargetStore() == "gameStick" then

	elseif self:getTargetStore() == "google" then
		return "https://play.google.com/store/apps/details?id=" .. self:getAppID( "android" )
	elseif self:getTargetStore() == "ouya" then

	elseif self:getTargetStore() == "windows" then

	elseif self:getTargetStore() == "none" then
		return self:getAppID( "none" )
	end

end

--- Shows other games.
function System:showOtherGames()

	if puggle.config:get( "otherGames" ) then
		local store = self:getTargetStore()
		local links = puggle.config:get( "otherGames" ) or {}
		if links[ store ] then
			system.openURL( links[ store ] )
		end
	end

end

--- Checks if the game is currently running on an Android TV.
-- @return True if it is, false otherwise.
function System:isAndroidTV()

	-- Is this the first time we've checked
	if self._isAndroidTV == nil then

		-- Set it to false by default
		self._isAndroidTV = false

		-- Work out of this is an AndroidTV device
		if self._launchArguments then

			local categories = self._launchArguments[ "androidIntent" ][ "categories" ]
			for i = 1, #categories, 1 do
				if categories[ i ] == "android.intent.category.LEANBACK_LAUNCHER" then
					self._isAndroidTV = true
					break
				end
			end

		end

	end

    return self:isDevice() and self._isAndroidTV

end

--- Registers the launch arguments. Call in 'main.lua'.
-- @param arguments The arguments.
function System:registerLaunchArguments( arguments )
	self._launchArguments = arguments
end

--- Shows the app store popup for the current app. You must have already registered the 'ios' or 'tvOS' app id via puggle.system:registerAppID( platform, id ).
function System:showAppStore()
	local options =
	{
	   iOSAppId = self:isIOS() and self:getAppID( "ios" ).id,
	   tvOSAppId = self:isAppleTV() and self:getAppID( "tvOS" ),
	   androidAppPackageName = self:isAndroid() and self:getAppID( "android" ),
	   supportedAndroidStores = { "google", "amazon" }
	}

	if native.canShowPopup( "appStore" ) then
		native.showPopup( "appStore", options )
	else
		system.openURL( puggle.system:getStoreLink() )
	end
end

--- Registers an app ID for a specific platform.
-- @param platform The platform to register for. Can be 'ios', 'tvOS', or pretty much anything else. The first two are the important ones.
-- @param id The id to set.
function System:registerAppID( platform, id )
	self._appIDs = self._appIDs or {}
	self._appIDs[ string.lower( platform ) ] = id
end

--- Gets a registered app ID for a specific platform.
-- @param platform The platform to check for.
-- @return The id for the platform.
function System:getAppID( platform )
	return self._appIDs[ string.lower( platform ) ]
end

--- Makes a capture of the current screen, centres it, and then hides it.
-- @return The capture as a display object.
function System:captureScreen()

	local capture = display.captureScreen()
	capture.x = display.contentCenterX
    capture.y = display.contentCenterY
	capture.isVisible = false

	return capture

end

--- Saves a display object out to a file, then deletes the capture.
-- @param capture The display object to save.
-- @param baseDir The base directory to save the file to. Optional, defaults to system.TemporaryDirectory.
-- @return A table containing 'filename' and 'baseDir'.
function System:saveCapture( capture, baseDir )

	capture.isVisible = true
	local filename = os.time() .. ".jpg"
	local params = { filename = filename, baseDir = baseDir or system.TemporaryDirectory }
	display.save( capture, params )
	capture.isVisible = false

	local t
	local destroy = function()

		if t then
			timer.cancel( t )
		end
		t = nil

		display.remove( capture )
		capture = nil

	end
	t = timer.performWithDelay( 250, destroy, 1 )

	return params
end

--- Closes the current application. Not supported on iOS.
function System:requestExit()
	native.requestExit()
end

--- Return the System class definition.
return System
