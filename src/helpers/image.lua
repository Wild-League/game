local https = require('https')
local Constants = require('src.constants')

local Image = {
	missing_card = love.graphics.newImage('assets/missing-card.png')
}

--[[
	try to load the image from the url, otherwise
	return default card image
]]
function Image:load_from_url(url, file_name)
	if not url or type(url) ~= 'string' or url == '' then
		return self.missing_card
	end

	local code, image = https.request(url, { method = 'GET' })

	-- Some storage backends (e.g. SeaweedFS public buckets) reject requests
	-- when Authorization header is present. Retry with bearer only when needed.
	if (code == 401 or code == 403) and Constants.ACCESS_TOKEN and Constants.ACCESS_TOKEN ~= '' then
		code, image = https.request(url, {
			method = 'GET',
			headers = {
				Authorization = 'Bearer ' .. Constants.ACCESS_TOKEN
			}
		})
	end

	if code ~= 200 then
		print(string.format('[IMAGE LOAD] failed code=%s url=%s', tostring(code), tostring(url)))
		return self.missing_card
	end

	if image then
		local file_data = love.filesystem.newFileData(image, file_name)

		local new_image = love.graphics.newImage(
			love.image.newImageData(file_data)
		)

		return new_image
	end

	return self.missing_card
end

return Image
