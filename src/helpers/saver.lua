local Saver = {}

-- local user = require('../src/entities/user')

-- for k, v in ipairs(getmetatable(user).__index) do
-- 	print(k, v)
-- end

function Saver:save(data)
	print('saving data...')
	-- love.filesystem.write('/tmp/card-game/data.txt', data)
end

return Saver
