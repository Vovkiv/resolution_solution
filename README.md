# Resolution Solution - v3000 testing branch
Yet another scaling library.

"Resolution Solution" was inspired by:
* TLfres (https://love2d.org/wiki/TLfres)
* PUSH (https://github.com/Ulydev/push)
* maid64 (https://github.com/adekto/maid64) libraries.

# Announces
I will post announces when new update will be dropped here.
https://love2d.org/forums/viewtopic.php?t=92494

# Selling point of this library:
* Library have 3 scale modes and you can switch between at any time:

1 Aspect Scaling mode - scaling with preverved aspect.

2 Stretching - stretch game to fill entire window.

3 Pixel Perfect - will scale, using only integer scale factors and adds black bars if it can't. Must-have for pixel-art.

* Library doesn't force you to use any specific way to scale your content, unlike some libraries. You can choose canvases, scissor, draw rectangles on top of game, shaders... whatever you want!
* Library written according to kikito's guide: https://web.archive.org/web/20190406163041/http://kiki.to/blog/2014/03/30/a-guide-to-authoring-lua-modules/, which resulted in very monkey-patchable library! No unreachable locals, no globals, nothing like that! Everything that library produces during calculations can be reached by simple accessing library table: rs.game_width, rs.scale_mode, rs.game_zone.x, etc.
* Comes with .PDF manual, that includes some illustrations and examples. Includes "Tips and Tricks" chapter where you could found interesting code snippets for you game related to this scaling library (more snippets will come out later).
* Written with shake_case.
* Actively miantained (kind of, especially compared to other scaling libraries)

# Video demonstration:
https://youtu.be/cslfWOpetrc

# Basic setup:
1 drop library into your main.lua:

``` local rs = require("resolution_solution") ```

2 Configure it:

``` rs.conf({game_width = 640, game_height = 480, scale_mode = 3}) ```

Make window resizable:

``` rs.setMode(rs.game_width, rs.game_height, {resizable = true}) ```

3 Update library:
 ```
love.resize = function(w, h)
   rs.resize()
end
``` 
4 Draw something! (In this example we used scissors, but there another ways to achieve this. Read manual for more info.)
```
love.draw = function()
  rs.push()
    local old_x, old_y, old_w, old_h = love.graphics.getScissor()
    love.graphics.setScissor(rs.get_game_zone())
    love.graphics.setColor(1, 1, 1)
    
    love.graphics.print("Hello, world!", rs.game_width / 2, rs.game_height / 2)
    
    love.graphics.setScissor(old_x, old_y, old_w, old_h)
  rs.pop()
end
```

You can also check this demo for more examples of library usage: https://github.com/Vovkiv/resolution_solution/blob/main/demo.love
