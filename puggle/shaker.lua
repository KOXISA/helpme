--[[---------------------------------------
ScreenShake
	The crux of this code was found on the
	Corona Forums many moons ago. If anyone
	can remember who originally wrote it,
	please let me know!
--]]---------------------------------------

-- Middleclass library.
local class = require( "puggle.ext.middleclass" )

--- Class creation.
local Shaker = class( "Shaker" )

-- Required libraries

-- Localised functions
local performWithDelay = timer.performWithDelay
local cancel = timer.cancel
local random = math.random

-- Localised variables

------------------
--	CONSTRUCTOR --
------------------

--- Initiates a new Scene object.
-- @param params Paramater table for the object.
-- @return The new object.
function Shaker:initialize( params )

	self._count = 0
    self._power = { x = 20, y = 20 }
    self._period = 2

	self:setStage( display.currentStage )

end

-----------------------
--	PUBLIC FUNCTIONS --
-----------------------


function Shaker:setStage( stage )
	self._stage = stage
end

function Shaker:getStage()
	return self._stage
end

--- Sets the value of the shaker period.
-- @param value The new value.
function Shaker:setPeriod( value )
	self._period = value
end

--- Gets the value of the shaker period.
-- @return The value.
function Shaker:getPeriod()
	return self._period
end

--- Sets the power of the shaker.
-- @param x The power along the X axis.
-- @param y The power along the Y axis.
function Shaker:setPower( x, y )
	self:setPowerX( x )
	self:setPowerY( y )
end

--- Gets the power of the shaker.
-- @return Two values, the power along the X axis and the Y axis.
function Shaker:getPower()
	return self:getPowerX(), self:getPowerY()
end

--- Sets the power of the shaker along the X axis.
-- @param value The power for the axis.
function Shaker:setPowerX( value )
	self._power.x = value or x
end

--- Gets the power of the shaker along the X axis.
-- @return The power value.
function Shaker:getPowerX()
	return self._power.x or 0
end

--- Sets the power of the shaker along the Y axis.
-- @param value The power for the axis.
function Shaker:setPowerY( value )
	self._power.y = value or y
end

--- Gets the power of the shaker along the Y axis.
-- @return The power value.
function Shaker:getPowerY()
	return self._power.y or 0
end

--- Starts the shake action.
-- @param duration The duration of the shake.
function Shaker:start( duration, onComplete )

	if self:isShaking() then
		self:stop()
	end

	self._stage.x0 = 0 --stage.x
	self._stage.y0 = 0 --stage.y

	self._count = 0

	Runtime:addEventListener( "enterFrame", self )
	self:_setIsShaking( true )

	if duration then

		local stop = function()

			cancel( self._durationTimer )

			self._durationTimer = nil

			self:stop()

			if onComplete then
				onComplete()
			end

		end

		if self._durationTimer then
			cancel( self._durationTimer )
		end

		self._durationTimer = nil

		self._durationTimer = performWithDelay( duration, stop )

	end

end

--- Destroys the shaking.
function Shaker:stop()

	Runtime:removeEventListener( "enterFrame", self )
	self:_setIsShaking( false )

	local resetStage = function()

		cancel( self._stopTimer )

		self._stopTimer = nil

		self._stage.x = self._stage.x0
     	self._stage.y = self._stage.y0

	end

	if self._stopTimer then
		cancel( self._stopTimer )
	end

	self._stopTimer = nil

	self._stopTimer = performWithDelay( 50, resetStage )

end

--- Destroys this Shaker object.
function Shaker:destroy()

	Runtime:removeEventListener( "enterFrame", self )

	if self._durationTimer then
		cancel( self._durationTimer )
	end

	self._durationTimer = nil

	if self._stopTimer then
		cancel( self._stopTimer )
	end

	self._stopTimer = nil

	self._count = nil
    self._power = nil
    self._period = nil

end

--- Checks if this shaker is currently active.
-- @return True if it is, false otherwise.
function Shaker:isShaking()
	return self._isShaking
end

------------------------
--	PRIVATE FUNCTIONS --
------------------------

--- Does the actual screen shake.
function Shaker:_doShake()

	if self._count and self._period then

		if self._count % self._period == 0 then
			self._stage.x = self._stage.x0 + random( -self._power.x, self._power.x )
			self._stage.y = self._stage.y0 + random( -self._power.y, self._power.y )
		end

		self._count = self._count + 1

	end

end


--- Sets this shaker to be active or not.
-- @param value True if it is, false if not.
function Shaker:_setIsShaking( value )
	self._isShaking = value
end

---------------------
--	EVENT HANDLERS --
---------------------

--- The enterFrame handler for the shaker.
-- @param event The event table.
function Shaker:enterFrame( event )
	self:_doShake()
end

return Shaker
