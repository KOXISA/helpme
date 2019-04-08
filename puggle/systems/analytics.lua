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
local Analytics = class( "Analytics" )

--- Required libraries.
local flurry
pcall( function() flurry = require( "plugin.flurry.analytics" ) end )

local google
pcall( function() google = require( "plugin.googleAnalytics" ) end )

--- Class variables.
Analytics.static.FLURRY = "flurry"
Analytics.static.GOOGLE = "google"

--- Localised functions.

--- Initiates a new Analytics object.
-- @param params Paramater table for the object.
-- @return The new object.
function Analytics:initialize( params )

	-- Set the name of this manager
	self.name = "analytics"

	-- Pre declare the provider
	self._provider = nil

	-- We're not currently initiated
	self._initiated = false

end

--- Initiates the individual provider.
-- @param provider The name of the provider, either 'google' or 'flurry'.
-- @param params Paramater table for the provider. For Google you'll need an 'appName' and a 'trackingID' and for Flurry you'll need an 'apiKey', plus optionally a 'crashReportingEnabked' and a 'logLevel'.
-- @param callback Optional callback for the Flurry events, if using Flurry.
function Analytics:init( provider, params, callback )

	-- Are we initiating flurry and do we have the plugin?
	if provider == Analytics.FLURRY and flurry then

		-- Listener function for the flurry provider
		local listener = function( event )

			if event.phase == "init" then  -- Successful initialisation

				-- We're now initiated
				self._initiated = true

		   end

		   -- Were we given a callback?
		   if callback then

			   -- If so then call it back
			   callback( event )

		   end

		end

		-- Set the provider
		self._provider = flurry

		-- Initiate flurry
		self._provider.init( listener, params )

	-- Are we initiating google and do we have the plugin?
	elseif provider == Analytics.GOOGLE and google then

		-- Set the provider
		self._provider = google

		-- Do we have an app name and a tracking id
		if params.appName and params.trackingID then

			-- Initiate google analytics
			self._provider.init( params.appName, params.trackingID )

			-- Assume we're now initiated
			self._initiated = true

		end

	end

	-- Store out the name of the provider
	self._providerName = provider

end

--- Checks if the provider is initiated.
-- @return True if it is, false otherwise.
function Analytics:isInitiated()
	return self._initiated
end

--- Gets the name of the provider.
-- @return The name.
function Analytics:getProviderName()
	return self._providerName
end

--- Logs an event.
-- @param name The name of the event ( if flurry ), or category ( if google ).
-- @param params The paramater table of optional values for flurry, or 'action, 'label', and 'value' for google.
function Analytics:logEvent( name, params )

	-- Do we have a prover set, and if so, is it initiated?
	if self._provider and self:isInitiated() then

		-- Are we using flurry?
		if self:getProviderName() == Analytics.FLURRY then

			-- Log the event
			self._provider.logEvent( name, params )

		-- Are we using google?
		elseif self:getProviderName() == Analytics.GOOGLE then

			-- Log the event
			self._provider.logEvent( name, params.action, params.label, params.value )

		end

	end

end

--- Logs a screen name.
-- @param name The name of the screen.
function Analytics:logScreenName( name )

	-- Do we have a prover set, and if so, is it initiated?
	if self._provider and self:isInitiated() then

		-- Are we using flurry?
		if self:getProviderName() == Analytics.FLURRY then

			-- Log the screen
			self:logEvent( "screen", { location = name } )

		-- Are we using google?
		elseif self:getProviderName() == Analytics.GOOGLE then

			-- Log the screen
			self._provider.logScreenName( name )

		end

	end

end

--- Starts a timed event. Only supported by Flurry.
-- @param name The name of the event.
-- @param params Optional table of paramaters for the event.
function Analytics:startTimedEvent( name, params )

	-- Do we have a prover set, and if so, is it initiated?
	if self._provider and self:isInitiated() then

		-- Are we using flurry?
		if self:getProviderName() == Analytics.FLURRY then

			-- Start the event
			self._provider.startTimedEvent( name, params )

		end

	end

end

--- Ends a timed event. Only supported by Flurry.
-- @param name The name of the event.
-- @param params Optional table of paramaters for the event.
function Analytics:endTimedEvent( name, params )

	-- Do we have a prover set, and if so, is it initiated?
	if self._provider and self:isInitiated() then

		-- Are we using flurry?
		if self:getProviderName() == Analytics.FLURRY then

			-- Start the event
			self._provider.endTimedEvent( name, params )

		end

	end

end

--- Return the Analytics class definition.
return Analytics
