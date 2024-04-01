local Base = {
	current = 'dev',

	dev = {
		base_url = 'http://localhost:8000/v1/'
	},
	prod = {
		base_url = 'https://api.wildleague.org/v1/'
	}
}

function Base:Response(status, body, success)
	return {
		status = status,
		body = body,
		success = success
	}
end

return Base
