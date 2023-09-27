-- This is simplest example of how you can implement ui scaling which will always be "crispy".
-- Note, that this method would require more advanced math to implement all of this, especially for
-- something more easier them rectangles.
-- Since I suck at math, I can only show simple rectangle example.
-- Also, this example (because how it was implemented) mostly usable with
-- Aspect and Pixel-Perfect scaling modes, at least fonts.
local image
love.graphics.setDefaultFilter("nearest", "nearest")

local rs = require("resolution_solution")
rs.conf({
    game_width = 640,
    game_height = 480,
    scale_mode = 1
  })
love.graphics.setBackgroundColor(0.3, 0.5, 1)
rs.setMode(rs.game_width, rs.game_height, {resizable = true})

local rectangle_button_frame = {}
local rectangle_button_font
local rectangle_is_touching = false

local is_inside_game_zone = false

love.load = function()
  image = love.graphics.newImage("image.png")
end
local game_canvas = love.graphics.newCanvas(rs.get_game_size())

love.keypressed = function(key)
  if key == "f1" then
    rs.conf({scale_mode = 1})
  elseif key == "f2" then
    rs.conf({scale_mode = 2})
  elseif key == "f3" then
    rs.conf({scale_mode = 3})
  end
end

love.resize = function()
  rs.resize()
end

rs.resize_callback = function()
  rectangle_button_frame = {
    x = rs.game_zone.x + rs.game_zone.w / 2,
    y = rs.game_zone.y + rs.game_zone.h / 2,
    w = rs.game_zone.w * 0.25,
    h = rs.game_zone.h * 0.25,
  }
  -- Note: this scaling example not going to work with Stretch Scaling (2), so for that mode you need to come up with something better if you wish to support it.
  rectangle_button_font = love.graphics.newFont(
    math.max( -- If you pass font size less then 1, then love will raise error, so to prevent htis, we will limit it to 1.
      math.min(
        rs.game_zone.w * 0.04, rs.game_zone.h * 0.04
              ),
          1)
  )
end
rs.resize_callback()

love.update = function()
  local mx, my = love.mouse.getPosition()
  is_inside_game_zone = rs.is_it_inside(mx, my)
  
  -- Collision check for rectangle.
  if mx > rectangle_button_frame.x and
     my > rectangle_button_frame.y and
     mx < rectangle_button_frame.x + rectangle_button_frame.w and
     my < rectangle_button_frame.y + rectangle_button_frame.h then
     
    rectangle_is_touching = true
  else
    rectangle_is_touching = false
  end
end

love.draw = function()
  love.graphics.setCanvas(game_canvas)
  love.graphics.clear(0, 0, 0, 1)
  love.graphics.draw(image)
  love.graphics.setCanvas()
  
  rs.push()
    love.graphics.draw(game_canvas)
  rs.pop()
  
  local old_font = love.graphics.getFont()
  love.graphics.setFont(rectangle_button_font)
  
  if rectangle_is_touching then
    love.graphics.setColor(0, 1, 0)
  else
    love.graphics.setColor(1, 0, 0)
  end
  
  love.graphics.print("Rectangle", rectangle_button_frame.x, rectangle_button_frame.y)
  
  love.graphics.setFont(old_font)
  
  love.graphics.setColor(1, 1, 1)
  
  love.graphics.rectangle("line", rectangle_button_frame.x, rectangle_button_frame.y, rectangle_button_frame.w, rectangle_button_frame.h)
end