local Constants = require('src.constants')
local https = require('https')
local json = require('lib.json')
local BaseApi = require('src.api.base')
local Utils = require('src.helpers.utils')

local DeckApi = {}

local function decode_json_or_nil(response)
	local payload = Utils.trim(response)
	if payload == '' then return nil end

	local first_char = payload:sub(1, 1)
	local is_json = first_char == '{' or first_char == '['
	if not is_json then return nil end

	return json.decode(payload)
end

function DeckApi:get_list()
	local url = BaseApi:get_resource_url('deck')
	local _, response = https.request(url, {
		method = 'GET',
		headers = {
			Authorization = 'Bearer ' .. Constants.ACCESS_TOKEN,
		},
	})

	return decode_json_or_nil(response) or {}
end

function DeckApi:get_current_deck()
	local url = BaseApi:get_resource_url('deck') .. '/current/'

	local _, response = https.request(url, {
		method = 'GET',
		headers = {
			Authorization = 'Bearer ' .. Constants.ACCESS_TOKEN,
		},
	})

	return decode_json_or_nil(response)
end

function DeckApi:get_deck_by_id(id)
	local url = BaseApi:get_resource_url('deck') .. '/' .. id .. '/'

	local _, response = https.request(url, {
		method = 'GET',
		headers = {
			Authorization = 'Bearer ' .. Constants.ACCESS_TOKEN,
		},
	})

	return decode_json_or_nil(response)
end

function DeckApi:set_selected_declk(id)
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


	print('Deck selection response: ', decode_json_or_nil(response))
end

return DeckApi
