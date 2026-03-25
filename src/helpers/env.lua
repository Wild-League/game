--[[
Loads dotenv-style files from the game root (same directory as main.lua).

- ENV=prod → reads .env.prod
- otherwise → reads .env

Missing file is fine: BaseApi and others fall back to defaults.
Call order: require this module before src.context (see main.lua).
]]

local Env = {
	_values = {},
}

local function trim(s)
	if not s then
		return ''
	end
	return (s:gsub('^%s+', ''):gsub('%s+$', ''))
end

local function parse(contents)
	local out = {}
	if not contents or contents == '' then
		return out
	end
	for line in contents:gmatch('[^\r\n]+') do
		line = trim(line)
		if line ~= '' and line:sub(1, 1) ~= '#' then
			local eq = line:find('=')
			if eq then
				local key = trim(line:sub(1, eq - 1))
				local val = trim(line:sub(eq + 1))
				local q1 = val:sub(1, 1)
				local qn = val:sub(-1)
				if #val >= 2 and q1 == qn and (q1 == '"' or q1 == "'") then
					val = val:sub(2, -2)
				end
				if key ~= '' then
					out[key] = val
				end
			end
		end
	end
	return out
end

local function load_from_disk()
	if not love or not love.filesystem or not love.filesystem.read then
		return {}
	end
	local mode = os.getenv('ENV') or 'dev'
	local filename = (mode == 'prod') and '.env.prod' or '.env'
	local contents = love.filesystem.read(filename)
	if not contents then
		return {}
	end
	return parse(contents)
end

Env._values = load_from_disk()

function Env.get(key)
	return Env._values[key]
end

return Env
