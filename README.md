# Resolution Solution
Yet another scaling library.

# What is it?
It was inspired by TLfres (https://love2d.org/wiki/TLfres), PUSH (https://github.com/Ulydev/push), maid64 (https://github.com/adekto/maid64). So, you can inspect same functionality and functions naming.

# Selling point of this library:
It have 3 scale modes and you can switch between them at any time:

1 Aspect scaling mode - creates black lines/bars on sides, will provide same width and height scale for pixels, result in more clean look.

2 Stretching - stretch game to fill entire window.

3 Pixel Perfect - will scale, using only integer scale factors and adds black bars if it can't. Useful for pixel art.

# Video demonstration:
https://youtu.be/cslfWOpetrc

# Basic setup:
1 drop library into your main.lua:

``` local rs = require("resolution_solution") ```

2 Init library:

``` rs.init({width = 640, height = 480, mode = 3}) ```

Make window resizable:

``` rs.setMode(800, 600, {resizable = true}) ```

3 update library
 ```
love.resize = function(w, h)
   rs.resize(w, h)
end
``` 
4 draw it
```
love.draw = function()
    rs.start()
       love.graphics.print("hello world!", 400, 300)
    rs.stop()
end
```
