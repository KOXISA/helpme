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
local Map = class( "Map" )

--- Required libraries.
local cellular = require( "puggle.mapGenerators.cellular" )

--- Localised functions.
local floor = math.floor

--- Static values.
Map.Type = {}
Map.Type.Cellular = "cellular"

--- Initiates a new Map object.
-- @param params Paramater table for the object.
-- @return The new object.
function Map:initialize( params )

    self._cells = {}

    local params = params or {}
    params.map = self

    for k, v in pairs( params ) do
        self[ "_" .. k ] = v
    end

    if params and params.type == Map.Type.Cellular then
        self._cells = cellular:go( params )
    else

    end

end

--- Gets the cells in the Map.
-- @return The cells
function Map:getCells()
    return self._cells
end

--- Gets the width of the Map.
-- @return The width, in number of cell.
function Map:getWidth()
    return self._width
end

--- Gets the height of the Map.
-- @return The height, in number of cell.
function Map:getHeight()
    return self._height
end

--- Gets a specific cell from the Map.
-- @param x The X position of the cell in the grid.
-- @param y The Y position of the cell in the grid.
-- @param cells The cells to check. Optional, defaults to the ones in this map.
-- @return The cell.
function Map:getCell( x, y, cells )

    local cells = cells or self._cells

    if cells[ x ] then
        return cells[ x ][ y ]
    end
end

--- Checks if the cell in a certain position is a wall.
-- @param x The X position of the cell in the grid.
-- @param y The Y position of the cell in the grid.
-- @param cells The cells to check. Optional, defaults to the ones in this map.
-- @return True if it is, false otherwise.
function Map:isWall( x, y, cells )

    local cell = self:getCell( x, y, cells )

    if cell == nil or cell.dead == true then
        return true
    else
        return false
    end

end

--- Checks if the cell in a certain position is an edge.
-- @param x The X position of the cell in the grid.
-- @param y The Y position of the cell in the grid.
-- @param cells The cells to check. Optional, defaults to the ones in this map.
-- @return True if it is, false otherwise.
function Map:isEdge( x, y, cells )

    local cell = self:getCell( x, y, cells )

    return cell and cell.edge

end

--- Looks for a free position in the map.
-- @param width The width the position should be. Optional, defaults to 1.
-- @param height The height the position should be. Optional, defaults to 1.
function Map:getFreePosition( width, height )

    local width = width or 1
    local height = height or 1

    local getRandomPosition = function()
        return puggle.random:inRange( 1, self:getWidth() ), puggle.random:inRange( 1, self:getHeight() )
    end

    local isFree = function( x, y, width, height )

        for x1 = x - floor( width * 0.5 ), x + floor( width * 0.5 ), 1 do
            for y1 = y - floor( height * 0.5 ), y + floor( height * 0.5 ), 1 do
                if self:isWall( x1, y1 ) then
                    return false
                end
            end
        end

        return true

    end

    local x, y = getRandomPosition()

    while not isFree( x, y, width, height ) do
        x, y = getRandomPosition()
    end

    return x, y

end

--- Return the Map class definition.
return Map
