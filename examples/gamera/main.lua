-- Gamera.lua - https://github.com/kikito/gamera, MIT License.

-- Setup resolution solution.
local rs = require("resolution_solution")
rs.conf({game_width = 640, game_height = 480, scale_mode = 1})
rs.setMode(rs.game_width, rs.game_height, {resizable = true})
