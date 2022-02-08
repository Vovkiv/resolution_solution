-- FYI: this library was designed to do 1 specific thing: scale game from virtual size to entire window;
-- you don't need to lock window from resizing or do other methods for that;
-- you can set virtual game size/resolution to 1280x720 and that amount of content will be showed in
-- window with 1024x600 or 1920x1080;
-- But that don't mean, that if you hard coded game to 1280x720 and simple do "scaling.setGame(1920, 1080)"
-- then game will NOT magically works natively at 1920x1080;
-- You still need manually adapt ui, what player should be able to see in-game world, camera system, etc;
-- It might sounds silly, but i was recieved messages, where people asked why library not works when
-- they resized virtual size (which was hard coded to 1 specific size) and game not works correctly;
-- Luckly, library provide every value that it generates to you, so make sure to read source code of that library to have idea what every value do (every function/value have mostly detailed comments, so read them)

-- TL;DR
-- At bottom you will find demo, don't miss it, if you have not much idea of what this library do;
-- There changelog, too;

local scaling = {
  _URL = "https://github.com/Vovkiv/resolution_solution",
  _VERSION = 1002,
  _LOVE = 11.4,
  _DESCRIPTION = "Scale library, that help you add resolution support to your games in love2d!",
  -- for simlicity, iternal library name is "scaling"
  _NAME = "Resolution Solution",
  _LICENSE = "The Unlicense",
}

-- callback functions, that will be triggered when window size changed
-- with that you can, for example, draw custom ui, which shouldn't be scaled with game
-- and update it only when window and/or game virtual resolution is changed
scaling.windowChanged = function() end

-- callback functions, that will be triggered when game size changed
scaling.gameChanged = function() end

-- 1 aspect scaling (default; scale game with black bars on top-bottom or left-right)
-- 2 stretched scaling mode (scale virtual resolution to fill entire window; may be really harmful for pixel art)
-- (also, just tip: if possible, add in-game option to change scale method (scaling.switchScaleMode should be preferred, in case if i add more scaling methods in future)
-- it might be just preferred for someone to play with stretched graphics; youtubers/streamers may have better experience with your game, for example, if they won't to get rid of black bars, without dealing with obs crop tools or in montage apps)
scaling.scaleMode    = 1 

-- can be used to quicky disable rendering of black bars
-- for example, to see if game stop objects rendering if they outside of players fov and if it works correctly with black bars offset)
-- true is default; when scaling.scaleMode is 2, does nothing
scaling.drawBars     = true

scaling.widthScale   = 0
scaling.heightScale  = 0

-- virtual size for game, that library should scale to
scaling.gameWidth    = 800
scaling.gameHeight   = 600

-- Window size; with that you don't need to use love.graphics.getWidth()/getHeight()
scaling.windowWidth  = 800
scaling.windowHeight = 600

-- Aspect for virtual size; used to trigger scaling.gameChanged() callback
scaling.gameAspect   = 0
-- Aspect for window size; used to trigger scaling.windowChanged() callback
scaling.windowAspect = 0

 -- offset caused by black bars
scaling.xOff         = 0
scaling.yOff         = 0

-- data of black bars; if bars left-right then: 1 bar is left, 2 is right
scaling.x1, scaling.y1, scaling.w1, scaling.h1 = 0, 0, 0, 0

-- if top-bottom then: 1 bar is upper, 2 is bottom
scaling.x2, scaling.y2, scaling.w2, scaling.h2 = 0, 0, 0, 0

-- colors of black bars; red, green, blue, alpha
-- by default, it's just opaque black bars
scaling.r, scaling.g, scaling.b, scaling.a = 0, 0, 0, 1

scaling.update = function()
  -- coordinates of black bars
  local x1, y1, w1, h1
  local x2, y2, w2, h2

  -- scale for game virtual size
  local scaleWidth, scaleHeight
  
  -- offset for black bars
  local xOff, yOff

  -- virtual game size
  local gameWidth, gameHeight = scaling.gameWidth, scaling.gameHeight
  -- window size
  local windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()

  -- get aspect of window and virtual game size
  local gameAspect = gameWidth / gameHeight
  local windowAspect = windowWidth / windowHeight
  
  -- check scaling.gameChanged() callback
  local oldGameAspect   = scaling.gameAspect
  
  -- check scaling.windowChanged() callback
  local oldWindowAspect = scaling.windowAspect
  
  -- scale mode
  local scaleMode = scaling.scaleMode

  -- aspect scaling method; 1 with black bars
  if scaleMode == 1 then

     -- if window height > game height; create black bars on top and bottom
    if gameAspect > windowAspect then
      local scale = windowWidth / gameWidth
      
      local barHeight = math.abs((gameHeight * scale - windowHeight) / 2)
      
      scaleWidth, scaleHeight = scale, scale
      
      x1, y1, w1, h1 = 0, 0, windowWidth, barHeight
      x2, y2, w2, h2 = 0, windowHeight, windowWidth, barHeight * -1
      
      xOff, yOff = 0, windowHeight / 2 - (scale * gameHeight) / 2

  -- if window width > game width; create bars on left and right sides
  elseif gameAspect < windowAspect then

      local scale = windowHeight / gameHeight
      
      local barWidth = math.abs((gameWidth * scale - windowWidth) / 2)
      
      scaleWidth, scaleHeight = scale, scale
      
      x1, y1, w1, h1 = 0, 0, barWidth, windowHeight
      x2, y2, w2, h2 = windowWidth, 0, barWidth * -1, windowHeight
      
      xOff = windowWidth / 2 - (scale * gameWidth) / 2
      yOff = 0

    else -- if window and game size equal
      scaleWidth, scaleHeight = 1, 1
      
      x1, y1, w1, h1 = 0, 0, 0, 0
      x2, y2, w2, h2 = 0, 0, 0, 0
      
      xOff, yOff = 0, 0
    end -- end aspect scaling method

  end -- end scaleMode == 1
  
  -- stretch scaling method; 2 which fills entire window
  if scaleMode == 2 then
    
    scaleWidth = windowWidth / gameWidth
    scaleHeight = windowHeight / gameHeight
    
    x1, y1, w1, h1 = 0, 0, 0, 0
    x2, y2, w2, h2 = 0, 0, 0, 0
    
    xOff, yOff = 0, 0
  end -- end stretch scaling method

  -- write all changes to library
  
  -- black bars
  scaling.x1, scaling.y1, scaling.w1, scaling.h1 = x1, y1, w1, h1
  scaling.x2, scaling.y2, scaling.w2, scaling.h2 = x2, y2, w2, h2
  
  -- offset generated for black bars
  scaling.xOff, scaling.yOff = xOff, yOff
  
  -- scale
  scaling.scaleWidth, scaling.scaleHeight = scaleWidth, scaleHeight
  
  -- window size
  scaling.windowWidth, scaling.windowHeight = windowWidth, windowHeight
  
  -- ascpects
  scaling.gameAspect, scaling.windowAspect = gameAspect, windowAspect
  
  -- Call scaling.gameChanged() if virtual game size is changed
  if oldGameAspect ~= gameAspect then
    scaling.gameChanged()
  end
  
  -- Call scaling.windowChanged() if window size is changed
  if oldWindowAspect ~= windowAspect then
    scaling.windowChanged()
  end

end

scaling.start = function()
  -- prepare to scale
  love.graphics.push()
  
  -- reset transformation
  love.graphics.origin()

  -- set offset, based on size of black bars
  love.graphics.translate(scaling.xOff, scaling.yOff)
  
  -- scale game
  love.graphics.scale(scaling.scaleWidth, scaling.scaleHeight)
end

scaling.stop = function()
  -- stop scaling
  love.graphics.pop()

  -- do nothing if we don't need draw bars or we in aspect scaling mode (1; with black bars)
  if not scaling.drawBars or scaling.scaleMode ~= 1 then
    return
  end
  
  -- get colors, that was before scaling.stop() function
  local r, g, b, a = love.graphics.getColor()
  
  -- prepare to draw black bars
  love.graphics.push()
  
  -- reset transformation
  love.graphics.origin()

  -- set color for black bars
  love.graphics.setColor(scaling.r, scaling.g, scaling.b, scaling.a)

  -- draw left or top most
  love.graphics.rectangle("fill", scaling.x1, scaling.y1, scaling.w1, scaling.h1)
  -- draw right or bottom most
  love.graphics.rectangle("fill", scaling.x2, scaling.y2, scaling.w2, scaling.h2)
  
  -- return original colors that was before scaling.stop()
  love.graphics.setColor(r, g, b, a)
  
  -- end black bars rendering
  love.graphics.pop()
end -- end scaling.stop

scaling.unscaleStart = function()
  -- if you need draw somethiong not scaled by library
  -- for example, custom ui
  
  -- start unscaling
  love.graphics.push()
  
  -- reset coordinates and scaling
  love.graphics.origin()
end

scaling.unscaleStop = function()
  -- stop unscaling
  love.graphics.pop()
end

scaling.setColor = function(r, g, b, a)
  -- set color of black bars

  scaling.r = r -- red
  scaling.g = g -- green
  scaling.b = b -- blue
  scaling.a = a -- alpha
end

scaling.getColor = function()
  -- return color of black bars

  return scaling.r, -- red
         scaling.g, -- green
         scaling.b, -- blue
         scaling.a  -- alpha
end

scaling.defaultColor = function()
  -- will reset black bars color to default black

  scaling.r = 0 -- red
  scaling.g = 0 -- green
  scaling.b = 0 -- blue
  scaling.a = 1 -- alpha
end

scaling.getScale = function()
  return scaling.scaleWidth, scaling.scaleHeight
end

scaling.switchScaleMode = function()
  -- function to switch in-between scale modes

    if scaling.scaleMode ~= 1 then 
      scaling.scaleMode = 1 -- aspect mode
    else
      scaling.scaleMode = 2 -- stretch mode
    end
end

scaling.setGame = function(width, height)
  -- set virtual size which game should be scaled to

  scaling.gameWidth = width
  scaling.gameHeight = height
end

scaling.getGame = function()
  -- return game virtual width and height

  return scaling.gameWidth, scaling.gameHeight
end

scaling.getWindow = function()
  -- get window width and height

  return scaling.windowWidth, scaling.windowHeight
end

scaling.switchDrawBars = function()
  -- switch rendering for black bars
  
  scaling.drawBars = not scaling.drawBars
end

scaling.isMouseInside = function()
  -- determine if cursor inside scaled area and don't touch black bars
  -- use it when you need detect if cursor touch in-game objects, without false detection on black bars zone;
  -- always return true if scaling.scalingMode == 2 because game will be scaled to entire window
  -- so there is no black bars, so you can safely use this function with any scaling method;

  -- check if scale mode is not stretching (2), otherwise return true
  if scaling.scaleMode == 2 then
    return true
  end
  
  -- get mouse coordinates
  local mouseX, mouseY = love.mouse.getPosition()
  
  -- get offset
  -- also, as will be mentioned in scaling.toGame, there will some rounding/missmath with float coordinates;
  -- scaling.toGame don't do anything with that, you should take care about this, but here
  -- for convenience, this function simply round to nearest integer, which should take care about edge cases;
  -- if you have any suggestion, etc, feel free add issue ticket/pull request at library's github page, provided in scaling.__URL
  local xOff, yOff     = math.floor(scaling.xOff + 0.5), math.floor(scaling.yOff + 0.5)
  
  -- get window size
  local windowWidth    = scaling.windowWidth
  local windowHeight   = scaling.windowHeight

  -- check if cursor touch black bars
  if mouseX    >= xOff                 and -- left
     mouseY    >= yOff                 and -- top
     mouseX    <= windowWidth  - xOff  and -- right
     mouseY    <= windowHeight - yOff then -- bottom
     return true
  end

  -- if cursor touch black bars
  return false
end

scaling.toGame = function(x, y)
  -- thanslate coordinates from non-scaled to scaled;
  -- e.g translate real mouse coordinates into scaled so you can check
  -- for example, area to check collisions;
  
  -- ALSO, NOTE: don't forget about math precition and rounding, because with some scaling value
  -- using something like "scaling.toGame(love.mouse.getPosition())" coordinates may produce: x -0.31 y -0.10
  -- when you may expect just 0, 0
  -- so make sure that you properly threat this kind of edge cases
  -- because, as you might already guessed, library don't do anything with this, so take care about this yourself

  return (x - scaling.xOff) / scaling.scaleWidth, (y - scaling.yOff) / scaling.scaleHeight
end

scaling.toGameX = function(x)
  -- shortcut to deal with only x coordinates

  return (x - scaling.xOff) / scaling.scaleWidth
end

scaling.toGameY = function(y) 
  -- shortcut to deal with only y coordinates

  return (y - scaling.yOff) / scaling.scaleHeight
end

scaling.toScreen = function(x, y)
  -- thanslate coordinates from scaled to non scaled.
  -- e.g translate x and y of object inside scaled area
  -- to, for example, set cursor position to that object
  
  -- Please, if you still don't, read comments under "scaling.toGame"
  
  return (x * scaling.scaleWidth) + scaling.xOff, (y * scaling.scaleHeight) + scaling.yOff
end

scaling.toScreenX = function(x)
  -- shortcut to deal with only x coordinates
  
  return (x * scaling.scaleWidth) + scaling.xOff
end

scaling.toScreenY = function(y)
  -- shortcut to deal with only y coordinates
  
  return (y * scaling.scaleHeight) + scaling.yOff
end

return scaling

-- demo:
--[[
local scaling = require("resolution_solution")

-- i highly recommend always allow window resizing for your games
love.window.setMode(800, 600, {resizable = true})
love.window.setTitle(scaling._NAME .. " - library demo - v" .. scaling._VERSION)

-- set game virtual size
scaling.setGame(1280, 720)

love.graphics.setBackgroundColor(0.1, 0.1, 0.1)

-- rectangle that doesn't move; used to show how use toScreen() function
local rectangle = {100, 100, 100, 100}

-- timer for sine and cosine
local timer = 0
local timerLimit = math.pi * 2

-- is mouse under moving rectangle?
local underRectangle = false

-- rectangle that moves; used to show how you can implement mouse colission detection
local x, y, w, h = 200, 200, 20, 20
local dx, dy, dw, dh = 0, 0, 0, 0

-- generate image via canvas, 1280x720
local image = love.graphics.newCanvas(1280, 720)
love.graphics.setCanvas(image)
love.graphics.push("all")
love.graphics.setColor(0.5, 0.5, 0.5, 1)
love.graphics.rectangle("fill", 0, 0, 1280, 720)
love.graphics.setColor(1, 0, 0, 1)
love.graphics.setBlendMode("alpha")
love.graphics.rectangle("fill", 0, 0, 3, 3)
love.graphics.rectangle("fill", 1277, 0, 3, 3)
love.graphics.rectangle("fill", 0, 717, 3, 3)
love.graphics.rectangle("fill", 1277, 717, 3, 3)
love.graphics.setColor(1, 1, 1, 1)
love.graphics.setNewFont(24)
love.graphics.print("x = 0, y = 0", 0, 5)
love.graphics.print("x = 1280, y = 0", 1070, 0)
love.graphics.print("x = 0, y = 720", 0, 680)
love.graphics.print("x = 1280, y = 720", 1050, 680)
love.graphics.pop()
love.graphics.setCanvas()

-- instruction message
local message = ""

-- used to show that callback functions exist in this library
local gameChangedTimes = 0
local windowChangedTimes = 0

-- virtual game size changed callback
scaling.gameChanged = function()
  gameChangedTimes = gameChangedTimes + 1
end

--  window size changed callback
scaling.windowChanged = function()
  windowChangedTimes = windowChangedTimes + 1
end

-- keyboard
love.keypressed = function(key)
  -- set randow virtual size
  if key == "q" then scaling.setGame(love.math.random(800, 1920), love.math.random(600, 1080)) end
  
  -- switch scale mode
  if key == "w" then scaling.switchScaleMode() end
  
  -- reset virtual size
  if key == "r" then scaling.setGame(1280, 720) end
end

local isMouseUnder = function(x, y, w, h)
  -- function to check if mouse under something
  
  -- get scaled to game mouse position
  local mx, my = scaling.toGame(love.mouse.getPosition())
  
  -- check if cursor under
  if mx >= x     and -- left
     my >= y     and -- top
     mx <= x + w and -- right
     my <= y + h then -- bottom
    return true
  end
  
  return false
  
end

love.update = function(dt)
  -- update library
  scaling.update()
  
  -- count timer
  timer = timer + dt
  
  -- set timer to zero if it reach limit
  if timer > timerLimit then timer = 0 end

  -- move rectangle in circle
  -- x coordinate
  dx = x * math.sin(timer) + 150 + (scaling.gameWidth / 10)
  
  -- y coordinate
  dy = y * math.cos(timer) + 150 + (scaling.gameHeight / 10)

  -- change width and height of moving rectangle
  dw = w + 200 * math.sin(timer / 2)
  dh = h + 200 * math.sin(timer / 2)

  -- this will be used to determine is mouse under rectangle in love.draw
  underRectangle = isMouseUnder(dx, dy, dw, dh)
  
  -- message/instructions
  message = "Does mouse touch moving rectangle?: " .. tostring(underRectangle) .. "\n" ..
            "Press Q to change virtual size: w" .. tostring(scaling.gameWidth) .. " h" .. tostring(scaling.gameHeight) .. "\n" ..
            "Press W to change scaling mode: " .. tostring(scaling.scaleMode) .. "\n" ..
            "Press R to reset virtual size" .. "\n" ..
            "Times virtual size changed: " .. gameChangedTimes .. "\n" ..
            "Times window size changed: " .. windowChangedTimes .. "\n" ..
            "Is mouse inside scaled area?(does it touch black bars?): " .. tostring(scaling.isMouseInside()) .. "\n" ..
            "Press space to set cursor to moving rectangle" .. "\n" ..
            "Press S to set non moving rectangle to cursor" .. "\n" ..
            "Scaled mouse coordinates: x" .. string.format("%.2f", scaling.toGameX(love.mouse.getX())) .. " y: " .. string.format("%.2f", scaling.toGameY(love.mouse.getY())) .. "\n"

  -- set cursor to moving rectangle; that how you can use toScreen() function
  if love.keyboard.isDown("space") then love.mouse.setPosition(scaling.toScreen(dx, dy)) end
  
  -- set non-moving rectangle to cursor; that how you can use toGame() function
  if love.keyboard.isDown("s") then 
    rectangle[1] = scaling.toGameX(love.mouse.getX())
    rectangle[2] = scaling.toGameY(love.mouse.getY())
    end

end
  
love.draw = function()
  scaling.start()
  
  -- set color for example image
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(image)
  
  -- change color of moving rectangle, if you touch it with cursor or not
  if underRectangle then love.graphics.setColor(0, 1, 0) else love.graphics.setColor(1, 0, 0) end
  
  -- draw moving rectangle
  love.graphics.rectangle("line", dx, dy, dw, dh)
    
    -- set color for "cursor" which will follow cursor
    love.graphics.setColor(1, 0.4, 0.9, 1)
  
    -- draw "cursor" translated to in-game coordinates
    love.graphics.rectangle("fill", scaling.toGameX(love.mouse.getX()), scaling.toGameY(love.mouse.getY()), 10, 10)
    
    -- set color for non-moving rectangle
    love.graphics.setColor(0, 0, 0, 1)
    
    -- draw non-moving rectangle
    love.graphics.rectangle("line", unpack(rectangle))
    
    scaling.unscaleStart()
    -- example how you can use "unscale" function
    -- with that you can draw custom ui, that you don't want to scale with library itself
    -- or maybe with that create nice rendering for string, in pair with scaling.window/gameChanged
  
      -- draw semi-transparent background for "I'm unscaled!" string
      -- set i't color to black and make transparent
      love.graphics.setColor(0, 0, 0, 0.5)

      -- get width and height for that background
  love.graphics.rectangle("fill", scaling.windowWidth - (scaling.xOff + 100), scaling.windowHeight - (scaling.yOff + 100), love.graphics.newFont():getWidth("I'm unscaled!"), love.graphics.newFont():getHeight("I'm unscaled!"))
    
      -- draw "I'm unscaled!" string
      -- add offset for it, so it will be not drawed under black bars
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.print("I'm unscaled!", scaling.windowWidth - (scaling.xOff + 100), scaling.windowHeight - (scaling.yOff + 100))
      
    scaling.unscaleStop()
  scaling.stop()
  
    -- draw explaination/instruction
    love.graphics.setColor(0, 0, 0, 0.4)
    -- count how much string have new lines and use them to determine height oh string
  love.graphics.rectangle("fill", 0, 0, love.graphics.newFont():getWidth(message), love.graphics.newFont():getHeight(message) * select(2, string.gsub(message, "\n", "\n")))

  love.graphics.setColor(1, 1, 1, 1) 
  love.graphics.print(message)
end
--]]

-- Changelog:
--[[
Version 1000, 7 january 2021
Initial release

Version 1001, 6 february 2022
* Now, scaling.stop() will remember color that was set before it and return it back after
* Added comments for "Simple demo"
* Added more comments for functions and variables in library, to clarify more what the do and don't
* Fixed typo in "Simple demo"

Version 1002, 8 february 2022
* Fixed (probably) edge cases in isMouseInside() function, so now it should corectly deal with non integer offsets provided by scaling.xOff/yOff
* Now isMouseInside() return always true if scale mode is == 2, since there is no black bars in that scaling method
* Updated isMouseInside() comments
* Rewrited "Simple demo", now it uses modified demo from github's page (at moment, it takes whoping 193 lines of code, bloat!)
* Fixed typos, rewrited/rephrased comments
* Added note in scaling.toGame/scaling.toScreen about rounding/missmathing, make sure check it
* Added note about scaling.isMouseInside, make sure check it
--]]