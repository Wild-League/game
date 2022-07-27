local function Teste(name)
	local obj = {
		name = name
	}
	obj.__index = obj
	setmetatable(obj, {})

	function obj.new(name)
		if obj._instance then
			return obj._instance
		end

		local instance = setmetatable({}, obj)
		if instance.ctor then
			instance:ctor(name)
		end

		obj._instance = instance
		return obj._instance
	end

	return obj
end

local class = Teste('ropoko')
local a = class.new()
local b = class.new()

-- a.name = 'asd'

print(a.teste)
print(b.name)
