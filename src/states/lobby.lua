local Suit = require('lib.suit')
local Layout = require('src.helpers.layout')
local nakama = require('lib.nakama.nakama')
local socket = require('lib.nakama.socket')
local DeckApi = require('src.api.deck')
local json = require('lib.json')
local Constants = require('src.constants')
local Timer = require('src.helpers.timer')
local FriendListSidebar = require('src.ui.friend-list-sidebar')
local HeaderBar = require('src.ui.header-bar')
local Toast = require('src.ui.toast')
local Lobby = {
	matchmake_state = 'idle',
	matchmake_ticket = nil,
	timer = Timer:new(),
	friends = {},
	show_add_friend_input = false,
	friend_input = { text = "" },
	selected_deck = nil
}

function Lobby:load()
	FriendListSidebar:load()
	self.selected_deck = DeckApi:get_current_deck()

	socket.on_matchmaker_matched(Constants.SOCKET_CONNECTION, function(match)
		local matched = match.matchmaker_matched or {}
		local matched_token = matched.token
		local matched_match_id = matched.match_id

		Constants.ENEMY_ID = self:get_enemy_user_id(match.matchmaker_matched.users)

		coroutine.resume(coroutine.create(function()
			self.matchmake_state = 'idle'
			self.matchmake_ticket = nil

			local objects = {
				{
					collection = 'selected_deck',
					key = 'selected_deck',
					value = json.encode(self.selected_deck),
					permissionRead = 2,
					permissionWrite = 1,
					version = ""
				}
			}

			local write_result = nakama.write_storage_objects(Constants.NAKAMA_CLIENT, objects)
			if write_result and write_result.error then
				Toast:show('error', 'Failed to sync deck before joining match.', 4)
				return
			end

			local join_result = socket.match_join(Constants.SOCKET_CONNECTION, matched_match_id, matched_token, nil)
			if join_result and join_result.error then
				Toast:show('error', 'Failed to join match. Please try again.', 4)
				return
			end

			if join_result and join_result.match and join_result.match.match_id then
				Constants.MATCH_ID = join_result.match.match_id
			end

			CONTEXT:change('loading_game')
		end))
	end)
end

function Lobby:has_selected_deck()
	return self.selected_deck ~= nil
			and self.selected_deck.cards ~= nil
			and type(self.selected_deck.cards) == 'table'
			and #self.selected_deck.cards > 0
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

	if play_button.hit then
		coroutine.resume(coroutine.create(function()
			self.timer:reset()

			if self.matchmake_state == 'searching' then
				self.matchmake_state = 'idle'
				socket.matchmaker_remove(Constants.SOCKET_CONNECTION, self.matchmake_ticket)
			else
				if not self:has_selected_deck() then
					Toast:show('warning', 'Select a deck before searching for a match.', 4)
					return
				end
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

function Lobby:resize()

end

return Lobby
