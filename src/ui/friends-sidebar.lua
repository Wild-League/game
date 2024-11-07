local FriendsSidebar = {}

function FriendsSidebar.draw(suit, fonts, screen)
    local sidebar_width = 250
    local sidebar_x = love.graphics.getWidth() - sidebar_width
    local sidebar_y = 0

    love.graphics.setColor(0.1, 0.1, 0.1, 0.8)
    love.graphics.rectangle('fill', sidebar_x, sidebar_y, sidebar_width,
                            love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1, 1)

    suit.Label('Friends', sidebar_x + 10, sidebar_y + 20)

    if screen.show_add_friend_input then
        love.graphics.setFont(fonts.jura(15))
        suit.Input(screen.friend_input, sidebar_x + 10, sidebar_y + 60, 230, 30)
        love.graphics.setFont(fonts.jura(24))
    end

    local button_y = sidebar_y + (screen.show_add_friend_input and 100 or 60)
    love.graphics.setFont(fonts.jura(15))
    local add_friend_button = suit.Button('Add Friend +', sidebar_x + 10,
                                          button_y, 230, 30)
    love.graphics.setFont(fonts.jura(24))

    if add_friend_button.hit then
        if not screen.show_add_friend_input then
            screen.show_add_friend_input = true
        else
            if screen.friend_input.text ~= "" then

                print("Adding friend: " .. screen.friend_input.text)
                screen.friend_input.text = ""
            end

            screen.show_add_friend_input = false
        end
    end

    local friend_y = button_y + 40

    if #screen.friends > 0 then
        for i, friend in ipairs(screen.friends) do
            suit.Label((friend.name or "Friend ") .. i, sidebar_x + 10, friend_y)
            -- local status_color = friend.online and {0, 1, 0} or {0.5, 0.5, 0.5}

            -- love.graphics.setColor(unpack(status_color))
            love.graphics.circle('fill', sidebar_x + sidebar_width - 20,
                                 friend_y + 8, 5)
            love.graphics.setColor(1, 1, 1, 1)
            friend_y = friend_y + 30
        end
    else
        love.graphics.setFont(fonts.jura(15))
        suit.Label('No friends found', sidebar_x + 10, friend_y)
        suit.Label('Add friends to play against them', sidebar_x + 10,
                   friend_y + 30)
        love.graphics.setFont(fonts.jura(24))
    end

end

return FriendsSidebar;
