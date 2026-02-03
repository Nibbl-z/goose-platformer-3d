require "yan"

local ui = {}

function MenuButton(color, text, position, callback)
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
            callback(btn)
        end
    }
end

function ui:enterAnim()
    self.screen:get("main"):get("play").position = UDim2.new(0,-150,0,300)
    self.screen:get("main"):get("create").position = UDim2.new(0,-150,0,410)
    self.screen:get("main"):get("quit").position = UDim2.new(0,-150,0,520)
    self.screen:get("main"):get("logo").position = UDim2.new(0.5,0,0,-150)

    tween:new(self.screen:get("main"):get("play"), TweenInfo.new(1, EasingStyle.CubicOut), {position = UDim2.new(0,200,0,300)}):play()

    tween:new(self.screen:get("main"):get("logo"), TweenInfo.new(1, EasingStyle.CubicOut), {position = UDim2.new(0.5,0,0,25)}):play()

    biribiri:CreateAndStartTimer(0.1, function ()
        tween:new(self.screen:get("main"):get("create"), TweenInfo.new(1, EasingStyle.CubicOut), {position = UDim2.new(0,200,0,410)}):play()
    end)

    biribiri:CreateAndStartTimer(0.2, function ()
        tween:new(self.screen:get("main"):get("quit"), TweenInfo.new(1, EasingStyle.CubicOut), {position = UDim2.new(0,200,0,520)}):play()
    end)
end

function ui:init()
    self.screen = screen:new {
        main = uibase:new {
            size = UDim2.new(1,0,1,0),
            backgroundcolor = Color.new(0,0,0,0),
            children = {
                logo = imagelabel:new {
                    size = UDim2.new(0,420,0,180),
                    position = UDim2.new(0.5,0,0,25),
                    anchorpoint = Vector2.new(0.5,0),
                    image = "img/logo.png",
                    backgroundcolor = Color.new(0,0,0,0)
                },
        
                play = MenuButton("green", "Play Levels", UDim2.new(0,200,0,300), function (btn)
                    tween:new(btn.parent, TweenInfo.new(1, EasingStyle.CubicOut), {position = UDim2.new(-1,0,0,0)}):play()
                    tween:new(self.screen:get("levels"), TweenInfo.new(1, EasingStyle.CubicOut), {position = UDim2.new(0,0,0,0)}):play()
                end),
                create = MenuButton("blue", "Create Levels", UDim2.new(0,200,0,410), function ()
                    currentScene = "editor"
                end),
                quit = MenuButton("red", "Exit", UDim2.new(0,200,0,520), function ()
                    love.event.quit()
                end)
            }
        },
        levels = uibase:new {
            size = UDim2.new(1,0,1,0),
            backgroundcolor = Color.new(0,0,0,0),
            position = UDim2.new(1,0,0,0),
            children = {
                levelContainer = uibase:new {
                    size = UDim2.new(1,-120,0.4,0),
                    position = UDim2.new(0,60,0,40),
                    backgroundcolor = Color.new(0.1,0.1,0.1,0.98),
                    cornerradius = UDim.new(0,16),
                    bordercolor = Color.new(1,1,1,0.5),
                    bordersize = 4,
                    clipdescendants = true,
                    children = {
                        scroller = uibase:new {
                            layout = "list",
                            listdirection = "horizontal",
                            size = UDim2.new(1,0,1,0),
                            cornerradius = UDim.new(0,16),
                            bordercolor = Color.new(1,1,1,0.5),
                            position = UDim2.new(-0.04,0,0,0),
                            backgroundcolor = Color.new(0,0,0,0),
                            children = {
                                level = uibase:new {
                                    size = UDim2.new(0.2,0,1,0)
                                },
                                level2 = uibase:new {
                                    size = UDim2.new(0.2,0,1.5,0),
                                    backgroundcolor = Color.new(1,0,0,1)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    self:enterAnim()
end

return ui