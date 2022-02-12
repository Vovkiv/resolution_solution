-- How to setup API:
--[[
(Go to https://studio.zerobrane.com/doc-api-auto-complete, for additional info)

(Since this library designed for love2d, we will add it for love2d auto-completion)
There 2 ways to add this API:
1. Go to your user.lua or system.lua and add to it:
api = {
  love2d = {"RS_ZBS_API"}
}
And place RS_ZBS_API.lua file in Zerobrane studio folder:
"path"/"to"/zbstudio/api/lua/

(On my linux system that is:
/opt/zbstudio/api/lua/)
And restart Zerobrane and you done!

2. Open your Zerobrane's folder:
/"path"/"to"/zbstudio/interpreters/
open love2d.lua
find "api" variable and edit it:
api = {"baselib", "love2d"}, --> api = {"baselib", "love2d", "RS_ZBS_API"},

Restart Zerobrane Studio and you done!
(Difference with 1st and 2nd method is, if Zerobrane will get update, then, probably, love2d.lua will be rewrited, while your config file will note)
--]]

-- Special notes:

--[[
1. If you already have project, where you dropped this library with different name, e.g:
local res = require("resolution_solution")
and auto-completion don't work

That's because auto-completion was coded for "rs" name
You can either rename all lib's variable to "rs" or...
find in this file (RS_ZBS_API.lua):
"rs = {" and change it to something else
Restart Zerobrane Studio and now it will work for different name!

--]]
return {
  rs = {
    _URL = "https://github.com/Vovkiv/resolution_solution",
    _DESCRIPTION = "Resolution Solution auto-completion API for Zerobrane Studio",
    _NAME = "Resolution Solution ZBS API",
    -- Version of api
    _VERSION = 1000,
    --Library version that API cover
    _LIB_VERSION = 1003,
    -- Zerobrane studio version on which API was tested on
    _ZBS_VERSION = "1.90",
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
]],

  type = "lib",
  description = "Scale library, that help you add resolution support to your games in love2d!",
  childs = {
    windowChanged = {
      type = "function",
      args = "()",
      returns = "()",
      description = "Callback functions, that will be triggered when window size is changed.",
    },
    gameChanged = {
      type = "function",
      args = "()",
      returns = "()",
      description = "Callback functions, that will be triggered when game virtual size is changed.",
    },
    scaleMode = {
      type = "value",
      description = "(number)\n1 aspect scaling (default; scale game with black bars on top-bottom or left-right)\n2 stretched scaling mode (scale virtual resolution to fill entire window; may be harmful for pixel art)",
    },
    drawBars = {
      type = "value",
      description = "(boolean)\nTrue (default) - render black bars.\nFalse - don't render black bars.",
    },
    widthScale = {
      type = "value",
      description = "(number)\nScale width value, use that for scaling related math\n(if rs.scaleMode == 1, rs.widthScale and rs.heightScale is eqial).",
    },
    heightScale = {
      type = "value",
      description = "(number)\nScale height value, use that for scaling related math\n(if rs.scaleMode == 1, rs.widthScale and rs.heightScale is eqial)"
    },
    gameWidth = {
      type = "value",
      description = "(number)\nVirtual width for game, that library will scale to"
      },
    gameHeight = {
      type = "value",
      description = "(number)\nVirtual height for game, that library will scale to"
      },
    windowWidth = {
      type = "value",
      description = "(number)\nWindow width"
      },
    windowHeight = {
      type = "value",
      description = "(number)\nWindow height"
      },
    gameAspect = {
      type = "value",
      description = "(number)\nAspect for virtual game size"
      },
    windowAspect = {
      type = "value",
      description = "(number)\nAspect for window size"
      },
    xOff = {
      type = "value",
      description = "(number)\nWidth offset, caused by black bars\nThere will be 2 black bars on each side, so take into account that"
      },
    yOff = {
      type = "value",
      description = "(number)\nHeight offset, caused by black bars\nThere will be 2 black bars on each side, so take into account that"
      },
    x1 = {
      type = "value",
      description = "(number)\nX coordinate of 1st bar."
      },
    y1 = {
      type = "value",
      description = "(number)\nY coordinate of 1st bar."
      },
    w1 = {
      type = "value",
      description = "(number)\nWidth for 1st bar."
    },
    h1 = {
      type = "value",
      description = "(number)\nHeight for 1st bar."
      },
    x2 = {
      type = "value",
      description = "(number)\nX coordinate of 2nd bar."
      },
    y2 = {
      type = "value",
      description = "(number)\nY coordinate of 2nd bar."
      },
    w2 = {
      type = "value",
      description = "(number)\nWidth for 2nd bar."
      },
    h2 = {
      type = "value",
      description = "(number)\nHeight for 2nd bar."
      },
    r = {
      type = "value",
      description = "(number)\nRed color of black bars."
      },
    g = {
      type = "value",
      description = "(number)\nGreen color of black bars."
      },
    b = {
      type = "value",
      description = "(number)\nBlue color of black bars."
      },
    a = {
      type = "value",
      description = "(number)\nAlpha of black bars."
    },  
    update = {
      type = "function",
      args = "()",
      returns = "()",
      description = "Function to update library values.\nPlace it in love.update."
    },
    start = {
    type = "function",
      args = "()",
      returns = "()",
      description = "Start scaling graphics until rs.stop().\nEverything inside this function will be scaled to fit virtual game size"
    },
    stop = {
      type = "function",
      args = "()",
      returns = "()",
      description = "Stop scaling caused by rs.start() and draw black bars, if needed."
      },  
    unscaleStart = {
      type = "function",
      args = "()",
      returns = "()",
      description = "Reset scaling with love.origin() until rs.unscaleStop().\nWith that you can, for example, draw ui with custom scaling."
      },
    unscaleStop = {
      type = "function",
      args = "()",
      returns = "()",
      description = "Stop scaling caused by rs.unscaleStart().\nWith that you can, for example, draw ui with custom scaling."
    },
    setColor = {
      type = "function",
      args = "(red: number, green: number, blue: number, alpha: number)",
      returns = "()",
      description = "Set color of black bars.",
    },
    getColor = {
      type = "function",
      args = "()",
      returns = "(red: number, green: number, blue: number, alpha: number)",
      description = "Get red, green, blue and alpha colors of black bars.",
      },
    defaultColor = {
      type = "function",
      args = "()",
      returns = "()",
      description = "Reset colors for black bars to default black opague color.",
      },
    getScale = {
      type = "function",
      args = "()",
      returns = "(scale by width: number, scale by height: number)",
      returns = "(scale by width: number, scale by height: number)",
      description = "Get scale by width and height",
      },
    switchScaleMode = {
      type = "function",
      args = "()",
      returns = "()",
      description = "Function to switch in-between scale modes.",
      },
    setGame = {
      type = "function",
      args = "(width: number, height: number)",
      returns = "()",
      description = "Set virtual size which game should be scaled to.\n(Note: this function doesn't do any validation for incoming arguments)"
      },
    getGame = {
      type = "function",
      args = "()",
      returns = "(width: number, height: number)",
      description = "Return game virtual width and height.",
      },
    getWindow = {
      type = "function",
      args = "()",
      returns = "(width: number, height: number)",
      description = "Get window width and height.",
      },
    switchDrawBars = {
      type = "function",
      args = "()",
      returns = "()",
      description = "Turn of/off rendering for black bars.",
      },
    isMouseInside = {
      type = "function",
      args = "()",
      returns = "(is inside?: boolean)",
      description = "Determine if cursor inside scaled area and don't touch black bars.\nUse it when you need detect if cursor touch in-game objects, without false detection on black bars zone",
      },
    toGame = {
      type = "function",
      args = "(x: number, y: number)",
      returns = "(scaled x: number, scaled y: number)",
      description = "Translate coordinates from non-scaled values to scaled.\ne.g translate real mouse coordinates into scaled so you can check\nfor example, area to check collisions with object and cursor.",
      },
    toGameX = {
      type = "function",
      args = "(x: number)",
      returns = "(scaled x: number)",
      description = "Translate x coordinate from non-scaled to scaled.\ne.g translate real mouse coordinates into scaled so you can check\nfor example, area to check collisions with object and cursor.",
      },
    toGameY = {
      type = "function",
      args = "(y: number)",
      returns = "(scaled y: number)",
      description = "Translate y coordinate from non-scaled to scaled.\ne.g translate real mouse coordinates into scaled so you can check\nfor example, area to check collisions with object and cursor.",
      },
    toScreen = {
      type = "function",
      args = "(scaled x: number, y: number)",
      returns = "(x: number, y: number)",
      description = "Thanslate coordinates from scaled to non scaled.\ne.g translate x and y of object inside scaled area\nto, for example, set cursor position to that object.",
      },
    toScreenX = {
      type = "function",
      args = "(scaled x: number)",
      returns = "(x: number)",
      description = "Thanslate x coordinate from scaled to non scaled.\ne.g translate x of object inside scaled area\nto, for example, set cursor position to that object.",
      },
    toScreenY = {
      type = "function",
      args = "(scaled y: number)",
      returns = "(y: number)",
      description = "Thanslate y coordinate from scaled to non scaled.\ne.g translate y of object inside scaled area\nto, for example, set cursor position to that object.",
      },
    },
  },
}

-- Test:
--[[
local rs = require("resolution_solution")
rs.windowChanged = function() end
rs.gameChanged = function() end
rs.scaleMode = 1
rs.drawBars = true
rs.widthScale = 0
rs.heightScale = 0
rs.gameWidth = 800
rs.gameHeight = 600
rs.windowWidth = 800
rs.windowHeight = 600
rs.gameAspect = 1
rs.windowAspect = 1
rs.xOff = 0
rs.yOff = 0
rs.x1, rs.y1, rs.w1, rs.h1 = 0, 0, 0, 0
rs.x2, rs.y2, rs.w2, rs.h2 = 0, 0, 0, 0
rs.r, rs.g, rs.b, rs.a = 0, 0, 0, 1
rs.update = function() end
rs.start = function() end
rs.stop = function() end
rs.unscaleStart = function() end
rs.unscaleStop = function() end
rs.setColor = function(r, g, b, a) end
rs.getColor = function() end
rs.defaultColor = function() end
rs.getScale = function() end
rs.switchScaleMode = function() end
rs.setGame = function(width, height) end
rs.getGame = function() end
rs.getWindow = function() end
rs.switchDrawBars = function() end
rs.isMouseInside = function() end
rs.toGame = function(x, y) end
rs.toGameX = function(x) end
rs.toGameY = function(y) end
rs.toScreen = function(x, y) end
rs.toScreenX = function(x) end
rs.toScreenY = function(y) end
--]]

-- Changelog:
--[[
Version 1000, 12 february 2022
Library version 1003
Zerobrane Studio version 1.90

Initial release
--]]
