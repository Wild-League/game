local Suit = require('lib.suit')
local Layout = require('src.helpers.layout')
local nakama = require('lib.nakama.nakama')
local socket = require('lib.nakama.socket')
local love2d = require('lib.nakama.engine.love2d')
local https = require('https')
-- local socket = require('socket')

local Lobby = {
	connection = {}
}

local client = nakama.create_client({
	host = 'localhost',
	port = 7350,
	username = 'defaultkey',
	password = '',
	engine = love2d
})

-- love.math.setRandomSeed(os.time())

local co = coroutine.create(function()
	-- local n = love.math.random(1, 100)

	-- authenticate
	local result = nakama.authenticate_email(client, 'ropoko2@gmail.com', '12345678', nil, true, 'ropoko2')
	-- local result = nakama.authenticate_device(client, '00000000-0000-0000-0000-000000000000', nil, true, 'ropoko_'..n)

	if result then
		nakama.set_bearer_token(client, result.token)
	end

	Lobby.connection = nakama.create_socket(client)
	socket.connect(Lobby.connection)
end)

coroutine.resume(co)

socket.on_matchmaker_matched(Lobby.connection, function(matched)
	local match_id = matched.matchmaker_matched.ticket
	local token = matched.matchmaker_matched.token

	socket.match_create(Lobby.connection, 'new-match', function(match)
		print('match created')

		for key, value in pairs(match.match) do
			print(key, value)
		end
	end)
	-- socket.match_join(Lobby.connection, match_id, token, nil, function(a)
	-- end)
end)

function Lobby:load() end

function Lobby:update()
end

function Lobby:draw()
	love.graphics.setBackgroundColor(10/255,16/255,115/255)

	local center = Layout:center(300, 30)

	local play_button = Suit.Button('Search Match', center.width, center.height, 300, 40)

	Suit.Label('Welcome to our alpha v0.0.1 ', center.width, 100)
	Suit.Label('For now, you can only play with 3 cards', center.width - 50, 130)
	Suit.Label('Search for a match or play against a friend', center.width - 70, 160)

	if play_button.hit then
		local c = coroutine.create(function()
			print('searching match')
			socket.matchmaker_add(Lobby.connection, 2, 2, nil)
		end)
		coroutine.resume(c)
	end
end

return Lobby
