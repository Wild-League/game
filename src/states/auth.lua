local Suit = require('lib.suit')
local Images = require('src.ui.images')
local Constants = require('src.constants')
local UserApi = require('src.api.user')
local nakama = require('lib.nakama.nakama')
local socket = require('lib.nakama.socket')
local love2d = require('lib.nakama.engine.love2d')
local BaseApi = require('src.api.base')
local Toast = require('src.ui.toast')

local function read_error_message(data, fallback)
	if data == nil then return fallback end
	if data.error ~= nil and data.error ~= '' then return data.error end
	if data.detail ~= nil and data.detail ~= '' then return data.detail end
	if data.message ~= nil and data.message ~= '' then return data.message end
	return fallback
end

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

	-- Login
	Suit.Label('Login', { align = 'center', color = { normal = { fg = { 0, 0, 0 } } } }, width / 4 - inputWidth / 2,
		startY - 55, inputWidth, inputHeight)
	Suit.Label('Welcome back!', { align = 'center', color = { normal = { fg = { 0.1, 0.1, 0.1 } } } },
		width / 4 - inputWidth / 2, startY - 20, inputWidth, inputHeight)
	Suit.Input(self.signin_username, width / 4 - inputWidth / 2, startY + 55, inputWidth, inputHeight)
	Suit.Input(self.signin_password, width / 4 - inputWidth / 2, startY + 125, inputWidth, inputHeight)

	local signin_button = Suit.Button('Sign In', width / 4 - inputWidth / 2, startY + 250, inputWidth, buttonHeight)

	if signin_button.hit then
		local data = UserApi:signin(self.signin_username.text, self.signin_password.text)

		Constants.ACCESS_TOKEN = data.access or ''
		Constants.REFRESH_TOKEN = data.refresh or ''

		if Constants.ACCESS_TOKEN == '' then
			Toast:error(read_error_message(data, 'Unable to login. Check credentials and try again.'), 4, 'Login Failed')
			return
		end

		self:auth_multiplayer_server(self.signin_username.text, self.signin_username.text, self.signin_password.text)

		Toast:success('Logged in successfully.', 2.5, 'Welcome')
		CONTEXT:change('lobby')
	end

	-- Sign Up
	Suit.Label("Don't have an account?", { align = 'center', color = { normal = { fg = { 0, 0, 0 } } } },
		width / 4 * 3 - inputWidth / 2, startY - 55, inputWidth, inputHeight)
	Suit.Input(self.signup_username, width / 4 * 3 - inputWidth / 2, startY + 55, inputWidth, inputHeight)
	Suit.Input(self.signup_email, width / 4 * 3 - inputWidth / 2, startY + 125, inputWidth, inputHeight)
	Suit.Input(self.signup_password, width / 4 * 3 - inputWidth / 2, startY + 195, inputWidth, inputHeight)

	local signup_button = Suit.Button('Sign Up', width / 4 * 3 - inputWidth / 2, startY + 280, inputWidth, buttonHeight)

	if signup_button.hit then
		local data = UserApi:signup(self.signup_username.text, self.signup_email.text, self.signup_password.text)

		if data.success then
			local signin_data = UserApi:signin(self.signup_username.text, self.signup_password.text)
			Constants.ACCESS_TOKEN = signin_data.access or ''
			Constants.REFRESH_TOKEN = signin_data.refresh or ''

			if Constants.ACCESS_TOKEN == '' then
				Toast:warning('Account created, but auto login failed. Please sign in manually.', 4, 'Sign Up')
				return
			end

			self:auth_multiplayer_server(self.signup_username.text, self.signup_email.text, self.signup_password.text)

			Toast:success('Account created successfully.', 3, 'Sign Up')
			CONTEXT:change('lobby')
		else
			Toast:error(read_error_message(data, 'Unable to create account right now.'), 4, 'Sign Up Failed')
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
	love.graphics.line(width / 2, 50, width / 2, 450)
end

function Auth:auth_multiplayer_server(username, email, password)
	local client = nakama.create_client({
		host = BaseApi[BaseApi.current].multiplayer_server_url,
		port = BaseApi[BaseApi.current].multiplayer_server_port,
		username = 'defaultkey',
		password = '',
		engine = love2d
	})

	local me = UserApi:get_me()

	Constants.NAKAMA_CLIENT = client

	coroutine.resume(coroutine.create(function()
		local result = nakama.authenticate_email(client, me.email, password, { level = "1" }, true, username)

		if result then
			Constants.USER_ID = result.user_id
			nakama.set_bearer_token(client, result.token)
		end

		Constants.SOCKET_CONNECTION = nakama.create_socket(client)
		socket.connect(Constants.SOCKET_CONNECTION)
	end))
end

function Auth:resize()

end

return Auth
