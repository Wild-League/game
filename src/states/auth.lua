local Suit = require('lib.suit')
local Images = require('src.ui.images')
local Constants = require('src.constants')
local UserApi = require('src.api.user')
local json = require('lib.json')

local Auth = {
	signin_username = { text = 'ropoko' },
	signin_password = { text = 'password@123' },

	signup_username = { text = 'ropoko2' },
	signup_email = { text = 'ropoko2@gmail.com' },
	signup_password = { text = 'password@123' },

	background = nil
}

function Auth:load()
	self.background = Images.background_cloud or Constants.WORLD_BACKGROUND
end

function Auth:update(dt)
	local width = love.graphics.getWidth()
	local inputWidth = 300
	local inputHeight = 40
	local buttonHeight = 50
	local startY = 200

	-- Sign In
	Suit.Label('Sign In', { align = 'center', color = { normal = { fg = { 0, 0, 0 } } }}, width/4 - inputWidth/2, startY, inputWidth, inputHeight)
	Suit.Input(self.signin_username, width/4 - inputWidth/2, startY + 70, inputWidth, inputHeight)
	Suit.Input(self.signin_password, width/4 - inputWidth/2, startY + 140, inputWidth, inputHeight)

	local signin_button = Suit.Button('Sign In', width/4 - inputWidth/2, startY + 280, inputWidth, buttonHeight)

	if signin_button.hit then
		local data = UserApi:signin(self.signin_username.text, self.signin_password.text)
		Constants.ACCESS_TOKEN = data.access
		Constants.REFRESH_TOKEN = data.refresh
		CONTEXT:change('lobby')
	end

	-- Sign Up
	Suit.Label('Sign Up', { align = 'center', color = { normal = { fg = { 0, 0, 0 } } }}, width/4*3 - inputWidth/2, startY, inputWidth, inputHeight)
	Suit.Input(self.signup_username, width/4*3 - inputWidth/2, startY + 70, inputWidth, inputHeight)
	Suit.Input(self.signup_email, width/4*3 - inputWidth/2, startY + 140, inputWidth, inputHeight)
	Suit.Input(self.signup_password, width/4*3 - inputWidth/2, startY + 210, inputWidth, inputHeight)

	local signup_button = Suit.Button('Sign Up', width/4*3 - inputWidth/2, startY + 280, inputWidth, buttonHeight)

	if signup_button.hit then
		local data = UserApi:signup(self.signup_username.text, self.signup_email.text, self.signup_password.text)

		if data.success then
			local signin_data = UserApi:signin(self.signup_username.text, self.signup_password.text)
			Constants.ACCESS_TOKEN = signin_data.access
			Constants.REFRESH_TOKEN = signin_data.refresh
			CONTEXT:change('lobby')
		end
	end
end

function Auth:draw()
	love.graphics.draw(
		self.background,
		0, 0, 0,
		love.graphics.getWidth() / self.background:getWidth(),
		love.graphics.getHeight() / self.background:getHeight()
	)

	local width = love.graphics.getWidth()
	love.graphics.line(width/2, 50, width/2, 450)
end

return Auth
