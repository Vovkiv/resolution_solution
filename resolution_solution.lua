local rs = {
  _URL = "https://github.com/Vovkiv/resolution_solution",
  _VERSION = 2001,
  _LOVE = 11.4,
  _DESCRIPTION = "Scale library, that help you add resolution support to your games in love2d!",
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

--[[
  * Alwasy allow window to be resizable. Even if you think this is "unnecessary". It restrict player ability to play in that window/screen size, that they want.
  * Always add in your game option to change scaleMode. Even if your game have pixel graphics. For example, some people don't like to have big black bars on top, left, right, bottom. Maybe they want just stretched view. Or aspect scale. They might prefer it over clean pixels.
  * Don't forget to use rs.isMouseInside() when you develop mouse support in game. This function will tell you if cursor is touching bars. You don't want to trigger cursor touch if scaled object behind black bar.
  * Don't forget to set filter to nearest, if you make pixel graphics. For example, with this: love.graphics.setDefaultFilter("nearest", "nearest").

  (May be updated in future)
--]]

rs.setMode = function(width, height, flags)
-- Wrap around love.window.setMode.
-- Use it instead.

  love.window.setMode(width, height, flags)
  rs.resize(love.graphics.getWidth(), love.graphics.getHeight())
end

-- https://github.com/Vovkiv/resolution_solution/issues/9
-- In short, when you in pixel perect scale mode, if window size is non even, it will result in
-- non integer offset values for x and y, which result in pixels bleedingm which is acceptable in
-- non pixel pefrect modes, but not here.
rs.pixelPerfectOffsetsHack = false

rs.switchPixelHack = function()
-- Turn on/off hack.
  rs.pixelPerfectOffsetsHack = not rs.pixelPerfectOffsetsHack
  rs.resize(love.graphics.getWidth(), love.graphics.getHeight())
end
-- Configure library with this.
-- Can change all possible settings at once.
-- If you don't need to change any parameter and need simple initilise library, call empty rs.init()
rs.init = function(options)
  if type(options) ~= "nil" and type(options) ~= "table" then
    error(".init: Expected table or nil argument. You passed: " .. type(options) .. ".")
  end

  options = options or {}

  -- Game width.
  -- If user passed .width parameter, check it for being number.
  if options.width then
      if type(options.width) ~= "number" then
        error(".init: table field \".width\" should be number. You passed: " .. type(options.width) .. ".")
      end

      rs.gameWidth  = options.width
  end

  -- Game height.
  -- If user passed .height parameter, check it for being number.
  if options.height then
      if type(options.height) ~= "number" then
        error(".init: table field \".height\" should be number. You passed: " .. type(options.height) .. ".")
      end

      rs.gameHeight  = options.height
  end

  -- Render bars?
  -- If user passed .bars parameter, check it for being boolean.
  if options.bars ~= nil then
      if type(options.bars) ~= "boolean" then
        error(".init: table field \".bars\" should be boolean. You passed: " .. type(options.bars) .. ".")
      end

      rs.bars = options.bars
  end

  -- Show/hide debug info.
  -- If user passed .debug parameter, check it for being boolean.
  if options.debug ~= nil then
      if type(options.debug) ~= "boolean" then
        error(".init: table field \".debug\" should be boolean. You passed: " .. type(options.debug) .. ".")
      end

      rs.debug = options.debug
  end

  -- Scale mode.
  -- If user passed .mode parameter, check it for being number.
  if options.mode then
      if type(options.mode) ~= "number" then
        error(".init: table field \".mode\" should be number. You passed: " .. type(options.mode) .. ".")
      end
      
      -- Check for out of bounds
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

      rs.r  = options.r
  end

  -- Green from RGBA for bars.
  -- If user passed .g parameter, check it for being number.
  if options.g then
      if type(options.g) ~= "number" then
        error(".init: table field \".g\" should be number. You passed: " .. type(options.g) .. ".")
      end

      rs.g  = options.g
  end

  -- Blue from RGBA for bars.
  -- If user passed .b parameter, check it for being number.
  if options.b then
      if type(options.b) ~= "number" then
        error(".init: table field \".b\" should be number. You passed: " .. type(options.b) .. ".")
      end

      rs.b  = options.b
  end

  -- Alpha from RGBA for bars.
  -- If user passed .a parameter, check it for being number.
  if options.a then
      if type(options.a) ~= "number" then
        error(".init: table field \".a\" should be number. You passed: " .. type(options.a) .. ".")
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
  -- Set scale mode by number.
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
rs.debugFunc = function()
-- If debug disabled, there no point in wasting time on rendering debug info.
  if not rs.debug then return end

  -- Return this colors later.
  local r, g, b, a = love.graphics.getColor()

  -- Draw background rectangle for text.
  love.graphics.setColor(0, 0, 0, 0.5)
  love.graphics.rectangle("fill", 0, 0, 180, 240)

  -- Set fonts.
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setFont(love.graphics.newFont(12))

  -- Print data.
  love.graphics.print(rs._NAME .. " v." .. tostring(rs._VERSION), 0, 0)
  love.graphics.print("gameWidth: " .. tostring(rs.gameWidth), 0, 15)
  love.graphics.print("gameHeight: " .. tostring(rs.gameHeight), 0, 30)
  love.graphics.print("scaleWidth: " .. tostring(rs.scaleWidth), 0, 45)
  love.graphics.print("scaleHeight: " .. tostring(rs.scaleHeight), 0, 60)
  love.graphics.print("windowWidth: " .. tostring(rs.windowWidth), 0, 75)
  love.graphics.print("windowHeight: " .. tostring(rs.windowHeight), 0, 90)
  love.graphics.print("scaleMode: " .. tostring(rs.scaleMode), 0, 105)
  love.graphics.print("bars: " .. tostring(rs.bars), 0, 120)
  love.graphics.print("debug: " .. tostring(rs.debug), 0, 135)
  love.graphics.print("xOff: " .. tostring(rs.xOff), 0, 150)
  love.graphics.print("yOff: " .. tostring(rs.yOff), 0, 165)
  love.graphics.print("pixelPerfectOffsetsHack: " .. tostring(rs.pixelPerfectOffsetsHack), 0, 180)
  love.graphics.print("filter: " .. tostring(select(1, love.graphics.getDefaultFilter())), 0, 195)
  love.graphics.print("anisotropy: " .. tostring(select(3, love.graphics.getDefaultFilter())), 0, 210)

  -- Return colors.
  love.graphics.setColor(r, g, b, a)
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
    
    -- https://github.com/Vovkiv/resolution_solution/issues/9
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
  -- Bars.
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
  -- Will return table with:
  -- x, y, w, h
  -- Useful to determine scale zone, to build UI.

  local gameZone = rs.gameZone
  return {
    x = gameZone.x, 
    y = gameZone.y,
    w = gameZone.w,
    h = gameZone.h
  }
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

-- demo:
--[[
rs = require("resolution_solution")
-- Refer ro source code of library, for rs.init() to get full list of avaliable options or their explanation.
-- but in most cases you only need to specify game width/height and default scale mode.
rs.init({width = 640, height = 480, mode = 3})
-- This function allow you to change color of bars that you will appear in aspect and pixel perfect modes.
-- By default, they will have black color, but you can change it and even make transparent.
-- To change individual color, use rs.r, rs.g, rs.b, rs.a for red, green, blue and alpha.
-- Also rs.getColor() will return 4 arguments with currect colors and rs.defaultColor() will return default black color.
rs.setColor(0.1, 0.5, 0.2, 0.5)

-- Filter, works best for pixeleted raphics.
-- can be use without arguments, which same as "true".
-- It's simple wrapper for love.graphics.setDefaultFilter().
-- Refer source code for more info.
rs.nearestFilter(true)

-- Make window resizeable. I strongly suggest you to always make window resiable, via this love function or conf.lua
-- After all, this library was designed for this.
rs.setMode(800, 600, {resizable = true})
-- Show library name and version in title.
love.window.setTitle(tostring(rs._NAME .. " v." .. rs._VERSION))

-- Example rectangle, that demonstrate how you can implement, for example, mouse collision detection,
-- and other translate functions.
local rectangle1 = {
  x = 100,
  y = 100,
  w = 100,
  h = 100,
  click = 0
}

-- Show/hide rectangle around scaled area. 
local showGameZone = true

-- library was designed to update at love.resize() (it possible to update at love.update(), but it's not something that you want to do),
-- so place it there. Also, side not: never forget to use rs.init() (even if you don't need to change any settings) at least 1 at start of game/scene.
-- This is required since until 1st window resize, library will be not updated, so no scale, no offset, nothing will be calculated.
love.resize = function(w, h)
  rs.resize(w, h)
end

-- Change options with keyborad
love.keypressed = function(key, scancode, isrepeat)
  if key == "f1" then
    rs.switchScaleMode()
  elseif key == "f2" then
      rs.switchBars()
  elseif key == "f3" then
      rs.switchDebug()
  elseif key == "f4" then
      showGameZone = not showGameZone
  elseif key == "f5" then
      rs.switchPixelHack()
  end
end

-- Example of how you can implement mouse collision detection function.
local mouseFunc = function(x, y, w, h)

  -- Translate mouse to ingame coordinates
  local mx, my = rs.toGame(love.mouse.getPosition())
  if mx  >= x                 and -- left
     my    >= y                 and -- top
     mx    <= x         +    w  and -- right
     my    <= y         +    h  then -- bottom
     return true
    end

    return false
end

love.mousepressed = function(x, y, button, istouch, presses)

    -- Example of usage for mouse collision.
    -- Add 1 to counter if clicked.
    if rs.isMouseInside() and mouseFunc(rectangle1.x, rectangle1.y, rectangle1.w, rectangle1.h) and button == 1 then
      rectangle1.click = rectangle1.click + 1
    end

    -- Example of how to use and transka scaled coordinates to screen coordinates.
    -- Set mouse cursor to rectangle.
    if button == 2 then
      love.mouse.setPosition(rs.toScreenX(rectangle1.x), rs.toScreenY(rectangle1.y))
    end

    -- Another translation example.
    -- Move rectangle to cursor.
    if button == 3 then
      rectangle1.x, rectangle1.y = rs.toGame(love.mouse.getPosition())
    end
end

love.draw = function()
  -- Start scaling
  rs.start()
  -- Background color.
    love.graphics.setBackgroundColor(0, 0.4, 0.6, 1)

    -- Change rectangle color if we touch it.
    if rs.isMouseInside() and mouseFunc(rectangle1.x, rectangle1.y, rectangle1.w, rectangle1.h) then
      love.graphics.setColor(1, 0.5, 0.5, 1)
    else
        love.graphics.setColor(0.5, 0.5, 0.5, 1)
    end

    -- Draw rectangle.
    love.graphics.rectangle("fill", rectangle1.x, rectangle1.y, rectangle1.w, rectangle1.h)

    -- Show counter and explanation.
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print("Click on me!" .. tostring(rectangle1.click) ..  "\nYou can't click on me, if i behind\nbars, because library\ncan take care of it!", rectangle1.x, rectangle1.y)

    -- Scaled text.
    love.graphics.print("I'm scaled text!", 200, 50)

    -- Example of how you can implement UI that should be scaled separately/differently from game.
    rs.unscaleStart()
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.print("I'm unscaled, despite being in-between rs.start() and rs.stop()!\nAlso bars draws ontop of me!", 180, 50)
    rs.unscaleStop()

  -- Stop scaling.
  rs.stop()

  -- Bars text.
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print("Bars can be any color you want! Not only black!", rs.windowWidth - 200, 0)

  love.graphics.setColor(0, 0, 0, 1)
    -- Example of how you can use rs.gameZone.
    -- Draw rectangle.
  if showGameZone then
    -- love.graphics.rectangle("line", rs.gameZone.x, rs.gameZone.y, rs.gameZone.w, rs.gameZone.h)
  end

  -- Call debug function.
  rs.debugFunc()

  -- Instructions.
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print("Press F1 to change scaleMode. F2 to enable/disable bars. F3 to enable/disable debug info. Press f4 to show/hide game zone borders.\nPress F5 to activate/deactivate pixel perfect hack (make sure to be in scaling mode 3). When active, try resize window and see if you notice difference. \nTry to change window size and click on rectangle. Press right mouse button to move cursor to rectangle. Press middle mouse to move rectangle under cursor.", 0, rs.windowHeight - 100)
end
--]]

-- Changelog:
--[[
Version 1000, 7 january 2021
Initial release

Version 1001, 6 february 2022
* Now, scaling.stop() will remember color that was set before it and return it back after
* Added comments for "Simple demo"
* Added more comments for functions and variables in library, to clarify more what the do and don't
* Fixed typo in "Simple demo"

Version 1002, 8 february 2022
* Fixed (probably) edge cases in isMouseInside() function, so now it should corectly deal with non integer offsets provided by scaling.xOff/yOff
* Now isMouseInside() return always true if scale mode is == 2, since there is no black bars in that scaling method
* Updated isMouseInside() comments
* Rewrited "Simple demo", now it uses modified demo from github's page (at moment, it takes whoping 193 lines of code, bloat!)
* Fixed typos, rewrited/rephrased comments
* Added note in scaling.toGame/scaling.toScreen about rounding/missmathing, make sure check it
* Added note about scaling.isMouseInside, make sure check it

Version 1003, 12 february 2022
* Added library license text in rs._LICENSE_TEXT
* Added auto-completion API for Zerobrane Studio!
Visit rs._URL and file RS_ZBS_API.lua for more info
* Updated comments

Version 1004, 19 may 2022
* rs.widthScale = 0 --> rs.scaleWidth = 0
* rs.heightScale  = 0 --> rs.scaleHeight = 0
I'm stupid.
If you use rs.getScale(), you don't need to worry about anything,
this function terunred correct values, but
documentation: "rs.widthScale" and "rs.heightScale" while
should be "rs.scaleWidth" and "rs.scaleHeight", so meaning that
trying to get "rs.widthScale" or "rs.heightScale" will result in 0, 0.
Yeah...

Version 1005, 19 may 2022
(Sorry for bothering again with update on the same day...)
Anyway:
* Added table rs.gameZone, which contains x, y, w, h coordinates of scaled area.
You might need it when you want to draw UI, which shoudn't be scaled by lib
regardless of currect scaling mode (stretching or with black bars),
because to draw UI you need to know where starts/ends scaled area on window.
And it might help for camera libraries, which uses love.graphics.setScissors.

For example, if you want to use kikito's camera lib (https://github.com/kikito/gamera)
with this my lib, you need to do:

--[=[
rs = require("scaling_solution")
gamera = require("gamera")

cam = gamera.new(0, 0, 2000, 2000)

love.update = function(dt)
  -- Update my lib.
  rs.update()
  -- Unpack new function.
  local gameZone = RS.getGameZone()
  -- Set right coordinates for scissors.
  -- (also, for best results, do rounding to uncoming values
  -- because it might create empty space between black bars (that my lib render)
  -- and everything, that gamera lib draw.)
  cam:setWindow(math.ceil(gameZone.x - 0.5), math.ceil(gameZone.y - 0.5), math.ceil(gameZone.w), math.ceil(gameZone.h))
end

local draw = function()
  -- Then after gamera finished tranlsating and scaling, call my lib draw:
  rs.start()
  -- * Here you draw everything that you need to be scaled.
end

love.draw = function()
  cam:draw(draw) -- you need to call camera draw in first place.
  rs.stop() -- and only after camera done drawing, you stops my lib.
end

Version v1006 20 may 2022
* rs.drawBlackBars added.
So now you can call it to draw black bar outside of rs.start and rs.stop.
Some libraries, especialy that use love's scissors functionality
might broke back bars rendering;
Or camera (or any translating related) libraries might mess with coordinate translating
Which might end up in broken graphics and frustration.

ALso, this function uses same rules as rs.stop, meaning
rs.drawBars = false will result in rs.drawBlackBars will be not rendered.
* Now rs.stop will draw black bars via rs.drawBlackBars.

Version v2000 27 december 2022
Big rewrite! Check source file for all detailed changes. (Some functionality in this version is not compatible with old versions.)
Source file, at almost top, now include some tips and "tricks", check them out.

New:
* Pixel Perfect scaling! rs.setScaleMode(3) to check it out!
* rs.init(options) - before, to change some options in library, you could update value directly from rs.* table or use provided built-in functions. Now, considering new "insidies" of library, changing options directly as rs.scaleMode = 1 will do nothing, because library will be updated only on rs.resize() or via newly (and old one) provided functions, including rs.init().
You should call rs.init() at least once, even if you don't need to update anything in options, otherwise until first rs.resize(), you will see black screen.
You can pass argument as table with options, or pass nothing to just update. List of options avaliable in source library file.
* rs.setScaleMode() - allow you to change scale mode via number. Pass 1, 2, 3 to change.
* rs.debug - boolean, which controls if rs.debugFunc() will be rendered or not.
* rs.debugFunc() - function that will show some data that useful for debug. Call it somewhere in love.draw() as rs.debugFunc().
* rs.switchDebug() - switch rs.debug, from true to false and vice-versa.

Removed:
* rs.windowChanged() - because now there no need in this callback.
* rs.gameChanged() - also not really useful anymore.
* rs.gameAspect - it was not really useful anyway.
* rs.windowAspect - also not useful.
* rs.update() - explained below.

Changed functionality:
* Before, there was only 2 bars: Left/right or top/bottom and they was avaliable only at scaleMode 1. With intoduced 3rd scale method, Pixel perfect, that has bars at top/bottom/left/right at same time, their functionality changed.
You can still access them as: rs.x1, rs.y1, rs.w1, rs.h1 (from 1 to 4, rs.x1, rs.x2, rs.x3...), but order changed:
1 for top bar
2 for left bar
3 for right bar
4 for bottom bar
* Apperantly, rs.gameZone table was never updated, because i forgot to do so in rs.update... Welp, that sucks. Now it updates properly.
* Now all functions, that expects arguments, have error messages to point out if you passed something wrong. Yay!
* rs.resize - now library update loop was designed around love.resize() function, instead of love.update(), like other scaling libs do. So less wasted frame time, yay! Don't forget to pass w and h from love.resize(w, h) to library as rs.resize(w, h). For compatability sake, it should be possible to put rs.resize at love.update and just pass rs.resize(love.graphics.getWidth(), love.graphics.getHeight()). It was not tested properly, but i believe there shoudn't be any problem with it, except maybe performance.
* rs.switchScaleMode() - before until 3rd scaling method, there was only 2 methods and this function acted more like "boolean". Now, you can pass 1 or -1 to choose how you want to switch methods: 1 -> 2 -> 3 -> 1... or 3 -> 2 -> 1 -> 1...
If you pass nothing, function will act as you passed 1.

Renamed, but functionality the same:
rs.drawBars -> rs.bars
rs.drawBlackBars -> rs.drawBars
rs.switchDrawBars -> rs.switchBars

* Rewrited demo.
* From now on, i will include minified version of library, with removed comments and minified code, that will make filesize lesser. https://mothereff.in/lua-minifier. Check github page.

Version v2001 31 december 2022
Small update, that add some QoL features, and hack for Pixel Pefrect Scaling. Check source code (specifically
rs.pixelPerfectOffsetsHack and rs.resize) and this update log for more info.
Happy new year!

New:
* nearestFilter(filter, anisotropy) - this function is easier to use wrapper for love.graphics.setDefaultFilter()
It expects 2 optional arguments:
1st in true/false or nil (which is esentially nothing). true/nil results in nearest filtering, while false is linear.
2nd is anisotropy. It can be number or nil. If number, function will simply use it to slap into love.graphics.setDefaultFilter(),
but if nil, then library will simply get anisotropy value from love.graphics.getDefaultFilter() and will use it instead. Current love uses 1 as default.
If this function was never run, library will never touch or edit love.graphics.setDefaultFilter()

* rs.pixelPerfectOffsetsHack = false/true - very experimental feature, that aim to fix pixel bleeding in perfect scaling mode
when window size is not even. It result in always "clean" pixels, byt comes with side effects such as:
1. rs.windowWidth and rs.windowHeight will be wrong by 1 if window is non even. The workaround is to use love.graphics.getWidth/Height instead.
2. On non even window size, offset from left and top will place game content on 1 pixel left/upper.
It shouldn't be problem for end user tho.

But if you never ever draw anything inside rs.unscaleStart() and rs.unscaleStop() and outside of rs.start() and stop(), then you should probably fine using this hack.

* rs.switchPixelHack() - turn on/off mentioned hack.
* rs.setMode() - wrapper around love.window.setMode(). You should use this functions instead, since using love.window.setMode() might
don't trigger love.resize and therefore rs.resize.  

Updated:
* Updated demo to include all new functions and values
* Updated rs.debugFunc to include all new values and functions
--]=]
  
--]]