local Constants = require('src.constants')
local https = require('https')
local json = require('lib.json')
local BaseApi = require('src.api.base')
local Utils = require('src.helpers.utils')

local CardsApi = {}

local function decode_json_or_nil(response)
	local payload = Utils.trim(response)
	if payload == '' then return nil end

	local first_char = payload:sub(1, 1)
	local is_json = first_char == '{' or first_char == '['
	if not is_json then return nil end

	return json.decode(payload)
end

--[[
	GET /cards/?limit=
	Returns array of card objects (CardSerializer).
]]
function CardsApi:get_list(opts)
	opts = opts or {}
	local url = BaseApi:get_resource_url('cards') .. '/'
	local qs = {}
	if opts.limit ~= nil then
		table.insert(qs, 'limit=' .. tostring(opts.limit))
	end
	if #qs > 0 then
		url = url .. '?' .. table.concat(qs, '&')
	end

	local _, response = https.request(url, {
		method = 'GET',
		headers = {
			Authorization = 'Bearer ' .. Constants.ACCESS_TOKEN,
		},
	})

	local decoded = decode_json_or_nil(response)
	return decoded or {}
end

return CardsApi
