-- Example how to implement cursor that won't go outside of game zone.
local image
local is_inside = false

love.load = function()
  image = love.graphics.newImage("image.png")
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
  is_inside = rs.is_it_inside(love.mouse.getPosition())
end

love.draw = function()
  love.graphics.setCanvas(game_canvas)
  love.graphics.clear(0, 0, 0, 1)
  
  love.graphics.draw(image)
  
  if is_inside then
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print("Cursor inside game zone!", rs.game_width / 2, rs.game_height / 2)
  else
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.print("Cursor outside of game zone!", rs.game_width / 2, rs.game_height / 2)
  end
  
  
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setCanvas()
  
  rs.push()
    love.graphics.draw(game_canvas)
  rs.pop()
end