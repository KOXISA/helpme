local composer = require( "composer" )
local json = require("json")

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    local sceneGroup = self.view
    display.setStatusBar(display.HiddenStatusBar)
    local textCurrentScore = display.newText("Current Score: " .. puggle.data:get("score"), display.contentCenterX, 0, native.systemFont, 25)
    textCurrentScore:setFillColor(255 / 255, 0 / 255, 0 / 255)
    sceneGroup:insert(textCurrentScore)
    local textStart = display.newText("Start", display.contentCenterX, display.contentCenterY, native.systemFont, 50)
    sceneGroup:insert(textStart)
    local textHighscore = display.newText("Bestscore: " .. ( puggle.data:get( "best" ) or 0 ), display.contentCenterX, display.contentHeight - 50, native.systemFont, 25)
    textHighscore:setFillColor(255 / 255, 0 / 255, 0 / 255)
    sceneGroup:insert(textHighscore)

    local function gotoGame()
        composer.setVariable("time", 160)
        composer.gotoScene("game")
    end
    puggle.data:set("score", 0)
    textStart:addEventListener("tap", gotoGame)
end


-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
    end
end


-- hide()
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
    end
end


-- destroy()
function scene:destroy( event )

    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
