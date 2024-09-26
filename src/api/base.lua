local BaseApi = {
	current = 'prod',

	dev = {
		world_url = 'http://localhost:8000/v1/',
		host_url = 'https://host-api.wildleague.org/v1/'
	},
	prod = {
		world_url = 'https://api.wildleague.org/v1/',
		host_url = 'https://host-api.wildleague.org/v1/'
	}
}

function BaseApi:Response(status, body, success)
	return {
		status = status,
		body = body,
		success = success
	}
end

return BaseApi
