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

-- Middleclass library.
local class = require( "puggle.ext.middleclass" )

--- Class creation.
local GameObject = class( "GameObject" )

--- Required libraries.

--- Localised functions.
local abs = math.abs

--- Initiates a new Game Object object.
-- @param params Paramater table for the object.
function GameObject:initialize( params )

	self._id = puggle.utils:generateUUID()

	for k, v in pairs( params ) do
		self[ "_" .. k ] = v
	end

	self._params = params

end

--- Initiates a new Game Object object - called manually from the subclass.
-- @param params Paramater table for the object.
function GameObject:init( params )

	self._id = puggle.utils:generateUUID()
	self._totalFrames = 0
	self._tags = {}
	self._performedActions = {}

	for k, v in pairs( params or {} ) do
		self[ "_" .. k ] = v
		if self._visual and self._visual[ k ] then
			self._visual[ k ] = v
		end
	end

	self._params = params

	if self._visual then
		self._visual.owner = self
	end

	puggle:addGameObject( self )

end

--- Gets the ID of this object.
-- @return The id.
function GameObject:getID()
	return self._id
end

--- Gets the type of this object.
-- @return The type.
function GameObject:getType()
	return self._type
end

--- Sets the type of this object.
-- @param type The type to set.
function GameObject:setType( type )
	self._type = type
end

--- Adds a tag to this object.
-- @param name The name of the tag to add.
function GameObject:addTag( name )
	self._tags[ name ] = true
end

--- Removes a tag from this object.
-- @param name The name of the tag to remove.
function GameObject:removeTag( name )
	self._tags[ name ] = nil
end

--- Checks if this object has a certain tag.
-- @param name The name of the tag to check for.
-- @return True if it does, false otherwise.
function GameObject:hasTag( name )
	return self._tags[ name ]
end

--- Sets the value of a certain tag.
-- @param name The name of the tag to set.
-- @param value The value to set.
function GameObject:setTag( name, value )
	self._tags[ name ] = value
end

--- Gets the visual object attached to this object.
-- @return The object. Nil if there isn't one.
function GameObject:getVisual()
	if self._visual then
		return self._visual
	end
end

--- Flags an "action" as being performed. Can be anything, for instance "firedGun", "jumped".
-- @param name The name of the action.
function GameObject:flagActionAsPerformed( name )
	self._performedActions[ name ] = self._totalFrames
end

--- Checks what frame an "action" was performed.
-- @param name The name of the action.
-- @return The frame number. Nil if action never performed.
function GameObject:getFrameActionWasPerformedOn( name )
	return self._performedActions[ name ]
end

--- Gets how many frames have passed since the action was performed.
-- @param name The name of the action.
-- @return The frames since the action was performed. Nil if never performed.
function GameObject:getFramesSinceActionWasPerformed( name )

	if self:getFrameActionWasPerformedOn( name ) then
		return self:getFrames() - self:getFrameActionWasPerformedOn( name )
	end

	return nil

end

--- Moves this object.
-- @param x The amount of movement along the X axis.
-- @param y The amount of movement along the Y axis.
function GameObject:translate( x, y )
	self:setPosition( self:getX() + ( x or 0 ), self:getY() + ( y or 0 ) )
end

--- Sets the position of this object.
-- @param x The new X position.
-- @param y The new Y position.
function GameObject:setPosition( x, y )
	self:setX( x )
	self:setY( y )
end

--- Get the position of this object.
-- @param asTable Set to true if you want the position returned as a table. Optional, defaults to false.
-- @return The position. Either as a table containing .x and .y values or as two seperate values.
function GameObject:getPosition( asTable )
	if asTable then
		return { x = self:getX(), y = self:getY() }
	else
		return self:getX(), self:getY()
	end
end

--- Sets the X position of this object.
-- @param value The new X position.
function GameObject:setX( value )
	if self._visual then
		self._visual.x = value
	else
		self._x = value
	end
end

--- Gets the X position of this object.
-- @return The position.
function GameObject:getX()
	if self._visual then
		return self._visual.x
	else
		return self._x
	end
end

--- Sets the Y position of this object.
-- @param value The new Y position.
function GameObject:setY( value )
	if self._visual then
		self._visual.y = value
	else
		self._y = value
	end
end

--- Gets the Y position of this object.
-- @return The position.
function GameObject:getY()
	if self._visual then
		return self._visual.y
	else
		return self._y
	end
end

--- Sets the rotation of this object.
-- @param value The new rotation.
function GameObject:setRotation( value )
	if self._visual then
		self._visual.rotation = value
	else
		self._rotation = value
	end
end

--- Gets the rotation of this object.
-- @return The rotation of the object.
function GameObject:getRotation()
	if self._visual then
		return self._visual.rotation
	else
		return self._rotation
	end
end

--- Rotates this object.
-- @param degrees The amount of rotation to apply. In degrees.
function GameObject:rotate( degrees )
	self:setRotation( self:getRotation() + ( degrees or 0 ) )
end

--- Sets the scale of this object.
-- @param x The X scale to set.
-- @param y The Y scale to set. Optional, defaults to the specified X scale.
function GameObject:setScale( x, y )
	self:setScaleX( x )
	self:setScaleY( y or x )
end

--- Sets the X scale of this object.
-- @param value The scale to set.
function GameObject:setScaleX( value )
	if self._visual then
		self._visual.xScale = value
	end
end

--- Gets the X scale of this object.
-- @return The scale.
function GameObject:getScaleX()
	if self._visual then
		return self._visual.xScale
	end
end

--- Sets the Y scale of this object.
-- @param value The scale to set.
function GameObject:setScaleY( value )
	if self._visual then
		self._visual.yScale = value
	end
end

--- Gets the Y scale of this object.
-- @return The scale.
function GameObject:getScaleY()
	if self._visual then
		return self._visual.yScale
	end
end

--- Scales this object by the set amount.
-- @param x The amount to scale the object along the xAxis.
-- @param y The amount to scale the object along the yAxis. Optional, defaults to whatever the X value is.
function GameObject:scale( x, y )
	self:setScaleX( self:getScaleX() + ( x or 0 ) )
	self:setScaleY( self:getScaleY() + ( y or x or 0 ) )
end

--- Sets the alpha of this object.
-- @param value The new alpha value.
function GameObject:setAlpha( value )
	if self._visual then
		self._visual.alpha = value
	end
end

--- Gets the alpha of this object.
-- @return The alpha.
function GameObject:getAlpha()
	if self._visual then
		return self._visual.alpha
	end
end

--- Fades this object in or out by the set amount.
-- @param amount The amount to fade the object in or out.
function GameObject:fade( amount )
	if self._visual then
		self:setAlpha( self:getAlpha() + ( amount or 0 ) )
	end
end

--- Gets the content width of this object.
-- @return The width.
function GameObject:getContentWidth()
	if self._visual then
		return self._visual.contentWidth
	end
end

--- Gets the content height of this object.
-- @return The height.
function GameObject:getContentHeight()
	if self._visual then
		return self._visual.contentHeight
	end
end

--- Gets the number of frames this object has been active for.
-- @return The frame count.
function GameObject:getFrames()
	return self._totalFrames or 0
end

--- Moves this object to the front.
function GameObject:toFront()
	if self._visual then
		self._visual:toFront()
	end
end

--- Moves this object to the back.
function GameObject:toBack()
	if self._visual then
		self._visual:toBack()
	end
end

--- Hides this object.
function GameObject:hide()
	if self._visual then
		self._visual.isVisible = false
	end
end

--- Shows this object.
function GameObject:show()
	if self._visual then
		self._visual.isVisible = true
	end
end

--- Updates this GameObject object.
-- @param dt The current delta time for the game.
function GameObject:update( dt )
	self._totalFrames = ( self._totalFrames or 0 ) + 1
end

--- Scans the area around this object to find other game objects.
-- @param range The range to search in. Optional, defaults to 100
-- @param angle The angle to search in. Optional, defaults to 360.
-- @param frequency The frequency to perform the scan. Lower this to scan more thoroughly, at the sacrifice of performance. Optional, defaults to 10.
-- @param debugLines Flag to set whether debug lines should be drawn or not. Optional, defaults to false.
-- @return A list of found objects. Empty if none found.
function GameObject:scanForObjects( range, angle, frequency, debugLines )

	local range = range or 100
	local angle = angle or 360
	local frequency = frequency or 10

	local objects = {}

	if self._lines then
		for i = #self._lines, 1, -1 do
			display.remove( self._lines[ i ] )
			self._lines[ i ] = nil
		end
		self._lines = nil
	end

	if debugLines then
		self._lines = {}
	end

	local doScan = function( vector )

		if debugLines then
			self._lines[ #self._lines + 1 ] = display.newLine( self._visual.parent, self:getX(), self:getY(), self:getX() - ( vector.x * range ), self:getY() - ( vector.y * range ) )
		end

		local hits = physics.rayCast( self:getX(), self:getY(), self:getX() - ( vector.x * range ), self:getY() - ( vector.y * range ) ) or {}

		for i = 1, #hits, 1 do
			if hits[ i ].object.owner ~= self then
				objects[ #objects + 1 ] = hits[ i ].object
			end
		end

	end

	if angle > 0 then
		for i = 1, angle, frequency do
			doScan( puggle.maths:vectorFromAngle( self:getRotation() + i ) )
		end
	else
		for i = 1, abs( angle ), frequency do
			doScan( puggle.maths:vectorFromAngle( self:getRotation() - i ) )
		end
	end

	return objects

end

--- Mark this object for removal.
function GameObject:markForRemoval()
	self._markedForRemoval = true
end

--- Checks if this object has been marked for removal.
-- @return True if it has, false otherwise.
function GameObject:markedForRemoval()
	return self._markedForRemoval
end

--- Fire an event from this object.
-- @param name The name of the event.
-- @param params The paramaters for the event.
function GameObject:fireEvent( name, params )
	params.name = name
	params.gameObject = self
	Runtime:dispatchEvent( params )
end

--- Destroys this GameObject object.
function GameObject:destroy()

	display.remove( self._visual )
	self._visual = nil

	self._id = nil

end

--- Return the GameObject class definition.
return GameObject
