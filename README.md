# Resolution Solution
Scale library, that help you add resolution support to your games in love2d!

(NOTE, at current moment, library architecture/api/naming might drastically change with every update.
So don't expect any consistency and backward compatibility with updates any time soon.
If you don't need any fancy updates and just need scaling, stick to version v2000, aunder "history" folder.
Source file for every version includes "code as documentation", with demo, so you won't miss anything.)

# Why it was made?
This library was inspired by TLfres (https://love2d.org/wiki/TLfres), PUSH (https://github.com/Ulydev/push), maid64 (https://github.com/adekto/maid64).
So, you can inspect same functionality and naming as they have, but...:
1. I was not satisfied with this libraries.
* They lack monkeypathich design
So, adding new or changing exist functionality of library without source code editing almost impossible.
I try to design my solution as monkeypatchable as possible, without source code.
In fact, you can rewrite any function of library from outside, without losing anything, since all data produced by library is available to you.
* They lack some QoL features
This solutions mostly give you scaling, some getters and setters.
That's it.
Everything else you supposed to make by yourself.
My approach is different (and, i believe, better).
I give you sane default that you can use, but if something in my library don't suit you well,
you can replace it behaviour with your own, from game files, not via editing source of library.
It should allow you don't maintain your own fork of library.
* They mostly abandoned
Most of them have latest commit 1-5 years ago, so it highly unlikely that they receive new updates with features.
* If they give you way to do something, thay don't allow to change it
For example, if push dev say, that you need to draw onto canvas, you can't do anything with it.
If they crop scaled image with love.graphics.setScissor then you also can't do anything with this.
As it was mentioned, my library give you sane defaults and allow simple patching on top of library.

2. Due to mentioned in 1 limitations, it was hard to glue them with different libraries, such as camera libraries.
I tired of this and created my solution tgat hopefully break barrier of this issues.

3. Most of this libraries doesn't provide to you, as developer, any checks or verification.
No input check or proper return values.
No shortcuts.
Anything. This just annoy and might make development with this libraries harder.

In short, thi library tries to be netter replacement for any scaling solutions, and, if it become stable and mature enough, become standart for developing games with love.

# What it can/have?
It have 3 scale modes:

1 Aspect scaling mode - creates black lines/bars on sides, will provide same width and height scale for pixels, result in more clean look.

2 Stretching - stretch game to fill screen.

3 Pixel Perfect - will scale, using only integer scale factors and adds black bars if it can't. Useful for pixel art.

Provide all sort of functions to deal with library, such as:

rs.nearesFilter() - that allow quickly change filter for more pixel art scaling.

rs.switchBars() - function to enable/disable bars rendering

rs.setColor() - to change color of black bars.

rs.debugFunc() - that can help you monitor library values.

And much more!

# Okay, but where i can see it in action?
Her, YouTube little demonstration video:

https://www.youtube.com/watch?v=lvDzdOhtt_0

Or just download and run ```demo.love```!

# Looks good, but how basic setup looks like?
(For full documentation, open library source file, it include all info and documentation.)

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

# Does it support any IDE?
Yes:

* ZBS (zerobrane, https://studio.zerobrane.com/) auto-completion and tooltips! - abadoned, latest supported library version is v1003

Autocompletion showcase:

https://youtu.be/ecuK6hHHJwg

Tooltip showcase:

https://youtu.be/uOTg0r3ywuA

How to install:

(Open "RS_ZBS_API.lua" file for full documentation).

1. Download https://raw.githubusercontent.com/Vovkiv/resolution_solution/main/RS_ZBS_API.lua

2. Place it in: ```"path"/"to"/zbstudio/api/lua/```

3. Open your Zerobrane config (user.lua, system.lua or Edit -> Preferences -> Settings: User) and paste there:

```
api = {
  love2d = {"RS_ZBS_API"}
}
```

4. Restart Zerobrane Studio! (and don't forget to set interprier to love).
