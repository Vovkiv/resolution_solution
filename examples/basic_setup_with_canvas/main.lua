local image

love.load = function()
  image = love.graphics.newImage("image.png")
end

local rs = require("resolution_solution")
rs.conf({
    game_width = 640,
    game_height = 480,
    scale_mode = 1
  })
love.graphics.setBackgroundColor(0.3, 0.5, 1)
rs.setMode(rs.game_width, rs.game_height, {resizable = true})

local game_canvas = love.graphics.newCanvas(rs.get_game_size())

love.resize = function()
  rs.resize()
end

love.draw = function()
  love.graphics.setCanvas(game_canvas)
  love.graphics.clear(0, 0, 0, 1)
  love.graphics.draw(image)
  love.graphics.setCanvas()
  
  rs.push()
    love.graphics.draw(game_canvas)
  rs.pop()
end