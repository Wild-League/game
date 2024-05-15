df-serialize - A brainless Lua table serializer
============================================

**df-serialize** provides two functions:

* `pack()` packs Lua tables to string.
* `unpack()` unpacks a string back to a Lua table.

The implementation strives to be useful under the majority of reasonable use cases,
to be compact, understandable and sufficiently fast.
There is no pretense of complete generality, nor of absolute efficiency.
In case **df-serialize** does not exactly meet your requirements, its code
should be immediate enough to tweak to your needs.

Documentation
=============

Code is documented with [LDoc](https://github.com/lunarmodules/LDoc).

Documentation may be generated running the command:

```sh
ldoc init.lua
```

`ldoc` generates a `doc` directory, open `doc/index.html`
with your favorite browser to read the documentation.


Test suite
==========

The test suite uses [busted](https://olivinelabs.com/busted/).

Tests may be run with the command:

```sh
lua spec/serialize_spec.lua
```

License
=======

See [LICENSE](LICENSE) for details.
