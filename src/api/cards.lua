local Constants = require('src.constants')
local https = require('https')
local BaseApi = require('src.api.base')

local CardsApi = {}

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

	local decoded = BaseApi:decode_json_or_nil(response)
	return decoded or {}
end

return CardsApi
