local rs = {
  _URL = "https://github.com/Vovkiv/resolution_solution",
  _DOCUMENTATION = "",
  _VERSION = 2002,
  _LOVE = 11.4, -- love2d version for which this library designed for.
  _DESCRIPTION = "Yet another scaling library.",
  _NAME = "Resolution Solution",
  _LICENSE = "The Unlicense",
  _LICENSE_TEXT = [[
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <https://unlicense.org>
]]
}

rs.setMode = function(width, height, flags)
  love.window.setMode(width, height, flags)
  rs.resize(love.graphics.getWidth(), love.graphics.getHeight())
end

rs.pixelPerfectOffsetsHack = true

rs.switchPixelHack = function()
  rs.pixelPerfectOffsetsHack = not rs.pixelPerfectOffsetsHack
  rs.resize(love.graphics.getWidth(), love.graphics.getHeight())
end

rs.init = function(options)
  if type(options) ~= "nil" and type(options) ~= "table" then
    error(".init: Expected table or nil argument. You passed: " .. type(options) .. ".")
  end

  options = options or {}

  -- Game width.
  if options.width then
      if type(options.width) ~= "number" then
        error(".init: table field \".width\" should be number. You passed: " .. type(options.width) .. ".")
      end

      rs.gameWidth  = options.width
  end

  -- Game height.
  if options.height then
      if type(options.height) ~= "number" then
        error(".init: table field \".height\" should be number. You passed: " .. type(options.height) .. ".")
      end

      rs.gameHeight  = options.height
  end

  -- Render bars?
  if options.bars ~= nil then
      if type(options.bars) ~= "boolean" then
        error(".init: table field \".bars\" should be boolean. You passed: " .. type(options.bars) .. ".")
      end

      rs.bars = options.bars
  end

  -- Show/hide debug info.
  if options.debug ~= nil then
      if type(options.debug) ~= "boolean" then
        error(".init: table field \".debug\" should be boolean. You passed: " .. type(options.debug) .. ".")
      end

      rs.debug = options.debug
  end

  -- Scale mode.
  if options.mode then
      if type(options.mode) ~= "number" then
        error(".init: table field \".mode\" should be number. You passed: " .. type(options.mode) .. ".")
      end
      
      -- Check for out of bounds.
      if options.mode > 3 or options.mode < 1 then
        error(".init: table field \".mode\" should be 1, 2 or 3. You passed: " .. tostring(options.mode) .. ".")
      end

      rs.scaleMode  = options.mode
  end

  -- Red from RGBA for bars.
  -- If user passed .r parameter, check it for being number.
  if options.r then
      if type(options.r) ~= "number" then
        error(".init: table field \".r\" should be number. You passed: " .. type(options.r) .. ".")
      end
      
      -- Check for out-of-bounds. Starting from love 11, colors become 0 - 1 in float. Before it was 0 - 255.
      if options.r > 1 or options.r < 0 then
         error(".init: table field \".r\" should be in-between 0 to 1. You passed: " .. tostring(options.r) .. ".")
      end
      
      rs.r  = options.r
  end

  -- Green from RGBA for bars.
  if options.g then
      if type(options.g) ~= "number" then
        error(".init: table field \".g\" should be number. You passed: " .. type(options.g) .. ".")
      end
      
      -- Check for out-of-bounds. Starting from love 11, colors become 0 - 1 in float. Before it was 0 - 255.
      if options.g > 1 or options.g < 0 then
         error(".init: table field \".g\" should be in-between 0 to 1. You passed: " .. tostring(options.g) .. ".")
      end

      rs.g  = options.g
  end

  -- Blue from RGBA for bars.
  if options.b then
      if type(options.b) ~= "number" then
        error(".init: table field \".b\" should be number. You passed: " .. type(options.b) .. ".")
      end

      -- Check for out-of-bounds. Starting from love 11, colors become 0 - 1 in float. Before it was 0 - 255.
      if options.b > 1 or options.b < 0 then
         error(".init: table field \".b\" should be in-between 0 to 1. You passed: " .. tostring(options.b) .. ".")
      end

      rs.b  = options.b
  end

  -- Alpha from RGBA for bars.
  if options.a then
      if type(options.a) ~= "number" then
        error(".init: table field \".a\" should be number. You passed: " .. type(options.a) .. ".")
      end

      -- Check for out-of-bounds. Starting from love 11, colors become 0 - 1 in float. Before it was 0 - 255.
      if options.a > 1 or options.a < 0 then
         error(".init: table field \".a\" should be in-between 0 to 1. You passed: " .. tostring(options.a) .. ".")
      end

      rs.a  = options.a
  end

  -- Activate hack for pixel perfect scaling.
  if options.hack ~= nil then
      if type(options.hack) ~= "boolean" then
        error(".init: table field \".hack\" should be boolean. You passed: " .. type(options.hack) .. ".")
      end

      rs.pixelPerfectOffsetsHack  = options.hack
  end

  -- Update library with new parameters
  rs.resize(love.graphics.getWidth(), love.graphics.getHeight())
end

-- 1 aspect scaling (Scale game with bars on top-bottom or left-right. Scale by width and height will be same, but not ideal for pixel graphics.)
-- 2 stretched scaling mode (Scale game to fill entire window. So no bars.)
-- 3 pixel perfect (Scale with integer scaling numbers. It will lead to bars on top and bottom and left and right at same time. Ideal for pixel graphics.)
rs.scaleMode    = 1

rs.setScaleMode = function(mode)
  -- 1 aspect scaling.
  -- 2 stretch.
  -- 3 pixel perfect.

    if type(mode) ~= "number" then
      error(".setScaleMode: Expected number or nil argument. You passed: " .. type(mode) .. ".")
    else
        if mode > 3 or mode < 1 then
          error(".setScaleMode: Expected argument to be 1, 2 or 3. You passed: " .. tostring(mode).. ".")
        end
    end

    rs.scaleMode = mode
    rs.resize(love.graphics.getWidth(), love.graphics.getHeight())
end
rs.switchScaleMode = function(side)
  -- Function to switch in-between scale modes.
  -- Pass 1 or nil to change mode by +1 (so, if current mode 2, stretching, it become 3, pixel perfect)
  -- and pass -1 to change backwards.
  -- You can ise it like this:
  --[[
  love.keypressed = function(key)
    if key == "f3" then
      rs.switchScaleMode()
    end
  end
  --]]

  -- Default order is +1.
  side = side or 1

  if type(side) ~= "number" then
    error(".switchScaleMode: Expected number or nil argument. You passed: " .. type(side) .. ".")
  else
    -- You can't pass only 1 and +1 number.
    if side ~= 1 and side ~= -1 then
      error(".switchScaleMode: Expected argument should be 1, -1 or nil. You passed: " .. tostring(side))
    end
  end

  rs.scaleMode = rs.scaleMode + side

  -- Check for limits. It will loop from 1 to 3 and vice-versa.
  if rs.scaleMode > 3 then rs.scaleMode = 1 end
  if rs.scaleMode < 1 then rs.scaleMode = 3 end

  -- Since we changed scale mode, we need to re-calculate library data.
  rs.resize(love.graphics.getWidth(), love.graphics.getHeight())
end

-- Used to turn on/off rendering of bars when rs.drawBars() called.
-- If false, rs.drawBars() will NOT draw bars.
rs.bars  = true

-- Turn on/off bars rendering.
-- Use it like this:
--[[
love.keypressed = function(key)
    if key == "f2" then
      rs.switchBars()
    end
end
--]]
rs.switchBars = function()
  rs.bars = not rs.bars
end

-- Determine if rs.debugFunc() will show some debug info.
-- If true, then this function will draw debug.
rs.debug = true

-- Place it somewhere in love.draw() and set rs.debug to true, then this function will draw some useful information about library.
-- You can overide this function, but in most cases there no need to.
rs.debugFunc = function(debugX, debugY)
  
  -- If debug disabled, there no point in wasting time on rendering debug info.
  if not rs.debug then return end
  
  -- Offset for left side.
  local debugLeftOffset = 5
  local debugTopOffset = 5
  
  -- Set width and height for debug "window".
  local debugWidth = 200 + debugLeftOffset
  local debugHeight = 240 + debugTopOffset

  
  debugX = debugX or "left"
  debugY = debugY or "top"
  
  -- Do sanity check for input arguments.
  if (type(debugX) ~= "string" and type(debugX) ~= "number") then
    error(".debugFunc: 1st argument should be string or number or nil. You passed: " .. type(debugX) .. ".")
  end
  
  if (type(debugY) ~= "string" and type(debugY) ~= "number") then
    error(".debugFunc: 2nd argument should be string or number or nil. You passed: " .. type(debugY) .. ".")
  end
  
  -- Do sanity check if input is string.
  if type(debugX) == "string" then
    
    if debugX == "left" then
      debugX = 0
    elseif debugX == "right" then
      debugX = love.graphics.getWidth() - debugWidth
    end
  -- If number.
  elseif type(debugX) == "number" then
    
    if debugX < 0 then
      debugX = 0
    end
    
    if debugX > love.graphics.getWidth() - debugWidth then
      debugX = love.graphics.getWidth() - debugWidth
    end
  end
  
  -- Do sanity check if input is string.
  if type(debugY) == "string" then
    
    if debugY == "top" then
      debugY = 0
    elseif debugY == "bottom" then
      debugY = love.graphics.getHeight() - debugHeight
    end
    -- If number.
  elseif type(debugY) == "number" then
    
    if debugY < 0 then
      debugY = 0
    end
    
    if debugY > love.graphics.getHeight() - debugWidth then
      debugY = love.graphics.getHeight() - debugWidth
    end
  end
  
  -- Return this colors later.
  local r, g, b, a = love.graphics.getColor()
  
  -- Return this font later.
  local oldFont = love.graphics.getFont()

  -- Draw background rectangle for text.
  love.graphics.setColor(0, 0, 0, 0.5)
  
  -- Place debug info on screen according to user input.
  love.graphics.rectangle("fill", debugX, debugY, debugWidth, debugHeight)

  -- Set fonts.
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setFont(love.graphics.newFont(12))

  -- Print data.
  love.graphics.printf(
    rs._NAME .. " v." .. tostring(rs._VERSION) .. "\n" ..
    "gameWidth: " .. tostring(rs.gameWidth) .. "\n" ..
    "gameHeight: " .. tostring(rs.gameHeight) .. "\n" ..
    "scaleWidth: " .. tostring(rs.scaleWidth) .. "\n" ..
    "scaleHeight: " .. tostring(rs.scaleHeight) .. "\n" ..
    "windowWidth: " .. tostring(rs.windowWidth) .. "\n" ..
    "windowHeight: " .. tostring(rs.windowHeight) .. "\n" ..
    "scaleMode: " .. tostring(rs.scaleMode) .. "\n" ..
    "bars: " .. tostring(rs.bars) .. "\n" ..
    "debug: " .. tostring(rs.debug) .. "\n" ..
    "xOff: " .. tostring(rs.xOff) .. "\n" ..
    "yOff: " .. tostring(rs.yOff) .. "\n" ..
    "pixelPerfectOffsetsHack: " .. tostring(rs.pixelPerfectOffsetsHack) .. "\n" ..
    "filter: " .. tostring(select(1, love.graphics.getDefaultFilter())) .. "\n" ..
    "anisotropy: " .. tostring(select(3, love.graphics.getDefaultFilter())) .. "\n",
    debugX + debugLeftOffset, debugY + debugTopOffset, debugWidth)

  -- Return colors.
  love.graphics.setColor(r, g, b, a)
  
  -- Retun original font
  love.graphics.setFont(oldFont)
end

-- Turn on/off debug function.
-- Use it like this:
--[[
love.keypressed = function(key)
    if key == "f1" then
      rs.switchDebug()
    end
end
--]]
rs.switchDebug = function()
  rs.debug = not rs.debug
end

-- Scale width and height value, that library will produce, based on scale mode and ratio between game size and window size.
-- Use this values for scaling related math, such as glue this library with camera libraries, UI library, etc.
rs.scaleWidth, rs.scaleHeight = 0, 0

-- Virtual width and height for game, that library will scale to.
rs.gameWidth, rs.gameHeight    = 800, 600

-- Window size. Can be used instead of love.graphics.getWidth/getHeight functions.
rs.windowWidth, rs.windowHeight  = 0, 0

-- Width and height offsets, caused by scaling. In scale mode 2, will always be 0, 0.
rs.xOff, rs.yOff = 0, 0

-- X, Y, Width, Height for every ractangle-bar, that used to hide something behind offseted areas.
-- It also should be possible, to disable bar rendering via rs.bars = false and using love.graphics.setScissor() with combining
-- rs.getGameZone(), so it will act like PUSH scaling library, where it just draw scaled area to canvas and scale it.
rs.x1, rs.y1, rs.w1, rs.h1 = 0, 0, 0, 0 -- top (1)
rs.x2, rs.y2, rs.w2, rs.h2 = 0, 0, 0, 0 -- left (2)
rs.x3, rs.y3, rs.w3, rs.h3 = 0, 0, 0, 0 -- right (3)
rs.x4, rs.y4, rs.w4, rs.h4 = 0, 0, 0, 0 -- bottom (4)

-- Colors of bars: red, green, blue, alpha.
-- Black by default.
rs.r, rs.g, rs.b, rs.a = 0, 0, 0, 1

-- Coordinates for scaled area, that visible in window. So, if, for example, game width and height is 800x600 and current offsets is x = 10, y = 15
-- then this table will have:
-- x = 10
-- y = 15
-- w = 790
-- h = 585
-- Might be useful for integrating this library with camera libraries, UI libraries, etc.
rs.gameZone = {
  x = 0,
  y = 0,
  w = 0,
  h = 0
  }

rs.nearestFilter = function(filter, anisotropy)
-- Used to set neareast or linear filter. Refer to https://love2d.org/wiki/love.graphics.setDefaultFilter for more info.
-- 
-- If first argument is nil, it become true (so, nearest)
-- If 2nd argument is nil, then function will get anisotropy value from love.graphics.getDefaultFilter (so if you changed anisotropy value somewhere before, it will simply use it instead. Current version of love use 1 as default.)
--
-- Note: this function will set min and mag arguments to same value.

  -- Check anisotropy
  if type(filter) ~= "nil" and type(filter) ~= "boolean" then
    error(".nearestFilter: Expected that 1 argument should be nil or boolean. You passed: " .. type(filter) .. ".")
  end

  -- Check anisotropy argument
  if type(anisotropy) ~= "nil" and type(anisotropy) ~= "number" then
    error(".nearestFilter: Expected that 2 argument should be nil or number. You passed: " .. type(anisotropy) .. ".")
  end

  if anisotropy == nil then
    anisotropy = select(3, love.graphics.getDefaultFilter())
  end

  -- If no argument or true then nearest
  if filter == true or filter == nil then -- neareset
    filter = "nearest"
  else
    filter = "linear"
  end


  love.graphics.setDefaultFilter(filter, filter, anisotropy)
end

rs.resizeCallback = function()
  
end

rs.resize = function(windowWidth, windowHeight)
-- Everything updates here.
-- Call this function at love.resize and pass arguments to library. Like this:
--[[
love.resize = function(w, h)
  rs.resize(w, h)
end
--]]

  -- Check if user passed arguments and they are numbers.
  if type(windowHeight) ~= "number" or type(windowHeight) ~= "number" then
    error(".resize: Expected 2 arguments, that should be numbers. You passed: " .. type(windowWidth) .. " and " .. type(windowHeight) .. ". Make sure that you pass arguments from love.resize(w, h) to this function.")
  end

  -- Scale for game virtual size.
  local scaleWidth, scaleHeight = 0, 0
  
  -- Offsets.
  local xOff, yOff = 0, 0

  -- Virtual game size.
  local gameWidth, gameHeight = rs.gameWidth, rs.gameHeight
  
  -- Scale mode.
  local scaleMode = rs.scaleMode
  
  -- If we in stretch scaling mode.
  if scaleMode == 2 then
    -- We only need to update width and height scale.
    scaleWidth = windowWidth / gameWidth
    scaleHeight = windowHeight / gameHeight

  else
    
    -- In short, when you in pixel perect scale mode, if window size is non even, it will result in
    -- non integer offset values for x and y, which result in pixels bleedingm which is acceptable in
    -- non pixel pefrect modes, but not here.
    if rs.pixelPerfectOffsetsHack and rs.scaleMode == 3 then
      if (windowWidth % 2 ~= 0) then
        windowWidth = windowWidth + 1
      end
        
      if (windowHeight % 2 ~= 0) then
        windowHeight = windowHeight + 1
      end
    end

  -- Other scaling methods need to determine scale, based on window and game aspect.
    local scale = math.min(windowWidth / gameWidth,  windowHeight / gameHeight)

    -- Pixel perfect scaling.
    if scaleMode == 3 then
      -- We will floor to nearest int number.
      -- And we fallback to scale 1, if game size is less then window, so user can see at least something.
      scale = math.max(math.floor(scale), 1)
    end

    -- Update offsets.
    xOff, yOff = (windowWidth - (scale * gameWidth)) / 2, (windowHeight - (scale * gameHeight)) / 2
    -- Update scale
    scaleWidth, scaleHeight = scale, scale
  end
  
  -- Save values to library.
  -- Black bars.
  rs.x1, rs.y1, rs.w1, rs.h1 = 0, 0, windowWidth, yOff                                   --top
  rs.x2, rs.y2, rs.w2, rs.h2 = 0, yOff, xOff, windowHeight - (yOff * 2)                  -- left
  rs.x3, rs.y3, rs.w3, rs.h3 = windowWidth - xOff, yOff, xOff, windowHeight - (yOff * 2) -- right
  rs.x4, rs.y4, rs.w4, rs.h4 = 0, windowHeight - yOff, windowWidth, yOff                 -- bottom
  
  -- Offset generated by bars.
  rs.xOff, rs.yOff = xOff, yOff
  
  -- Scale.
  rs.scaleWidth, rs.scaleHeight = scaleWidth, scaleHeight
  
  -- Window size.
  rs.windowWidth, rs.windowHeight = windowWidth, windowHeight
  
  -- Game zone.
  rs.gameZone.x = xOff
  rs.gameZone.y = yOff
  rs.gameZone.w = windowWidth - (xOff * 2)
  rs.gameZone.h = windowHeight - (yOff * 2)

  -- Window size.
  rs.windowWidth, rs.windowHeight = windowWidth, windowHeight
  
  -- Callback.
  rs.resizeCallback()
end

rs.start = function()
  -- Start scaling graphics until rs.stop().
  -- Everything inside this function will be scaled to fit virtual game size.
  -- Place it in love.draw() like this:
  --[[
  love.draw = function()
    rs.start()
  
    rs.stop()
  end
  --]]

  -- Prepare to scale.
  love.graphics.push()
  
  -- Reset transformation.
  love.graphics.origin()

  -- Set offset, based on size of bars.
  love.graphics.translate(rs.xOff, rs.yOff)
  
  -- Scale.
  love.graphics.scale(rs.scaleWidth, rs.scaleHeight)
end

rs.stop = function()
  -- Stop scaling caused by rs.start().
  -- Place it in love.draw() like this:
  --[[
  love.draw = function()
    rs.start()
  
    rs.stop()
  end
  --]]

  -- Stop scaling.
  love.graphics.pop()

  -- Draw bars.
  rs.drawBars()
end

rs.unscaleStart = function()
  -- Reset scaling with love.origin() until rs.unscaleStop().
  -- With that you can, for example, draw UI with custom scaling, fonts, etc.
  -- Place it in-between rs.start() and rs.stop() like this:
  --[[
  love.draw = function()
    rs.start()
      rs.unscaleStart()

      rs.unscaleStop()
    rs.stop()
  end
  --]]
  
  -- Start unscaling.
  love.graphics.push()
  
  -- Reset transformation and scaling.
  love.graphics.origin()
end

rs.unscaleStop = function()
  -- Stop scaling caused by rs.unscaleStart().
  -- With that you can, for example, draw UI with custom scaling, fonts, etc.
  -- Place it in-between rs.start() and rs.stop() like this:
  --[[
  love.draw = function()
    rs.start()
      rs.unscaleStart()

      rs.unscaleStop()
    rs.stop()
  end
  --]]

  -- Stop unscaling.
  love.graphics.pop()
end

rs.setColor = function(r, g, b, a)
  -- Set color of bars.

  if type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number" or type(a) ~= "number" then
      error(".setColor: Expected 4 arguments, that should be numbers. You passed: " .. type(r) .. ", " .. type(g) .. ", " .. type(b) .. ", " .. type(a) .. ".")
  end
  
    -- Check for out-of-bounds. Starting from love 11, colors become 0 - 1 in float. Before it was 0 - 255.
    if r > 1 or r < 0 then
        error(".setColor: Argument \"r\" should be number in-between 0 - 1. You passed: " .. tostring(r) .. ".")
    end
    
    -- Check for out-of-bounds. Starting from love 11, colors become 0 - 1 in float. Before it was 0 - 255.
    if g > 1 or g < 0 then
        error(".setColor: Argument \"g\" should be number in-between 0 - 1. You passed: " .. tostring(g) .. ".")
    end
    
    -- Check for out-of-bounds. Starting from love 11, colors become 0 - 1 in float. Before it was 0 - 255.
    if b > 1 or b < 0 then
        error(".setColor: Argument \"b\" should be number in-between 0 - 1. You passed: " .. tostring(b) .. ".")
    
    end    -- Check for out-of-bounds. Starting from love 11, colors become 0 - 1 in float. Before it was 0 - 255.
    if a > 1 or a < 0 then
        error(".setColor: Argument \"a\" should be number in-between 0 - 1. You passed: " .. tostring(a) .. ".")
    end

  rs.r = r -- red
  rs.g = g -- green
  rs.b = b -- blue
  rs.a = a -- alpha
end

rs.getColor = function()
  -- Get red, green, blue and alpha colors of bars.

  return rs.r, -- red
         rs.g, -- green
         rs.b, -- blue
         rs.a  -- alpha
end

rs.getGameZone = function()
  -- Scaled zone with real screen coordinates.
  -- Will return 4 values:
  -- x, y, w, h
  -- Useful to determine scale zone, to build UI.

  local gameZone = rs.gameZone
  return gameZone.x, gameZone.y, gameZone.w, gameZone.h
end

rs.defaultColor = function()
  -- Reset colors for bars to default black color.

  rs.r = 0 -- red
  rs.g = 0 -- green
  rs.b = 0 -- blue
  rs.a = 1 -- alpha
end


rs.drawBars = function()
  -- Function that will draw bars.
  -- Can be called manually, if you don't use rs.start() and rs.stop() and scale everything manually somewhere else.
  
  -- Scale mode 2 is stretch, so no need waste time on bars rendering at all.
  if rs.scaleMode == 2 then
    return
  end

  -- Can we can draw bars?
  if not rs.bars then
      return
  end

  
  -- Get colors, that was before rs.stop() function.
  local r, g, b, a = love.graphics.getColor()
  
  -- Prepare to draw bars.
  love.graphics.push()
  
  -- Reset transformation.
  love.graphics.origin()

  -- Set color for bars.
  love.graphics.setColor(rs.r, rs.g, rs.b, rs.a)

  -- Draw bars.
  love.graphics.rectangle("fill", rs.x1, rs.y1, rs.w1, rs.h1) -- top
  love.graphics.rectangle("fill", rs.x2, rs.y2, rs.w2, rs.h2) -- left
  love.graphics.rectangle("fill", rs.x3, rs.y3, rs.w3, rs.h3) -- right
  love.graphics.rectangle("fill", rs.x4, rs.y4, rs.w4, rs.h4) -- bottom
  
  -- Return original colors that was before rs.stop()
  love.graphics.setColor(r, g, b, a)
  
  -- End bars rendering.
  love.graphics.pop()
end

rs.getScale = function()
  -- Get width and height scale.

  return rs.scaleWidth, rs.scaleHeight
end

rs.setGame = function(width, height)
  -- Set virtual size which game should be scaled to.

  if type(width) ~= "number" or type(height) ~= "number"  then
      error(".setGame: Expected 2 arguments, that should be numbers. You passed: " .. type(width) .. ", " .. type(height) .. ".")
  end

  rs.gameWidth = width
  rs.gameHeight = height
  rs.resize(love.graphics.getWidth(), love.graphics.getHeight())
end

rs.getGame = function()
  -- Return game virtual width and height.

  return rs.gameWidth, rs.gameHeight
end

rs.getWindow = function()
  -- Get window width and height.

  return rs.windowWidth, rs.windowHeight
end

rs.isMouseInside = function()
  -- Determine if cursor inside scaled area and don't touch bars.
  -- Use it when you need detect if cursor touch in-game objects, without false detection on bars zone.
  --Use it like this:
  --[[
      love.mousepressed = function(x, y, button, istouch, presses)
        if rs.isMouseInside and button == 1 then
          print("Hello, World!")
        end 
      end
  --]]

  -- If we in stretch mode (1), then there is no bars, so no reasons to waste time on checks,
  -- since there is no bars. 
  if rs.scaleMode == 2 then
    return true
  end
  
  -- Get mouse coordinates.
  local mouseX, mouseY = love.mouse.getPosition()
  
  -- Get offset.
  local xOff, yOff     = rs.xOff, rs.yOff
  
  -- Get window size.
  local windowWidth    = rs.windowWidth
  local windowHeight   = rs.windowHeight

  -- Check if cursor inside game zone.
  if mouseX    >= xOff                 and -- left
     mouseY    >= yOff                 and -- top
     mouseX    <= windowWidth  - xOff  and -- right
     mouseY    <= windowHeight - yOff then -- bottom
     return true
  end

  -- Cursor on bars.
  return false
end

rs.toGame = function(x, y)
  -- Translate coordinates from non-scaled values to scaled;
  -- e.g translate real mouse coordinates into scaled so you can check
  -- for example, area to check collisions with object and cursor.
  -- Use it like this:
  --[[
love.mousepressed = function(x, y, button, istouch, presses)
  if RS.isMouseInside() and button == 1 then
      local mx, my = RS.toGame(love.mouse.getPosition())
      if mx    >= 100                   and -- left
         my    >= 100                   and -- top
         mx    <= 100         +    100  and -- right
         my    <= 100         +    100  then -- bottom
        print("You clicked in rectangle of: 100, 100, 100, 100!")
      end

    end 
  end
  --]]

  if type(x) ~= "number" or type(y) ~= "number" then
    error(".toGame: Expected 2 arguments, that should be numbers. You passed: " .. type(x) .. ", " .. type(y) .. ".")
  end

  return (x - rs.xOff) / rs.scaleWidth, (y - rs.yOff) / rs.scaleHeight
end

rs.toGameX = function(x)
  -- Translate x coordinate from non-scaled to scaled
  -- e.g translate real mouse coordinates into scaled so you can check
  -- for example, area to check collisions with object and cursor.

  if type(x) ~= "number" then
    error(".toGameX: Expected argument, that should be number. You passed: " .. type(x) .. ".")
  end

  return (x - rs.xOff) / rs.scaleWidth
end

rs.toGameY = function(y) 
  -- Translate y coordinate from non-scaled to scaled
  -- e.g translate real mouse coordinates into scaled so you can check
  -- for example, area to check collisions with object and cursor;

  if type(y) ~= "number" then
    error(".toGameY: Expected argument, that should be number. You passed: " .. type(y) .. ".")
  end

  return (y - rs.yOff) / rs.scaleHeight
end

rs.toScreen = function(x, y)
  -- Thanslate coordinates from scaled to non scaled.
  -- e.g translate x and y of object inside scaled area
  -- to, for example, set cursor position to that object
  -- Use it like this:
  --[[
  ingameObject = {x = 200, y = 200}
  love.draw = function()
    rs.start()
    love.graphics.rectangle("fill", ingameObject.x, ingameObject.y, 100, 100)
    if RS.toGameX(love.mouse.getX()) > ingameObject.x then
        love.mouse.setPosition(RS.toScreenX(ingameObject.x), love.mouse.getY())
    end
    rs.stop()
  end
  --]]
  
  if type(x) ~= "number" or type(y) ~= "number" then
    error(".toScreen: Expected 2 arguments, that should be numbers. You passed: " .. type(x) .. ", " .. type(y) .. ".")
  end

  return (x * rs.scaleWidth) + rs.xOff, (y * rs.scaleHeight) + rs.yOff
end

rs.toScreenX = function(x)
  -- Thanslate x coordinate from scaled to non scaled.
  -- e.g translate x of object inside scaled area
  -- to, for example, set cursor position to that object
  
  if type(x) ~= "number" then
    error(".toScreenX: Expected argument, that should be number. You passed: " .. type(x) .. ".")
  end

  return (x * rs.scaleWidth) + rs.xOff
end

rs.toScreenY = function(y)
  -- Thanslate y coordinate from scaled to non scaled.
  -- e.g translate y of object inside scaled area
  -- to, for example, set cursor position to that object
  
  if type(y) ~= "number" then
    error(".toScreenY: Expected argument, that should be number. You passed: " .. type(y) .. ".")
  end
  
  return (y * rs.scaleHeight) + rs.yOff
end

return rs