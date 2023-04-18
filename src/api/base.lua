local Base = {
	current = 'dev',

	dev = {
		base_url = 'http://localhost:9090'
	},
	prod = {
		base_url = 'https://api-wild-league-production.up.railway.app'
	}
}

return Base
