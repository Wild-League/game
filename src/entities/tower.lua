local Layout = require('src.helpers.layout')
local Assets = require('src.assets')

local Tower = {}

local default_props = {
    type = 'tower',
    life = 100,
    current_life = 100,
    w = Assets.TOWER:getWidth(),
    h = Assets.TOWER:getHeight(),
    scale_x = 1 --Escala usada para espelhar a torre
}

function Tower:load(side, position)
    if side ~= 'left' and side ~= 'right' then
        error('Invalid side for Tower')
    end

    if position ~= 'top' and position ~= 'bottom' then
        error('Invalid position for Tower')
    end

    -- Calcular a posição central baseada nas dimensões da tela
    local center = {
        width = love.graphics.getWidth() / 2,
        height = love.graphics.getHeight() / 2
    }

    -- Definir as posições baseadas no centro da tela
    local positions = {
        left = {
            top = {
                x = center.width - 470,
                y = center.height - 180,
                scale_x = -1
            },
            bottom = {
                x = center.width - 470,
                y = center.height + 200,
                scale_x = -1
            }
        },
        right = {
            top = {
                x = center.width + 470,
                y = center.height - 180,
                scale_x = 1 -- Normal
            },
            bottom = {
                x = center.width + 470,
                y = center.height + 200,
                scale_x = 1
            }
        }
    }

    local tower = {}

    for key, value in pairs(default_props) do
        tower[key] = value
    end

    tower.char_x = positions[side][position].x
    tower.char_y = positions[side][position].y
    tower.img = Assets.TOWER
    tower.scale_x = positions[side][position].scale_x

    tower.update = function(tower_, dt)
        return Tower.update(tower_, dt)
    end

    tower.draw = function(tower_, current_life)
        return Tower.draw(tower_, current_life)
    end

    setmetatable(tower, self)
    self.__index = self

    return tower
end

function Tower:update(dt)
    -- Lógica de atualização da torre (se necessário)
end
function Tower.draw(tower_, current_life)
    love.graphics.draw(tower_.img, tower_.char_x, tower_.char_y, 0, tower_.scale_x, 1, tower_.w / 2, tower_.h / 2)

    local lifebar_x = tower_.char_x - (100 / 2)  -- Centraliza a lifebar com o tamanho da tower no eixo X
    local lifebar_y = tower_.char_y - tower_.h / 2 - 10  -- Coloca a lifebar logo acima da tower
    Tower:lifebar(lifebar_x, lifebar_y, current_life)
end

function Tower:lifebar(x, y, current_life)
    love.graphics.setColor(0/255, 255/255, 0/255)
    love.graphics.rectangle("line", x, y, 100, 5)
    love.graphics.rectangle("fill", x, y, current_life, 5)
    love.graphics.setColor(255, 255, 255)
end

return Tower
