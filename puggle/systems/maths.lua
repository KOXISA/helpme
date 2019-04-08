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
local Maths = class( "Maths" )

--- Required libraries.

--- Localised functions.
local cos = math.cos
local sin = math.sin
local rad = math.rad
local deg = math.deg
local atan = math.atan
local atan2 = math.atan2
local max = math.max
local min = math.min
local floor = math.floor
local ceil = math.ceil
local sqrt = math.sqrt
local pi = math.pi
local pi2 = pi * 2
local abs = math.abs

--- Initiates a new Maths object.
-- @param params Paramater table for the object.
-- @return The new object.
function Maths:initialize( params )
	self.name = "maths"
end

--- Gets a heading vector for an angle.
-- @param angle The angle to use, in degrees.
-- @return The heading vector.
function Maths:vectorFromAngle( angle )
	return { x = cos( rad( angle - 90 ) ), y = sin( rad( angle - 90 ) ) }
end

--- Gets the angle between two position vectors.
-- @param vector1 The first position.
-- @param vector2 The second position.
-- @return The angle.
function Maths:angleBetweenVectors( vector1, vector2 )
	local angle = deg( atan2( vector2.y - vector1.y, vector2.x - vector1.x ) ) + 90
	if angle < 0 then angle = 360 + angle end
	return angle
end

--- Gets the angle between two position vectors, limited by a turn rate.
-- @param vector1 The first position.
-- @param vector2 The second position.
-- @param current The current rotation of the object.
-- @param turnRate The max rate of the turn.
-- @return The angle.
function Maths:limitedAngleBetweenVectors( vector1, vector2, current, turnRate )

	local target = self:angleBetweenVectors( vector1, vector2 )

	local delta = floor( target - current )

	delta = self:normaliseAngle( delta )

	delta = self:clamp( delta, -turnRate, turnRate )

	return current + delta

end

--- Gets the distance between two position vectors.
-- @param vector1 The first position.
-- @param vector2 The second position.
-- @return The distance.
function Maths:distanceBetweenVectors( vector1, vector2 )
	if not vector1 or not vector1.x or not vector1.y or not vector2 or not vector2.x or not vector2.y then
		return
	end
	return sqrt( self:distanceBetweenVectorsSquared( vector1, vector2 ) )
end

--- Gets the squared distance between two position vectors.
-- @param vector1 The first position.
-- @param vector2 The second position.
-- @return The distance.
function Maths:distanceBetweenVectorsSquared( vector1, vector2 )
	if not vector1 or not vector1.x or not vector1.y or not vector2 or not vector2.x or not vector2.y then
		return
	end
	local factor = { x = vector2.x - vector1.x, y = vector2.y - vector1.y }
	return ( factor.x * factor.x ) + ( factor.y * factor.y )
end

--- Clamps a value between lowest and highest values.
-- @param value The value to clamp.
-- @param lowest The lowest the value can be.
-- @param highest The highest the value can be.
-- @return The clamped value.
function Maths:clamp( value, lowest, highest )
    return max( lowest, min( highest, value ) )
end

--- Rounds a number.
-- @param number The number to round.
-- @param idp The number of decimal places to round to. Optional, defaults to 0.
-- @return The rounded number.
function Maths:round( number, idp )
	local mult = 10 ^ ( idp or 0 )
	return floor( number * mult + 0.5 ) / mult
end

--- Checks if a number is actually NotANumber.
-- @return True if it is, false otherwise.
function Maths:isNan( x )
	return x ~= x
end

--- Checks if a number is even.
-- @return True if it is, false otherwise.
function Maths:isEven( x )
	return x % 2 == 0
end

--- Checks if a number is odd.
-- @return True if it is, false otherwise.
function Maths:isOdd( x )
	return not self:isEven( x )
end

--- Checks if a point is within a given rectangle.
-- @param bounds The bounds of the rectangle.
-- @param pX The X position of the point.
-- @param pY The Y position of the point.
-- @return True if it is, false otherwise.
function Maths:pointInRectangle( bounds, pX, pY )

	if bounds then

		if pX >= bounds.xMin and pX <= bounds.xMax then
			if pY >= bounds.yMin and pY <= bounds.yMax then
				return true
			end
		end

	end

	return false

end

--- Checks if a point is within a given circle.
-- @param cX The X position of the circle.
-- @param cY The Y position of the circle.
-- @param radius The radius of the circle.
-- @param pX The X position of the point.
-- @param pY The Y position of the point.
-- @return True if it is, false otherwise.
function Maths:pointInCircle( cX, cY, radius, pX, pY )
	return self:distanceBetweenVectorsSquared( { x = cX, y = cY }, { x = pX, y = pY } ) <= ( radius * radius )
end

--- Checks if two circles intersect.
-- @param x1 The X position of the first circle.
-- @param y1 The Y position of the first circle.
-- @param r1 The radius of the first circle.
-- @param x2 The X position of the second circle.
-- @param y2 The Y position of the second circle.
-- @param r2 The radius of the second circle.
-- @return True if the doy, false otherwise.
function Maths:circlesIntersect( x1, y1, r1, x2, y2, r2 )

	local x = x1 - x2
    local y = y1 - y2
	local size = r2 + r1

	return x * x + y * y < size * size

end

--- Checks if two rectangles intersect.
-- @param x1 The X position of the first rectangle.
-- @param y1 The Y position of the first rectangle.
-- @param w1 The width of the first rectangle.
-- @param h1 The height of the first rectangle.
-- @param x2 The X position of the second rectangle.
-- @param y2 The Y position of the second rectangle.
-- @param w2 The width of the second rectangle.
-- @param h2 The height of the second rectangle.
-- @return True if they do, false otherwise.
function Maths:rectanglesIntersect( x1, y1, w1, h1, x2, y2, w2, h2 )
	return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1
end

--- Checks if a point is within a given polygon.
-- @param The vertices of the polygon.
-- @param x The X position of the point.
-- @param x The Y position of the point.
-- @return True if it is, false otherwise.
function Maths:pointInPolygon( vertices, x, y )

	local intersects = false
	local j = #vertices
	for i = 1, #vertices, 1 do
	    if (vertices[i][2] < y and vertices[j][2] >= y or vertices[j][2] < y and vertices[i][2] >= y) then
	        if (vertices[i][1] + ( y - vertices[i][2] ) / (vertices[j][2] - vertices[i][2]) * (vertices[j][1] - vertices[i][1]) < x) then
	            intersects = not intersects
	        end
	    end
	    j = i
	end
	return intersects

end

function Maths:areaOfPolygon( vertices )

	local area = self:crossProduct( vertices[ #vertices ], vertices[ 1 ] )

	for i = 1, #vertices - 1, 1 do
		area = area + self:crossProduct( vertices[ i ], vertices[ i + 1 ] )
	end

	area = area / 2

	return area

end

function Maths:centreOfPolygon( vertices )

	local p,q = vertices[ #vertices ], vertices[ 1 ]
	local det = self:crossProduct( p, q )
	local centroid = { x = ( p.x + q.x ) * det, y = ( p.y + q.y ) * det }

	for i = 1, #vertices - 1, 1 do
		p, q = vertices[ i ], vertices[ i + 1 ]
		det = self:crossProduct( p, q )
		centroid.x = centroid.x + ( p.x + q.x ) * det
		centroid.y = centroid.y + ( p.y + q.y ) * det
	end

	local area = self:areaOfPolygon( vertices )
	centroid.x = centroid.x / ( 6 * area )
	centroid.y = centroid.y / ( 6 * area )

	return centroid

end

--- Normalises a value to within 0 and 1.
-- @param value The current unnormalised value.
-- @param min The minimum the value can be.
-- @param max The maximum the value can be.
-- @return The newly normalised value.
function Maths:normalise( value, min, max )
	local result = ( value - min ) / ( max - min )
	if result > 1 then
		result = 1
	end
	return result
end

--- Normalises a value from one range to another so that it's within within 0 and 1.
-- @param value The current value.
-- @param minA The minimum the value can be on the first range.
-- @param maxA The maximum the value can be on the first range.
-- @param minB The minimum the value can be on the second range.
-- @param maxB The maximum the value can be on the second range.
-- @return The newly normalised value.
function Maths:normaliseAcrossRanges( value, minA, maxA, minB, maxB )
	return ( ( ( value - minA ) * ( maxB - minB ) ) / ( maxA - minA ) ) + minB
end

--- Normalises an angle.
-- @param angle The angle to normalise.
-- @return The newly normalised angle.
function Maths:normaliseAngle( angle )

    local newAngle = angle

    while newAngle <= -180 do
		newAngle = newAngle + 360
	end

    while newAngle > 180 do
		newAngle = newAngle - 360
	end

    return newAngle

end

--- Limits a rotation to a max rate.
-- @param current The current rotation.
-- @param target The target rotation.
-- @param maxRate The maximum number of degrees the rotation can go to.
-- @return The newly limited angle.
function Maths:limitRotation( current, target, maxRate )

	if current and target and maxRate then

		local angle = target

	    local d = current - angle

		d = self:normaliseAngle( d )

	    if d > maxRate then
	        angle = current - maxRate
	    elseif d < -maxRate then
	        angle = current + maxRate
	    end

		return angle

	end

end

--- Contstrains a position to within a given bounds.
-- @param x The current X position.
-- @param y The current Y position.
-- @param bounds The bounds to constrain to.
-- @return The new X and Y values.
function Maths:constrainPosition( x, y, bounds )

	if x < bounds.xMin then
        x = bounds.xMin
    elseif x > bounds.xMax then
        x = bounds.xMax
    end

    if y < bounds.yMin then
    	y = bounds.yMin
    elseif y > bounds.yMax then
        y = bounds.yMax
    end

	return x, y

end

--- Contstrains a position to within the screen.
-- @return The new X and Y values.
function Maths:constrainPositionToScreen( x, y )

	local bounds = {}
	bounds.xMin = display.screenOriginX
	bounds.yMin = display.screenOriginY
	bounds.xMax = display.contentWidth - display.screenOriginX
	bounds.yMax = display.contentHeight - display.screenOriginY

	return self:constrainPosition( x, y, bounds )

end

--- Contstrains a position to within a given radius
-- @param x The current X position.
-- @param y The current Y position.
-- @param origin The origin of the bounding radius.
-- @param radius The radius to constrain to.
-- @return The new X and Y values.
function Maths:constrainPositionWithinRadius( x, y, origin, radius )

	if self:distanceBetweenVectors( { x = x, y = y }, origin ) > radius then

		local angle = self:angleBetweenVectors( { x = x, y = y }, origin )

		local radians = rad( angle + 90 )

		x = cos( radians ) * radius
		y = sin( radians ) * radius
		x = floor( x )
		y = floor( y )

		x = origin.x + x
		y = origin.y + y

	end


	return x, y

end

--- Gets a 1d index from a 2d array.
-- @param row The row to use.
-- @param column The colume to use.
-- @param clumnCount Count of columns in the array.
-- @return The index.
function Maths:indexFrom2DArray( row, column, columnCount )
	return ( ( row * columnCount ) + column ) - columnCount
end

--- Calculate the dot product of two vectors.
-- @param v1 The first vector. An object containing both an 'x' and a 'y' property.
-- @param v2 The second vector. An object containing both an 'x' and a 'y' property.
-- @return The calculated dot product.
function Maths:dotProduct( v1, v2 )
	return v1.x * v2.x + v1.y * v2.y
end

function Maths:crossProduct( v1, v2 )
	return ( v1.x * v2.y ) - ( v1.y * v2.x )
end

function Maths:vectorMultiply( v1, v2 )
	return { x = v1.x * v2.x, y = v1.y * v2.y }
end

function Maths:degToRad( deg )
	return ( deg * pi ) / 180
end

function Maths:radToDeg( rad )
	return ( rad * 180 ) / pi
end

function Maths:rowColumnToIndex( row, column, numColumns )
	return row * numColumns + column - numColumns
end

function Maths:indexToRowColumn( index, numColumns )
	return ceil( index / numColumns ), ceil( index % numColumns )
end

function Maths:worldToGridPosition( position, tileSize )
    return ceil( position.y / tileSize ), ceil( position.x / tileSize )
end

function Maths:calculatePercentage( value, max )
	return ( value / max ) * 100
end

-- Linear interpolates between two numbers.
-- @param from The first number.
-- @param to The second number.
-- @param time The time value for the interpolation.
-- @return The interpolated value.
function Maths:lerp( from, to, time )
	return from + ( to - from ) * time
end

--- Destroys this Maths object.
function Maths:destroy()

end

--- Return the Maths class definition.
return Maths
