local rs = require("resolution_solution")
-- Function to configure library.
-- Here we configured library to scale 640x480 game to fill window,
-- using pixel pefrect scaling mode.
rs.conf({
  game_width = 640,
  game_height = 480,
  scale_mode = rs.PIXEL_PERFECT_MODE
  })

-- Must-have for pixel-art graphics.
love.graphics.setDefaultFilter("nearest", "nearest")

-- Set background color.
love.graphics.setBackgroundColor(0, 0.4, 0.6, 1)

-- I strongly suggest you to always make window resizable.
-- Also here we changed window size to match game size.
rs.setMode(rs.game_width, rs.game_height, {resizable = true})

-- Show library name and version in title.
love.window.setTitle(tostring(rs._NAME .. " v." .. rs._VERSION))

-- Example of scaling ui elements.
local rectangle2 = {}
-- Example rectangle, that demonstrate how you can implement, for example, mouse collision detection.
local rectangle1 = {
  x = 100,
  y = 100,
  w = 100,
  h = 100,
  click = 0
}

-- Image for background.
local image = love.graphics.newImage("image.png")
-- Show frame around game zone.
local show_game_zone = false
-- We will use this as example for scaling fonts for maximum crispiness!
local font

-- Place rs.resize() in love.resize() to update library everytime when window was resized.
love.resize = function(w, h)
  rs.resize(w, h)
end

-- Function will be called every time when rs.resize() was called.
-- Useful for updating UI.
rs.resize_callback = function()
  -- Place rectangle in center of game zone.
  rectangle2 = {
    x = rs.game_zone.x + rs.game_zone.w / 2,
    y = rs.game_zone.y + rs.game_zone.h / 2,
    w = rs.game_zone.w * 0.25,
    h = rs.game_zone.h * 0.25,
  }
  -- Note: this scaling example not going to work with Stretch Scaling (2), so for that mode you need to come up with something better.
  font = love.graphics.newFont(math.min(rs.game_zone.w * 0.04, rs.game_zone.h * 0.04))
end
-- Call this immediately to initilize data. 
rs.resize_callback()

-- Change options with keyborad
-- F1-F3 to change scale mode.
-- F4 to hide/show frame around game zone.
love.keypressed = function(key)
  if key == "f1" then
    rs.conf({scale_mode = rs.ASPECT_MODE})
  elseif key == "f2" then
    rs.conf({scale_mode = rs.STRETCH_MODE})
  elseif key == "f3" then
    rs.conf({scale_mode = rs.PIXEL_PERFECT_MODE})
  elseif key == "f4" then
    rs.conf({scale_mode = rs.NO_SCALING_MODE})
  elseif key == "f5" then
      show_game_zone = not show_game_zone
  end
end

-- Example of how you can implement mouse collision detection function.
local mouse_func = function(x, y, w, h)

  -- Translate mouse to game coordinates.
  local mx, my = rs.to_game(love.mouse.getPosition())
  
  -- Check if cursor inside given coordinates.
  if mx  >= x                 and -- left
     my    >= y                 and -- top
     mx    <= x         +    w  and -- right
     my    <= y         +    h  then -- bottom
    
    -- Cursor inside.
     return true
    end

    -- Cursor outside.
    return false
end

love.mousepressed = function(x, y, button, istouch, presses)
    -- Add 1 to counter if clicked.
    if rs.is_it_inside(love.mouse.getPosition()) and mouse_func(rectangle1.x, rectangle1.y, rectangle1.w, rectangle1.h) and button == 1 then
      rectangle1.click = rectangle1.click + 1
    end

    -- Example of how to translate game coordinates to window coordinates.
    -- Teleports cursor to rectangle when right mouse button clicked.
    if button == 2 then
      love.mouse.setPosition(rs.to_window(rectangle1.x, rectangle1.y))
    end

    -- Move rectangle to cursor if you click middle mouse button.
    if button == 3 then
      rectangle1.x, rectangle1.y = rs.to_game(love.mouse.getPosition())
    end
end

love.draw = function()
  -- Start scaling
  rs.push()
    -- Example of hiding game content via scissors. Read manual to see how to implement htis using canvas.
    -- Get scissors that were before.
    local old_x, old_y, old_w, old_h = love.graphics.getScissor()
    -- Scissor game to game zone.
    love.graphics.setScissor(rs.get_game_zone())
    -- Draw Brian.
    love.graphics.draw(image)
    
    -- Change rectangle color if we touch it.
    if rs.is_it_inside(love.mouse.getPosition()) and mouse_func(rectangle1.x, rectangle1.y, rectangle1.w, rectangle1.h) then
      love.graphics.setColor(1, 0.5, 0.5, 1)
    else
      love.graphics.setColor(0.5, 0.5, 0.5, 1)
    end

    -- Draw UI rectangle.
    love.graphics.rectangle("fill", rectangle1.x, rectangle1.y, rectangle1.w, rectangle1.h)

    -- Show counter and explanation.
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Click on me! " ..
    tostring(rectangle1.click) .. 
    "\nYou can't click on me, if I behind\nbars, because library\ncan take care of this!",
    rectangle1.x, rectangle1.y)
  
  -- Return old scissor to avoid visual garbage.
  love.graphics.setScissor(old_x, old_y, old_w, old_h)
  -- Stop scaling.
  rs.pop()

  love.graphics.setColor(1, 1, 1, 1)
  
  -- Draw rectangle with custom scaling.
  -- Get font that was before.
  local old_font = love.graphics.getFont()
  
  -- Draw UI rectangle.
  love.graphics.rectangle("line", rectangle2.x, rectangle2.y, rectangle2.w, rectangle2.h)
  -- Set font that we calculated back at rs.resize_callback()
  love.graphics.setFont(font)
  -- Draw text with custom drawing.
  love.graphics.print("Hello!", rectangle2.x, rectangle2.y)
  -- Return old font.
  love.graphics.setFont(old_font)
  
  -- Another example of how you can use rs.game_zone
  -- Draw frame around game zone.
  if show_game_zone then
    love.graphics.rectangle("line", rs.get_game_zone())
  end

  -- Instructions.
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print([[
Try to change window size and click on grey rectangle.
Press F1-4 to change scale mode.
Press F5 to show/hide game zone borders.
Press right mouse button to teleport cursor to rectangle (Might not work under Wayland).
Press middle mouse to move rectangle under cursor.
String with "Hello" show that you can scale UI elements that will always will look crispy.
(Note, that font scaling in example doesn't work properly on scale mode 2.)
]], 0, love.graphics.getHeight() - 100)

  -- Show debug info.
  rs.debug_info()
end
