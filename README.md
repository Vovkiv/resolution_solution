
# Resolution Solution

Yet another scaling library. Currently in maintenance-only mode.

---

Resolution Solution was inspired by:

* [TLfres](https://love2d.org/wiki/TLfres)
* [PUSH](https://github.com/Ulydev/push)
* [SimpleScale](https://github.com/tomlum/simpleScale)

Other similar scaling libraries that you might want to look into:

* [Center](https://github.com/S-Walrus/center)
* [maid64](https://github.com/adekto/maid64)
* [love2d-pixelscale](https://github.com/DimitriBarronmore/love2d-pixelscale)
* [CScreen](https://github.com/CodeNMore/CScreen)
* [terebi](https://github.com/oniietzschan/terebi)
* [FSAL](https://sourceforge.net/projects/fsal/)
* [gb-screen](https://github.com/darkfrei/gb-screen)

# Video demonstration

[![](https://markdown-videos-api.jorgenkh.no/youtube/cslfWOpetrc)](https://youtu.be/cslfWOpetrc)

# Basic setup
1. Require library:

```lua
local rs = require("resolution_solution")
```

2. Configure library:

```lua
rs.conf({game_width = 640, game_height = 480, scale_mode = rs.PIXEL_PERFECT_MODE})
```

3. Make window resizable (optionally, but stongly advised):

```lua
rs.setMode(rs.game_width, rs.game_height, {resizable = true})
```

4. Hook into `love.resize`:
 ```lua
love.resize = function(w, h)
   rs.resize(w, h)
end
``` 
5. Draw something:

_(In this example we used scissors, but there [another way](examples/basic_setup_with_canvas) to achieve this. Read [manual](resolution_solution_documentation.pdf) or check [examples](examples) for more info.)_
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
* [Demo folder that you can run](demo) with `cd demo; love .`
* [examples folder](examples).

# Selling points of this library
* Library have 4 scale modes and you can switch between at any time:
  1. Aspect Scaling mode - scaling with preserved aspect.
  2. Stretching - stretch game to fill entire window.
  3. Pixel Perfect - will scale, using only integer scale factors and adds black bars if it can't. Must-have for pixel-art.
  4. No Scale - as name suggests, nothing will be scalled. Might be useful for debugging or if you make some kind of program (e.g, game engine) where you need to switch between scaling for game itself and no scaling when user editing game scripts.

* Library doesn't force you to use any specific way to scale your content, unlike some libraries. You can choose canvas, scissors, draw rectangles on top of game, shader, etc. Pick whatever you like!
* Library written with [kikito's guide](https://web.archive.org/web/20190406163041/http://kiki.to/blog/2014/03/30/a-guide-to-authoring-lua-modules/) in mind, which resulted in very monkey-patchable library! No unreachable locals, no globals, nothing like that! Everything that library produces during calculations can be reached by simple accessing library table: `rs.game_width`, `rs.scale_mode`, `rs.game_zone.x`, etc. Hack and slash your way to make library suitable for your game!
* Library has [.pdf manual](resolution_solution_documentation.pdf), that includes some illustrations, examples, explanations, tips and tricks. Single file documentation, that can be opened in almost anything, including your browser!
* Written with `snake_case`. Before it was camelCase.
* Library licensed under [`The Unlicense`](LICENSE). Do whatever you want with it with no restrictions!
* This library supports type annotations in VSCode. To make it work, you need to use `---@type ResolutionSolution`.

**Example:**
```lua
rs = require("resolution_solution") ---@type ResolutionSolution
```

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
* [Joycoin](https://hmmmgames.itch.io/coingame)

By [Saxashitter](https://github.com/Saxashitter):

* [UNSTOPPABLE-FUCK-Poyo-and-the-Refill-Mart](https://github.com/Saxashitter/UNSTOPPABLE-FUCK-Poyo-and-the-Refill-Mart/)

If you made game/program using this library, fell free to ask via [contacts](#contacts) to add your game in this list.

# Announces
I will post announces when new update will be dropped [here](https://love2d.org/forums/viewtopic.php?t=92494) or will create new release here on GitHub.

# Contacts
If you have any questions about this library, have ideas, etc, you can contact me via:

1. [Submit new issue](https://github.com/Vovkiv/resolution_solution/issues/new).
2. [love forum](https://love2d.org/forums/memberlist.php?mode=viewprofile&u=169762).
3. [matrix](https://matrix.to/#/@vovkiv:matrix.org).
4. Email - volkovissocool@gmail.com
