Yui - A Declarative UI library for LÖVE
=======================================

**Yui** - Yet another User Interface, is a library to create menu-like GUIs
for the [LÖVE](https://love2d.org) engine.

## Why is that?

Because I'm spending so much time tweaking and customizing existing libraries,
I might as well make my own.

## Hello, World!

```lua
local yui = require 'lib.yui'

function love.load()
    local w, h = 300, 80
    local x = math.floor((love.graphics.getWidth() - w) / 2)
    local y = math.floor((love.graphics.getHeight() - h) / 2)

    ui = yui.Ui:new {
        x = x, y = y,

        yui.Rows {
            yui.Label {
                w = w, h = h / 2,
                text = "Hello, World!"
            },
            yui.Button {
                text = "Close",

                onHit = function() love.event.quit() end
            }
        }
    }
end

function love.update(dt)
    ui:update(dt)
end

function love.draw()
    ui:draw()
end
```

![Hello, World!](https://codeberg.org/1414codeforge/yui-examples/raw/branch/master/pics/hello_world.png)

## Features

**Yui** fills the following gaps:

* Immediate mode UIs tend to clutter LÖVE `update()` code a lot, using a declarative approach - that is:
  describing how the UI should look upfront, and then letting the UI code `update()` and `draw()` itself accordingly,
  makes for a cleaner code.
* Adapt to different sources of input easily (keyboard, mouse, touch, gamepad).
* Out of the box internationalization.
* Out of the box keyboard navigation across widgets.
* Simple layouts (place widget in columns or rows, or possibly build rows made of several columns - grids).
* Custom widgets support.
* Custom theme support.
* Custom input sources support.
* Sufficiently compact, straightforward and hackable code.

**Yui** does have some downsides:

* The declarative approach makes UIs harder to change drastically from frame to frame.
  * **Yui** tries to ameliorate this, allowing widgets property tweening, it's still less powerful
    compared to an all out immediate UI approach.
* Features come with a price, **Yui**'s code tries to be small and simple, but there are definitely smaller
  (and less featureful) frameworks out there.

## Dependencies

**Yui** depends on:

* [gear](https://codeberg.org/1414codeforge/gear) for general algorithms.
* [moonspeak](https://codeberg.org/1414codeforge/moonspeak) for its localization functionality.
* ...and any of their dependencies.

You may either download each of them manually and place them inside a `lib` subdirectory, or use
[crush](https://codeberg.org/1414codeforge/crush) to do the work for you.

1. Clone this repository.

```sh
git clone https://codeberg.org/1414codeforge/yui
```

2. Move to repository root directory:

```sh
cd yui
```

3. Resolve dependencies using **crush**.

```sh
lua crush.lua
```

You should now see a `lib` subdirectory containing the necessary dependencies.

## Integrating yui in my project using crush

1. Download the latest [crush.lua](https://codeberg.org/1414codeforge/crush/src/branch/master/crush.lua) file and
   place it in your project's root directory.

2. Create a `.lovedeps` text file in your project's root with the following entry:

```lua
{
    yui = "https://codeberg.org/1414codeforge/yui",

    -- ...more dependencies, if necessary...
}
```

3. **Yui** can now be downloaded directly by `crush` to the project's `lib` directory:

```sh
lua crush.lua
```

4. Now `yui` can be `require()`d in your code, like this:

```lua
local yui = require 'lib.yui'
```

5. Any project depending on yours will now fetch `yui`
   automatically when using `crush`, following the above procedure.

## Documentation

Code is documented with [LDoc](https://github.com/lunarmodules/LDoc).

Documentation may be generated running the command:

```sh
ldoc .
```

`ldoc` generates a `doc` directory, open `doc/index.html`
with your favorite browser to read the documentation.

The source code is also (IMHO) sufficiently
straightforward and disciplined to have a decent overview of the functionality.

Examples are available at:
<https://codeberg.org/1414codeforge/yui-examples>

## Acknowledgement

Portions of this library's widget rendering code are taken from the
Simple User Interface Toolkit (**SUIT**) for LÖVE by Matthias Richter.

SUIT's source code is available at: [vrld/SUIT](https://github.com/vrld/SUIT).
SUIT is licensed under the [MIT license](https://github.com/vrld/suit/blob/master/license.txt).

Widgets offered by **yui** and basic theme are also mostly taken from SUIT.

See [ACKNOWLEDGEMENT](README.ACKNOWLEDGEMENT) for full SUIT license
information and copyright notice.

## Similar projects

* [SUIT](https://github.com/vrld/SUIT) an excellent, simple and flexible framework for immediate UIs.
* [Gspöt](https://notabug.org/pgimeno/Gspot) a stateful GUI lib for LÖVE, has similar aims, but different approach.

## License

Zlib, see [LICENSE](LICENSE) for details.
