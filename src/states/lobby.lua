local Suit = require('lib.suit')
local Layout = require('src.helpers.layout')
local nakama = require('lib.nakama.nakama')
local socket = require('lib.nakama.socket')
local love2d = require('lib.nakama.engine.love2d')
local DeckApi = require('src.api.deck')
local json = require('lib.json')
local Constants = require('src.constants')
local Timer = require('src.helpers.timer')
local Images = require('src.ui.images')
local Fonts = require('src.ui.fonts')
local FriendListSidebar = require('src.ui.friend-list-sidebar')
local Alert = require('src.ui.alert')

local Lobby = {
	matchmake_state = 'idle',
	matchmake_ticket = nil,
	timer = Timer:new(),
	friends = {},
	show_add_friend_input = false,
	friend_input = { text = "" }
}

function Lobby:load()
	local client = nakama.create_client({
		host = 'localhost',
		port = 7350,
		username = 'defaultkey',
		password = '',
		engine = love2d
	})

	Constants.NAKAMA_CLIENT = client

	-- TODO: add real code
	-- local selected_deck = DeckApi:get('1')

	-- coroutine.resume(coroutine.create(function()
	-- 	-- add user to nakama server
	-- 	local result = nakama.authenticate_email(client, 'ropoko@gmail.com', '12345678', { level = "1" }, true, 'ropoko')

	-- 	if result then
	-- 		Constants.USER_ID = result.user_id
	-- 		nakama.set_bearer_token(client, result.token)
	-- 	end

	-- 	Constants.SOCKET_CONNECTION = nakama.create_socket(client)
	-- 	socket.connect(Constants.SOCKET_CONNECTION)
	-- end))

	-- socket.on_matchmaker_matched(Constants.SOCKET_CONNECTION, function(match)
	-- 	Constants.MATCH_ID = match.matchmaker_matched.match_id
	-- 	Constants.ENEMY_ID = self:get_enemy_user_id(match.matchmaker_matched.users)

	-- 	coroutine.resume(coroutine.create(function()
	-- 		local objects = {
	-- 			{
	-- 				collection = 'selected_deck',
	-- 				key = 'selected_deck',
	-- 				value = json.encode(selected_deck),
	-- 				permissionRead = 2,
	-- 				permissionWrite = 1,
	-- 				version = ""
	-- 			}
	-- 		}

	-- 		nakama.write_storage_objects(client, objects, function ()
	-- 			socket.match_join(Constants.SOCKET_CONNECTION, Constants.MATCH_ID, nil, nil, function()
	-- 				CONTEXT:change('game')
	-- 			end)
	-- 		end)
	-- 	end))
	-- end)
end

function Lobby:update(dt) self.timer:update(dt) end

function Lobby:draw()
	love.graphics.setBackgroundColor(10 / 255, 16 / 255, 115 / 255)

	love.graphics.setColor(0.1, 0.1, 0.1, 0.8)
	love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), 50)
	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.setFont(Fonts.jura(20))
	local deck_builder_btn = Suit.Button("Deck Builder", 20, 10, 150, 30)
	love.graphics.setFont(Fonts.jura(24))

	if deck_builder_btn.hit then CONTEXT:change('deck_selection') end

	local center = Layout:center(300, 30)
	local mainX = center.width - 150

	local text = self.matchmake_state == 'searching' and 'Cancel' or 'Search Match'
	local play_button = Suit.Button(text, mainX, center.height, 300, 40)

	if self.matchmake_state == 'searching' then
		self.timer:draw(mainX, center.height + 50, 300, 40)
		Suit.Label('searching players ...', mainX + 50, center.height + 90)
	end

	Suit.Label('Welcome to our alpha v0.0.1 ', mainX, 100)
	Suit.Label('For now, you can only play with 3 cards', mainX - 50, 130)
	Suit.Label('Search for a match or play against a friend', mainX - 70, 160)

	FriendListSidebar.draw(Suit, Fonts, Lobby)

	Alert:draw()

	if play_button.hit then
		coroutine.resume(coroutine.create(function()
			self.timer:reset()

			if self.matchmake_state == 'searching' then
				self.matchmake_state = 'idle'
				socket.matchmaker_remove(Constants.SOCKET_CONNECTION, self.matchmake_ticket)
			else
				self.matchmake_state = 'searching'
				socket.matchmaker_add(Constants.SOCKET_CONNECTION, 2, 2, nil, nil, nil, nil, function(matchmake)
					self.matchmake_ticket = matchmake.matchmaker_ticket.ticket
				end)
			end
		end))
	end
end

function Lobby:get_enemy_user_id(users)
	for _, user in pairs(users) do
		if user.presence.user_id ~= Constants.USER_ID then
			return user.presence.user_id
		end
	end
end

return Lobby
