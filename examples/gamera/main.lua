-- Gamera.lua - https://github.com/kikito/gamera, by kikito, MIT License.
-- 
-- This is example for Resolution Solution, how you can use
-- gamera camera library with Resolution Solution.
-- This example relies on love's canvas system, but there possibility
-- to use scissors instead.

-- Set filtering.
love.graphics.setDefaultFilter("nearest", "nearest")

-- Load example image.
local image = love.graphics.newImage("image.png")

-- Setup resolution solution.
local rs = require("resolution_solution")
-- Set our game scaling to 640x480 with aspect scaling.
-- Gamera should work absolutely fine with any scaling mode:
-- Be it: Stretch, Aspect Scaling or Pixel Perfect.
-- Try to change it to: 1, 2 and 3 and see how it goes.
rs.conf({game_width = 640, game_height = 480, scale_mode = 1})
-- Make window resizable.
rs.setMode(rs.game_width, rs.game_height, {resizable = true})

-- Setup gamera.
local gamera = require("gamera")
-- Create new camera that will be x2 times bigger then our game resolution.
local cam = gamera.new(0, 0, rs.game_width * 2, rs.game_height * 2)

-- By default, gamera use whole window to display stuff
-- but we will restrict it to game size.
-- As far as I understands, gamera use love.graphics.scissors
-- to limit drawing area.
-- Since we scale game to our game size, there no need for
-- gamera to draw to entire screen anyway.
cam:setWindow(0, 0, rs.game_width, rs.game_height)

-- Update resolution solution once window size changed.
love.resize = function(w, h)
  rs.resize()
end

-- Create canvas that gamera will draw to.
-- It should be same size as game width and height.
local gamera_canvas = love.graphics.newCanvas(rs.game_width, rs.game_height)
-- Create draw function for gamera.
local gamera_draw_function = function(l, t, w, h)
  -- Draw here everything, that should be affected by camera.
  -- Game world, etc.
  
  -- Setup canvas for gamera.
  love.graphics.setCanvas(gamera_canvas)
  -- Clear it with color.
  -- Refer to love wiki for more info.
  love.graphics.clear(1, 1, 1, 0)
  -- Draw example image.
  love.graphics.draw(image)
  -- Draw some text.
  love.graphics.print("Gamera is the best!", 512, 512)
  -- Once you done with drawing to canvas, unset it.
  love.graphics.setCanvas()
end

-- Change scaling mode at runtime.
love.keypressed = function(key)
  if key == "f1" then
    rs.conf({scale_mode = 1})
  elseif key == "f2" then
    rs.conf({scale_mode = 2})
  elseif key == "f3" then
    rs.conf({scale_mode = 3})
  end
  -- IMPORTANT NOTE:
  -- If you planning to implement scaling mode switching during runtime
  -- e.g: via some keyboard key or in-game options menu.
  -- Don't forget to call camera's setPosition function.
  -- Otherwise, canvas with gamera stuff will get more and more
  -- artefacts every time when you switch scaling mode.
  -- This is due to canvas + resolution solution + gamera combo.
  -- If you implement it using scissors or something else, then
  -- There won't be such problem
  -- 
  -- Comment this line and start switching scaling mode.
  -- Take closer look at "Gamera is the best!" string at 512, 512
  -- and see how it become less and less redably with every
  -- scaling mode switch.
  cam:setPosition(cam:getPosition())
end

love.update = function(dt)
  -- Quick example how you can move camera around.
  local current_x, current_y = cam:getPosition()
  local speed = 100
  
  -- Move around with WASD to see, if camera is working.
  if love.keyboard.isDown("a") then
    current_x = current_x - (speed * dt)
  end
  
  if love.keyboard.isDown("d") then
    current_x = current_x + (speed * dt)
  end
  
  if love.keyboard.isDown("w") then
    current_y = current_y - (speed * dt)
  end
  
  if love.keyboard.isDown("s") then
    current_y = current_y + (speed * dt)
  end
  
  -- Once we moved, we can update camera position.
  cam:setPosition(current_x, current_y)
  end

love.draw = function()
  -- Before we do scaling work, you need to draw to gamera's
  -- canvas and only then scale gamera's canvas with
  -- Resolution Solution.
  cam:draw(gamera_draw_function)
  -- Do usual Resolution Solution stuff.
  -- Start scaling.
  rs.push()
    -- Draw gamera's canvas.
    love.graphics.draw(gamera_canvas)
    -- Print current camera x and y position.
    love.graphics.print("x: " .. select(1, cam:getPosition()), 0, 0)
    love.graphics.print("y: " .. select(2, cam:getPosition()), 0, 20)
    -- Hint that you can move around and resize window and switch scaling mode.
    love.graphics.print("Use WASD to move camera around.", 0, 40)
    love.graphics.print("Also try to resize window.", 0, 60)
    love.graphics.print("Press F1, F2, F3 to change scale mode.", 0, 80)
    -- Stop scaling.
  rs.pop()
  
  -- Draw rectangle to see game zone.
  love.graphics.rectangle("line", rs.get_game_zone())
end