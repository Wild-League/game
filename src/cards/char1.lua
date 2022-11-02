local BaseCard = require('./src/entities/base_card')

local Char1 = BaseCard.create()

-- override default config
Char1.name = 'char1'
Char1.range = 'melee'

return Char1
