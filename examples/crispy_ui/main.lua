-- This is simplest example of how you can implement ui scaling which will always be "crispy".
-- Note, that this example only shows you general idea, how this can be achieved,
-- not fully ready to be used solution.
-- https://github.com/Vovkiv/resolution_solution

-- Set filtering to be more "crispy".
love.graphics.setDefaultFilter("nearest", "nearest")

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

-- Data for rectngle button.
local rectangle_button_frame = {}
local rectangle_button_font
local rectangle_is_touching = false

-- Boolean, which tells if cursor inside game zone.
local is_inside_game_zone = false

-- Setup Resolution Solution canvas.
local game_canvas = love.graphics.newCanvas(rs.get_game_size())

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

-- Update Resolution Solution once window size changes.
love.resize = function()
  rs.resize()
end

-- This function called after rs.resize done it's things
-- so you can hook into it and update UI after game re-scales
-- to avoid updating UI on love.update.
rs.resize_callback = function()
  -- Re-create rectangle button.
  rectangle_button_frame = {
    x = rs.game_zone.x + rs.game_zone.w / 2,
    y = rs.game_zone.y + rs.game_zone.h / 2,
    w = rs.game_zone.w * 0.25,
    h = rs.game_zone.h * 0.25,
  }
  -- Note: this scaling example not going to work with Stretch Scaling (2), so for that mode you need to come up with something better if you wish to support it.
  rectangle_button_font = love.graphics.newFont(
    math.max( -- If you pass font size less then 1, then love will raise error, so to prevent htis, we will limit it to 1.
      math.min(rs.game_zone.w * 0.04, rs.game_zone.h * 0.04),
    1)
  )
end
-- Call at least once this function manually, to update buttons calculations.
-- Otherwise, if user never change scale mode or window size,
-- rectangle_button_frame will be empty, so
-- error will be raised.
rs.resize_callback()

love.update = function()
  -- Get cursor position.
  local mx, my = love.mouse.getPosition()
  -- check if cursor inside game aread.
  is_inside_game_zone = rs.is_it_inside(mx, my)
  
  -- Collision check for rectangle.
  if is_inside_game_zone and
    mx > rectangle_button_frame.x and
    my > rectangle_button_frame.y and
    mx < rectangle_button_frame.x + rectangle_button_frame.w and
    my < rectangle_button_frame.y + rectangle_button_frame.h then
     
    rectangle_is_touching = true
  else
    rectangle_is_touching = false
  end
end

love.draw = function()
  -- Setup canvas.
  love.graphics.setCanvas(game_canvas)
  -- Clear it to avoid artefacts. Refer to love wiki.
  love.graphics.clear(0, 0, 0, 1)
  -- Draw our example image.
  love.graphics.draw(image)
  
  -- Print some hints.
  love.graphics.print("Try to resize window and see that string remains crispy!", 0, 0)
  love.graphics.print("Press F1, F2, F3 to change scale mode.", 0, 20)
  love.graphics.print("Try to touch rectangle with cursor.", 0, 40)
  
  -- Once we done with drawing, lets close canvas.
  love.graphics.setCanvas()
  
  -- Start scaling.
  rs.push()
    -- Scale our canvas.
    love.graphics.draw(game_canvas)
    -- Stop scaling.
  rs.pop()
  
  -- Save current font.
  local old_font = love.graphics.getFont()
  -- Get scaled font for rectangle.
  love.graphics.setFont(rectangle_button_font)
  
  -- If we inside rectangle, then paint string as green
  -- and red if outside.
  if rectangle_is_touching then
    love.graphics.setColor(0, 1, 0)
  else
    love.graphics.setColor(1, 0, 0)
  end
  
  -- Print "rectangle" string.
  love.graphics.print("Rectangle", rectangle_button_frame.x, rectangle_button_frame.y)
  
  -- Restore old font.
  love.graphics.setFont(old_font)
  
  -- Restore old color.
  love.graphics.setColor(1, 1, 1)
  
  -- Draw rectangle.
  love.graphics.rectangle("line", rectangle_button_frame.x, rectangle_button_frame.y, rectangle_button_frame.w, rectangle_button_frame.h)
end