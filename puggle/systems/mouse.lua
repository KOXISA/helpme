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
local Mouse = class( "Mouse" )

--- Required libraries.

--- Localised functions.

-- Enumerated values
Mouse.ButtonState = {}
Mouse.ButtonState.JustPressed = "justPressed"
Mouse.ButtonState.JustReleased = "justReleased"
Mouse.ButtonState.Pressed = "pressed"
Mouse.ButtonState.Released = "released"

Mouse.Button = {}
Mouse.Button.Primary = "primary"
Mouse.Button.Secondary = "secondary"
Mouse.Button.Middle = "middle"

Mouse.ButtonPhase = {}
Mouse.ButtonPhase.Down = "down"
Mouse.ButtonPhase.Up = "up"

--- Initiates a new Mouse object.
-- @param params Paramater table for the object.
-- @return The new object.
function Mouse:initialize( params )

	-- Set the name of this manager
	self.name = "mouse"

    -- Table to store the current button states
	self._buttonStates = {}

    -- Table to stare the current button phases
    self._buttonPhases = {}

    -- Table to store the last known position of the mouse
    self._position = {}

    for k, v in pairs( Mouse.Button ) do
    	self._buttonStates[ v ] = Mouse.ButtonState.Released
        self._buttonPhases[ v ] = Mouse.ButtonPhase.Up
    end

	-- Table to stare custom names for buttons
	self._namedButtons = {}

    -- Register the event handler for 'mouse'
	Runtime:addEventListener( "mouse", self )

end

--- The 'mouse' event handler.
-- @param event The 'mouse' event.
function Mouse:mouse( event )

	-- If this event was fired by puggle, then ignore it
	if event.puggle then
		return
	end

    -- Store the position of the mouse
    self:setPosition( event )

    self:setButtonPhase( Mouse.Button.Primary, event.isPrimaryButtonDown == true and Mouse.ButtonPhase.Down or Mouse.ButtonPhase.Up )
    self:setButtonPhase( Mouse.Button.Secondary, event.isSecondaryButtonDown == true and Mouse.ButtonPhase.Down or Mouse.ButtonPhase.Up )
    self:setButtonPhase( Mouse.Button.Middle, event.isMiddleButtonDown == true and Mouse.ButtonPhase.Down or Mouse.ButtonPhase.Up )

end


--- Sets the current phase of a button.
-- @param key The name of the button.
-- @param phase The phase to set.
function Mouse:setButtonPhase( button, phase )

	if self._buttonPhases[ button ] ~= phase then

		self._buttonPhases[ button ] = phase

		local actions = self:getActionFromButton( button )
		for i = 1, #actions, 1 do
			self._buttonPhases[ actions[ i ] ] = phase
		end

	end

end

--- Gets the current phase of a button.
-- @param key The name of the button.
-- @return The current phase.
function Mouse:getButtonPhase( button )
	return self._buttonPhases[ button ]
end

--- Gets the current state of a button.
-- @param button The name of the button.
-- @return The current state.
function Mouse:getButtonState( button )
    return self._buttonStates[ button ]
end

--- Sets the current state of a button.
-- @param button The name of the button.
-- @param state The state to set.
function Mouse:setButtonState( button, state )
	if self._buttonStates[ button ] ~= state then
    	self._buttonStates[ button ] = state
    	Runtime:dispatchEvent{ name = "mouse", phase = state, button = button, x = self:getX(), y = self:getY(), puggle = true }
	end
end

--- Checks if a certain button is in a certain state.
-- @param button The name of the button.
-- @param state The state to check for.
-- @return True if it is, false otherwise.
function Mouse:isButtonInState( button, state )
    return self:getButtonState( button ) == state
end

--- Checks if a certain button is currently pressed.
-- @param button The name of the button.
-- @return True if it is, false otherwise.
function Mouse:isButtonPressed( button )
    return self:isButtonInState( button, Mouse.ButtonState.Pressed )
end

--- Checks if a certain button is currently released.
-- @param button The name of the button.
-- @return True if it is, false otherwise.
function Mouse:isButtonReleased( button )
    return self:isButtonInState( button, Mouse.ButtonState.Released )
end

--- Checks if a certain button was just pressed.
-- @param button The name of the button.
-- @return True if it was, false otherwise.
function Mouse:wasButtonJustPressed( button )
    return self:isButtonInState( button, Mouse.ButtonState.JustPressed )
end

--- Checks if a certain button was just released.
-- @param button The name of the button.
-- @return True if it was, false otherwise.
function Mouse:wasButtonJustReleased( button )
    return self:isButtonInState( button, Mouse.ButtonState.JustReleased )
end

--- Records the current position of the mouse.
-- @param position Table containing an x and y value.
function Mouse:setPosition( position )
    self._position = { x = position.x, y = position.y }
	puggle.cursor:setPosition( position.x, position.y )
end

--- Gets the last known position of the mouse.
-- @param asTable True if you want to get the position as a table, false if you want it as two individual return values. Optional, defaults to false.
-- @return Either the position as a table containing x and y or as two individual values.
function Mouse:getPosition( asTable )
    if asTable then
        return { x = self:getX(), y = self:getY() }
    else
        return self:getX(), self:getY()
    end
end

--- Gets the last known X position of the mouse.
-- @return The position.
function Mouse:getX()
    return self._position.x or 0
end

--- Gets the last known Y position of the mouse.
-- @return The position.
function Mouse:getY()
    return self._position.y or 0
end

--- Returns a named action from a button.
-- @param button The button to check for.
-- @return The name of the action if one is linked to this button, the name of the passed in button if there isn't.
function Mouse:getActionFromButton( button )

	local actions = {}

	for b, buttons in pairs( self._namedButtons or {} ) do
		if puggle.utils:tableContains( buttons, button ) then
			actions[ #actions + 1 ] = b
		end
	end

	return #actions > 0 and actions or { button }

end

--- Registers an action and links it to a button.
-- @param name The name of the action.
-- @param button The name of the button to set. Can also be a table containing button names.
function Mouse:register( name, button )

	self._namedButtons[ name ] = self._namedButtons[ name ] or {}

	if type( button ) == "table" then
		for i = 1, #button, 1 do
			self:register( name, button[ i ] )
		end
	else
		self._namedButtons[ name ][ #self._namedButtons[ name ] + 1 ] = button
	end

end

--- Update handler for this system.
-- @param dt The delta time of the game.
function Mouse:update( dt )

    for button, phase in pairs( self._buttonPhases ) do

		local state = self:getButtonState( button )

		if state then

			if phase == Mouse.ButtonPhase.Down then
				if state == Mouse.ButtonState.JustPressed or state == Mouse.ButtonState.JustReleased then
					self:setButtonState( button, Mouse.ButtonState.Pressed )
				elseif state == Mouse.ButtonState.Released then
					self:setButtonState( button, Mouse.ButtonState.JustPressed )
				end
			elseif phase == Mouse.ButtonPhase.Up then
				if state == Mouse.ButtonState.JustReleased then
					self:setButtonState( button, Mouse.ButtonState.Released )
				elseif state == Mouse.ButtonState.Pressed or state == Mouse.ButtonState.JustPressed then
					self:setButtonState( button, Mouse.ButtonState.JustReleased )
				end
			end

		else
			if phase == Mouse.ButtonPhase.Down then
				self:setButtonState( button, Mouse.ButtonState.JustPressed )
			elseif phase == Mouse.ButtonPhase.Up then
				self:setButtonState( button, Mouse.ButtonState.JustReleased )
			end
		end
	end

end

--- Hides the native mouse cursor.
function Mouse:hide()
	native.setProperty( "mouseCursorVisible", false )
end

--- Shows the native mouse cursor.
function Mouse:show()
	native.setProperty( "mouseCursorVisible", true )
end

--- Destroys this Mouse object.
function Mouse:destroy()

	-- Remove the event handler for 'mouse'
	Runtime:removeEventListener( "mouse", self )

end

--- Return the Mouse class definition.
return Mouse
