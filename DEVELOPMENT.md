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

## Release (GitHub Actions)

`/.github/workflows/release.yml` builds and publishes release artifacts for:
- macOS (`WildLeague-macos.zip`)
- Windows (`WildLeague-windows.zip`)

The workflow targets **LÖVE 12** by downloading nightlies from the
`love2d/love` `main` branch artifacts via `nightly.link`:
- `love-windows-x64.zip`
- `love-macos.zip`

Trigger a release by pushing a tag like:

```bash
git tag v0.1.0
git push origin v0.1.0
```

If you run the workflow manually (`workflow_dispatch`), provide the `tag` input
(for example `v0.1.0`) so GitHub Release has an explicit tag to publish.
