local Suit = require('lib.suit')
local Saver = require('src.helpers.saver')
local UserApi = require('src.api.user')
local Constants = require('src.constants')

local SignIn = {
	username_input = { text = '' },
	password_input = { text = '' },

	message_error = ''
}

function SignIn:save_token(access_token)
	Constants.ACCESS_TOKEN = access_token
end

function SignIn:load() end

function SignIn:update()
	Suit.Label('username: ', { align='center' }, 10, 0, 200, 30)
	Suit.Input(self.username_input, 10, 40, 200, 30)

	Suit.Label('password: ', { align='center' }, 10, 80, 200, 30)
	Suit.Input(self.password_input, 10, 120, 200, 30)
end

function SignIn:draw()
	local save_nick = Suit.Button('Enter', 10, 160, 200, 30)

	if self.message_error ~= '' then
		love.graphics.setColor(1,0,0)
		love.graphics.print(self.message_error, 50, 200)
		love.graphics.setColor(0,0,0)
	end

	if save_nick.hit then
		local data = UserApi:signin(self.username_input.text, self.password_input.text)

		if data.message then
			self.message_error = data.message
		end

		if data.access_token then
			self.message_error = ''
			self:save_token(data.access_token)
			CONTEXT:change('lobby')
		end
	end
end

return SignIn
