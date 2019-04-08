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
local Input = class( "Input" )

--- Required libraries.

--- Localised functions.
local abs = math.abs
local sqrt = math.sqrt
local atan = math.atan
local pi = math.pi
local find = string.find
local gsub = string.gsub
local tonumber = tonumber

-- Enumerated values
Input.ButtonState = {}
Input.ButtonState.JustPressed = "justPressed"
Input.ButtonState.JustReleased = "justReleased"
Input.ButtonState.Pressed = "pressed"
Input.ButtonState.Released = "released"

Input.KeyPhase = {}
Input.KeyPhase.Down = "down"
Input.KeyPhase.Up = "up"

--- Initiates a new Input object.
-- @param params Paramater table for the object.
-- @return The new object.
function Input:initialize( params )

	-- Set the name of this manager
	self.name = "input"

	-- Table to store the current button states
	self._buttonStates =
	{
		{}
	}

	-- Table to store the current key phases
	self._keyPhases =
	{
		{}
	}

	-- Table to store the current axis data
	self._axis =
	{
		{}
	}

	-- Table to stare custom names for buttons
	self._namedButtons = {}

	-- Table to store custom names for axis
	self._namedAxis = {}

	-- Table to store the previous axis values
	self._previousAxisValues = {}

	-- Axis values less than, or equal to, this amount will be ignored
	self._deadzone = 0.15

	-- Table to store possible controller names
	self._validControllerNames = { "Gamepad ", "Joystick " }

	-- Distance a relative touch event must be for it to be classed as d-pad input
	self._relativeTouchDPadDistance = 100

	-- Register the event handler for 'key'
	Runtime:addEventListener( "key", self )

	-- Register the event handler for 'axis'
	Runtime:addEventListener( "axis", self )

	-- Register the event handler for 'relativeTouch'
	Runtime:addEventListener( "relativeTouch", self )

end

--- Get a controller index from an event.
-- @param event The 'key' or 'axis' event.
-- @return The found index.
function Input:_getIndexFromEvent( event )

	local index = 1

	if event.device and event.device.descriptor then

		for i = 1, #self._validControllerNames, 1 do

			local s, e = find( event.device.descriptor, self._validControllerNames[ i ] )
			if e then
				index = tonumber( gsub( event.device.descriptor, self._validControllerNames[ i ], "" ), e + 1 )
			end

		end

	end

	return index

end

--- The 'key' event handler.
-- @param event The 'key' event.
function Input:key( event )
	self:setKeyPhase( event.keyName, event.phase, self:_getIndexFromEvent( event ) )
end

--- The 'axis' event handler.
-- @param event The 'axis' event.
function Input:axis( event )
	self:setAxisValue( event.axis.number, abs( event.normalizedValue ) > self._deadzone and event.normalizedValue or 0, self:_getIndexFromEvent( event ) )
end

--- The 'relativeTouch' event handler.
-- @param event The 'relativeTouch' event.
function Input:relativeTouch( event )

	-- Did the event just end?
	if event.phase == "ended" then

		-- Pre declare key variable
		local key = nil

		-- Was a key pressed?
		if event.x < -self._relativeTouchDPadDistance then
			key = "left"
		elseif event.x > self._relativeTouchDPadDistance then
			key = "right"
		elseif event.y < -self._relativeTouchDPadDistance then
			key = "up"
		elseif event.y > self._relativeTouchDPadDistance then
			key = "down"
		end

		-- If no key was pressed then treat it as a regular touchpad press
		if not key then
			key = "buttonA"
		end

		-- Was a key "pressed"
		if key then

			-- Fire a key down event
			self:key{ keyName = key, phase = "down" }

			-- Then after a short delay, fire a key up event
			puggle.timer:performWithDelay( 50, function() self:key{ keyName = key, phase = "up" } end, 1 )

			return true

		end

	end

end

--- Checks if a certain button is currently pressed.
-- @param button The name of the button.
-- @param index The index of the controller. Optional, defaults to 1.
-- @return True if it is, false otherwise.
function Input:isButtonPressed( button, index )
	return self:isButtonInState( button, Input.ButtonState.Pressed, index )
end

--- Checks if a certain button is currently released.
-- @param button The name of the button.
-- @param index The index of the controller. Optional, defaults to 1.
-- @return True if it is, false otherwise.
function Input:isButtonReleased( button, index )
	return self:isButtonInState( button, Input.ButtonState.Released, index )
end

--- Checks if a certain button was just pressed.
-- @param button The name of the button.
-- @param index The index of the controller. Optional, defaults to 1.
-- @return True if it was, false otherwise.
function Input:wasButtonJustPressed( button, index )
	return self:isButtonInState( button, Input.ButtonState.JustPressed, index )
end

--- Checks if a certain button was just released.
-- @param button The name of the button.
-- @param index The index of the controller. Optional, defaults to 1.
-- @return True if it was, false otherwise.
function Input:wasButtonJustReleased( button, index )
	return self:isButtonInState( button, Input.ButtonState.JustReleased, index )
end

--- Checks if a certain button is in a certain state.
-- @param button The name of the button.
-- @param state The state to check for.
-- @param index The index of the controller. Optional, defaults to 1.
-- @return True if it is, false otherwise.
function Input:isButtonInState( button, state, index )
	return self:getButtonState( button, index ) == state
end

--- Gets the current state of a button.
-- @param button The name of the button.
-- @param index The index of the controller. Optional, defaults to 1.
-- @return The current state.
function Input:getButtonState( button, index )
	self._buttonStates[ index or 1 ] = self._buttonStates[ index or 1 ] or {}
	return self._buttonStates[ index or 1 ][ button ]
end

--- Sets the current state of a button.
-- @param button The name of the button.
-- @param state The state to set.
-- @param index The index of the controller. Optional, defaults to 1.
function Input:setButtonState( button, state, index )
	self._buttonStates[ index or 1 ] = self._buttonStates[ index or 1 ] or {}
	self._buttonStates[ index or 1 ][ button ] = state
	Runtime:dispatchEvent{ name = "input", phase = state, button = button, index = index or 1 }
end

--- Sets the current phase of a key.
-- @param key The name of the key.
-- @param phase The phase to set.
-- @param index The index of the controller. Optional, defaults to 1.
function Input:setKeyPhase( key, phase, index )
	self._keyPhases[ index or 1 ] = self._keyPhases[ index or 1 ] or {}
	local actions = self:getActionFromKey( key )
	for i = 1, #actions, 1 do
		self._keyPhases[ index or 1 ][ actions[ i ] ] = phase
	end
end

--- Gets the current phase of a key.
-- @param key The name of the key.
-- @param index The index of the controller. Optional, defaults to 1.
-- @return The current phase.
function Input:getKeyPhase( key, index )
	self._keyPhases[ index or 1 ] = self._keyPhases[ index or 1 ] or {}
	return self._keyPhases[ index or 1 ][ key ]
end

--- Sets the current value of an axis.
-- @param axis The index of the axis.
-- @param value The normalised value of the axis.
-- @param index The index of the controller. Optional, defaults to 1.
function Input:setAxisValue( axis, value, index )
	self._axis[ index or 1 ] = self._axis[ index or 1 ] or {}
	self._axis[ index or 1 ][ self:getAxisFromName( axis ) ] = value
end

--- Gets the current value of an axis.
-- @param axis The index of the axis.
-- @param index The index of the controller. Optional, defaults to 1.
-- @return The current value.
function Input:getAxisValue( axis, index )
	self._axis[ index or 1 ] = self._axis[ index or 1 ] or {}
	return self._axis[ index or 1 ][ self:getAxisFromName( axis ) ] or 0
end

--- Gets the distance an axis has travelled.
-- @param axisX The index of the axis that is considered 'x'.
-- @param axisY The index of the axis that is considered 'y'.
-- @param index The index of the controller. Optional, defaults to 1.
-- @return The distance.
function Input:getAxisDistance( axisX, axisY, index )

	local x = self:getAxisValue( axisX, index )
    local y = self:getAxisValue( axisY, index )

	local a = abs( x * x )
    local b = abs( y * y )

    return sqrt( a + b )

end

--- Gets the angle of an axis.
-- @param axisX The index of the axis that is considered 'x'.
-- @param axisY The index of the axis that is considered 'y'.
-- @param index The index of the controller. Optional, defaults to 1.
-- @return The angle.
function Input:getAxisAngle( axisX, axisY, index )

	local x = self:getAxisValue( axisX, index )
    local y = self:getAxisValue( axisY, index )

	if ( not x or x == 0 ) and self._previousAxisValues[ index ] then
		x = self._previousAxisValues[ index ][ axisX ] or 0
	end

	if ( not y or y == 0 ) and self._previousAxisValues[ index ] then
		y = self._previousAxisValues[ index ][ axisY ] or 0
	end

	if x == 0 or y == 0 then
        return nil
    else

		-- Store out this value as the previous value
		self._previousAxisValues[ index ] = self._previousAxisValues[ index ] or {}
		self._previousAxisValues[ index ][ axisX ] = x
		self._previousAxisValues[ index ][ axisY ] = y

		local tanX = abs( y ) / abs( x )
	    local atanX = atan( tanX )
	    local angleX = atanX * 180 / pi

	    if y <= 0 then
	        angleX = angleX * -1
	    end

	    if x < 0 and y < 0 then
	        angleX = 270 + abs( angleX )
	    elseif x < 0 and y > 0 then
	        angleX = 270 - abs( angleX )
	    elseif x > 0 and y > 0 then
	        angleX = 90 + abs( angleX )
	    else
	        angleX = 90 - abs( angleX )
	    end

	    return angleX

	end

end

--- Updated handler for this system.
-- @param dt The delta time of the game.
function Input:update( dt )

	if self:enabled() then

		for i = 1, #self._keyPhases, 1 do

			for key, phase in pairs( self._keyPhases[ i ] ) do

				local state = self:getButtonState( key, i )

				if state then

					if phase == Input.KeyPhase.Down then
						if state == Input.ButtonState.JustPressed or state == Input.ButtonState.JustReleased then
							self:setButtonState( key, Input.ButtonState.Pressed, i )
						elseif state == Input.ButtonState.Released then
							self:setButtonState( key, Input.ButtonState.JustPressed, i )
						end
					elseif phase == Input.KeyPhase.Up then
						if state == Input.ButtonState.JustReleased then
							self:setButtonState( key, Input.ButtonState.Released, i )
						elseif state == Input.ButtonState.Pressed or state == Input.ButtonState.JustPressed then
							self:setButtonState( key, Input.ButtonState.JustReleased, i )
						end
					end

				else
					if phase == Input.KeyPhase.Down then
						self:setButtonState( key, Input.ButtonState.JustPressed, i )
					elseif phase == Input.KeyPhase.Up then
						self:setButtonState( key, Input.ButtonState.JustReleased, i )
					end
				end
			end

		end

	end

end

--- Returns a named action from a key.
-- @param key The key to check for.
-- @return The name of the action if one is linked to this key, the name of the passed in key if there isn't.
function Input:getActionFromKey( key )

	local actions = {}

	for k, keys in pairs( self._namedButtons or {} ) do
		if puggle.utils:tableContains( keys, key ) then
			actions[ #actions + 1 ] = k
		end
	end

	return #actions > 0 and actions or { key }

end

--- Registers an action and links it to a key.
-- @param name The name of the action.
-- @param key The name of the key to set. Can also be a table containing key names.
function Input:register( name, key )

	self._namedButtons[ name ] = self._namedButtons[ name ] or {}

	if type( key ) == "table" then
		for i = 1, #key, 1 do
			self:register( name, key[ i ] )
		end
	else
		self._namedButtons[ name ][ #self._namedButtons[ name ] + 1 ] = key
	end

end

--- Returns an axis index from a name.
-- @param name The name to check for.
-- @return The index of the axis if found, or the name that was passed in if it wasn't.
function Input:getAxisFromName( name )
	return self._namedAxis[ name ] or name
end

--- Registers an axis and links it to an index
-- @param name The name of the axis.
-- @param index The index of the axis to set.
function Input:registerAxis( name, index )
	self._namedAxis[ name ] = index
end

--- Clears the current states of all buttons.
function Input:clearStates()
	self._buttonStates = {}
	self._keyPhases = {}
end

--- Disables all input.
function Input:disable()
	self._disabled = true
end

--- Enables all input.
function Input:enable()
	self._disabled = false
end

--- Checks if input is currently enabled.
-- @return True if it is, false otherwise.
function Input:enabled()
	return not self:disabled()
end

--- Checks if input is currently disabled.
-- @return True if it is, false otherwise.
function Input:disabled()
	return self._disabled
end

--- Destroys this Input object.
function Input:destroy()

	-- Remove the event handler for 'key'
	Runtime:removeEventListener( "key", self )

	-- Remove the event handler for 'axis'
	Runtime:removeEventListener( "axis", self )

	-- Remove the event handler for 'relativeTouch'
	Runtime:removeEventListener( "relativeTouch", self )

end

--- Return the Input class definition.
return Input
