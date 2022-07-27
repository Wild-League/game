local Saver = {}

local user = require('../src/entities/user')

function Saver:save(data)
	print(user)
	print('saving data...')
	-- love.filesystem.write('/tmp/card-game/data.txt', data)
end

return Saver
