local Saver = {}

local User = require '../src/entities/user'
local Lume = require '../../lib/lume'

local path = '/savedata.txt'

function Saver:save(user)
	print('saving data...')

	local serialized_data = Lume.serialize({ nickname = user.nickname })

	love.filesystem.write(path, serialized_data)
end

function Saver:retrieveData()
	print('getting data...')

	if love.filesystem.getInfo(path) then
		local file = love.filesystem.read(path)
		return Lume.deserialize(file)
	end

	return nil
end

return Saver
