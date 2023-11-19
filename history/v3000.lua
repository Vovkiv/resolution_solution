local rs = {
  _URL = "https://github.com/Vovkiv/resolution_solution",
  _DOCUMENTATION = "",
  _VERSION = 3000,
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
rs.scale_mode = 1

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

rs.conf = function(options)
  if type(options) ~= "table" then
    error("configure should be table.", 2)
  end
  
  if options.game_width then
    if type(options.game_width) ~= "number" then error("game_width should be number. You passed: " .. type(options.game_width) .. ".", 2) end
    if options.game_width < 0 then error("game_width should be 0 or more. You passed: " .. tostring(options.game_width) .. ".", 2) end
    rs.game_width = options.game_width
  end
  
  if options.game_height then
    if type(options.game_height) ~= "number" then error("game_height should be number. You passed: " .. type(options.game_height) .. ".", 2) end
    if options.game_height < 0 then error("game_height should be 0 or more. You passed: " .. tostring(options.game_height) .. ".", 2) end
    rs.game_height = options.game_height
  end
  
  if options.scale_mode then
    if type(options.scale_mode) ~= "number" then error("scale_mode should be number.", 2) end
    if options.scale_mode > 3 or options.scale_mode < 1 then error("scale_mode can be only 1, 2 and 3. You passed: " .. tostring(options.scale_mode) .. ".") end
    rs.scale_mode = options.scale_mode
  end
  
  rs.resize()
end

rs.push = function()
  -- Prepare to scale.
  love.graphics.push()
  
  -- Reset transformation.
  love.graphics.origin()

  -- Set offset.
  love.graphics.translate(rs.x_offset, rs.y_offset)
  
  -- Scale.
  love.graphics.scale(rs.scale_width, rs.scale_height)
end

rs.pop = function()
  -- Stop scaling.
  love.graphics.pop()
end

rs.resize = function()
  local window_width, window_height = love.graphics.getWidth(), love.graphics.getHeight()

  -- Scale for game virtual size.
  local scale_width, scale_height = 0, 0
  
  -- Offsets.
  local x_offset, y_offset = 0, 0

  -- Virtual game size.
  local game_width, game_height = rs.game_width, rs.game_height
  
  -- Scale mode.
  local scale_mode = rs.scale_mode
  
  -- If we in stretch scaling mode.
  if scale_mode == 2 then
    -- We only need to update width and height scale.
    scale_width = window_width / game_width
    scale_height = window_height / game_height
  
  -- Other scaling modes.
  else

  -- Other scaling methods need to determine scale, based on window and game aspect.
    local scale = math.min(window_width / game_width, window_height / game_height)

    -- Pixel perfect scaling.
    if scale_mode == 3 then
      -- We will floor to nearest int number.
      -- And we fallback to scale 1, if game size is less then window, because when scale == 0, there nothing to see.
      scale = math.max(math.floor(scale), 1)
    end

    -- Update offsets.
    x_offset, y_offset = (window_width - (scale * game_width)) / 2, (window_height - (scale * game_height)) / 2
    -- Update scaling values.
    scale_width, scale_height = scale, scale
  end
  
  -- Save values to library --
  
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

rs.resize_callback = function() end
rs.debug_info = function(debugX, debugY)
  -- Function used to render debug info on-screen.

  -- Set width and height for debug "window".
  local debugWidth = 215
  local debugHeight = 120

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
    "game_width: " .. tostring(rs.game_width) .. "\n" ..
    "game_height: " .. tostring(rs.game_height) .. "\n" ..
    "scale_width: " .. tostring(rs.scale_width) .. "\n" ..
    "scale_height: " .. tostring(rs.scale_height) .. "\n" ..
    "scale_mode: " .. tostring(rs.scale_mode) .. "\n" ..
    "x_offset: " .. tostring(rs.x_offset) .. "\n" ..
    "y_offset: " .. tostring(rs.y_offset) .. "\n",
    debugX, debugY, debugWidth)

  -- Return colors.
  love.graphics.setColor(r, g, b, a)
  
  -- Return font.
  love.graphics.setFont(oldFont)
end
rs.get_game_zone = function()
  local game_zone = rs.game_zone
  return game_zone.x, game_zone.y, game_zone.w, game_zone.h
end

rs.get_game_size = function()
  return rs.game_width, rs.game_height
end

rs.is_it_inside = function(it_x, it_y)
  -- Input sanitizing.
  if type(it_x) ~= "number" then
    error(".is_it_inside: Argument #1 should be number. You passed: " .. type(it_x) .. ".", 2)
  end
  
  if type(it_y) ~= "number" then
    error(".is_it_inside: Argument #2 should be number. You passed: " .. type(it_y) .. ".", 2)
  end
  
  -- If we in Stretch Scaling mode we always "inside".
  if rs.scaleMode == 2 then
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

rs.get_both_scales = function()
  -- Get both width and height scale.
  
  return rs.scale_width, rs.scale_height
end

rs.to_game = function(x, y)
  -- User passed only X.
  if type(x) == "number" and type(y) == "nil" then
    return (x - rs.x_offset) / rs.scale_width
  
  -- User passed only Y.
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

rs.setMode = function(width, height, flags)
  -- Wrapper for love.window.setMode()

  local okay, errorMessage = pcall(love.window.setMode, width, height, flags)
  if not okay then
    error(".setMode: Error: " .. errorMessage, 2)
  end
  
  rs.resize()
end

rs.updateMode = function(width, height, flags)
  -- Wrapper for love.window.updateMode()
  
  local okay, errorMessage = pcall(love.window.updateMode, width, height, flags)
  if not okay then
    error(".updateMode: Error: " .. errorMessage, 2)
  end
  
  rs.resize()
end

return rs