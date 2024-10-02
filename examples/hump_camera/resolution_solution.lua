---@class ResolutionSolution
local rs = {
  _URL = "https://github.com/Vovkiv/resolution_solution",
  -- All functionality of this library documented here.
  _DOCUMENTATION = "https://github.com/Vovkiv/resolution_solution/blob/main/resolution_solution_documentation.pdf",
  _VERSION = 3003,
  -- love2d version for which this library designed.
  _LOVE = 11.5,
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

rs.scale_mode = 1

-- Magic numbers for scaling mode.
rs.ASPECT_MODE = 1
rs.STRETCH_MODE = 2
rs.PIXEL_PERFECT_MODE = 3
rs.NO_SCALING_MODE = 4

rs.scale_width, rs.scale_height = 0, 0

rs.game_width, rs.game_height = 800, 600

rs.x_offset, rs.y_offset = 0, 0

rs.game_zone = {
  x = 0,
  y = 0,
  w = 0,
  h = 0
}

----------------------------------------------------------------------
--                        Essential functions                       --
----------------------------------------------------------------------

--- Function to quickly (re)init, (re)configure library.
--- 
--- Optional argument can be table with fields:
--- - game_width: number – game virtual width, should be 0 or bigger, otherwise function will error.
--- - game_height: number – game virtual height, should be 0 or more, otherwise function will error.
--- - scale_mode: number – scaling more, should be 1, 2 or 3, otherwise function will error.
---
--- Before finishing, this function will call rs.resize() function to update library state, even if nothing was changed.
--- 
--- Example:
--- ```lua
--- rs.conf({
---   game_width = 640,
---   game_height = 480,
---   scale_mode = 3
--- })
--- ```
---@param options table?
rs.conf = function(options)
  -- Sanitize.
  if type(options) == "nil" then
    options = {}
  elseif type(options) ~= "table" then
      error(".conf: 1st argument should be table or nil. You passed: " .. type(options) .. ".", 2)
  end
  
  
  if options.game_width then
    if type(options.game_width) ~= "number" then
      error(".conf: field \'game_width\' should be number. You passed: " .. type(options.game_width) .. ".", 2)
    end
    
    if options.game_width < 0 then
      error(".conf: field \'game_width\' should be 0 or more. You passed: " .. tostring(options.game_width) .. ".", 2)
    end
    
    rs.game_width = options.game_width
  end
  
  if options.game_height then
    if type(options.game_height) ~= "number" then
      error(".conf: \'game_height\' should be number. You passed: " .. type(options.game_height) .. ".", 2)
    end
    
    if options.game_height < 0 then
      error(".conf: \'game_height\' should be 0 or more. You passed: " .. tostring(options.game_height) .. ".", 2)
    end
    
    rs.game_height = options.game_height
  end
  
  if options.scale_mode then
    if type(options.scale_mode) ~= "number" then
      error(".conf: field \'scale_mode\' should be number. You passed: " .. type(options.scale_mode) .. ".", 2)
    end
    
    if options.scale_mode > 4 or options.scale_mode < 1 then
      error("conf: field \'scale_mode\' can be only 1, 2, 3 and 4. You passed: " .. tostring(options.scale_mode) .. ".")
    end
    
    rs.scale_mode = options.scale_mode
  end
  
  rs.resize()
end

--- Function that scales your game. Also see rs.pop().
--- ```lua
--- -- Basic usage
--- local rs = require("resolution_solution")
--- rs.conf({
---   game_width = 640,
---   game_height = 480,
---   scale_mode = 1
--- })
--- love.graphics.setBackgroundColor(0.3, 0.5, 1)
--- rs.setMode(rs.game_width, rs.game_height, {resizable = true})
--- 
--- local game_canvas = love.graphics.newCanvas(rs.get_game_size())
--- 
--- love.resize = function()
---   rs.resize()
--- end
--- 
--- love.draw = function()
---   love.graphics.setCanvas(game_canvas)
---   love.graphics.clear(0, 0, 0, 1)
---   love.graphics.setColor(1, 1, 1, 1)
---   love.graphics.setCanvas()
---
---   rs.push()
---     love.graphics.draw(game_canvas)
---   rs.pop()
--- end
--- ```
rs.push = function()
  love.graphics.push()
  love.graphics.origin()
  love.graphics.translate(rs.x_offset, rs.y_offset)
  love.graphics.scale(rs.scale_width, rs.scale_height)
end

--- A function that closes rs.push(). Also see rs.push().
--- ```lua
--- local rs = require("resolution_solution")
--- rs.conf({
---   game_width = 640,
---   game_height = 480,
---   scale_mode = 1
--- })
--- love.graphics.setBackgroundColor(0.3, 0.5, 1)
--- rs.setMode(rs.game_width, rs.game_height, {resizable = true})
--- 
--- local game_canvas = love.graphics.newCanvas(rs.get_game_size())
--- 
--- love.resize = function()
---   rs.resize()
--- end
--- 
--- love.draw = function()
---   love.graphics.setCanvas(game_canvas)
---   love.graphics.clear(0, 0, 0, 1)
---   love.graphics.setColor(1, 1, 1, 1)
---   love.graphics.setCanvas()
---
---   rs.push()
---     love.graphics.draw(game_canvas)
---   rs.pop()
--- end
--- ```
rs.pop = function()
  love.graphics.pop()
end

--- A function that forces the library to update. It was designed to be called inside love.resize() 
--- function. You can optionally pass width and height arguments to it, or pass nothing and library will 
--- get window size from love.
--- 
--- **Example:**
--- ```lua
--- local rs = require("resolution_solution")
--- rs.conf({
---   game_width = 640,
---   game_height = 480,
---   scale_mode = 1
--- })
--- love.graphics.setBackgroundColor(0.3, 0.5, 1)
--- rs.setMode(rs.game_width, rs.game_height, {resizable = true})
--- 
--- local game_canvas = love.graphics.newCanvas(rs.get_game_size())
--- 
--- love.resize = function()
---   rs.resize()
--- end
--- ```
---@param window_width number?
---@param window_height number?
rs.resize = function(window_width, window_height)
  -- Sanitize.
  -- Window width.
  if type(window_width) == "nil" then
    window_width = love.graphics.getWidth()
  elseif type(window_width) ~= "number" then
    error(".resize: 1st argument should be nil or number. You passed: " .. type(window_width) .. ".")
  end
  
  -- Window height.
  if type(window_height) == "nil" then
    window_height = love.graphics.getHeight()
  elseif type(window_height) ~= "number" then
    error(".resize: 2nd argument should be nil or number. You passed: " .. type(window_height) .. ".")
  end
  
  local scale_width, scale_height = 0, 0
  local x_offset, y_offset = 0, 0
  local game_width, game_height = rs.game_width, rs.game_height
  local scale_mode = rs.scale_mode
  
  if scale_mode == rs.STRETCH_MODE then
    -- We only need to update width and height scale.
    scale_width = window_width / game_width
    scale_height = window_height / game_height

  elseif scale_mode == rs.NO_SCALING_MODE then
    scale_width = 1
    scale_height = 1

  else
    -- Other scaling methods need to determine scale based on window and game aspects.
    local scale = math.min(window_width / game_width, window_height / game_height)

    if scale_mode == rs.PIXEL_PERFECT_MODE then
      -- We will floor to nearest int number.
      -- And we fallback to scale 1, if game size is less then window,
      -- because when scale == 0, there nothing to see.
      scale = math.max(math.floor(scale), 1)
    end

    x_offset = (window_width - (scale * game_width)) / 2
    y_offset = (window_height - (scale * game_height)) / 2
    scale_width, scale_height = scale, scale
  end
  
  -- Write new values to library --
  rs.x_offset, rs.y_offset = x_offset, y_offset
  rs.scale_width, rs.scale_height = scale_width, scale_height
  
  rs.game_zone.x = x_offset
  rs.game_zone.y = y_offset
  rs.game_zone.w = window_width - (x_offset * 2)
  rs.game_zone.h = window_height - (y_offset * 2)
  
  rs.resize_callback()
end

----------------------------------------------------------------------
--                        Helper functions                          --
----------------------------------------------------------------------

--- A function that is invoked every time rs.resize() is called. This function is useful if you need to 
--- hook into the library. For example, to rescale the UI. To do so, you can write your own 
--- rs.resize_callback() and insert your own code inside the function.
--- 
--- **Note:** rs.resize_callback() is called after rs.resize() is finished updating the library.
--- 
--- **Example:**
--- ```lua
--- local rs = require("resolution_solution")
-- rs.conf({
---   game_width = 640,
---   game_height = 480,
---   scale_mode = 1
--- })
--- love.graphics.setBackgroundColor(0.3, 0.5, 1)
--- rs.setMode(rs.game_width, rs.game_height, {resizable = true})
--- 
--- local game_canvas = love.graphics.newCanvas(rs.get_game_size())
--- 
--- love.resize = function()
---   rs.resize()
--- end
--- 
--- rs.resize_callback = function()
---   print("Library was resized!")
--- end
--- 
--- love.draw = function()
---   love.graphics.setCanvas(game_canvas)
---   love.graphics.clear(0, 0, 0, 1)
---   love.graphics.setColor(1, 1, 1, 1)
---   love.graphics.setCanvas()
---
---   rs.push()
---     love.graphics.draw(game_canvas)
---   rs.pop()
--- end
--- ```
rs.resize_callback = function() end

--- This is a function to help you debug. It shows information about the library states. You can 
--- display these states on the screen to help you troubleshoot. Calling rs.debug_info() without 
--- arguments is the same as calling rs.debug_info(0,0) which draws the debug window in the top left 
--- corner of the window.
--- 
--- **Information displayed:**
--- - Library name
--- - Library version
--- - rs.game_width
--- - rs.game_height
--- - rs.scale_width
--- - rs.scale_height
--- - rs.scale_mode
--- - rs.x_offset
--- - rs.y_offset
---@param debug_x number? If you pass nothing or nil, then it will same as if you pass 0.
---@param debug_y number? If you pass nothing or nil, then it will same as if you pass 0.
rs.debug_info = function(debug_x, debug_y)
  -- Set width and height for debug "window".
  local debug_width, debug_height = 215, 120

  -- Default position is top-left corner of window.
  debug_x = debug_x or 0
  debug_y = debug_y or 0
  
  -- Do sanity check for input arguments.
  if type(debug_x) ~= "number" then
    error(".debug_info: 1st argument should be number or nil. You passed: " .. type(debug_x) .. ".", 2)
  end

  if type(debug_y) ~= "number" then
    error(".debug_info: 2nd argument should be number or nil. You passed: " .. type(debug_y) .. ".", 2)
  end

  -- Save color that was used before debug function.
  local r, g, b, a = love.graphics.getColor()

  -- Save font that was used before debug function.
  local old_font = love.graphics.getFont()

  -- Draw background rectangle for text.
  love.graphics.setColor(0, 0, 0, 0.5)
  
  -- Place debug info on screen according to user input.
  love.graphics.rectangle("fill", debug_x, debug_y, debug_width, debug_height)

  -- Set color.
  love.graphics.setColor(1, 1, 1, 1)

  -- Set font.
  love.graphics.setFont(love.graphics.newFont(12))

  -- Print data.
  love.graphics.printf(
    rs._NAME .. " v." .. tostring(rs._VERSION) .. "\n" ..
    "game_width: " .. tostring(rs.game_width) .. "\n" ..
    "game_height: " .. tostring(rs.game_height) .. "\n" ..
    "scale_width: " .. tostring(rs.scale_width) .. "\n" ..
    "scale_height: " .. tostring(rs.scale_height) .. "\n" ..
    "scale_mode: " .. tostring(rs.scale_mode) .. "\n" ..
    "x_offset: " .. tostring(rs.x_offset) .. "\n" ..
    "y_offset: " .. tostring(rs.y_offset) .. "\n",
    debug_x, debug_y, debug_width)

  -- Return previous color.
  love.graphics.setColor(r, g, b, a)
  
  -- Return previous font.
  love.graphics.setFont(old_font)
end

--- This provides an alternate way to return game zone data. Individual values can be retrieved using 
--- rs.game_zone.x, rs.game_zone.y, rs.game_zone.w, rs.game_zone.h
--- 
--- **Example:**
--- ```lua
--- local x, y, w, h = rs.get_game_zone()
--- ```
--- 
---@return number game_zone.x
---@return number game_zone.y
---@return number game_zone.w
---@return number game_zone.h
rs.get_game_zone = function()
  local game_zone = rs.game_zone
  return game_zone.x, game_zone.y, game_zone.w, game_zone.h
end

--- A shortcut function that will return rs.game_width and rs.game_height. For more information, 
--- see rs.game_width and rs.game_height.
--- 
--- **Example:**
--- ```lua
--- -- Basic usage.
--- local game_width, game_height = rs.get_game_size()
--- ```
---@return number rs.game_width
---@return number rs.game_height
rs.get_game_size = function()
  return rs.game_width, rs.game_height
end

--- A function to determine if given coordinates are inside the game zone. This is useful if you 
--- develop games with mouse or touchscreen support that has controls on the screen and outside the 
--- game zone.
--- 
--- This is especially useful if you develop games with scrolling worlds or camera movements. Click 
--- the black bars should manipulate controls and not objects in the game world. When scale mode == 
--- 2, the function will always return true because there won't be any black bars.
--- 
--- **Example:**
--- ```lua
--- -- Basic usage.
--- local rs = require("resolution_solution")
--- 
--- rs.conf({
---   game_width = 640,
---   game_height = 480,
---   scale_mode = 1
--- })
--- love.graphics.setBackgroundColor(0.3, 0.5, 1)
--- rs.setMode(rs.game_width, rs.game_height, {resizable = true})
--- 
--- local game_canvas = love.graphics.newCanvas(rs.get_game_size())
--- 
--- local is_inside = false
--- 
--- love.load = function()
---   image = love.graphics.newImage("image.png")
--- end
--- 
--- love.resize = function()
---   rs.resize()
--- end
--- 
--- love.update = function()
---   is_inside = rs.is_it_inside(love.mouse.getPosition())
--- end
--- 
--- love.draw = function()
---   love.graphics.setCanvas(game_canvas)
---   love.graphics.clear(0, 0, 0, 1)
---
---   if is_inside then
---     love.graphics.setColor(0, 1, 0, 1)
---     love.graphics.print("Cursor inside game zone.", rs.game_width / 2, 
---     rs.game_height / 2)
---   else
---    love.graphics.setColor(1, 0, 0, 1)
---     love.graphics.print("Cursor outside game zone.", rs.game_width / 2, 
---     rs.game_height / 2)
---   end
---
---   love.graphics.setColor(1, 1, 1, 1)
---   love.graphics.setCanvas()
---
---   rs.push()
---     ove.graphics.draw(game_canvas)
---   rs.pop()
--- end
--- ```
---@param it_x number
---@param it_y number
rs.is_it_inside = function(it_x, it_y)
  -- Input sanitizing.
  if type(it_x) ~= "number" then
    error(".is_it_inside: Argument #1 should be number. You passed: " .. type(it_x) .. ".", 2)
  end
  
  if type(it_y) ~= "number" then
    error(".is_it_inside: Argument #2 should be number. You passed: " .. type(it_y) .. ".", 2)
  end
  
  -- If we in Stretch or No Scaling mode - then we always inside.
  if rs.scale_mode == rs.STRETCH_MODE or rs.scale_mode == rs.NO_SCALING_MODE then
    return true
  end
  
  local x, y, w, h = rs.game_zone.x, rs.game_zone.y, rs.game_zone.w, rs.game_zone.h

  -- Check if it inside game zone.
  if it_x    >= x                 and -- left
     it_y    >= y                 and -- top
     it_x    <= x + w             and -- right
     it_y    <= y + h            then -- bottom
      -- It inside game zone.
     return true
  end

  -- It outside of game zone.
  return false
end

--- A shortcut function that returns rs.scale_width and rs.scale_height.
--- 
--- **Example:**
--- ```lua
--- -- Basic usage.
--- local x_scale, y_scale = rs.get_both_scales()
--- ```
---@return number rs.scale_width
---@return number rs.scale_height
rs.get_both_scales = function()
  return rs.scale_width, rs.scale_height
end

--- A function to translate coordinates from the window to the game zone. This can be used to 
--- translate cursor coordinates so you can check collisions with objects inside the game zone.
--- 
--- **Example:**
--- ```lua
--- local rs = require("resolution_solution")
--- rs.conf({
---   game_width = 640,
---   game_height = 480,
---   scale_mode = 1
--- })
--- love.graphics.setBackgroundColor(0.3, 0.5, 1)
--- rs.setMode(rs.game_width, rs.game_height, {resizable = true})
--- 
--- local game_canvas = love.graphics.newCanvas(rs.get_game_size())
--- 
--- local is_touching = false
--- local rectangle = {x = 200, y = 200, w = 100, h = 100}
--- 
--- love.resize = function()
---   rs.resize()
--- end
--- 
--- love.update = function()
---   -- Get cursor position.
---   local mx, my = love.mouse.getPosition()
---
---   -- Translate it to game.
---   mx, my = rs.to_game(mx, my)
---   if mx >= rectangle.x and -- left
---   my >= rectangle.y and -- top
---   mx <= rectangle.x + rectangle.w and -- right
---   my <= rectangle.y + rectangle.h then -- bottom
---     is_touching = true
---   else
---     is_touching = false
---   end
--- end
--- ```
---@param x number
---@param y number
---@return number|nil ScaledGameX
---@return number|nil ScaledGameY
rs.to_game = function(x, y)
  -- User passed only x.
  if type(x) == "number" and type(y) == "nil" then
    return (x - rs.x_offset) / rs.scale_width

  -- User passed only y.
  elseif type(x) == "nil" and type(y) == "number" then
    return (y - rs.y_offset) / rs.scale_height

  -- User passed both X and Y.
  elseif type(x) == "number" and type(y) == "number" then
    return (x - rs.x_offset) / rs.scale_width, (y - rs.y_offset) / rs.scale_height

  -- User passed wrong arguments.
  else
    error(".to_game: At least 1 argument should be number. You passed: " .. type(x) .. " and " .. type(y), 2)
  end
end

--- A function similar to rs.to_game but reversed. It translates coordinates from the game world to 
--- the window. For example, when you want to move the cursor to an object inside the game zone.
--- 
--- **Example:**
--- ```lua
--- -- Basic example.
--- -- Press left button of mouse to teleport cursor to center or rectangle that you can see in center of window.
--- -- Note: might not work if you use Linux with Wayland.
--- local rs = require("resolution_solution")
--- rs.conf({
---    game_width = 640,
---    game_height = 480,
---    scale_mode = 1
--- })
--- love.graphics.setBackgroundColor(0.3, 0.5, 1)
--- rs.setMode(rs.game_width, rs.game_height, {resizable = true})
--- 
--- local game_canvas = love.graphics.newCanvas(rs.get_game_size())
--- 
--- love.resize = function()
---   rs.resize()
--- end
--- 
--- love.mousepressed = function(x, y, button)
---   if button == 1 then
---     love.mouse.setPosition(
---       rs.toScreen(
---         (rs.game_width / 2), -- Translate X.
---         (rs.game_height / 2) -- Translate y.
---       )
---     )
---   end
--- end
--- 
--- love.draw = function()
---   love.graphics.setCanvas(game_canvas)
---   love.graphics.clear(0, 0, 0, 1)
---   love.graphics.setColor(1, 1, 1, 1)
---   -- Place 100x100 rectangle in center of game zone.
---   love.graphics.rectangle("line", (rs.game_width / 2) - 50, (rs.game_height / 
--- 2) - 50, 100, 100)
---   love.graphics.rectangle("line", (rs.game_width / 2) - 4, (rs.game_height / 
--- 2) - 4, 4, 4)
---   love.graphics.setCanvas()
---  
---   rs.push()
---     love.graphics.draw(game_canvas)
---   rs.pop()
--- end
--- ```
---@param x number
---@param y number
---@return number|nil ScaledWindowX
---@return number|nil ScaledWindowY
rs.to_window = function(x, y)
  -- User passed only X.
  if type(x) == "number" and type(y) == "nil" then
    return (x * rs.scale_width) + rs.x_offset
  
  -- User passed only Y.
  elseif type(x) == "nil" and type(y) == "number" then
    return (y * rs.scale_height) + rs.y_offset
  
  -- User passed both X and Y.
  elseif type(x) == "number" and type(y) == "number" then
    return (x * rs.scale_width) + rs.x_offset, (y * rs.scale_height) + rs.y_offset

  -- User passed wrong arguments.
  else
    error(".to_window: At least 1 argument should be number. You passed: " .. type(x) .. " and " .. type(y), 2)
  end
end

----------------------------------------------------------------------
--                        love wrappers                             --
----------------------------------------------------------------------

--- This function is a wrapper for love.window.setMode() that should be used with this library. See 
--- the Love2d wiki page for information about love.window.setMode():
--- https://love2d.org/wiki/love.window.setMode
--- 
--- **For advanced users:**
--- ```lua
--- -- This wrapper function equivalent of doing this:
--- love.window.setMode(width, height, flags)
--- rs.resize()
--- ```
--- 
--- **Example:**
--- ```lua
--- -- Basic usage.
--- rs = require("resolution_solution")
--- rs.conf({game_width = 800, game_height = 600, scale_mode = 3})
--- rs.setMode(rs.get_game_size(), select(3, love.window.getMode()))
-- -- Done, now we initialized game with 800x600 game size and resized window to be same as game width and height.
--- ```
---@param width number
---@param height number
---@param flags table
rs.setMode = function(width, height, flags)
  -- Wrapper for love.window.setMode()

  local okay, errorMessage = pcall(love.window.setMode, width, height, flags)
  if not okay then
    error(".setMode: Error: " .. errorMessage, 2)
  end
  
  rs.resize()
end

--- This function is a wrapper for love.window.updateMode() that should be used with this library. 
--- See the Love2d wiki page for information about love.window.updateMode(): https://love2d.org/wiki/love.window.updateMode
--- 
--- **For advanced users:**
--- ```lua
--- -- This wrapper function equivalent of doing this:
--- love.window.updateMode(width, height, flags)
--- rs.resize()
--- ```
--- 
--- **Example:**
--- ```lua
--- -- Basic usage.
--- rs = require("resolution_solution")
--- rs.conf({
---          game_width = 800,
---          game_height = 600,
---          scale_mode = 3})
--- -- We want to create game with 800x600 resolution
--- -- But we also want to change window size to be same as game.
--- -- To achieve this, we can do...
--- rs.updateMode(rs.get_game_size())
--- -- Done, now we initialized game with 800x600 game size and resized window to 
--- be same as game width and height.
--- ```
---@param width number
---@param height number
---@param flags table
rs.updateMode = function(width, height, flags)
  -- Wrapper for love.window.updateMode()
  
  local okay, errorMessage = pcall(love.window.updateMode, width, height, flags)
  if not okay then
    error(".updateMode: Error: " .. errorMessage, 2)
  end
  
  rs.resize()
end

return rs