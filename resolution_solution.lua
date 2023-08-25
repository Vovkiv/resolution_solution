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

----------------------------------------------------------------------
--                        Library variables                         --
----------------------------------------------------------------------

-- 1 Aspect Ascaling
-- 2 Stretched Scaling
-- 3 Pixel Perfect scaling
rs.scaleMode = 1

rs.scaleWidth, rs.scaleHeight = 0, 0

rs.gameWidth, rs.gameHeight    = 800, 600

rs.windowWidth, rs.windowHeight  = 0, 0

rs.xOff, rs.yOff = 0, 0

-- Black bars.
rs.x1, rs.y1, rs.w1, rs.h1 = 0, 0, 0, 0 -- top (1)
rs.x2, rs.y2, rs.w2, rs.h2 = 0, 0, 0, 0 -- left (2)
rs.x3, rs.y3, rs.w3, rs.h3 = 0, 0, 0, 0 -- right (3)
rs.x4, rs.y4, rs.w4, rs.h4 = 0, 0, 0, 0 -- bottom (4)

-- Color for bars.
rs.r, rs.g, rs.b, rs.a = 0, 0, 0, 1

-- Render black bars?
rs.bars  = true

rs.gameZone = {
  x = 0,
  y = 0,
  w = 0,
  h = 0
}

-- Render debug window when rs.debugFunc() called?
rs.debug = true

rs.pixelPerfectOffsetsHack = true

----------------------------------------------------------------------
--                        Library functions                         --
----------------------------------------------------------------------

rs.init = function(options)
  if type(options) ~= "nil" and type(options) ~= "table" then
    error(".init: Expected table or nil argument. You passed: " .. type(options) .. ".", 2)
  end

  options = options or {}

  -- Game width.
  if options.width then
      if type(options.width) ~= "number" then
        error(".init: table field \".width\" should be number. You passed: " .. type(options.width) .. ".", 2)
      end

      rs.gameWidth  = options.width
  end

  -- Game height.
  if options.height then
      if type(options.height) ~= "number" then
        error(".init: table field \".height\" should be number. You passed: " .. type(options.height) .. ".", 2)
      end

      rs.gameHeight  = options.height
  end

  -- Render bars?
  if options.bars ~= nil then
      if type(options.bars) ~= "boolean" then
        error(".init: table field \".bars\" should be boolean. You passed: " .. type(options.bars) .. ".", 2)
      end

      rs.bars = options.bars
  end

  -- Show/hide debug info.
  if options.debug ~= nil then
      if type(options.debug) ~= "boolean" then
        error(".init: table field \".debug\" should be boolean. You passed: " .. type(options.debug) .. ".", 2)
      end

      rs.debug = options.debug
  end

  -- Scale mode.
  if options.mode then
      if type(options.mode) ~= "number" then
        error(".init: table field \".mode\" should be number. You passed: " .. type(options.mode) .. ".", 2)
      end

      -- Check for out of bounds.
      if options.mode > 3 or options.mode < 1 then
        error(".init: table field \".mode\" should be 1, 2 or 3. You passed: " .. tostring(options.mode) .. ".", 2)
      end

      rs.scaleMode  = options.mode
  end

  -- Red from RGBA for bars.
  -- If user passed .r parameter, check it for being number.
  if options.r then
      if type(options.r) ~= "number" then
        error(".init: table field \".r\" should be number. You passed: " .. type(options.r) .. ".", 2)
      end

      -- Check for out-of-bounds. Starting from love 11, colors become 0 - 1 in float. Before it was 0 - 255.
      if options.r > 1 or options.r < 0 then
         error(".init: table field \".r\" should be in-between 0 to 1. You passed: " .. tostring(options.r) .. ".", 2)
      end
      
      rs.r  = options.r
  end

  -- Green from RGBA for bars.
  if options.g then
      if type(options.g) ~= "number" then
        error(".init: table field \".g\" should be number. You passed: " .. type(options.g) .. ".", 2)
      end

      -- Check for out-of-bounds. Starting from love 11, colors become 0 - 1 in float. Before it was 0 - 255.
      if options.g > 1 or options.g < 0 then
         error(".init: table field \".g\" should be in-between 0 to 1. You passed: " .. tostring(options.g) .. ".", 2)
      end

      rs.g  = options.g
  end

  -- Blue from RGBA for bars.
  if options.b then
      if type(options.b) ~= "number" then
        error(".init: table field \".b\" should be number. You passed: " .. type(options.b) .. ".", 2)
      end

      -- Check for out-of-bounds. Starting from love 11, colors become 0 - 1 in float. Before it was 0 - 255.
      if options.b > 1 or options.b < 0 then
         error(".init: table field \".b\" should be in-between 0 to 1. You passed: " .. tostring(options.b) .. ".", 2)
      end

      rs.b  = options.b
  end

  -- Alpha from RGBA for bars.
  if options.a then
      if type(options.a) ~= "number" then
        error(".init: table field \".a\" should be number. You passed: " .. type(options.a) .. ".", 2)
      end

      -- Check for out-of-bounds. Starting from love 11, colors become 0 - 1 in float. Before it was 0 - 255.
      if options.a > 1 or options.a < 0 then
         error(".init: table field \".a\" should be in-between 0 to 1. You passed: " .. tostring(options.a) .. ".", 2)
      end

      rs.a  = options.a
  end

  -- Activate hack for pixel perfect scaling.
  if options.hack ~= nil then
      if type(options.hack) ~= "boolean" then
        error(".init: table field \".hack\" should be boolean. You passed: " .. type(options.hack) .. ".", 2)
      end

      rs.pixelPerfectOffsetsHack  = options.hack
  end

  -- Update library with new parameters.
  rs.resize()
end

rs.getGameZone = function()
  local gameZone = rs.gameZone
  return gameZone.x, gameZone.y, gameZone.w, gameZone.h
end

rs.setGame = function(width, height)
  -- Virtual size for game that library will scale to.

  -- Sanity check for input arguments.
  if type(width) ~= "number" or type(height) ~= "number"  then
      error(".setGame: Expected 2 arguments, that should be numbers. You passed: " .. type(width) .. ", " .. type(height) .. ".", 2)
  end

  rs.gameWidth = width
  rs.gameHeight = height

  rs.resize()
end

rs.getGame = function()
  return rs.gameWidth, rs.gameHeight
end

rs.setScaleMode = function(mode)
  -- Sanity check for input argument.
    if type(mode) ~= "number" then
      error(".setScaleMode: Expected number or nil argument. You passed: " .. type(mode) .. ".", 2)
    else
      -- Since currently there only 3 modes, anything other then that should raise error.
      if mode > 3 or mode < 1 then
        error(".setScaleMode: Expected argument to be 1, 2 or 3. You passed: " .. tostring(mode).. ".", 2)
      end
    end

    rs.scaleMode = mode
    rs.resize()
end
rs.switchScaleMode = function(side)
  -- Default order is +1.
  side = side or 1

  if type(side) ~= "number" then
    error(".switchScaleMode: Expected number or nil argument. You passed: " .. type(side) .. ".", 2)
  else
    -- Anything other then 1 and -1 and nil will raise error.
    if side ~= 1 and side ~= -1 then
      error(".switchScaleMode: Expected argument should be 1, -1 or nil. You passed: " .. tostring(side), 2)
    end
  end

  rs.scaleMode = rs.scaleMode + side

  -- Check for limits. It will loop from 1 to 3 and vice-versa.
  if rs.scaleMode > 3 then rs.scaleMode = 1 end
  if rs.scaleMode < 1 then rs.scaleMode = 3 end

  -- Since we changed scale mode, we need to re-calculate library data.
  rs.resize()
end

rs.setMode = function(width, height, flags)
  -- Wrapper for love.window.setMode()

  local okay, errorMessage = pcall(love.window.setMode, width, height, flags)
  if not okay then
    error(".setMode: Error: " .. errorMessage, 2)
  end

  -- Since we potentially changed here window size, we need to recalculate all data.
  rs.resize()
end

rs.switchPixelHack = function()
  rs.pixelPerfectOffsetsHack = not rs.pixelPerfectOffsetsHack
  rs.resize()
end

rs.switchBars = function()
  rs.bars = not rs.bars
end

rs.drawBars = function()
  -- Function that will draw bars.
  
  -- Can we can draw bars?
  if not rs.bars then
    return
  end
  
  -- Scale mode 2 is stretch, so no need waste time on bars rendering at all.
  if rs.scaleMode == 2 then
    return
  end
  
  -- Get color components, that was before rs.stop() function.
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
  
  -- Return original color that was before rs.stop()
  love.graphics.setColor(r, g, b, a)
  
  -- End bars rendering.
  love.graphics.pop()
end

rs.setColor = function(r, g, b, a)
  -- Set color of "black" bars.
  
  -- Check if all arguments are on place.
  if type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number" or type(a) ~= "number" then
      error(".setColor: Expected 4 arguments, that should be numbers. You passed: " .. type(r) .. ", " .. type(g) .. ", " .. type(b) .. ", " .. type(a) .. ".", 2)
  end
  
    -- Check for out-of-bounds. Starting from love 11, colors become 0 - 1 in float. Before it was 0 - 255.
    -- Red
    if r > 1 or r < 0 then
        error(".setColor: Argument \"r\" should be number in-between 0 - 1. You passed: " .. tostring(r) .. ".", 2)
    end
    
    -- Green
    if g > 1 or g < 0 then
        error(".setColor: Argument \"g\" should be number in-between 0 - 1. You passed: " .. tostring(g) .. ".", 2)
    end
    
    -- Blue
    if b > 1 or b < 0 then
        error(".setColor: Argument \"b\" should be number in-between 0 - 1. You passed: " .. tostring(b) .. ".", 2)
    
  end
  
  -- Alpha
    if a > 1 or a < 0 then
        error(".setColor: Argument \"a\" should be number in-between 0 - 1. You passed: " .. tostring(a) .. ".", 2)
    end

  rs.r = r -- red
  rs.g = g -- green
  rs.b = b -- blue
  rs.a = a -- alpha
end

rs.defaultColor = function()
  -- Reset color for "black" bars to black color.

  rs.r = 0 -- red
  rs.g = 0 -- green
  rs.b = 0 -- blue
  rs.a = 1 -- alpha
end

rs.getColor = function()
  -- Get red, green, blue and alpha componets of "black" bars color.

  return rs.r, -- red
         rs.g, -- green
         rs.b, -- blue
         rs.a  -- alpha
end

rs.switchDebug = function()
  rs.debug = not rs.debug
end

rs.debugFunc = function(debugX, debugY)
  -- Function used to render debug info on-screen.

  -- If debug disabled, there no point in wasting time on futher actions.
  if not rs.debug then return end

  -- Set width and height for debug "window".
  local debugWidth = 230
  local debugHeight = 230

  -- Default position is top-left corner of window.
  debugX = debugX or 0
  debugY = debugY or 0
  
  -- Do sanity check for input arguments.
  if type(debugX) ~= "number" then
    error(".debugFunc: 1st argument should be number or nil. You passed: " .. type(debugX) .. ".", 2)
  end

  if type(debugY) ~= "number" then
    error(".debugFunc: 2nd argument should be number or nil. You passed: " .. type(debugY) .. ".", 2)
  end

  -- Save color that was before debug function.
  local r, g, b, a = love.graphics.getColor()

  -- Save font that was before debug function.
  local oldFont = love.graphics.getFont()

  -- Draw background rectangle for text.
  love.graphics.setColor(0, 0, 0, 0.5)
  
  -- Place debug info on screen according to user input.
  love.graphics.rectangle("fill", debugX, debugY, debugWidth, debugHeight)

  -- Set font and color.
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
    "filter: " .. "min: " .. tostring(select(1, love.graphics.getDefaultFilter())) .. ", mag: " .. tostring(select(2, love.graphics.getDefaultFilter())) .. "\n" ..
    "anisotropy: " .. tostring(select(3, love.graphics.getDefaultFilter())) .. "\n" ..
    "isMouseInside: " .. tostring(rs.isMouseInside()),
    debugX, debugY, debugWidth)

  -- Return colors.
  love.graphics.setColor(r, g, b, a)
  
  -- Return font.
  love.graphics.setFont(oldFont)
end

rs.nearestFilter = function(filter, anisotropy)
  -- Sanity check for filter argument.
  if filter == nil then
    filter = true
  end
  
  if type(filter) ~= "boolean" then
    error(".nearestFilter: 1 argument should be nil or boolean. You passed: " .. type(filter) .. ".", 2)
  end
  
  -- Translate boolean to string.
  if filter == true then -- neareset
    filter = "nearest"
  elseif filter == false then -- linear
    filter = "linear"
  end
  
  -- Check anisatropy.
  anisotropy = anisotropy or select(3, love.graphics.getDefaultFilter())
  
  if type(anisotropy) ~= "number" then
    error(".nearestFilter: 2 argument should be nil or number. You passed: " .. type(anisotropy) .. ".", 2)
  end
  
  -- Just in case, call this function in protected way.
  local okay, errorMessage = pcall(love.graphics.setDefaultFilter, filter, filter, anisotropy)
  if not okay then
    error(".nearestFilter: Error: " .. errorMessage, 2)
  end
end

rs.resize = function(windowWidth, windowHeight)
  windowWidth = windowWidth or love.graphics.getWidth()
  windowHeight = windowHeight or love.graphics.getHeight()
  
  -- Check if user passed arguments and if they are numbers.
  if type(windowWidth) ~= "number" then
    error(".resize: 1 argument should be number or nil. You passed: " .. type(windowWidth) .. ".", 2)
  end
  if type(windowHeight) ~= "number" then
    error(".resize: 2 argument should be number or nil. You passed: " .. type(windowHeight) .. ".", 2)
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
    -- When you in Pixel Pefrect scaling mode (3), if window size is non-even, it will result in
    -- non-integer offset values for x and y, which result in pixels bleeding.
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
      -- And we fallback to scale 1, if game size is less then window, because when scale == 0, there nothing to see.
      scale = math.max(math.floor(scale), 1)
    end

    -- Update offsets.
    xOff, yOff = (windowWidth - (scale * gameWidth)) / 2, (windowHeight - (scale * gameHeight)) / 2
    -- Update scaling values.
    scaleWidth, scaleHeight = scale, scale
  end
  
  -- Save values to library --
  
  -- Black bars.
  rs.x1, rs.y1, rs.w1, rs.h1 = 0, 0, windowWidth, yOff                                   --top
  rs.x2, rs.y2, rs.w2, rs.h2 = 0, yOff, xOff, windowHeight - (yOff * 2)                  -- left
  rs.x3, rs.y3, rs.w3, rs.h3 = windowWidth - xOff, yOff, xOff, windowHeight - (yOff * 2) -- right
  rs.x4, rs.y4, rs.w4, rs.h4 = 0, windowHeight - yOff, windowWidth, yOff                 -- bottom
  
  rs.xOff, rs.yOff = xOff, yOff
  
  rs.scaleWidth, rs.scaleHeight = scaleWidth, scaleHeight
  
  rs.windowWidth, rs.windowHeight = windowWidth, windowHeight
  
  rs.gameZone.x = xOff
  rs.gameZone.y = yOff
  rs.gameZone.w = windowWidth - (xOff * 2)
  rs.gameZone.h = windowHeight - (yOff * 2)
  
  rs.resizeCallback()
end

rs.resizeCallback = function()
  
end

rs.start = function()
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
  -- Stop scaling.
  love.graphics.pop()

  -- Draw bars.
  rs.drawBars()
end

rs.unscaleStart = function()  
  -- Start unscaling.
  love.graphics.push()
  
  -- Reset transformation and scaling.
  love.graphics.origin()
end

rs.unscaleStop = function()
  love.graphics.pop()
end

rs.getScale = function()
  -- Get width and height scale.
  
  return rs.scaleWidth, rs.scaleHeight
end

rs.getWindow = function()
  return rs.windowWidth, rs.windowHeight
end

rs.isMouseInside = function()
  -- If we in Stretch Scaling mode (2), then there is no bars, so mouse always "inside".
  if rs.scaleMode == 2 then
    return true
  end
  
  local mouseX, mouseY = love.mouse.getPosition()
  local x, y, w, h = rs.getGameZone()

  -- Check if cursor inside game zone.
  if mouseX    >= x                 and -- left
     mouseY    >= y                 and -- top
     mouseX    <= x + w             and -- right
     mouseY    <= y + h            then -- bottom
      -- Cursor inside game zone.
     return true
  end

  -- Cursor outside game zone.
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
    error(".toGame: Expected 2 arguments, that should be numbers. You passed: " .. type(x) .. ", " .. type(y) .. ".", 2)
  end

  return (x - rs.xOff) / rs.scaleWidth, (y - rs.yOff) / rs.scaleHeight
end

rs.toGameX = function(x)
  -- Translate x coordinate from non-scaled to scaled
  -- e.g translate real mouse coordinates into scaled so you can check
  -- for example, area to check collisions with object and cursor.

  if type(x) ~= "number" then
    error(".toGameX: Expected argument, that should be number. You passed: " .. type(x) .. ".", 2)
  end

  return (x - rs.xOff) / rs.scaleWidth
end

rs.toGameY = function(y) 
  -- Translate y coordinate from non-scaled to scaled
  -- e.g translate real mouse coordinates into scaled so you can check
  -- for example, area to check collisions with object and cursor;

  if type(y) ~= "number" then
    error(".toGameY: Expected argument, that should be number. You passed: " .. type(y) .. ".", 2)
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
    error(".toScreen: Expected 2 arguments, that should be numbers. You passed: " .. type(x) .. ", " .. type(y) .. ".", 2)
  end

  return (x * rs.scaleWidth) + rs.xOff, (y * rs.scaleHeight) + rs.yOff
end

rs.toScreenX = function(x)
  -- Thanslate x coordinate from scaled to non scaled.
  -- e.g translate x of object inside scaled area
  -- to, for example, set cursor position to that object
  
  if type(x) ~= "number" then
    error(".toScreenX: Expected argument, that should be number. You passed: " .. type(x) .. ".", 2)
  end

  return (x * rs.scaleWidth) + rs.xOff
end

rs.toScreenY = function(y)
  -- Thanslate y coordinate from scaled to non scaled.
  -- e.g translate y of object inside scaled area
  -- to, for example, set cursor position to that object
  
  if type(y) ~= "number" then
    error(".toScreenY: Expected argument, that should be number. You passed: " .. type(y) .. ".", 2)
  end
  
  return (y * rs.scaleHeight) + rs.yOff
end

return rs