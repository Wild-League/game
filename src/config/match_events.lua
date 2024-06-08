local MatchEvents = {
	-- CARD RELATED EVENTS
	-- send x, y, card_id
	card_spawn = 0,
	-- send x, y and card_id
	card_position = 1,
	-- send card_id and action (attack, walk, death ...)
	card_action = 2,
	-- send card_id (remove the card from the game)
	card_dead = 3,
	-- send card_id and damage (this is for the card receiving the damage)
	card_damage = 4,
	-- send card_id and healing (this is for the card receiving the healing)
	card_healing = 5,

	-- TOWER RELATED EVENTS
	-- tower_id and damage
	tower_damage = 6,
	-- tower_id and healing
	tower_healing = 7,
	-- (tower_id) the tower being destroyed
	tower_destroy = 8
}

return MatchEvents
