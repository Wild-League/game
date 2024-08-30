local Initial = require('src.states.initial')
local SignIn = require('src.states.auth.signin')
local SignUp = require('src.states.auth.signup')
local Game = require('src.states.game')
local NewGame = require('src.scenes.game')
local Queue = require('src.states.queue')
local Lobby = require('src.states.lobby')
local LoadingGame = require('src.states.loading-game')

local Context = {
    states = {
        initial = Initial,
        signin = SignIn,
        signup = SignUp,
        lobby = Lobby,
        queue = Queue,
        loading_game = LoadingGame,
        game = Game,
        newGame = NewGame
    },

    current = 'newGame',

    load = function(self, dt) return self.states[self.current]:load() end,

    update = function(self, dt) return self.states[self.current]:update(dt) end,

    draw = function(self) return self.states[self.current]:draw() end,

    change = function(self, ctx)
        if ctx == nil then error('Context should not be nil') end

        local new_ctx = self.states[ctx]

        if new_ctx ~= nil then
            self.current = ctx
            self.states[self.current]:load()
        else
            error('This context does not exist')
        end
    end
}

return Context
