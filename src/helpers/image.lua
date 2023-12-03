local https = require('https')

local Image = {}

--[[
	try to load the image from the url, otherwise
	return default card image
]]
function Image:load_from_url(url, file_name)
	local code, image = https.request(url)

	local missing_card = love.graphics.newImage('assets/missing-card.png')

	if code ~= 200 then return missing_card end

	if image then
		local file_data = love.filesystem.newFileData(image, file_name)

		local new_image = love.graphics.newImage(
			love.image.newImageData(file_data)
		)

		return new_image
	end

	return missing_card
end

return Image
