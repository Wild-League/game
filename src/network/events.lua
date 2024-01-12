local Events = {
	-- when the client connect to the server
	Connect = 'connect',
	-- when the client disconnect to the server, for any reason
	-- this also applies to when the match finishes
	Disconnect = 'disconnect',
	-- when start the search for a match in the game state `queue`
	Matchmaking = 'matchmaking',
	-- when the user leave the game state `queue`
	CancelMatchmaking = 'cancel_matchmaking',
	-- when match was found, it should occur after matchmaking event
	MatchFound = 'match_found',
	-- represent any object sent, like a card played.
	Object = 'object',
	-- represent any object sent, like a card played. (from enemy)
	EnemyObject = 'enemy_object',
}

return Events
