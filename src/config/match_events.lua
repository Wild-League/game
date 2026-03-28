local MatchEvents = {
	-- authoritative protocol: client intents
	spawn_intent = 20,
	command_intent = 21,

	-- authoritative protocol: server snapshots/deltas
	state_snapshot = 30,
	entity_spawned = 31,
	entity_updated = 32,
	entity_removed = 33,
	damage_event = 34,
	tower_event = 35,
	match_end = 36,
	reject_intent = 37
}

return MatchEvents
