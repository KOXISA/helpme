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
local Cursor = class( "Cursor" )

--- Required libraries.
local mouseCursor = require( "plugin.mousecursor" )

--- Localised functions.

--- Class variables.

--- Initiates a new Cursor object.
-- @param params Paramater table for the object.
-- @return The new object.
function Cursor:initialize( params )

    -- Set the name of this manager
	self.name = "cursor"

    self._cursors = {}

end

function Cursor:add( name, params )

	local cursor = {}

	if mouseCursor then
		cursor.native = mouseCursor.newCursor{ filename = params.path, baseDir = params.baseDir, x = params.x, y = params.y }
		cursor.offset = { x = params.x, y = params.y }
	end

	if params.width and params.height and params.path then
		cursor.displayObject = display.newImageRect( params.path, params.baseDir, params.width, params.height )
	elseif params.path then
		cursor.displayObject = display.newImage( params.path, params.baseDir )
	end

	self._cursors[ name ] = cursor

end

function Cursor:set( name )

	if not self._currentName or self._currentName ~= name then

		if self._current then
			if self._current.native then
				self._current.native:hide()
			end
			if self._current.displayObject then
				self._current.displayObject.isVisible = false
			end
		end

		self._current = self:get( name )

		if self._current then
			if self._current.native then
				self._current.native:show()
			end
			if self._current.displayObject then
				self._current.displayObject.isVisible = true
				self._current.displayObject:toFront()
			end
		end

		self._currentName = name

	end

end

function Cursor:get( name )
    return self._cursors[ name ]
end

function Cursor:getPosition( asTable )

	if self._current then
		if self._current.displayObject then
			if asTable then
				return { x = self._current.displayObject.x, y = self._current.displayObject.y }
			else
				return self._current.displayObject.x, self._current.displayObject.y
			end
		end
	end

end

function Cursor:setPosition( x, y )

	if self._current then
		if self._current.displayObject then
			self._current.displayObject.x = x
			self._current.displayObject.y = y
		end
	end

end

function Cursor:getOffset( asTable )
	if self._current then
		local offset
		if self._current.displayObject then
			offset = { x = self._current.displayObject.contentWidth * 0.5, y = self._current.displayObject.contentHeight * 0.5 }
		else
			offset = self._current.offset
		end
		if asTable then
			return offset
		else
			return offset.x, offset.y
		end
	end
end

function Cursor:setSensitivty( value )
	self._sensitivity = value
end

function Cursor:getSensitivity()
	return self._sensitivity or 1
end

function Cursor:translate( x, y )

	local x0, y0 = self:getPosition()

	if x0 and y0 then
		self:setPosition( x0 + ( x * self:getSensitivity() ), y0 + ( y * self:getSensitivity() ) )
	end

end

function Cursor:update( dt )
	if self._currentName then
		self:set( self._currentName )
	end

end

--- Destroys this Cursor object.
function Cursor:destroy()

end

--- Return the Cursor class definition.
return Cursor
