local Suit = require('lib.suit')
local Layout = require('src.helpers.layout')
local nakama = require('lib.nakama.nakama')
local socket = require('lib.nakama.socket')
local love2d = require('lib.nakama.engine.love2d')
local Deck = require('src.api.deck')
local json = require('lib.json')
local Constants = require('src.constants')

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

Constants.NAKAMA_CLIENT = client

-- TODO: move to load
local co = coroutine.create(function()
	-- authenticate
	local result = nakama.authenticate_email(client, 'ropoko@gmail.com', '12345678', { level = "1" }, true, 'ropoko')

	if result then
		Constants.USER_ID = result.user_id
		nakama.set_bearer_token(client, result.token)
	end

	Lobby.connection = nakama.create_socket(client)
	socket.connect(Lobby.connection)
end)

coroutine.resume(co)

local selected_deck = Deck:get('1')

socket.on_matchmaker_matched(Lobby.connection, function(match)
	CONTEXT:change('game')

	coroutine.resume(coroutine.create(function()
		local objects = {
			{
				collection = 'selected_deck',
				key = 'selected_deck',
				value = json.encode(selected_deck),
				permissionRead = 1,
				permissionWrite = 1,
				version = ""
			}
		}

		nakama.write_storage_objects(client, objects)
	end))

	-- local match_id = match.on_matchmaker_matched.match_id
	-- socket.match_data_send(Lobby.connection, match_id, { message = 'hello' })
end)

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
		local c = coroutine.create(function()
			print('searching match')
			socket.matchmaker_add(Lobby.connection, 2, 2, nil)
		end)
		coroutine.resume(c)
	end
end

return Lobby
