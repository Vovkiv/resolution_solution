-- Example how to implement cursor that won't go outside of game zone.
local image
local cursor_image
local cursor_x, cursor_y = 0, 0

love.load = function()
  image = love.graphics.newImage("image.png")
  cursor_image = love.graphics.newImage("cursor.png")
end

local rs = require("resolution_solution")
rs.conf({
    game_width = 640,
    game_height = 480,
    scale_mode = 3
  })
love.graphics.setBackgroundColor(0.3, 0.5, 1)
rs.setMode(rs.game_width, rs.game_height, {resizable = true})

local game_canvas = love.graphics.newCanvas(rs.get_game_size())

love.resize = function()
  rs.resize()
end

love.update = function()
  cursor_x, cursor_y = love.mouse.getPosition()
  if cursor_x < rs.game_zone.x then
    cursor_x = rs.game_zone.x
  end
  
  if cursor_x > rs.game_zone.x + rs.game_zone.w then
    cursor_x = rs.game_zone.x + rs.game_zone.w
  end
  
  if cursor_y < rs.game_zone.y then
    cursor_y = rs.game_zone.y
  end
  
  if cursor_y > rs.game_zone.y + rs.game_zone.h then
    cursor_y = rs.game_zone.y + rs.game_zone.h
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
  
  love.graphics.draw(cursor_image, cursor_x, cursor_y)
end