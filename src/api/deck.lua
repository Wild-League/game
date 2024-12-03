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
	local body = json.encode({
		id = id
	})

	local headers = {
		['Content-Type'] = 'application/json',
		['Content-Lenght'] = #body
	}

	local url_change_deck = BaseApi:get_resource_url('deck') .. '/select/'

	local _, response = https.request(url_change_deck, {
		data = body,
		method = 'POST',
		headers = headers
	})


	print('Deck selection response: ', json.decode(response))
end

function DeckApi:set_selected_deck(id)
	local url = BaseApi:get_resource_url('deck') .. '/' .. 'select' .. '/'

	local _, response = https.request(url, {
		method = 'POST',
		headers = {
			Authorization = 'Bearer ' .. Constants.ACCESS_TOKEN,
		},
	})

	return json.decode(response)
end

return DeckApi
