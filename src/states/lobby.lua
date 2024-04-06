local Suit = require('lib.suit')
local Layout = require('src.helpers.layout')
local nakama = require('lib.nakama.nakama')
local socket = require('lib.nakama.socket')
local love2d = require('lib.nakama.engine.love2d')
local https = require('https')
-- local socket = require('socket')

local Lobby = {
	server = {}
}

local client = nakama.create_client({
	host = 'localhost',
	port = 7350,
	username = 'defaultkey',
	password = '',
	engine = love2d
})

local co = coroutine.create(function()

	-- authenticate
	local result = nakama.authenticate_device(client, '0424aea1-0662-4087-81f5-4ee1582fabdd', nil, true, 'ropoko')

	if result then
		nakama.set_bearer_token(client, result.token)
	end

	local sock = nakama.create_socket(client)

	local ok, err = socket.connect(sock)

	print('res', ok, err)

	-- Lobby.server:connect()

	-- Lobby.server.match_create('match 1')
end)

coroutine.resume(co)

-- sock.match_create(sock, 'first match')
-- local ok,err = nakama.socket_connect(sock)

-- print('ok: ', ok, 'err: ', err)

-- server:connect()

function Lobby:load() end

function Lobby:update() end

function Lobby:draw()
	love.graphics.setBackgroundColor(10/255,16/255,115/255)

	local center = Layout:center(300, 30)

	local play_button = Suit.Button('Search Match', center.width, center.height, 300, 40)

	Suit.Label('Welcome to our alpha v0.0.1 ', center.width, 100)
	Suit.Label('For now, you can only play with 3 cards', center.width - 50, 130)
	Suit.Label('Search for a match or play against a friend', center.width - 70, 160)

	if play_button.hit then
		self.server.match_create('new match')
	end
end

return Lobby
