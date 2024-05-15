moonspeak - LÖVE game localization library
==========================================

**moonspeak** is a basic internationalization library for
the [LÖVE](https://love2d.org/) engine.
It makes your game easy to translate to multiple languages.

**moonspeak** does the following:

* Loads dictionary files for your game.
* Allows selecting one of the many available languages.
* Translates messages by id (and provides default fallback to English).

## Dependencies

**moonspeak** uses [df-serialize](https://codeberg.org/1414codeforge/df-serialize)
to read the dictionary file.

You may either doenload **df-serialize** manually and place it inside a `lib` subdirectory,
or use [crush](https://codeberg.org/1414codeforge/crush)
to do this for you.

## Using crush to download moonspeak dependencies

1. Clone this repository.

```sh
git clone https://codeberg.org/1414codeforge/moonspeak
```

2. Move to repository root directory:

```sh
cd moonspeak
```

3. Resolve dependencies using **crush**.

```sh
lua crush.lua
```

You should now see a `lib` subdirectory containing the necessary dependencies.

## Integrating moonspeak in my project using crush

1. Download the latest [crush.lua](https://codeberg.org/1414codeforge/crush/src/branch/master/crush.lua) file and
   place it in your project's root directory.

2. Create a `.lovedeps` text file in your project's root with the following dependency entry:

```lua
{
    moonspeak = "https://codeberg.org/1414codeforge/moonspeak",

    -- ...more dependencies, if necessary...
}
```

3. `moonspeak` can now be downloaded directly by `crush` to the project's `lib` directory:

```sh
lua crush.lua
```

4. Now `moonspeak` can be `require()`d in your code, like this:

```lua
local moonspeak = require 'lib.moonspeak'
```

5. Any project depending on yours will now fetch `moonspeak`
   automatically when using `crush`, following the above procedure.

## Documentation

Code is documented with [LDoc](https://github.com/lunarmodules/LDoc).

Documentation may be generated running the command:

```sh
ldoc init.lua
```

`ldoc` outputs to a local `doc` directory, open `index.html`
with your favorite browser to read it.

## License

Zlib, See [LICENSE](LICENSE) for details.
