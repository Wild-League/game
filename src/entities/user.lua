local function User(nickname)
	local obj = {
		__call = function(self)
			return self.new()
		end,

		__tostring = function(self)
			return string.format('nickname: %s', self.nickname)
		end,

		nickname = nickname
	}

	obj.__index = obj

	setmetatable(obj, {})

	function obj.new()
		if obj._instance then
			return obj._instance
		end

		local instance = setmetatable({}, obj)

		obj._instance = instance
		return obj._instance
	end

	return obj
end

return User
