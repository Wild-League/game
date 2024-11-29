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
local HeaderBar = require('src.ui.header-bar')
local Lobby = {
	matchmake_state = 'idle',
	matchmake_ticket = nil,
	timer = Timer:new(),
	friends = {},
	show_add_friend_input = false,
	friend_input = { text = "" }
}

function Lobby:load()
	FriendListSidebar:load()
	local selected_deck = DeckApi:get_current_deck()
	for i, line in ipairs(selected_deck) do
		print(line)
		print(i)
	end

	socket.on_matchmaker_matched(Constants.SOCKET_CONNECTION, function(match)
		Constants.MATCH_ID = match.matchmaker_matched.match_id
		Constants.ENEMY_ID = self:get_enemy_user_id(match.matchmaker_matched.users)

		coroutine.resume(coroutine.create(function()
			local objects = {
				{
					collection = 'selected_deck',
					key = 'selected_deck',
					value = json.encode(selected_deck),
					permissionRead = 2,
					permissionWrite = 1,
					version = ""
				}
			}

			nakama.write_storage_objects(Constants.NAKAMA_CLIENT, objects, function()
				socket.match_join(Constants.SOCKET_CONNECTION, Constants.MATCH_ID, nil, nil, function()
					CONTEXT:change('game')
				end)
			end)
		end))
	end)
end

function Lobby:update(dt) self.timer:update(dt) end

function Lobby:draw()
	love.graphics.setBackgroundColor(10 / 255, 16 / 255, 115 / 255)

	HeaderBar:draw("Deck Builder", 'deck_selection')

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

	FriendListSidebar:draw(self)

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
