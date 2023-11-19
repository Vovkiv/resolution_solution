-- Example how to implement cursor that won't go outside of game zone.
-- Note: by "cursor" I mean "software cursor", texture that we use as "cursor".
-- For keeping your "real" cursor inside game area, use love mouse functions
-- with game zone size, that library provides.
-- https://github.com/Vovkiv/resolution_solution

-- Example image.
local image = love.graphics.newImage("image.png")
-- Example cursor image.
local cursor_image = love.graphics.newImage("cursor.png")
-- Cursor position.
local cursor_x, cursor_y = 0, 0

-- Setup Resolution Solution.
local rs = require("resolution_solution")
-- Configure Resolution Solution to 640x480 game with Aspect Scaling mode.
rs.conf({
    game_width = 640,
    game_height = 480,
    scale_mode = 3
  })

-- Make window resizable.
rs.setMode(rs.game_width, rs.game_height, {resizable = true})

-- Change "black" bars color to blue.
love.graphics.setBackgroundColor(0.3, 0.5, 1)

-- Setup Resolution Solution canvas.
local game_canvas = love.graphics.newCanvas(rs.get_game_size())

-- Update Resolution Solution once window size changes.
love.resize = function()
  rs.resize()
end

-- Check cursor position.
love.update = function()
  -- Set cursor position to "real" cursor position.
  cursor_x, cursor_y = love.mouse.getPosition()
  
  -- If cursor is outside of x, y, w, h position, then return it inside
  -- game zone.
  
  -- Left side.
  if cursor_x < rs.game_zone.x then
    cursor_x = rs.game_zone.x
  end
  
  -- Right side.
  if cursor_x > rs.game_zone.x + rs.game_zone.w then
    cursor_x = rs.game_zone.x + rs.game_zone.w
  end
  
  -- Top side.
  if cursor_y < rs.game_zone.y then
    cursor_y = rs.game_zone.y
  end
  
  -- Bottom side.
  if cursor_y > rs.game_zone.y + rs.game_zone.h then
    cursor_y = rs.game_zone.y + rs.game_zone.h
  end
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
  love.graphics.print("Your \"cursor\" won't be able to go outside of game zone.", 0, 40)
  
  -- Once we done with drawing, lets close canvas.
  love.graphics.setCanvas()
  
  -- Start scaling.
  rs.push()
    -- Scale our canvas.
    love.graphics.draw(game_canvas)
    -- Stop scaling.
  rs.pop()
  
  -- Draw our "cursor".
  love.graphics.draw(cursor_image, cursor_x, cursor_y)
end