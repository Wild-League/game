local Fonts = require('src.ui.fonts')
local Suit = require('lib.suit')

local HeaderBar = {}
function HeaderBar:draw(label, screen)
  love.graphics.setColor(0.1, 0.1, 0.1, 0.8)
  love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), 50)
  love.graphics.setColor(1, 1, 1, 1)

  love.graphics.setFont(Fonts.jura(20))
  local deck_builder_btn = Suit.Button(label, 20, 10, 150, 30)
  love.graphics.setFont(Fonts.jura(24))

  if deck_builder_btn.hit then CONTEXT:change(screen) end
end

return HeaderBar
