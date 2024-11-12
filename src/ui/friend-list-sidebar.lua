local json = require('lib.json')
local UserApi = require('src.api.user')
local Alert = require('src.ui.alert')

local RelationshipType = {
	Block = 'Block',
	Friend = 'Friend',
	FriendRequest = 'FriendRequest',
	Rejected = 'Rejected'
}

local FriendListSidebar = {
	friends = {}
}

function FriendListSidebar:load()
	self.friends = UserApi:get_friends()
end

function FriendListSidebar:draw(suit, fonts, screen)
	local sidebar_width = 250
	local sidebar_x = love.graphics.getWidth() - sidebar_width
	local sidebar_y = 0

	love.graphics.setColor(0.1, 0.1, 0.1, 0.8)
	love.graphics.rectangle('fill', sidebar_x, sidebar_y, sidebar_width, love.graphics.getHeight())
	love.graphics.setColor(1, 1, 1, 1)

	suit.Label('Friends', sidebar_x + 10, sidebar_y + 20)

	if screen.show_add_friend_input then
		love.graphics.setFont(fonts.jura(15))
		suit.Input(screen.friend_input, sidebar_x + 10, sidebar_y + 60, 230, 30)
		love.graphics.setFont(fonts.jura(24))
	end

	local button_y = sidebar_y + (screen.show_add_friend_input and 100 or 60)

	love.graphics.setFont(fonts.jura(15))
	local add_friend_button = suit.Button('Add Friend +', sidebar_x + 10, button_y, 230, 30)
	love.graphics.setFont(fonts.jura(24))

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
				love.graphics.setFont(fonts.jura(15))
				suit.Label('* wants to be your friend', sidebar_x + 10, friend_y)
				love.graphics.setFont(fonts.jura(24))
				suit.Label(friend.requester_username, sidebar_x + 10, friend_y + 15)

				local accept_button = suit.Button('Accept', sidebar_x + 10, i * friend_y + 50, 230, 30)
				local reject_button = suit.Button('Reject', sidebar_x + 10, i * friend_y + 90, 230, 30)

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
				love.graphics.setFont(fonts.jura(20))
				suit.Label(friend.requester_username, sidebar_x + 10, friend_y)
			end
		end
	else
		love.graphics.setFont(fonts.jura(15))
		suit.Label('No friends found', sidebar_x + 10, friend_y)
		suit.Label('Add friends to play against them', sidebar_x + 10, friend_y + 30)
		love.graphics.setFont(fonts.jura(24))
	end
end

return FriendListSidebar
