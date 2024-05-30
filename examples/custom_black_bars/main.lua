-- Example for Resolution Solution, how to change color for black bars or change them with custom stuff.

-- Load example image.
local image = love.graphics.newImage("image.png")

-- Setup resolution solution.
local rs = require("resolution_solution")
-- Set our game scaling to 640x480 with pixel perfect scaling.
rs.conf({
  game_width = 640,
  game_height = 480,
  scale_mode = rs.PIXEL_PERFECT_MODE
  })
-- Make window resizable.
rs.setMode(rs.game_width, rs.game_height, {resizable = true})
-- Change background color to orange.
-- So now "black bars" become "orange bars".
-- Change this value to any color you want.
love.graphics.setBackgroundColor(1, 0.5, 0.3)

-- Update library.
love.resize = function(w, h)
  rs.resize(w, h)
end

local draw_custom_bars = false

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
    -- Enable/disable rendering for custom black bars.
  elseif key == "f5" then
    draw_custom_bars = not draw_custom_bars
  end
end

love.draw = function()
  -- Start scaling.
  rs.push()
    -- Draw example image.
    love.graphics.draw(image)
    
    -- Draw hint text.
    love.graphics.print("Try to resize window.", 0, 0)
    love.graphics.print("Press F1, F2, F3, F4 to change scale mode.", 0, 20)
    love.graphics.print("Press F5 to rendering of custom bars.", 0, 40)
    
    -- Stop scaling.
  rs.pop()
  
  -- You might want to replace black bars with something else
  -- like picture, animations, etc.
  -- Here example, how you can do something like that.
  if draw_custom_bars then
      -- When you in stretch or no scaling modes, then you don't need to draw anything since in this modes
      -- you can't see bars anyway.
      if rs.scale_mode ~= rs.STRETCH_MODE and rs.scale_mode ~= rs.NO_SCALING_MODE then
        -- Left bar.
          love.graphics.draw(image, 0, rs.y_offset, 0, rs.x_offset / image:getWidth(), (love.graphics.getHeight() - (rs.y_offset * 2)) / image:getHeight())
        -- Right bar.
          love.graphics.draw(image, love.graphics.getWidth() - rs.x_offset, rs.y_offset, 0, rs.x_offset / image:getWidth(), (love.graphics.getHeight() - (rs.y_offset * 2)) / image:getHeight())
        -- Top bar.
          love.graphics.draw(image, 0, 0, 0, love.graphics.getWidth() / image:getWidth(), rs.y_offset / image:getHeight())
        -- Bottom bar.
        love.graphics.draw(image, 0, love.graphics.getHeight() - rs.y_offset, 0, love.graphics.getWidth() / image:getWidth(), rs.y_offset / image:getHeight())
        end
  end
  -- For more advanced stuff, you can use love.graphics.scissors, animations, etc.

  -- Draw white rectangle for game zone, so you can distinguish
  -- between game image and black bars images.
  love.graphics.rectangle("line", rs.get_game_zone())
end
