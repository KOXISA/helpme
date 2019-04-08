local Generator = {}

function Generator:go( params )

    local params = params or {}
    local cells = {}

    local doStep = function()
        for x = 1, params.width, 1 do
            for y = 1, params.height, 1 do

                local count = 0

                count = count + ( params.map:isWall( x - 1, y, cells ) and 1 or 0 ) -- left
                count = count + ( params.map:isWall( x + 1, y, cells ) and 1 or 0 ) -- right
                count = count + ( params.map:isWall( x, y - 1, cells ) and 1 or 0 ) -- top
                count = count + ( params.map:isWall( x, y + 1, cells ) and 1 or 0 ) -- bottom

                count = count + ( params.map:isWall( x + 1, y - 1, cells ) and 1 or 0 ) -- top right
                count = count + ( params.map:isWall( x + 1, y + 1, cells ) and 1 or 0 ) -- bottom right
                count = count + ( params.map:isWall( x - 1, y - 1, cells ) and 1 or 0 ) -- top left
                count = count + ( params.map:isWall( x - 1, y + 1, cells ) and 1 or 0 ) -- bottom left

                if count > params.deathLimit then
                    cells[ x ][ y ] = { dead = true }
                elseif count < params.birthLimit then
                    cells[ x ][ y ] = { dead = false }
                end

            end

        end
    end

    for x = 1, params.width, 1 do
        cells[ x ] = {}
        for y = 1, params.height, 1 do
            cells[ x ][ y ] = { dead = puggle.random:inRange( 0, 100 ) / 100 < params.chanceToStartAlive }
        end
    end

    for i = 1, params.numberOfSteps or 1, 1 do
        doStep()
    end

    if params.edged then
        for x = 1, params.width, 1 do
            cells[ x ][ 1 ] = { dead = true, edge = true }
            cells[ x ][ params.height ] = { dead = true, edge = true }
            for y = 1, params.height, 1 do
                cells[ 1 ][ y ] = { dead = true, edge = true }
                cells[ params.width ][ y ] = { dead = true, edge = true }
            end
        end
    end

    return cells

end

return Generator
