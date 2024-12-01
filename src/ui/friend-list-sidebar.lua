local json = require('lib.json')
local UserApi = require('src.api.user')
local Alert = require('src.ui.alert')
local Suit = require('lib.suit')
local Fonts = require('src.ui.fonts')
local RelationshipType = {
	Block = 'Block',
	Friend = 'Friend',
	FriendRequest = 'FriendRequest',
	Rejected = 'Rejected'
}

local FriendListSidebar = {
	friends = {},
	width = 250,
	x = 0,
	y = 0
}

function FriendListSidebar:load()
	self.friends = UserApi:get_friends()
	self.x = love.graphics.getWidth() - self.width
end

function FriendListSidebar:draw(screen)
	self.x = love.graphics.getWidth() - self.width

	love.graphics.setColor(0.1, 0.1, 0.1, 0.8)
	love.graphics.rectangle('fill', self.x, self.y, self.width, love.graphics.getHeight())
	love.graphics.setColor(1, 1, 1, 1)

	Suit.Label('Friends', self.x + 10, self.y + 20)

	if screen.show_add_friend_input then
		love.graphics.setFont(Fonts.jura(15))
		Suit.Input(screen.friend_input, self.x + 10, self.y + 60, 230, 30)
		love.graphics.setFont(Fonts.jura(24))
	end

	local button_y = self.y + (screen.show_add_friend_input and 100 or 60)

	love.graphics.setFont(Fonts.jura(15))
	local add_friend_button = Suit.Button('Add Friend +', self.x + 10, button_y, 230, 30)
	love.graphics.setFont(Fonts.jura(24))

	if add_friend_button.hit then
		if not screen.show_add_friend_input then
			screen.show_add_friend_input = true
		else
			if screen.friend_input.text ~= "" then
				local data = UserApi:add_friend(screen.friend_input.text)

				if not data.success then
					Alert:show(data.body.error, 'we could not find the user ' .. screen.friend_input.text, 3)
				else
					Alert:show('Friend Request Sent', nil, 3)
					screen.friend_input.text = ""
					screen.show_add_friend_input = false
				end
			end
		end
	end

	local friend_y = button_y + 40

	if #self.friends > 0 then
		for i, friend in ipairs(self.friends) do
			if friend.relationship_type == RelationshipType.FriendRequest then
				love.graphics.setFont(Fonts.jura(15))
				Suit.Label('* wants to be your friend', self.x + 10, friend_y)
				love.graphics.setFont(Fonts.jura(24))
				Suit.Label(friend.requester_username, self.x + 10, friend_y + 15)

				local accept_button = Suit.Button('Accept', self.x + 10, i * friend_y + 50, 230, 30)
				local reject_button = Suit.Button('Reject', self.x + 10, i * friend_y + 90, 230, 30)

				if accept_button.hit then
					UserApi:accept_friend_request(friend.id)
					self.friends = UserApi:get_friends()
				end

				if reject_button.hit then
					UserApi:reject_friend_request(friend.id)
					self.friends = UserApi:get_friends()
				end
			end

			if friend.relationship_type == RelationshipType.Friend then
				love.graphics.setFont(Fonts.jura(20))
				Suit.Label(friend.requester_username, self.x + 10, friend_y)
			end
		end
	else
		love.graphics.setFont(Fonts.jura(15))
		Suit.Label('No friends found', self.x + 10, friend_y)
		Suit.Label('Add friends to play against them', self.x + 10, friend_y + 30)
		love.graphics.setFont(Fonts.jura(24))
	end
end

return FriendListSidebar
