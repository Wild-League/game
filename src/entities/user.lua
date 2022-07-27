local user = {}

setmetatable(user, {
	__call = function(cls, name, age)
		return cls.new(name, age)
	end
})

function user.new(name, age)
	local self = setmetatable({}, user)
	self.name = name
	self.age = age
	return self
end

return user
