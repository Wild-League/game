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

local Lobby = {
	matchmake_state = 'idle',
	matchmake_ticket = nil,
	timer = Timer:new(),
	friends = {},
	show_add_friend_input = false,
	friend_input = {text = ""}
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

function Lobby:update(dt)
	self.timer:update(dt)
end

function Lobby:draw()
	-- Set background color
	love.graphics.setBackgroundColor(10/255,16/255,115/255)

	-- Draw navbar
	love.graphics.setColor(0.1, 0.1, 0.1, 0.8)
	love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), 50)
	love.graphics.setColor(1, 1, 1, 1)

	-- Navbar content

	love.graphics.setFont(Fonts.jura(20))
	local deck_builder_btn = Suit.Button("Deck Builder", 20, 10, 150, 30)
	love.graphics.setFont(Fonts.jura(24))

	if deck_builder_btn.hit then
		CONTEXT:change('deck_selection')
	end

	-- Rest of the existing draw code, adjusted Y positions to account for navbar
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

	local sidebar_width = 250
	local sidebar_x = love.graphics.getWidth() - sidebar_width
	local sidebar_y = 0

	love.graphics.setColor(0.1, 0.1, 0.1, 0.8)
	love.graphics.rectangle('fill', sidebar_x, sidebar_y, sidebar_width, love.graphics.getHeight())
	love.graphics.setColor(1, 1, 1, 1)

	Suit.Label('Friends', sidebar_x + 10, sidebar_y + 20)

	if self.show_add_friend_input then
		love.graphics.setFont(Fonts.jura(15))
		Suit.Input(self.friend_input, sidebar_x + 10, sidebar_y + 60, 230, 30)
		love.graphics.setFont(Fonts.jura(24))
	end

	local button_y = sidebar_y + (self.show_add_friend_input and 100 or 60)
	love.graphics.setFont(Fonts.jura(15))
	local add_friend_button = Suit.Button('Add Friend +', sidebar_x + 10, button_y, 230, 30)
	love.graphics.setFont(Fonts.jura(24))

	if add_friend_button.hit then
		if not self.show_add_friend_input then
			self.show_add_friend_input = true
		else
			if self.friend_input.text ~= "" then

				print("Adding friend: " .. self.friend_input.text)
				self.friend_input.text = ""
			end

			self.show_add_friend_input = false
		end
	end

	local friend_y = button_y + 40

	if #self.friends > 0 then
		for i, friend in ipairs(self.friends) do
			Suit.Label((friend.name or "Friend ") .. i, sidebar_x + 10, friend_y)
			-- local status_color = friend.online and {0, 1, 0} or {0.5, 0.5, 0.5}

			-- love.graphics.setColor(unpack(status_color))
			love.graphics.circle('fill', sidebar_x + sidebar_width - 20, friend_y + 8, 5)
			love.graphics.setColor(1, 1, 1, 1)
			friend_y = friend_y + 30
		end
	else
		love.graphics.setFont(Fonts.jura(15))
		Suit.Label('No friends found', sidebar_x + 10, friend_y)
		Suit.Label('Add friends to play against them', sidebar_x + 10, friend_y + 30)
		love.graphics.setFont(Fonts.jura(24))
	end

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
