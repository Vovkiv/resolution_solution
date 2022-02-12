-- At bottom you will find demo, don't miss it, if you have not much idea of what this library do.
-- There changelog, too

local rs = {
  _URL = "https://github.com/Vovkiv/resolution_solution",
  _VERSION = 1003,
  _LOVE = 11.4,
  _DESCRIPTION = "Scale library, that help you add resolution support to your games in love2d!",
  _NAME = "Resolution Solution",
  _LICENSE = "The Unlicense",
  _LICENSE_TEXT = [[
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <https://unlicense.org>
]]
}

-- Callback functions, that will be triggered when window size is changed
-- with that you can, for example, draw custom ui, which shouldn't be scaled with game
-- and update it only when window and/or game virtual resolution is changed
rs.windowChanged = function() end
-- Callback functions, that will be triggered when game virtual size is changed
rs.gameChanged = function() end

-- 1 aspect scaling (default; scale game with black bars on top-bottom or left-right)
-- 2 stretched scaling mode (scale virtual resolution to fill entire window; may be harmful for pixel art)
-- (also, just tip: if possible, add in-game option to change scale method (rs.switchScaleMode should be preferred, in case if i add more scaling methods in future)
-- it might be just preferred for someone to play with stretched graphics; youtubers/streamers may have better experience with your game, for example, if they won't to get rid of black bars, without dealing with obs crop tools or in montage apps)
rs.scaleMode    = 1

-- can be used to quicky disable rendering of black bars
-- for example, to see if game stop objects rendering if they outside of players fov and if it works correctly with black bars offset)
-- True (default) - render black bars
-- False - don't render black bars
-- true is default; when rs.scaleMode is 2, does nothing
rs.drawBars     = true

-- Scale width value, use that for scaling related math
-- (if rs.scaleMode == 1, rs.widthScale and rs.heightScale is eqial)
rs.widthScale   = 0
-- Scale height value, use that for scaling related math
-- (if rs.scaleMode == 1, rs.widthScale and rs.heightScale is eqial)
rs.heightScale  = 0

-- Virtual width for game, that library will scale to
rs.gameWidth    = 800
-- Virtual height for game, that library will scale to
rs.gameHeight   = 600

-- Window width
rs.windowWidth  = 800
-- Window height
rs.windowHeight = 600

-- Aspect for virtual game size
rs.gameAspect   = 0
-- Aspect for window size
rs.windowAspect = 0

-- Width offset, caused by black bars;
-- There will be 2 black bars on each side, so take into account that
rs.xOff         = 0
-- Height offset, caused by black bars;
-- There will be 2 black bars on each side, so take into account that
rs.yOff         = 0

-- X, Y, Width, Height for 1st bar;
-- If bars drawed as left-right then: 1st bar is left; If bars drawed as left-right then 1st is upper
rs.x1, rs.y1, rs.w1, rs.h1 = 0, 0, 0, 0

-- X, Y, Width, Height for 2nd bar;
-- If bars drawed as left-right then: 2nd is right; If bars drawed as left-right then 2nd is bottom
rs.x2, rs.y2, rs.w2, rs.h2 = 0, 0, 0, 0

-- colors of black bars; red, green, blue, alpha
rs.r, rs.g, rs.b, rs.a = 0, 0, 0, 1

rs.update = function()
  -- coordinates of black bars
  local x1, y1, w1, h1
  local x2, y2, w2, h2

  -- scale for game virtual size
  local scaleWidth, scaleHeight
  
  -- offset for black bars
  local xOff, yOff

  -- virtual game size
  local gameWidth, gameHeight = rs.gameWidth, rs.gameHeight
  -- window size
  local windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()

  -- get aspect of window and virtual game size
  local gameAspect = gameWidth / gameHeight
  local windowAspect = windowWidth / windowHeight
  
  -- check rs.gameChanged() callback
  local oldGameAspect   = rs.gameAspect
  
  -- check rs.windowChanged() callback
  local oldWindowAspect = rs.windowAspect
  
  -- scale mode
  local scaleMode = rs.scaleMode

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
  rs.x1, rs.y1, rs.w1, rs.h1 = x1, y1, w1, h1
  rs.x2, rs.y2, rs.w2, rs.h2 = x2, y2, w2, h2
  
  -- offset generated for black bars
  rs.xOff, rs.yOff = xOff, yOff
  
  -- scale
  rs.scaleWidth, rs.scaleHeight = scaleWidth, scaleHeight
  
  -- window size
  rs.windowWidth, rs.windowHeight = windowWidth, windowHeight
  
  -- ascpects
  rs.gameAspect, rs.windowAspect = gameAspect, windowAspect
  
  -- Call rs.gameChanged() if virtual game size is changed
  if oldGameAspect ~= gameAspect then
    rs.gameChanged()
  end
  
  -- Call rs.windowChanged() if window size is changed
  if oldWindowAspect ~= windowAspect then
    rs.windowChanged()
  end

end

rs.start = function()
  -- Start scaling graphics until rs.stop().
  -- Everything inside this function will be scaled to fit virtual game size
  
  -- prepare to scale
  love.graphics.push()
  
  -- reset transformation
  love.graphics.origin()

  -- set offset, based on size of black bars
  love.graphics.translate(rs.xOff, rs.yOff)
  
  -- scale game
  love.graphics.scale(rs.scaleWidth, rs.scaleHeight)
end

rs.stop = function()
  -- Stop scaling caused by rs.start()
  -- and draw black bars, if needed.
  
  -- stop scaling
  love.graphics.pop()

  -- do nothing if we don't need draw bars or we in aspect scaling mode (1; with black bars)
  if not rs.drawBars or rs.scaleMode ~= 1 then
    return
  end
  
  -- get colors, that was before rs.stop() function
  local r, g, b, a = love.graphics.getColor()
  
  -- prepare to draw black bars
  love.graphics.push()
  
  -- reset transformation
  love.graphics.origin()

  -- set color for black bars
  love.graphics.setColor(rs.r, rs.g, rs.b, rs.a)

  -- draw left or top most
  love.graphics.rectangle("fill", rs.x1, rs.y1, rs.w1, rs.h1)
  -- draw right or bottom most
  love.graphics.rectangle("fill", rs.x2, rs.y2, rs.w2, rs.h2)
  
  -- return original colors that was before rs.stop()
  love.graphics.setColor(r, g, b, a)
  
  -- end black bars rendering
  love.graphics.pop()
end -- end rs.stop

rs.unscaleStart = function()
  -- Reset scaling with love.origin() until rs.unscaleStop().
  -- With that you can, for example, draw ui with custom scaling.
  
  -- start unscaling
  love.graphics.push()
  
  -- reset coordinates and scaling
  love.graphics.origin()
end

rs.unscaleStop = function()
  -- Stop scaling caused by rs.unscaleStart().
  -- With that you can, for example, draw ui with custom scaling.
  
  -- stop unscaling
  love.graphics.pop()
end

rs.setColor = function(r, g, b, a)
  -- Set color of black bars.

  rs.r = r -- red
  rs.g = g -- green
  rs.b = b -- blue
  rs.a = a -- alpha
end

rs.getColor = function()
  -- Get red, green, blue and alpha colors of black bars.

  return rs.r, -- red
         rs.g, -- green
         rs.b, -- blue
         rs.a  -- alpha
end

rs.defaultColor = function()
  -- Reset colors for black bars to default black opague color.

  rs.r = 0 -- red
  rs.g = 0 -- green
  rs.b = 0 -- blue
  rs.a = 1 -- alpha
end

rs.getScale = function()
  -- Get scale by width and height
  return rs.scaleWidth, rs.scaleHeight
end

rs.switchScaleMode = function()
  -- Function to switch in-between scale modes.

    if rs.scaleMode ~= 1 then 
      rs.scaleMode = 1 -- aspect mode
    else
      rs.scaleMode = 2 -- stretch mode
    end
end

rs.setGame = function(width, height)
  -- Set virtual size which game should be scaled to.
  -- Note: this function doesn't do any validation for incoming arguments.
  rs.gameWidth = width
  rs.gameHeight = height
end

rs.getGame = function()
  -- Return game virtual width and height.

  return rs.gameWidth, rs.gameHeight
end

rs.getWindow = function()
  -- Get window width and height.

  return rs.windowWidth, rs.windowHeight
end

rs.switchDrawBars = function()
  -- Turn of/off rendering for black bars.
  
  rs.drawBars = not rs.drawBars
end

rs.isMouseInside = function()
  -- Determine if cursor inside scaled area and don't touch black bars
  -- Use it when you need detect if cursor touch in-game objects, without false detection on black bars zone;
  -- always return true if rs.scalingMode == 2 because game will be scaled to entire window
  -- so there is no black bars, so you can safely use this function with any scaling method;

  -- check if scale mode is not stretching (2), otherwise return true
  if rs.scaleMode == 2 then
    return true
  end
  
  -- get mouse coordinates
  local mouseX, mouseY = love.mouse.getPosition()
  
  -- get offset
  -- also, as will be mentioned in rs.toGame, there will some rounding/missmath with float coordinates;
  -- rs.toGame don't do anything with that, you should take care about this, but here
  -- for convenience, this function simply round to nearest integer, which should take care about edge cases;
  -- if you have any suggestion, etc, feel free add issue ticket/pull request at library's github page, provided in rs.__URL
  local xOff, yOff     = math.floor(rs.xOff + 0.5), math.floor(rs.yOff + 0.5)
  
  -- get window size
  local windowWidth    = rs.windowWidth
  local windowHeight   = rs.windowHeight

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

rs.toGame = function(x, y)
  -- Translate coordinates from non-scaled values to scaled;
  -- e.g translate real mouse coordinates into scaled so you can check
  -- for example, area to check collisions with object and cursor;
  
  -- ALSO, NOTE: don't forget about math precition and rounding, because with some scaling value
  -- using something like "rs.toGame(love.mouse.getPosition())" coordinates may produce: x -0.31 y -0.10
  -- when you may expect just 0, 0
  -- so make sure that you properly threat this kind of edge cases
  -- because, as you might already guessed, library don't do anything with this, so take care about this yourself

  return (x - rs.xOff) / rs.scaleWidth, (y - rs.yOff) / rs.scaleHeight
end

rs.toGameX = function(x)
  -- Translate x coordinate from non-scaled to scaled
  -- e.g translate real mouse coordinates into scaled so you can check
  -- for example, area to check collisions with object and cursor;
  return (x - rs.xOff) / rs.scaleWidth
end

rs.toGameY = function(y) 
  -- Translate y coordinate from non-scaled to scaled
  -- e.g translate real mouse coordinates into scaled so you can check
  -- for example, area to check collisions with object and cursor;

  return (y - rs.yOff) / rs.scaleHeight
end

rs.toScreen = function(x, y)
  -- Thanslate coordinates from scaled to non scaled.
  -- e.g translate x and y of object inside scaled area
  -- to, for example, set cursor position to that object
  
  return (x * rs.scaleWidth) + rs.xOff, (y * rs.scaleHeight) + rs.yOff
end

rs.toScreenX = function(x)
  -- Thanslate x coordinate from scaled to non scaled.
  -- e.g translate x of object inside scaled area
  -- to, for example, set cursor position to that object
  
  return (x * rs.scaleWidth) + rs.xOff
end

rs.toScreenY = function(y)
  -- Thanslate y coordinate from scaled to non scaled.
  -- e.g translate y of object inside scaled area
  -- to, for example, set cursor position to that object
  
  return (y * rs.scaleHeight) + rs.yOff
end

return rs

-- demo:
--[[
local rs = require("resolution_solution")

-- i highly recommend always allow window resizing for your games
love.window.setMode(800, 600, {resizable = true})
love.window.setTitle(rs._NAME .. " - library demo - v" .. rs._VERSION)

-- set game virtual size
rs.setGame(1280, 720)

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
rs.gameChanged = function()
  gameChangedTimes = gameChangedTimes + 1
end

--  window size changed callback
rs.windowChanged = function()
  windowChangedTimes = windowChangedTimes + 1
end

-- keyboard
love.keypressed = function(key)
  -- set randow virtual size
  if key == "q" then rs.setGame(love.math.random(800, 1920), love.math.random(600, 1080)) end
  
  -- switch scale mode
  if key == "w" then rs.switchScaleMode() end
  
  -- reset virtual size
  if key == "r" then rs.setGame(1280, 720) end
end

local isMouseUnder = function(x, y, w, h)
  -- function to check if mouse under something
  
  -- get scaled to game mouse position
  local mx, my = rs.toGame(love.mouse.getPosition())
  
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
  rs.update()
  
  -- count timer
  timer = timer + dt
  
  -- set timer to zero if it reach limit
  if timer > timerLimit then timer = 0 end

  -- move rectangle in circle
  -- x coordinate
  dx = x * math.sin(timer) + 150 + (rs.gameWidth / 10)
  
  -- y coordinate
  dy = y * math.cos(timer) + 150 + (rs.gameHeight / 10)

  -- change width and height of moving rectangle
  dw = w + 200 * math.sin(timer / 2)
  dh = h + 200 * math.sin(timer / 2)

  -- this will be used to determine is mouse under rectangle in love.draw
  underRectangle = isMouseUnder(dx, dy, dw, dh)
  
  -- message/instructions
  message = "Does mouse touch moving rectangle?: " .. tostring(underRectangle) .. "\n" ..
            "Press Q to change virtual size: w" .. tostring(rs.gameWidth) .. " h" .. tostring(rs.gameHeight) .. "\n" ..
            "Press W to change scaling mode: " .. tostring(rs.scaleMode) .. "\n" ..
            "Press R to reset virtual size" .. "\n" ..
            "Times virtual size changed: " .. gameChangedTimes .. "\n" ..
            "Times window size changed: " .. windowChangedTimes .. "\n" ..
            "Is mouse inside scaled area?(does it touch black bars?): " .. tostring(rs.isMouseInside()) .. "\n" ..
            "Press space to set cursor to moving rectangle" .. "\n" ..
            "Press S to set non moving rectangle to cursor" .. "\n" ..
            "Scaled mouse coordinates: x" .. string.format("%.2f", rs.toGameX(love.mouse.getX())) .. " y: " .. string.format("%.2f", rs.toGameY(love.mouse.getY())) .. "\n"

  -- set cursor to moving rectangle; that how you can use toScreen() function
  if love.keyboard.isDown("space") then love.mouse.setPosition(rs.toScreen(dx, dy)) end
  
  -- set non-moving rectangle to cursor; that how you can use toGame() function
  if love.keyboard.isDown("s") then 
    rectangle[1] = rs.toGameX(love.mouse.getX())
    rectangle[2] = rs.toGameY(love.mouse.getY())
    end

end
  
love.draw = function()
  rs.start()
  
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
    love.graphics.rectangle("fill", rs.toGameX(love.mouse.getX()), rs.toGameY(love.mouse.getY()), 10, 10)
    
    -- set color for non-moving rectangle
    love.graphics.setColor(0, 0, 0, 1)
    
    -- draw non-moving rectangle
    love.graphics.rectangle("line", unpack(rectangle))
    
    rs.unscaleStart()
    -- example how you can use "unscale" function
    -- with that you can draw custom ui, that you don't want to scale with library itself
    -- or maybe with that create nice rendering for string, in pair with rs.window/gameChanged
  
      -- draw semi-transparent background for "I'm unscaled!" string
      -- set i't color to black and make transparent
      love.graphics.setColor(0, 0, 0, 0.5)

      -- get width and height for that background
  love.graphics.rectangle("fill", rs.windowWidth - (rs.xOff + 100), rs.windowHeight - (rs.yOff + 100), love.graphics.newFont():getWidth("I'm unscaled!"), love.graphics.newFont():getHeight("I'm unscaled!"))
    
      -- draw "I'm unscaled!" string
      -- add offset for it, so it will be not drawed under black bars
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.print("I'm unscaled!", rs.windowWidth - (rs.xOff + 100), rs.windowHeight - (rs.yOff + 100))
      
    rs.unscaleStop()
  rs.stop()
  
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

Version 1003, 12 february 2022
* Added library license text in rs._LICENSE_TEXT
* Added auto-completion API for Zerobrane Studio!
Visit rs._URL and file RS_ZBS_API.lua for more info
* Updated comments
--]]
