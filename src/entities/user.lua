local User = {}

local meta = {
	__call = function(self, name, age)
		return self.new(name, age)
	end,

	__index = function(self, key)
		error(string.format('the key: "%s" is not set in User Entity', key))
	end,

	__tostring = function(self)
		return string.format('name: %s, age: %d', self.name, self.age)
	end
}

setmetatable(User, meta)

function User.new(name, age)
	local user = setmetatable({}, meta)
	user.name = name
	user.age = age
	return user
end

return User
