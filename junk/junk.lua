scaling.resolutions = require("resolutions")

return {
  --[[
    list of common and uncommon resolutions.
    may be used to add ingame option, where you can choose
    what resolution you may want to use.
    Or that may be used as little cheat sheet.
  --]]

  _16x9 = {
    common = {
      {1024, 576},
      {1024, 600},
      {1152, 648},
      {1280, 720},   -- 720p, HD
      {1360, 768},
      {1366, 768},   -- WXGA
      {1600, 900},   -- HD+
      {1920, 1080},  -- 1080p, FHD
      {2560, 1440},  -- 1440p, QHD
      {3200, 1800},  -- QHD+
      {3840, 2160},  -- 4K, UHD
      {5120, 2880},  -- 5K, UHD+
      {7680, 4320},  -- 8K, UHD
      {15360, 8640}, -- 16K, UHD
    }, -- end common 16x9
    uncommon = {
      {128, 72},
      {266, 144},
      {384, 216},
      {512, 288},
      {640, 360},
      {768, 432},
      {720, 480},
      {896, 504},
      {960, 540},
      {1408, 792},
      {1536, 864},
      {1664, 936},
      {1792, 1008},
    } -- end uncommon 16x9
  }, -- end 16x9
  _16x10 = {
    common = {
      {640, 400},
      {960, 600},
      {1280, 800}, -- WXGA
      {1440, 900}, -- WXGA+
      {1680, 1050}, -- WSXGA+
      {1920, 1200}, -- WUXGA
      {2560, 1600}, -- WQXGA
      {3840, 2400}, -- WQUXGA
    }, -- end common 16x10
    uncommon = {
      -- later.
    } -- end uncommon 16x10
  }, -- end 16x10
  _4x3  = {
    common = {
      {640, 480},
      {800, 600},
      {960, 720},
      {1024, 768},
      {1280, 960},
      {1400, 1050},
      {1440, 1080},
      {1600, 1200},
      {1856, 1392},
      {1920, 1440},
      {2048, 1536},
    }, -- end common
    uncommon = {
      {160, 120},
      {256, 192},
      {320, 240},
      {384, 288},
      {400, 300},
      {512, 384},
      {832, 624},
      {1152, 864},
      {1400, 1050},
      {1792, 1344},
      {1856, 1392},
      {2304, 1728},
      {2560, 1920},
      {2800, 2100},
      {3200, 2400},
      {4096, 3072},
      {2704, 2028},
      {2720, 2040},
      {2732, 2048},
      {4000, 3000},
      {6400, 4800},
    } -- end uncommon 4x3
  } -- end 4x3
} -- end list of resolutions

scaling.drawDebug = function() -- unfinished
  --[[ 
    primitive draw debug info function.
  --]]
  
  -- if scaling.debug is false, then don't do anything
  if not scaling.debug then
    return
  end
  
  local r, g, b, a = love.graphics.getColor() -- return colors back after that function
  

-- local message = scaling._NAME .. ": v." .. scaling._VERSION .. "\n" ..
--                  "scaleMode: " .. scaling.scaleMode .. "\n" .. ""
  local message = string.format([[%s v.%s
    scalingMode: %s]],
    scaling._NAME, scaling._VERSION,
    scaling.scaleMode)
  
  local xOffset, yOffset = scaling.debugXOffset, scaling.debugYOffset
  local x, y = scaling.debugX, scaling.debugY
  local debugR, debugG, debugB, debugA = scaling.debugBackR, scaling.debugBackG, scaling.debugBackB, scaling.debugBackA
  
  local backWidth, backHeight
  local font = love.graphics.newFont()
  
  love.graphics.push()
  love.graphics.setFont(font)
  backWidth = font:getWidth(message)
  -- get width of string.
  -- to prevent need to manually add \n at end of every line
  -- i simply do +1 for count of \n
  backHeight = font:getHeight() * (select(2, message:gsub("\n", "")) + 1)
  love.graphics.setColor(debugR, debugG, debugB, debugA)
  -- offset used to create outline, mainly for fancynes.
  love.graphics.rectangle("fill", x - xOffset, y - yOffset, backWidth + (xOffset * 2), backHeight + (yOffset * 2))
  -- white color
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print(message, x, y)
  
  love.graphics.setColor(r, g, b, a)
  love.graphics.pop()
end

-- Debug options and functions.
-- If you don't need it, then simply ignore that section
scaling.debug = true -- if true, scaling.drawDebug will work.

scaling.debugX = 10 -- x and y where place debug "window"
scaling.debugY = 10

scaling.drawBackground = true -- draw background for text debug

scaling.debugBackR = 0 -- background Red color from RGB
scaling.debugBackG = 0 -- green
scaling.debugBackB = 0 -- blue
scaling.debugBackA = 0.5 -- alpha

scaling.debugXOffset = 5 -- offset for background
scaling.debugYOffset = 5

scaling.getAllData = function()
  --[[
    get all library data at 1 function.
    (excluding debugger data).
    maybe can be used to add custom debug or something.
  --]]
  
  return {scaleMode = scaling.scaleMode, }
end

scaling.switchDebug = function()
  scaling.debug = not scaling.debug
end