local uuid = {
	random = math.random
}

function uuid:generate()
	local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'

	return string.gsub(template, '[xy]', function (c)
		local v = (c == 'x') and self.random(0, 0xf) or self.random(8, 0xb)
		return string.format('%x', v)
	end)
end

return uuid
