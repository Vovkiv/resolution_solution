-- at bottom you will find simple "how to setup library" demo and changelog

local scaling = {
  _URL = "https://github.com/Vovkiv/resolution_solution",
  _VERSION = 1000,
  _LOVE = 11.4,
  _DESCRIPTION = "Scale library, that help you add resolution support to your games in love2d!",
  -- for simlicity, iternal library name is "scaling"
  _NAME = "Resolution Solution",
  _LICENSE = "The Unlicense",
}

-- callback functions, that will be triggered when window size changed
scaling.windowChanged = function() end

-- callback functions, that will be triggered when game size changed
scaling.gameChanged = function() end

-- 1 aspect scaling; 2 full window scaling
scaling.scaleMode    = 1 

-- can be used to quicky disable rendering of black bars
scaling.drawBars     = true

scaling.widthScale   = 0
scaling.heightScale  = 0

-- size to which game should be scaled to
scaling.gameWidth    = 800
scaling.gameHeight   = 600

scaling.windowWidth  = 800
scaling.windowHeight = 600

scaling.gameAspect   = 0
scaling.windowAspect = 0

 -- offset caused by black bars
scaling.xOff         = 0
scaling.yOff         = 0

-- data of black bars; if bars left-right then: 1 bar is left, 2 is right
scaling.x1, scaling.y1, scaling.w1, scaling.h1 = 0, 0, 0, 0

-- if top-bottom then: 1 bar is upper, 2 is bottom
scaling.x2, scaling.y2, scaling.w2, scaling.h2 = 0, 0, 0, 0

-- colors of black bars; red, green, blue, alpha
scaling.r, scaling.g, scaling.b, scaling.a = 0, 0, 0, 1

scaling.update = function()
  -- coordinates of black bars
  local x1, y1, w1, h1
  local x2, y2, w2, h2

  -- scale
  local scaleWidth, scaleHeight
  
  -- offset
  local xOff, yOff

  local gameWidth, gameHeight = scaling.gameWidth, scaling.gameHeight
  local windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()

  local gameAspect = gameWidth / gameHeight
  local windowAspect = windowWidth / windowHeight
  
  -- check for game size changes
  local oldGameAspect   = scaling.gameAspect
  
  -- check for window size changes
  local oldWindowAspect = scaling.windowAspect
  
  -- scale mode
  local scaleMode = scaling.scaleMode

  -- aspect scaling method
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
  
  -- stretch scaling method
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
  
  -- Callback check when game virtual size changes
  if oldGameAspect ~= gameAspect then
    scaling.gameChanged()
  end
  
  -- Callback check when window changes it size
  if oldWindowAspect ~= windowAspect then
    scaling.windowChanged()
  end

end

scaling.start = function()
  -- prepare to scale
  love.graphics.push()
  
  -- reset transformation
  love.graphics.origin()

  -- set offset
  love.graphics.translate(scaling.xOff, scaling.yOff)
  
  -- scale
  love.graphics.scale(scaling.scaleWidth, scaling.scaleHeight)
end

scaling.stop = function()
  -- stop scaling
  love.graphics.pop()

  -- do nothing if we don't need draw bars or we in aspect scaling mode (1)
  if not scaling.drawBars or scaling.scaleMode ~= 1 then
    return
  end

  -- prepare draw black bars
  love.graphics.push()
  
  -- reset transformation
  love.graphics.origin()

  -- set color for black bars
  love.graphics.setColor(scaling.r, scaling.g, scaling.b, scaling.a)

  -- draw left or top most
  love.graphics.rectangle("fill", scaling.x1, scaling.y1, scaling.w1, scaling.h1)
  -- draw right or bottom most
  love.graphics.rectangle("fill", scaling.x2, scaling.y2, scaling.w2, scaling.h2)
  
  love.graphics.pop()
end -- end scaling.stop

scaling.unscaleStart = function()
  -- if you need draw somethiong not scaled by library

  love.graphics.push()
  love.graphics.origin()
end

scaling.unscaleStop = function()
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
  -- will reset black bars color to black

  scaling.r = 0 -- red
  scaling.g = 0 -- green
  scaling.b = 0 -- blue
  scaling.a = 1 -- alpha
end

scaling.getScale = function()  
  return scaling.scaleWidth, scaling.scaleHeight
end

scaling.switchScaleMode = function()
  -- function to quckly switch in-between scale modes

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
  scaling.drawBars = not scaling.drawBars
end

scaling.isMouseInside = function()
  -- with that you can determine if mouse inside scaled area
  -- not touching black bars

  -- get mouse coordinates
  local mouseX, mouseY = love.mouse.getPosition()
  
  -- get offset
  -- be careful about edge cases where offset may be not integer
  -- math.floor was used to try to reduce that, but...
  local xOff, yOff     = math.floor(scaling.xOff), math.floor(scaling.yOff)
  
  -- get window size
  local windowWidth    = scaling.windowWidth
  local windowHeight   = scaling.windowHeight

  if mouseX    >= xOff                 and -- left
     mouseY    >= yOff                 and -- top
     mouseX    <= windowWidth  - xOff  and -- right
     mouseY    <= windowHeight - yOff then -- bottom
      return true
  end

  return false
end

scaling.toGame = function(x, y)
  -- thanslate coordinates from non-scaled to scaled.
  -- e.g translate real mouse coordinates into scaled so you can check
  -- for example, area to check collisions

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

-- Simple demo:
--[[
  local scaling = require("scaling")
  
  love.window.setMode(1024, 600, {resizable = true})
  
  scaling.setGame(1280, 720)

  love.graphics.setBackgroundColor(0.5, 0.5, 0.5)
  
  local helloWorld = "Hello!\nMy name is " .. tostring(scaling._NAME) .. "\nMy purpose is: " .. tostring(scaling._DESCRIPTION) .. "\nVersion is: " .. tostring(scaling._VERSION)
  local x, y = (scaling.gameWidth / 2) - love.graphics.newFont():getWidth(helloWorld) / 2, (scaling.gameHeight / 2) - love.graphics.newFont():getHeight(helloWorld) / 2
  
  love.update = function(dt)
    scaling.update()
  end

  love.draw = function()
    scaling.start()
    
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.print(helloWorld, x, y)
    
    scaling.stop()
  end
--]]

-- Changelog:
--[[
Version 1000, 7 january 2021
Initial release
--]]
