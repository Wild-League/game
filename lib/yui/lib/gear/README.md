gear - The LÖVE Utility Gear
============================

**gear** provides common functionality for
[LÖVE](https://love2d.org) game development, including:

* 2D vector algebra
* Minimal 3D vector algebra
* 2D bounds (axis-aligned rectangles)
* General utility math functions
* Common stateless algorithms

Code is reasonably biased towards speed, at the occasional
expense of abstraction.

Documentation
=============

Code is documented with [LDoc](https://github.com/lunarmodules/LDoc).

Documentation may be generated running the command:

```sh
ldoc .
```

`ldoc` generates a `doc` directory, open `doc/index.html`
with your favorite browser to read the documentation.


Test suite
==========

The test suite uses [busted](https://olivinelabs.com/busted/).

Tests may be run with the command:

```sh
lua spec/utils_spec.lua
```

License
=======

See [LICENSE](LICENSE) for details.
