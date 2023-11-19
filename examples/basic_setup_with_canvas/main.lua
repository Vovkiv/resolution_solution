-- This is basic setup for Resolution Solution using love's canvases.
-- https://github.com/Vovkiv/resolution_solution

-- Load example image.
local image = love.graphics.newImage("image.png")

-- Setup Resolution Solution.
local rs = require("resolution_solution")
-- Configure Resolution Solution to 640x480 game with Aspect Scaling mode.
rs.conf({
    game_width = 640,
    game_height = 480,
    scale_mode = 1
  })

-- Make window resizable.
rs.setMode(rs.game_width, rs.game_height, {resizable = true})

-- Change "black" bars color to blue.
love.graphics.setBackgroundColor(0.3, 0.5, 1)

-- Setup Resolution Solution canvas, which will be scaled later.
-- Set canvas to size of game.
-- Note:
-- If you going to implement several resolutions in your game
-- e,g 800x600, 1920x1080, etc
-- then you need to re-create this canvas with new game size.
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
-- Draw stuff.
love.draw = function()
  -- Setup canvas.
  love.graphics.setCanvas(game_canvas)
  -- Clear it to avoid artefacts. Refer to love wiki.
  love.graphics.clear(0, 0, 0, 1)
  -- Draw our example image.
  love.graphics.draw(image)
  
  -- Print some hints.
  love.graphics.print("Try to resize window!", 0, 0)
  love.graphics.print("Press F1, F2, F3 to change scale mode.", 0, 20)
  
  
  -- Once we done with drawing, lets close canvas.
  love.graphics.setCanvas()
  
  -- Start scaling.
  rs.push()
    -- Scale our canvas.
    love.graphics.draw(game_canvas)
    -- Stop scaling.
  rs.pop()
  
  -- Everything outside of rs.push and rs.pop will be unscaled.
  

end