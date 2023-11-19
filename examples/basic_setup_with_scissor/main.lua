-- This is basic setup for Resolution Solution using love's scissors.
-- https://github.com/Vovkiv/resolution_solution
-- This method might be easier to setup, compared to method using canvases,
-- (since you don't need to creat any canvas, clear it, etc)
-- And might be slightly more performant, but might lead to some
-- compatability issues with some libraries.
-- Most notable is camera libraries, which often relies on scissors to achieve
-- scrolling.


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

love.draw = function()
  -- Start scaling.
  rs.push()
    -- Get current scissors.
    local old_x, old_y, old_w, old_h = love.graphics.getScissor()
    
    -- Set scissors to size of game.
    -- Luckily, library provide get_game_zone() function for such cases.
    -- But you might pass values by hand as well.
    love.graphics.setScissor(rs.get_game_zone())
    
    -- Now you can draw something, that you want to scale.
    love.graphics.draw(image)
    
    -- Print some hints.
  love.graphics.print("Try to resize window!", 0, 0)
  love.graphics.print("Press F1, F2, F3 to change scale mode.", 0, 20)
    
    -- Once we done with our scissorring, we need to revert scissors.
    love.graphics.setScissor(old_x, old_y, old_w, old_h)
    -- Stop scaling.
  rs.pop()
end