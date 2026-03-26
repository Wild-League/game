local Suit = require('lib.suit')
local Images = require('src.ui.images')
local Constants = require('src.constants')
local UserApi = require('src.api.user')
local nakama = require('lib.nakama.nakama')
local socket = require('lib.nakama.socket')
local love2d = require('lib.nakama.engine.love2d')
local BaseApi = require('src.api.base')
local Toast = require('src.ui.toast')
local Utils = require('src.helpers.utils')

local skip_error_keys = {
	success = true,
	status = true,
	access = true,
	refresh = true,
}

-- e.g. { "non_field_errors": ["..."] }, per-field lists, or { "detail": "..." }
local function format_errors(data)
	if data == nil or type(data) ~= 'table' then return nil end
	if type(data.detail) == 'string' and data.detail ~= '' then
		return data.detail
	end
	local parts = {}
	if data.non_field_errors ~= nil then
		local nfe = data.non_field_errors
		if type(nfe) == 'table' then
			for _, msg in ipairs(nfe) do
				table.insert(parts, tostring(msg))
			end
		else
			table.insert(parts, tostring(nfe))
		end
	end
	for key, val in pairs(data) do
		if not skip_error_keys[key] and key ~= 'non_field_errors' then
			if type(val) == 'table' then
				local msgs = {}
				for _, msg in ipairs(val) do
					table.insert(msgs, tostring(msg))
				end
				if #msgs > 0 then
					table.insert(parts, key .. ': ' .. table.concat(msgs, ' '))
				end
			elseif type(val) == 'string' then
				table.insert(parts, key .. ': ' .. val)
			end
		end
	end
	if #parts > 0 then
		return table.concat(parts, ' · ')
	end
	return nil
end

local function read_error_message(data, fallback)
	if data == nil then return fallback end
	local formatted = format_errors(data)
	if formatted ~= nil and formatted ~= '' then return formatted end
	if data.error ~= nil and data.error ~= '' then return tostring(data.error) end
	if data.detail ~= nil and data.detail ~= '' then return tostring(data.detail) end
	if data.message ~= nil and data.message ~= '' then return tostring(data.message) end
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
		local li_user = Utils.trim(self.signin_username.text)
		local li_pass = self.signin_password.text
		local data = UserApi:signin(li_user, li_pass)

		Constants.ACCESS_TOKEN = data.access or ''
		Constants.REFRESH_TOKEN = data.refresh or ''

		if Constants.ACCESS_TOKEN == '' then
			Toast:error(read_error_message(data, 'Unable to login. Check credentials and try again.'), 4, 'Login Failed')
			return
		end

		self:auth_multiplayer_server(li_user, li_user, li_pass)

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
		local su = Utils.trim(self.signup_username.text)
		local se = Utils.trim(self.signup_email.text)
		local sp = self.signup_password.text

		if su == '' or se == '' or sp == '' then
			Toast:warning('Please enter username, email, and password.', 3.5, 'Sign Up')
		else
			local data = UserApi:signup(su, se, sp)

			if data.success then
				local signin_data = UserApi:signin(su, sp)
				Constants.ACCESS_TOKEN = (signin_data and signin_data.access) or ''
				Constants.REFRESH_TOKEN = (signin_data and signin_data.refresh) or ''

				if Constants.ACCESS_TOKEN == '' then
					Toast:error(
						read_error_message(signin_data, 'Account created, but sign-in failed. Try logging in manually.'),
						5,
						'Sign Up'
					)
				else
					self:auth_multiplayer_server(su, se, sp)
					Toast:success('Welcome! Your account is ready.', 3, 'Sign Up')
					CONTEXT:change('lobby')
				end
			else
				Toast:error(read_error_message(data, 'Unable to create account. Try again.'), 5, 'Sign Up Failed')
			end
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
