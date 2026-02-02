require "yan"

local ui = {}

function MenuButton(color, text, position)
    return imagelabel:new {
        size = UDim2.new(0, 300, 0, 100),
        position = position,
        anchorpoint = Vector2.new(0.5, 0.5),
        image = "img/btn_"..color..".png",
        backgroundcolor = Color.new(0,0,0,0),
        children = {
            label = textlabel:new {
                text = text,
                size = UDim2.new(1,0,1,0),
                textsize = 45,
                fontpath = "LTSuperior.ttf",
                backgroundcolor = Color.new(0,0,0,0),
                textcolor = Color.new(1,1,1,1)
            }
        },
        mouseenter = function (btn)
            tween:new(btn, TweenInfo.new(0.2, EasingStyle.CubicOut), {size = UDim2.new(0, 305, 0, 105)}):play()
        end,
        mouseexit = function (btn)
            btn.image = "img/btn_"..color..".png"
            tween:new(btn, TweenInfo.new(0.2, EasingStyle.CubicOut), {size = UDim2.new(0, 300, 0, 100)}):play()
        end,
        mousebutton1down = function (btn)
            btn.image = "img/btn_"..color.."_pressed.png"
            tween:new(btn, TweenInfo.new(0.2, EasingStyle.CubicOut), {size = UDim2.new(0, 290, 0, 95)}):play()
        end,
        mousebutton1up = function (btn)
            btn.image = "img/btn_"..color..".png"
            tween:new(btn, TweenInfo.new(0.2, EasingStyle.CubicOut), {size = UDim2.new(0, 305, 0, 105)}):play()
        end
    }
end

function ui:init()
    self.screen = screen:new {
        logo = imagelabel:new {
            size = UDim2.new(0,420,0,180),
            position = UDim2.new(0.5,0,0,25),
            anchorpoint = Vector2.new(0.5,0),
            image = "img/logo.png",
            backgroundcolor = Color.new(0,0,0,0)
        },

        play = MenuButton("green", "Play Levels", UDim2.new(0,200,0,300)),
        create = MenuButton("blue", "Create Levels", UDim2.new(0,200,0,410)),
        quit = MenuButton("red", "Exit", UDim2.new(0,200,0,520))
    }

    
end

return ui