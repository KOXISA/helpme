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
local Adverts = class( "Adverts" )

--- Required libraries.

--- Localised functions.

--- Class variables.
Adverts.static.CHARTBOOST = "chartboost"
Adverts.static.ADMOB = "admob"
Adverts.static.UNITY = "unity"
Adverts.static.ADCOLONY = "adcolony"
Adverts.static.REVMOB = "revmob"

--- Initiates a new Adverts object.
-- @param params Paramater table for the object.
-- @return The new object.
function Adverts:initialize( params )

	-- Set the name of this manager
	self.name = "adverts"

	self._providers = {}
	self._adverts = {}

	Runtime:addEventListener( "advert", self )

end

function Adverts:registerProvider( name, params )
	if name == Adverts.static.CHARTBOOST and puggle.chartboost then
		puggle.chartboost:init( params )
	elseif name == Adverts.static.REVMOB and puggle.revmob then
		puggle.revmob:init( params )
	elseif name == Adverts.static.ADMOB and puggle.admob then
		puggle.admob:init( params )
	end
	self._providers[ #self._providers + 1 ] = name
end

function Adverts:add( name, params )
	self._adverts[ name ] = params
end

--- Show an advert.
-- @param name The name of the advert.
function Adverts:show( name )

	local ad = self._adverts[ name ]

	if ad then

		local data = ad[ "admob" ]

		if data and puggle[ "admob" ] then
			puggle.admob:show( data.type, { y = data.y, bgColor = data.bgColor } )
		end

	end

end

--- Load an advert.
-- @param name The name of the advert.
function Adverts:load( name )

	local ad = self._adverts[ name ]

	if ad then

		local data = ad[ "admob" ]

		if data and puggle[ "admob" ] then
			puggle.admob:load( data.type, { adUnitId = data.id[ puggle.system:getPlatform() ], childSafe = data.childSafe, designedForFamilies = data.designedForFamilies, keywords = data.keywords } )
		end

	end

end

--- Checks if an advert has been loaded.
-- @param name The name of the advert.
-- @return True if it has been, false otherwise.
function Adverts:isLoaded( name )

	local ad = self._adverts[ name ]

	if ad then

		local data = ad[ "admob" ]

		if data and puggle[ "admob" ] then
			return puggle.admob:isLoaded( data.type )
		end

	end

end

--- Hide an advert.
-- @param name The name of the advert.
function Adverts:hide( name )

	local ad = self._adverts[ name ]

	if ad then

		local data = ad[ "admob" ]

		if data and puggle[ "admob" ] then
			puggle.admob:hide()
		end

	end

end

--- Loads all adverts for a specified provider.
-- @param provider The name of the provider.
function Adverts:loadAll( provider )
	for name, _ in pairs( self._adverts ) do
		self:load( name, provider )
	end
end

function Adverts:advert( event )

	local provider = event.provider
	local phase = event.phase
	local data = event.data
	local type = event.type

	if phase == "failed" then

	elseif phase == "reward" or phase == "rewardedVideoCompleted" then

	end

end

--- Destroys this Adverts object.
function Adverts:destroy()
	Runtime:removeEventListener( "advert", self )
end

--- Return the Adverts class definition.
return Adverts
