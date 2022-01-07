local scaling = require("resolution_solution")

-- i highly recommend always allow window resizing for your games
love.window.setMode(800, 600, {resizable = true})
love.window.setTitle(scaling._NAME .. " - library demo - v" .. scaling._VERSION)

-- set virtual size
scaling.setGame(1280, 720)

love.graphics.setBackgroundColor(0.5, 0.5, 0.5)

-- rectangle that doesn't move
-- used to show toScreen function
local rectangle = {100, 100, 100, 100}

-- timer for sine and cosine
local timer = 0
local timerLimit = math.pi * 2

-- is mouse under moving rectangle?
local underRectangle = false

-- rectangle that moves
-- used to show how you can implement mouse colission detection
local x, y, w, h = 200, 200, 20, 20
local dx, dy, dw, dh = 0, 0, 0, 0

-- example image
local image = love.graphics.newImage("example.png")

-- explaining what the fuck happening on screen
local message = ""

-- counters
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
  if key == "e" then scaling.setGame(1280, 720) end
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
            "Press S to set non moving rectangle to cursor" .. "\n"

  -- set cursor to moving rectangle
  if love.keyboard.isDown("space") then love.mouse.setPosition(scaling.toScreen(dx, dy)) end
  
  -- set not moving rectangle to cursor
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
  
  -- change color of moving rectangle, based on true or false
  if underRectangle then love.graphics.setColor(0, 1, 0) else love.graphics.setColor(1, 0, 0) end
  
  -- draw moving rectangle
  love.graphics.rectangle("line", dx, dy, dw, dh)
    
    -- set color for "cursor" which will follow cursor
    -- used to show how to use toGame function
    love.graphics.setColor(1, 0.4, 0.9, 1)
    -- draw that "cursor" rectangle
    love.graphics.rectangle("fill", scaling.toGameX(love.mouse.getX()), scaling.toGameY(love.mouse.getY()), 10, 10)
    
    -- set color for not moving rectangle
    love.graphics.setColor(0, 0, 0, 1)
    
    -- draw it
    love.graphics.rectangle("line", unpack(rectangle))
    
    scaling.unscaleStart()
  
    -- example how you can use "unscale" function
    -- maybe you can draw custom ui, that you don't want to scale with library itself
    -- or maybe with that create nice rendering for string, in pair with scaling.window/gameChanged
  
      -- draw semi-transparent background for "I'm unscaled!" string
      -- set i't color to black and make transparent
      love.graphics.setColor(0, 0, 0, 0.5)
      -- that how i got height and width for it
      -- ignore it
  love.graphics.rectangle("fill", scaling.windowWidth - (scaling.xOff + 100), scaling.windowHeight - (scaling.yOff + 100), love.graphics.newFont():getWidth("I'm unscaled!"), love.graphics.newFont():getHeight("I'm unscaled!"))
    
      -- draw "I'm unscaled!" string
      -- add offset for it, so it will be not drawed under black bars
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.print("I'm unscaled!", scaling.windowWidth - (scaling.xOff + 100), scaling.windowHeight - (scaling.yOff + 100))
      
    scaling.unscaleStop()
  scaling.stop()
  
    -- draw explaining/instruction
    love.graphics.setColor(0, 0, 0, 0.5)
    -- because i lazy, i count how much string have new lines and use them to determine height oh string
  love.graphics.rectangle("fill", 0, 0, love.graphics.newFont():getWidth(message), love.graphics.newFont():getHeight(message) * select(2, string.gsub(message, "\n", "\n")))

  love.graphics.setColor(1, 1, 1, 1)  
  love.graphics.print(message)
  
end