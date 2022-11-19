# Resolution Solution
Scale library, that help you add resolution support to your games in love2d!

Partially, library was inspired by TLfres https://love2d.org/wiki/TLfres
I was not satisfied with that, so i created my own

It have 2 scale mode:
1 aspect scaling mode (that creates black lines/bars)
2 and stretching

Also it provides some usefull functions to deal with scaling math, such as:
toGame, toScreen

Provides offset data, mouse data, scaling data and so on generated by library

Provide cursor function, that determine if cursor is touching black bars, so if you don't need to collide with something, that hided with black lines/bars, use that function

# Demostration video:

https://www.youtube.com/watch?v=lvDzdOhtt_0

# What it does/how to use:

(For full documentation, open source file "resolution_solution")

1 drop library into your main.lua:

``` local rs = require("resolution_solution") ```

2 You set game virtual size (that library will use to scale game to)

``` rs.setGame(1920, 1080) ```

3 additionaly configure it, if you need:

set scaling mode:
``` rs.scaleMode = 1 or 2 ```

set color for black bars/lines:
``` rs.setColor(1, 1, 1, 0.5) ```

4 update library
 ```
love.update = function()
   rs.update()
end
``` 
5 draw it
```
love.draw = function()
    rs.start()
       love.graphics.print("hello world!", 400, 300)
    rs.stop()
end
```

# Zerobrane Studio API!

This library supports ZBS auto-completion and tooltips!
(But, it was not updated for currect v1006, only for v1003.)

# Video demonstration

Autocompletion:

https://youtu.be/ecuK6hHHJwg

Tooltip:

https://youtu.be/uOTg0r3ywuA

# How to install

(Open "RS_ZBS_API.lua" file for full documentation)

1. Download https://raw.githubusercontent.com/Vovkiv/resolution_solution/main/RS_ZBS_API.lua

2. Place it in: ```"path"/"to"/zbstudio/api/lua/```

3. Open your Zerobrane config (user.lua, system.lua or Edit -> Preferences -> Settings: User) and paste there:

```
api = {
  love2d = {"RS_ZBS_API"}
}
```

4. Restart Zerobrane Studio! (and don't forget to set interprier to love)
