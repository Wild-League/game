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

function DeckApi:get_current_deck()
	local url = BaseApi:get_resource_url('deck') .. '/current/'

	local _, response = https.request(url, {
		method = 'GET',
		headers = {
			Authorization = 'Bearer ' .. Constants.ACCESS_TOKEN,
		},
	})

	return json.decode(response)
end

function DeckApi:get_deck_by_id(id)
	local url = BaseApi:get_resource_url('deck') .. '/' .. id .. '/'

	local _, response = https.request(url, {
		method = 'GET',
		headers = {
			Authorization = 'Bearer ' .. Constants.ACCESS_TOKEN,
		},
	})

	return json.decode(response)
end

return DeckApi
