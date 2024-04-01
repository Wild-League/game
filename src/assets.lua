local Assets = {
	-- BACKGROUND_INITIAL = love.graphics.newImage('assets/initial-background.png'),
	-- BUTTON = love.graphics.newImage('assets/button-play.png'),
	-- BUTTON_HOVER = love.graphics.newImage('assets/button-play-hover.png'),
	-- WORLD = love.graphics.newImage('assets/world.png'),
	-- TOWER_LEFT = love.graphics.newImage('assets/tower-left.png'),
	-- TOWER_RIGHT = love.graphics.newImage('assets/tower-right.png'),
	-- CHAR1 = {
	-- 	WALKING = love.graphics.newImage('assets/chars/char1/animations/walking-left.png'),
	-- 	CARD = love.graphics.newImage('assets/chars/char1/card.png'),
	-- 	ATTACK = love.graphics.newImage('assets/chars/char1/animations/attack.png'),
	-- 	SHOOT = love.graphics.newImage('assets/chars/char1/animations/shoot.png'),
	-- 	INITIAL = love.graphics.newImage('assets/chars/char1/initial.png')
	-- },
	-- WORLD_DETAIL = love.graphics.newImage('assets/world-detail.png'),
	-- DINO = {
	-- 	WALKING = love.graphics.newImage('assets/dino/walk.png'),
	-- 	CARD = love.graphics.newImage('assets/dino/card.png')
	-- }
}

setmetatable(Assets, {
	__index = function(key)
		error(string.format('the assets: "%s" is not set in assets', key))
	end
})

return Assets
