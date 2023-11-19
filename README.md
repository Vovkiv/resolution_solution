
# Resolution Solution

Yet another scaling library.

---

Resolution Solution was inspired by:

* [TLfres](https://love2d.org/wiki/TLfres)
* [PUSH](https://github.com/Ulydev/push)
* [SimpleScale](https://github.com/tomlum/simpleScale)

Other similar libraries:

* [Center](https://github.com/S-Walrus/center)
* [maid64](https://github.com/adekto/maid64)

# Video demonstration:

[![](https://markdown-videos-api.jorgenkh.no/youtube/cslfWOpetrc)](https://youtu.be/cslfWOpetrc)

# Basic setup:
1. Drop library into your `main.lua`:

```lua
local rs = require("resolution_solution")
```

2. Configure it:

```lua
rs.conf({game_width = 640, game_height = 480, scale_mode = 3})
```

3. Make window resizable:

```lua
rs.setMode(rs.game_width, rs.game_height, {resizable = true})
```

4. Update it:
 ```lua
love.resize = function(w, h)
   rs.resize()
end
``` 
5. Draw something:

(In this example we used scissors, but there another ways to achieve this. Read manual or check examples for more info.)
```lua
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

# Manual, examples, demo
* [.pdf manual](resolution_solution_documentation.pdf).
* [.odt manual](resolution_solution_documentation.odt).
* [.love demo example that you can run](demo.love).
* [examples folder](examples).

# Selling points of this library:
* Library have 3 scale modes and you can switch between at any time:
  1. Aspect Scaling mode - scaling with preserved aspect.
  2. Stretching - stretch game to fill entire window.
  3. Pixel Perfect - will scale, using only integer scale factors and adds black bars if it can't. Must-have for pixel-art.

* Library doesn't force you to use any specific way to scale your content, unlike some libraries. You can choose canvases, scissor, draw rectangles on top of game, shaders... whatever you want!
* Library written according to [kikito's guide](https://web.archive.org/web/20190406163041/http://kiki.to/blog/2014/03/30/a-guide-to-authoring-lua-modules/), which resulted in very monkey-patchable library! No unreachable locals, no globals, nothing like that! Everything that library produces during calculations can be reached by simple accessing library table: `rs.game_width`, `rs.scale_mode`, `rs.game_zone.x`, etc.
* Comes with .PDF manual, that includes some illustrations and examples. Includes "Tips and Tricks" chapter where you could found interesting code snippets for you game related to this scaling library (more snippets will come out later). Sadly, most libraries that I used as inspiration doesn't comes with manuals, or at least good ones.
* Written with `snake_case`.
* Licensed under `Unlicense license`. Do whatever you want with it.

# Games made using this library
By togfoxy:

* [Autarky2](https://github.com/togfoxy/Autarky2)
* [SpaceFleetBattles](https://github.com/togfoxy/SpaceFleetBattles)
* [FormulaSpeed](https://github.com/togfoxy/FormulaSpeed)
* [Silent strike](https://codeberg.org/togfox/SilentStrike)

By [Gunroar](https://hmmmgames.itch.io/):

* [YOU ARE DRAGON](https://hmmmgames.itch.io/dragon)
* [Rem Psycho](https://hmmmgames.itch.io/rem-psyche)
* [Dust: Battle Beneath](https://hmmmgames.itch.io/dust-bb)

# Announces
I will post announces when new update will be dropped [here](https://love2d.org/forums/viewtopic.php?t=92494).

# Contacts
If you have any questions about this library, have ideas, etc, you can contact me via:

1. [You can create new issue](https://github.com/Vovkiv/resolution_solution/issues/new)
2. [love forum](https://love2d.org/forums/memberlist.php?mode=viewprofile&u=169762)
3. [matrix](https://matrix.to/#/@vovkiv:matrix.org)
4. Email - volkovissocool@gmail.com
