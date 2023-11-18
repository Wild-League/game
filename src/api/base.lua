local Base = {
	current = 'dev',

	dev = {
		base_url = 'http://localhost:9090/api/'
	},
	prod = {
		base_url = 'https://api.wildleague.org/api/'
	}
}

return Base
