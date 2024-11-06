local Map = {image_width = 0, image_height = 0, scale_x = 1, scale_y = 1 }

local tile_size_const = 32
local map_scale_const = 1.25
function Map:load()

    self.initial_width, self.initial_height = love.graphics.getWidth(),
                                              love.graphics.getHeight()

    self.image_width, self.image_height =
        self.initial_width * (self.scale_x / map_scale_const),
        self.initial_height * (self.scale_x / map_scale_const)

    self.image = love.graphics.newImage("assets/map/wild map.png")
    self.image:setFilter("nearest", "nearest")

end

function Map:update(dt) end

function Map:draw()

    local lasting_tiles = (love.graphics.getWidth() - Map.image_width) /
                              tile_size_const

    love.graphics.draw(self.image, tile_size_const * (lasting_tiles / 2), 0, 0,
                       self.scale_x / map_scale_const,
                       self.scale_y / map_scale_const)
end

function love.resize(w, h)
    Map.scale_x = w / Map.image:getWidth()
    Map.scale_y = h / Map.image:getHeight()

    Map.image_width, Map.image_height = Map.initial_width *
                                            (Map.scale_x / map_scale_const),
                                        Map.initial_height *
                                            (Map.scale_x / map_scale_const)
end

return Map
