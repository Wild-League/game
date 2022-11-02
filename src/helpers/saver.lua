local Saver = {}
local Lume = require('../../lib/lume')

local Constants = require('./src/constants')
local User = require('./src/entities/user')

-- this is the default path LOVE2D sets
-- Love2D cannot write on another path, you only can do this using IO lib
-- ~/.local/share/love/wild-league/savedata.txt

local path = 'savedata.txt'

function Saver:save(user)
	if user.nickname == nil then
		error('user should have a nickname prop')
	end

	print('saving data...')

	local serialized_data = Lume.serialize({ nickname = user.nickname, level = user.level })

	Constants.LOGGED_USER = User(user.nickname, user.level)

	local res, message = love.filesystem.write(path, serialized_data)

	if res ~= true then
		error('error trying to save data. Message: '..message)
		return false
	end

	return true
end

function Saver:retrieveData()
	print('getting data... ')

	if love.filesystem.getInfo(path) then
		local file = love.filesystem.read(path)
		local data = Lume.deserialize(file)

		Constants.LOGGED_USER = User(data.nickname, data.level)

		return Constants.LOGGED_USER
	else
		love.filesystem.newFile(path)
	end

	return nil
end

return Saver
