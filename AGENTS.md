# Wild League — Agent Guidelines

## Project Overview

A [Love2D](https://love2d.org/) (v12) game written in **Lua (LuaJIT)**. No build system,
no package manager. Third-party libraries are manually vendored in `lib/`. The game
connects to a [Nakama](https://heroiclabs.com/nakama/) multiplayer backend.

---

## Running the Game

```bash
love .
```

There is no build step. The game runs directly through the Love2D executable.

> Note: `conf.lua` hardcodes `t.window.displayindex = 2`. Change to `1` if you only
> have one monitor.

---

## Linting

The project uses [luacheck](https://github.com/lunarmodules/luacheck) with a
root `.luacheckrc` configuration.

Run lint:

```bash
luacheck .
```

The config is set up for Love2D (`lua51+love`) and excludes vendored/generated paths:

- `lib/**`
- `assets/**`
- `test.lua`

If luacheck is not installed:

```bash
luarocks install luacheck
```

Follow `.editorconfig` rules manually as well:

- **Indent:** tabs (size 2)
- **Line endings:** LF
- **Charset:** UTF-8
- **Trim trailing whitespace:** yes
- **Final newline:** yes

---

## Testing

There is **no project-level test suite**. The root `test.lua` is a gitignored scratch
file. To verify behavior, run the game with `love .` and exercise the feature manually.

The vendored `lib/yui/` library contains internal Busted specs (not project tests):

```bash
# Run a single vendored library spec (requires busted installed)
cd lib/yui/lib/serialize && busted spec/serialize_spec.lua
cd lib/yui/lib/gear     && busted spec/gear_spec.lua
```

If you add project-level tests, place them under `test/` and use
[Busted](https://github.com/lunarmodules/busted) (`describe` / `it` / `assert.*` style).

---

## Project Structure

```
main.lua          Love2D entry point (load/update/draw callbacks)
conf.lua          Window configuration
src/
  context.lua     Global state machine / router (CONTEXT global)
  constants.lua   Global mutable constants (tokens, server URLs)
  assets.lua      Preloaded Love2D image assets
  api/            HTTP API clients (BaseApi, UserApi, DeckApi, InstanceApi)
  config/         Static config tables (match events, range sizes)
  entities/       Core game objects (Card, Deck, EnemyDeck, Map, Tower, User)
  helpers/        Utilities (animation, image loading, layout, timer, utils, saver)
  network/        Networking (UDP legacy, WebSocket wrapper, event constants)
  scenes/         WIP scene refactor (game scene)
  states/         State machine states (auth, lobby, queue, loading-game, game, …)
  ui/             Reusable UI components (alert, cards, fonts, header-bar, …)
lib/              Vendored third-party Lua libraries — do not modify
assets/           Images, fonts, Tiled map data
```

---

## Architecture

### State Machine

The whole application lifecycle is a hand-rolled FSM in `src/context.lua`.
`CONTEXT` is the single global (set in `love.load()`). All state transitions go
through `CONTEXT:change('state_name')`.

Each state implements exactly four methods:

```lua
function State:load()       end   -- called once on transition
function State:update(dt)   end   -- called every frame
function State:draw()       end   -- called every frame
function State:resize()     end   -- called on window resize
```

### Singletons vs. Instances

Most modules are singletons (a single shared table). Use `:new()` factory methods
only when per-instance state is required (`Card:new()`, `Timer:new()`,
`PlayerStatus:new()`).

### Dual UI System (in transition)

- **SUIT** (`lib/suit/`) — immediate-mode; used in auth, lobby, queue screens
- **yui** (`lib/yui/`) — retained-mode layout; used in initial screen and deck selection

Prefer `yui` for new UI work; `suit` is being phased out.

### Networking

- **Nakama SDK** (`lib/nakama/`) — active system for real-time match data,
  matchmaking, and storage
- **LuaSocket UDP** (`src/network/udp.lua`) — legacy matchmaking; still wired but
  superseded by Nakama

---

## Code Style

### Modules and Imports

```lua
-- Always local, always at the top of the file
local Json    = require('lib.json')
local Nakama  = require('lib.nakama.nakama')
local BaseApi = require('src.api.base')
local Utils   = require('src.helpers.utils')
```

- Use dot notation for paths: `'src.states.auth'`, `'lib.json'`
- Hyphenated filenames keep their exact name: `require('src.states.loading-game')`
- External native modules use string keys: `require('https')`, `require('socket')`
- No consistent ordering rule yet — group logically (stdlib, lib, src) and leave a
  blank line between groups when clarity helps

### Naming Conventions

| Thing                          | Convention              | Example                            |
| ------------------------------ | ----------------------- | ---------------------------------- |
| Module table / "class"         | `PascalCase`            | `Auth`, `Deck`, `BaseApi`          |
| Local variable                 | `snake_case`            | `card_selected`, `signin_username` |
| Global singleton               | `UPPER_CASE`            | `CONTEXT`                          |
| Constant / token               | `UPPER_CASE` on table   | `Constants.ACCESS_TOKEN`           |
| Event key                      | `snake_case` on table   | `MatchEvents.card_spawn`           |
| Enum-like event (inter-module) | `PascalCase` on table   | `Events.MatchFound`                |
| Private module-scope function  | `local function name()` | —                                  |
| Public method (self)           | colon syntax            | `function Auth:load()`             |
| Public utility (no self)       | dot syntax              | `function Utils.has_collision()`   |

### OOP (Metatable Prototype Pattern)

```lua
local MyClass = {}
MyClass.__index = MyClass

function MyClass:new(data)
    local obj = setmetatable({}, self)
    -- initialise fields
    return obj
end

function MyClass:some_method()
    -- use self
end

return MyClass
```

Use `Utils.merge_tables` / `Utils.copy_table` for mixin composition (see `Card:new()`).

### Formatting

- **Tabs** for indentation (2-wide), **not spaces** — some existing files use 4-space
  indentation (acknowledged inconsistency; prefer tabs in new/edited code)
- One blank line between top-level functions
- Keep lines reasonably short; no hard limit enforced
- Use `--#region` / `--#endregion` fold markers in large files (see `deck_selection.lua`)
- Section divider comments: `-- private functions`, `-- public functions`

### Error Handling

```lua
-- Programmer errors / preconditions
error('CONTEXT is nil — call love.load() first')
assert(condition, 'message')

-- API responses: always check .success
local res = UserApi:get_profile()
if not res.success then
    -- handle gracefully
    return
end

-- Async / non-blocking work: wrap in coroutine
coroutine.resume(coroutine.create(function()
    local data = nakama.read_storage_objects(client, payload)
    -- use data
end))
```

- **Do not use `pcall`** around normal game logic (only library internals use it)
- Provide a fallback (e.g., `missing_card` image) rather than crashing on asset errors
- Mark unhandled edge cases with `-- TODO:` rather than silently swallowing them

### Comments

```lua
-- Single-line comment

--[[
  Multi-line block comment
  for longer explanations
]]

-- TODO: describe what still needs doing
```

Avoid leaving large blocks of commented-out code in committed files unless it is
clearly labelled as a WIP refactor.

---

## Dependencies

All third-party libraries live in `lib/` and are **never modified**. Do not add new
dependencies via a package manager — download the `.lua` file and place it in `lib/`.

The one exception is `lua-https` (a native `.so`/`.dll`), which must be obtained as a
pre-built artifact from its GitHub Actions CI for the target OS. See `DEVELOPMENT.md`.

---

## Hot Reload

`lib/lurker.lua` is called on every `love.update()`. Saving any `.lua` file will
automatically reload it in the running game — no restart required during development.

---

## Cursor Cloud specific instructions

### Environment overview

Love2D v12 nightly is installed at `/opt/love2d/` with its binary at `/opt/love2d/bin/love`
(symlinked to `/usr/local/bin/love`). The shared libraries live in `/opt/love2d/lib/` and
`LD_LIBRARY_PATH` is configured in `~/.bashrc` to include that path.

The `lua-https` native module (`https.so`) must exist in the project root (`/workspace/https.so`)
for any API/network calls to work. It is built from source
([love2d/lua-https](https://github.com/love2d/lua-https)) using cmake + g++ against libcurl and
openssl. If it is missing, rebuild it:

```bash
cd /tmp && git clone --depth 1 https://github.com/love2d/lua-https.git
mkdir -p /tmp/lua-https/build && cd /tmp/lua-https/build
cmake .. -DCMAKE_CXX_COMPILER=g++ -DUSE_CURL_BACKEND=ON -DUSE_OPENSSL_BACKEND=ON
make -j$(nproc)
cp src/https.so /workspace/https.so
```

### Running the game

```bash
export LD_LIBRARY_PATH=/opt/love2d/lib:$LD_LIBRARY_PATH
love .
```

ALSA audio errors in the log are expected (no sound device in the VM) and do not affect
gameplay. `conf.lua` sets `t.window.displayindex = 2`; this works in the Cloud VM (which
has a virtual display), but on a single-monitor setup change it to `1`.

### Backend services

The game client requires two external services for full end-to-end testing:

- **World API** (Django REST) at `http://localhost:8000` — auth, users, decks, cards
- **Nakama** server at `localhost:7350` — real-time multiplayer

The backend is cloned at `/workspace/backend` and runs via Docker Compose. To start all
backend services:

```bash
cd /workspace/backend
docker compose up -d --build
```

This starts: Postgres (5432), API (8000), Nakama (7349-7351), and SeaweedFS (8333).
Migrations and `ensure_nakama_card_fdw` run automatically on API container startup
via `entrypoint.sh`.

**First-time SeaweedFS setup** (only needed once, after the containers are running):

```bash
# Create S3 credentials
docker compose exec seaweedfs-master weed shell -master=seaweedfs-master:9333 <<'EOF'
s3.configure -user=wildleague -access_key=wildleague -secret_key=wildleague-secret -buckets=cards -actions=Read,Write,List,Tagging,Admin -apply
EOF

# Seed card data + mirror images to S3
docker compose exec api python manage.py seed_default_cards

# Allow anonymous read access to card images
docker compose exec seaweedfs-master weed shell -master=seaweedfs-master:9333 <<'EOF'
s3.configure -user=anonymous -actions=Read:cards,List:cards -apply
EOF
```

**Backend tests:** `docker compose exec api python manage.py test`

Without the backend, the game launches to the server-selection screen but cannot
authenticate or enter a match.

### Linting and testing

- **Lint (game):** `luacheck .` — see `AGENTS.md` § Linting for details.
- **Tests (game):** No project-level test suite exists. Manual testing via `love .`.
- **Lint (backend):** No linter configured; follow `.editorconfig`.
- **Tests (backend):** `docker compose exec api python manage.py test` (in `/workspace/backend`).

### Docker in the Cloud VM

Docker is installed with `fuse-overlayfs` storage driver and `iptables-legacy` for
compatibility in the nested container environment. The `ubuntu` user is in the `docker`
group for non-root access. Start the daemon with `sudo dockerd &>/tmp/dockerd.log &`
if it's not already running.
