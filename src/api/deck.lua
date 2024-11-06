local Constants = require('src.constants')
local https = require('https')
local json = require('lib.json')
local BaseApi = require('src.api.base')

local DeckApi = {}

function DeckApi:get_list()
	local url = BaseApi:get_resource_url('deck')

	local _, response = https.request(url, {
		method = 'GET',
		headers = {
			Authorization = 'Bearer ' .. Constants.ACCESS_TOKEN,
		},
	})

	return json.decode(response)
end

return DeckApi
