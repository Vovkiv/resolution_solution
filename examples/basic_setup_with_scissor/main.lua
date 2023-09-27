local rs = require("resolution_solution")
rs.conf({
    game_width = 640,
    game_height = 480,
    scale_mode = 1
  })
love.graphics.setBackgroundColor(0.3, 0.5, 1)
rs.setMode(rs.game_width, rs.game_height, {resizable = true})

local image

love.load = function()
  image = love.graphics.newImage("image.png")
end

love.resize = function()
  rs.resize()
end

love.draw = function()
  rs.push()
    local old_x, old_y, old_w, old_h = love.graphics.getScissor()
    love.graphics.setScissor(rs.get_game_zone())
    love.graphics.draw(image)
    love.graphics.setScissor(old_x, old_y, old_w, old_h)
  rs.pop()
end