local composer = require( "composer" )
local timer = require("timer")
local json = require("json")
require( "puggle.core" )

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
    fade = {}
    count = {0, 0, 0, 0, 0, 0, 0}
    index = {}
    unique = {}
    math.randomseed(os.time())
    for i=1,7 do
        randnum = 0
        local tobreak = false
        while not tobreak do
            currandnum = math.random(1, 16)
            tobreak = true
            for j=1,16 do
                if unique[j] == currandnum then
                    tobreak = false
                    break
                end
            end
            randnum = currandnum
            table.insert(unique, randnum)
        end
        if randnum == 1 then
          fade[i] = "group1/image1.png"
        elseif randnum == 2 then
          fade[i] = "group1/image2.png"
        elseif randnum == 3 then
          fade[i] = "group1/image3.png"
        elseif randnum == 4 then
          fade[i] = "group1/image4.png"
        elseif randnum == 5 then
          fade[i] = "group1/image5.png"
        elseif randnum == 6 then
          fade[i] = "group1/image6.png"
        elseif randnum == 7 then
          fade[i] = "group1/image7.png"
        elseif randnum == 8 then
          fade[i] = "group1/image8.png"
        elseif randnum == 9 then
          fade[i] = "group1/image9.png"
        elseif randnum == 10 then
          fade[i] = "group1/image10.png"
        elseif randnum == 11 then
          fade[i] = "group1/image11.png"
        elseif randnum == 12 then
          fade[i] = "group1/image12.png"
        elseif randnum == 13 then
          fade[i] = "group1/image13.png"
        elseif randnum == 14 then
          fade[i] = "group1/image14.png"
        elseif randnum == 15 then
          fade[i] = "group1/image15.png"
        else
          fade[i] = "group1/image16.png"
        end
  end
    local circlesGroup = display.newGroup()
    local y = 125
    for i=1,4 do
      local x = 50
      for j=1,4 do
        local circle = display.newCircle(x, y, 30)
        local randomnumber = math.random(1, 7)
        count[randomnumber] = count[randomnumber] + 1
        index[4 * (i - 1) + j] = randomnumber
        circle.fill = {type="image", filename=fade[randomnumber]}
        circlesGroup:insert(circle)
        x = x + 75
      end
      y = y + 75
    end
    sceneGroup:insert(circlesGroup)
    for i=1,16 do
        index[i] = count[index[i]]
    end
    local max = 0
    for i=1,7 do
        if count[i] > max then
            max = count[i]
        end
    end
    local min = 16
    for i=1,7 do
        if count[i] < min and count[i] ~= 0 then
            min = count[i]
        end
    end
  local minormax = display.newText("New Text", display.contentCenterX, 50, native.systemFont, 50)
  local bool = math.random(0, 1)
  if bool == 0 then
      minormax.text = "Minimum"
  else
      minormax.text = "Maximum"
  end
  sceneGroup:insert(minormax)
  local time = composer.getVariable("time")
  local textTime = display.newText(time, display.contentCenterX, display.contentHeight - 50, native.systemFont, 50)
  textTime:setFillColor(255, 0, 0)
  sceneGroup:insert(textTime)
  local result = display.newText("", display.contentCenterX, display.contentHeight, native.systemFont, 50)
  sceneGroup:insert(result)
  local function stopwatch(event)
    time = composer.getVariable("time")
    textTime.text = time
    time = time  - 1
    if time <= 0 then
        time = 0
        timer.cancel(event.source)
        composer.gotoScene("menu")
    end
    composer.setVariable("time", time)
end

local maintimer = timer.performWithDelay(100, stopwatch, time, textTime)

local function tap1()
        if index[1] == max and bool == 1 then
            result.text = "Correct"
        elseif index[1] == min and bool == 0 then
            result.text = "Correct"
        else
            result.text = "Incorrect"
        end
end
local function tap2()
    if index[2] == max and bool == 1 then
        result.text = "Correct"
    elseif index[2] == min and bool == 0 then
        result.text = "Correct"
    else
        result.text = "Incorrect"
    end
end
local function tap3()
    if index[3] == max and bool == 1 then
        result.text = "Correct"
    elseif index[3] == min and bool == 0 then
        result.text = "Correct"
    else
        result.text = "Incorrect"
    end
end
local function tap4()
    if index[4] == max and bool == 1 then
        result.text = "Correct"
    elseif index[4] == min and bool == 0 then
        result.text = "Correct"
    else
        result.text = "Incorrect"
    end
end
local function tap5()
    if index[5] == max and bool == 1 then
        result.text = "Correct"
    elseif index[5] == min and bool == 0 then
        result.text = "Correct"
    else
        result.text = "Incorrect"
    end
end
local function tap6()
    if index[6] == max and bool == 1 then
        result.text = "Correct"
    elseif index[6] == min and bool == 0 then
        result.text = "Correct"
    else
        result.text = "Incorrect"
    end
end
local function tap7()
    if index[7] == max and bool == 1 then
        result.text = "Correct"
    elseif index[7] == min and bool == 0 then
        result.text = "Correct"
    else
        result.text = "Incorrect"
    end
end
local function tap8()
    if index[8] == max and bool == 1 then
        result.text = "Correct"
    elseif index[8] == min and bool == 0 then
        result.text = "Correct"
    else
        result.text = "Incorrect"
    end
end
local function tap9()
    if index[9] == max and bool == 1 then
        result.text = "Correct"
    elseif index[9] == min and bool == 0 then
        result.text = "Correct"
    else
        result.text = "Incorrect"
    end
end
local function tap10()
    if index[10] == max and bool == 1 then
        result.text = "Correct"
    elseif index[10] == min and bool == 0 then
        result.text = "Correct"
    else
        result.text = "Incorrect"
    end
end
local function tap11()
    if index[11] == max and bool == 1 then
        result.text = "Correct"
    elseif index[11] == min and bool == 0 then
        result.text = "Correct"
    else
        result.text = "Incorrect"
    end
end
local function tap12()
    if index[12] == max and bool == 1 then
        result.text = "Correct"
    elseif index[12] == min and bool == 0 then
        result.text = "Correct"
    else
        result.text = "Incorrect"
    end
end
local function tap13()
    if index[13] == max and bool == 1 then
        result.text = "Correct"
    elseif index[13] == min and bool == 0 then
        result.text = "Correct"
    else
        result.text = "Incorrect"
    end
end
local function tap14()
    if index[14] == max and bool == 1 then
        result.text = "Correct"
    elseif index[14] == min and bool == 0 then
        result.text = "Correct"
    else
        result.text = "Incorrect"
    end
end
local function tap15()
    if index[15] == max and bool == 1 then
        result.text = "Correct"
    elseif index[15] == min and bool == 0 then
        result.text = "Correct"
    else
        result.text = "Incorrect"
    end
end
local function tap16()
    if index[16] == max and bool == 1 then
        result.text = "Correct"
    elseif index[16] == min and bool == 0 then
        result.text = "Correct"
    else
        result.text = "Incorrect"
    end
end
local function refresh()
    composer.gotoScene("refresh")
end
local function refreshtimer()
    timer.performWithDelay(1000, refresh)
    local curscore = puggle.data:get("score")
    if result.text == "Correct" then
        composer.setVariable("time", time + 50)
        puggle.data:set( "score", curscore + 1)
        puggle.data:setIfHigher( "best", curscore )
    else
        composer.setVariable("time", math.max(0, time - 50))
    end
end

  circlesGroup[1]:addEventListener("tap", tap1)
  circlesGroup[2]:addEventListener("tap", tap2)
  circlesGroup[3]:addEventListener("tap", tap3)
  circlesGroup[4]:addEventListener("tap", tap4)
  circlesGroup[5]:addEventListener("tap", tap5)
  circlesGroup[6]:addEventListener("tap", tap6)
  circlesGroup[7]:addEventListener("tap", tap7)
  circlesGroup[8]:addEventListener("tap", tap8)
  circlesGroup[9]:addEventListener("tap", tap9)
  circlesGroup[10]:addEventListener("tap", tap10)
  circlesGroup[11]:addEventListener("tap", tap11)
  circlesGroup[12]:addEventListener("tap", tap12)
  circlesGroup[13]:addEventListener("tap", tap13)
  circlesGroup[14]:addEventListener("tap", tap14)
  circlesGroup[15]:addEventListener("tap", tap15)
  circlesGroup[16]:addEventListener("tap", tap16)
  circlesGroup[1]:addEventListener("tap", refreshtimer)
  circlesGroup[2]:addEventListener("tap", refreshtimer)
  circlesGroup[3]:addEventListener("tap", refreshtimer)
  circlesGroup[4]:addEventListener("tap", refreshtimer)
  circlesGroup[5]:addEventListener("tap", refreshtimer)
  circlesGroup[6]:addEventListener("tap", refreshtimer)
  circlesGroup[7]:addEventListener("tap", refreshtimer)
  circlesGroup[8]:addEventListener("tap", refreshtimer)
  circlesGroup[9]:addEventListener("tap", refreshtimer)
  circlesGroup[10]:addEventListener("tap", refreshtimer)
  circlesGroup[11]:addEventListener("tap", refreshtimer)
  circlesGroup[12]:addEventListener("tap", refreshtimer)
  circlesGroup[13]:addEventListener("tap", refreshtimer)
  circlesGroup[14]:addEventListener("tap", refreshtimer)
  circlesGroup[15]:addEventListener("tap", refreshtimer)
  circlesGroup[16]:addEventListener("tap", refreshtimer)

end


-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
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
        composer.removeScene("game")
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
