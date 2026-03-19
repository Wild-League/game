# Development

## Deps
- [love2d](https://love2d.org/) - now using v12 (unstable)
- [lua-https](https://github.com/love2d/lua-https/) - from actions, get an artifact for your OS
- [luacheck](https://github.com/lunarmodules/luacheck/) - lint tool for Lua (`luarocks install luacheck`)

## Lint

```bash
luacheck .
```

Uses project config from `.luacheckrc` (Love2D-aware and excludes `lib/**`, `assets/**`, and `test.lua`).
