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

local function auth_headers(with_json_body)
	local h = {
		Authorization = 'Bearer ' .. Constants.ACCESS_TOKEN,
	}
	if with_json_body then
		h['Content-Type'] = 'application/json'
	end
	return h
end

local function request_json(method, url, body)
	local headers = auth_headers(body ~= nil)
	if body then
		headers['Content-Length'] = tostring(#body)
	end
	local code, response = https.request(url, {
		method = method,
		headers = headers,
		data = body,
	})
	return code, decode_json_or_nil(response)
end

function DeckApi:get_list()
	local url = BaseApi:get_resource_url('deck') .. '/'
	local _, response = https.request(url, {
		method = 'GET',
		headers = auth_headers(false),
	})

	return decode_json_or_nil(response) or {}
end

function DeckApi:get_current_deck()
	local url = BaseApi:get_resource_url('deck') .. '/current/'

	local _, response = https.request(url, {
		method = 'GET',
		headers = auth_headers(false),
	})

	return decode_json_or_nil(response)
end

function DeckApi:get_deck_by_id(id)
	local url = BaseApi:get_resource_url('deck') .. '/' .. id .. '/'

	local _, response = https.request(url, {
		method = 'GET',
		headers = auth_headers(false),
	})

	return decode_json_or_nil(response)
end

function DeckApi:create_deck(name)
	local url = BaseApi:get_resource_url('deck') .. '/'
	local body = json.encode({ name = name })
	return request_json('POST', url, body)
end

function DeckApi:patch_deck(id, name)
	local url = BaseApi:get_resource_url('deck') .. '/' .. id .. '/'
	local body = json.encode({ name = name })
	return request_json('PATCH', url, body)
end

function DeckApi:delete_deck(id)
	local url = BaseApi:get_resource_url('deck') .. '/' .. id .. '/'
	local code, _ = https.request(url, {
		method = 'DELETE',
		headers = auth_headers(false),
	})
	return code
end

--[[
	POST /decks/{id}/set_cards/ body: { "card_ids": [1,2,3] }
	Returns HTTP status and decoded body (deck with cards) on success.
]]
function DeckApi:set_deck_cards(id, card_ids)
	local url = BaseApi:get_resource_url('deck') .. '/' .. id .. '/set_cards/'
	local body = json.encode({ card_ids = card_ids })
	return request_json('POST', url, body)
end

function DeckApi:set_selected_deck(id)
	local url = BaseApi:get_resource_url('deck') .. '/select/'
	local body = json.encode({ id = id })
	return request_json('POST', url, body)
end

return DeckApi
