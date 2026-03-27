local MatchEvents = {
	-- legacy card events
	card_spawn = 0,
	card_position = 1,
	card_action = 2,
	card_dead = 3,
	card_damage = 4,
	card_healing = 5,
	tower_damage = 6,
	tower_healing = 7,
	tower_destroy = 8,

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
