-- camera.lua - https://github.com/vrld/hump/blob/master/camera.lua, by Matthias Richter

-- This is example for Resolution Solution, how you can use
-- HUMP camera library with Resolution Solution.
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
rs.conf({
  game_width = 640,
  game_height = 480,
  scale_mode = rs.ASPECT_MODE
})
-- Make window resizable.
rs.setMode(rs.game_width, rs.game_height, {resizable = true})

-- Setup HUMP camera.
local HUMP_camera = require("camera")
-- Create new camera.
local cam = HUMP_camera(128, 128)

-- Update resolution solution once window size changed.
love.resize = function(w, h)
  rs.resize(w, h)
end

-- Create canvas that camera will draw to.
-- It should be same size as game width and height.
--
-- In case if we ould use no scaling mode, canvas should be updated everytime when window
-- size changes.
local camera_canvas = love.graphics.newCanvas(rs.game_width, rs.game_height)

-- Change scaling mode at runtime.
love.keypressed = function(key)
  if key == "f1" then
    rs.conf({scale_mode = rs.ASPECT_MODE})
  elseif key == "f2" then
    rs.conf({scale_mode = rs.STRETCH_MODE})
  elseif key == "f3" then
    rs.conf({scale_mode = rs.PIXEL_PERFECT_MODE})
  elseif key == "f4" then
    rs.conf({scale_mode = rs.NO_SCALING_MODE})
  end
end

love.update = function(dt)
  -- Quick example how you can move camera around.
  local current_x, current_y = cam:position()
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
  cam:lookAt(current_x, current_y)
  end

rs.resize_callback = function()
  if rs.scale_mode == rs.NO_SCALING_MODE then
    camera_canvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
  else
    camera_canvas = love.graphics.newCanvas(rs.game_width, rs.game_height)
  end
end

love.draw = function()
  -- Before we do scaling work, you need to draw to camera's
  -- canvas and only then scale camera's canvas with
  -- Resolution Solution.
  
  -- Here's deal:
  -- cam:attach() allow you passing arguments to it, to limit what camera can draw.
  -- Internally, HUMP camera relies on scissors, so arguments that you pass
  -- affects how much camera will see.
  -- So, we will force camera to draw to same resolution, as our game.
  -- You can pass it by hand or just use rs.get_game_size()
  --
  -- In case if we would use no scaling mode, we will pass
  -- window size instead.
  if rs.scale_mode == rs.NO_SCALING_MODE then
    cam:attach(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  else
    cam:attach(0, 0, rs.game_width, rs.game_height)
  end
    -- Setup canvas for camera.
    love.graphics.setCanvas(camera_canvas)
    -- Clear it with color.
    -- Refer to love wiki for more info.
    love.graphics.clear(1, 1, 1, 0)
    -- Draw example image.
    love.graphics.draw(image)
    -- Draw some text.
    love.graphics.print("HUMP camera!", 512, 512)
    
    -- Once you done with drawing to canvas, unset it.
    love.graphics.setCanvas()
    -- Dettach camera.
  cam:detach()
  
  -- Do usual Resolution Solution stuff.
  -- Start scaling.
  rs.push()
    -- Draw camera's canvas.
    love.graphics.draw(camera_canvas)
    -- Print current camera x and y position.
    love.graphics.print("x: " .. select(1, cam:position()), 0, 0)
    love.graphics.print("y: " .. select(2, cam:position()), 0, 20)
    -- Hint that you can move around and resize window and switch scaling mode.
    love.graphics.print("Use WASD to move camera around.", 0, 40)
    love.graphics.print("Also try to resize window.", 0, 60)
    love.graphics.print("Press F1, F2, F3, F4 to change scale mode.", 0, 80)
    -- Stop scaling.
  rs.pop()
  
  -- Draw rectangle to see game zone.
  love.graphics.rectangle("line", rs.get_game_zone())
end
