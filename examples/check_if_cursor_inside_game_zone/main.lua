-- Example how you can test, if cursor is inside game area.
-- Usually, in your games, you don't want to register clicks on objects
-- that behind black bars.
-- So this example show you, how you can test this.
-- https://github.com/Vovkiv/resolution_solution

-- Load example image.
local image = love.graphics.newImage("image.png")
-- Boolean which teels if cursor inside game zone.
local is_inside = false

-- Setup Resolution Solution.
local rs = require("resolution_solution")

-- Configure Resolution Solution to 640x480 game with Pixel Perfect Scaling mode.
rs.conf({
    game_width = 640,
    game_height = 480,
    scale_mode = 3
  })

-- Make window resizable.
rs.setMode(rs.game_width, rs.game_height, {resizable = true})

-- Change "black" bars color to blue.
love.graphics.setBackgroundColor(0.3, 0.5, 1)

-- Setup Resolution Solution canvas. You can use scissors method as well, but
-- in this example we will use canvas.
local game_canvas = love.graphics.newCanvas(rs.get_game_size())

-- Update Resolution Solution once window size changes.
love.resize = function()
  rs.resize()
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
end

love.update = function()
  -- Check if our "real" cursor inside game zone.
  is_inside = rs.is_it_inside(love.mouse.getPosition())
end

love.draw = function()
  -- Set our Resolution Solution canvas.
  love.graphics.setCanvas(game_canvas)
  -- Clear it to avoid artefacts. Refer to love wiki.
  love.graphics.clear(0, 0, 0, 1)
  
  -- Draw out example image.
  love.graphics.draw(image)
  
  -- Tester, if we inside game zone.
  -- String become green if we in, and red if outside.
  if is_inside then
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print("Cursor inside game zone!", rs.game_width / 2, rs.game_height / 2)
  else
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.print("Cursor outside of game zone!", rs.game_width / 2, rs.game_height / 2)
  end
  
  -- Revert colors back.
  love.graphics.setColor(1, 1, 1, 1)
  
  -- Print some hints.
  love.graphics.print("Try to resize window!", 0, 0)
  love.graphics.print("Press F1, F2, F3 to change scale mode.", 0, 20)
  love.graphics.print("If your cursor inside game zone, then string will become green", 0, 40)
  love.graphics.print("And red if outside.", 0, 60)
  
  -- Once we done with drawing, lets close canvas.
  love.graphics.setCanvas()
  
  -- Start scaling.
  rs.push()
    -- Scale our Resolution Solution canvas.
    love.graphics.draw(game_canvas)
    -- Stop scaling.
  rs.pop()
end