require "yan"

local ui = {}
local Level = require "level"

function ui:finish()
    tween:new(self.screen:get("fade"), TweenInfo.new(0.4), {backgroundcolor = Color.new(0,0,0,0.6)}):play()
    self.screen:get("ending").position = UDim2.new(0.5,0,0.5,-20)
    self.screen:get("ending").visible = true
    tween:new(self.screen:get("ending"), TweenInfo.new(0.4, EasingStyle.CubicOut), {position = UDim2.new(0.5,0,0.5,0)}):play()
end

function ui:pause()
    tween:new(self.screen:get("fade"), TweenInfo.new(0.4), {backgroundcolor = Color.new(0,0,0,0.6)}):play()
    self.screen:get("pause").position = UDim2.new(0.5,0,0.5,-20)
    self.screen:get("pause").visible = true
    tween:new(self.screen:get("pause"), TweenInfo.new(0.4, EasingStyle.CubicOut), {position = UDim2.new(0.5,0,0.5,0)}):play()
end

function ui:unpause()
    tween:new(self.screen:get("fade"), TweenInfo.new(0.4), {backgroundcolor = Color.new(0,0,0,0)}):play()
    self.screen:get("pause").visible = false
end

function ui:reset()
    self.screen:get("fade").backgroundcolor = Color.new(0,0,0,0)
    self.screen:get("ending").visible = false
end

function ui:init()
    self.winframe = 1

    biribiri:CreateAndStartTimer(0.2, function ()
        self.winframe = self.winframe + 1
        if self.winframe == 4 then
            self.winframe = 1
        end
    end, true)

    self.screen = screen:new {
        timer = uibase:new{
            size = UDim2.new(0.275,0,0.1,0),
            anchorpoint = Vector2.new(0.5,0),
            position = UDim2.new(0.5,0,0,10),
            cornerradius = UDim.new(0,16),
            backgroundcolor = Color.new(0,0,0,0.5),
            children = {
                textlabel:new {
                    text = function ()
                        local minutes = math.floor(gametime / 60)
                        local seconds = math.floor(gametime) - minutes * 60
                        local ms = math.floor((gametime - (math.floor(gametime))) * 1000)

                        return string.format("%02d", minutes)..":"..string.format("%02d", seconds).."."..string.format("%03d", ms)
                    end,
                    textsize = 40,
                    fontpath = "LTSuperior.ttf",
                    textcolor = Color.new(1,1,1,1),
                    backgroundcolor = Color.new(0,0,0,0),
                    size = UDim2.new(1,0,1,0)
                },
            }
        },

        fade = uibase:new {
            size = UDim2.new(1,0,1,0),
            backgroundcolor = Color.new(0,0,0,0),
            zindex = -1000
        },

        pause = uibase:new {
            size = UDim2.new(0.5,0,0.5,0),
            position = UDim2.new(0.5,0,0.5,30),
            anchorpoint = Vector2.new(0.5, 0.5),
            backgroundcolor = Color.new(0.1,0.1,0.1,0.98),
            cornerradius = UDim.new(0,16),
            bordercolor = Color.new(1,1,1,0.5),
            bordersize = 4,
            zindex = 15,
            visible = false,
            children = {
                title = textlabel:new {
                    text = "Paused",
                    textsize = 40,
                    fontpath = "LTSuperior.ttf",
                    textcolor = Color.new(1,1,1,1),
                    backgroundcolor = Color.new(0,0,0,0),
                    size = UDim2.new(1,0,0.2,0)
                },
                menu = Button("green", "Back to Menu", UDim2.new(0.5,0,0.5,0), function (btn)
                    paused = false
                    currentScene = "mainmenu"
                    self:unpause()
                    
                end, UDim2.new(0.6, -20, 0, 60), 25, true),

                restart = Button("red", "Restart", UDim2.new(0.5,0,0.5,70), function (btn)
                    paused = false
                    self:unpause()
                    Level:restart()
                    self:reset()
                end, UDim2.new(0.6, -20, 0, 60), 25, true)
            }
        },

        ending = uibase:new {
            size = UDim2.new(0.5,0,0.5,0),
            position = UDim2.new(0.5,0,0.5,30),
            anchorpoint = Vector2.new(0.5, 0.5),
            backgroundcolor = Color.new(0.1,0.1,0.1,0.98),
            cornerradius = UDim.new(0,16),
            bordercolor = Color.new(1,1,1,0.5),
            bordersize = 4,
            zindex = 15,
            visible = false,
            children = {
                title = textlabel:new {
                    text = "Winner!!!",
                    textsize = 40,
                    fontpath = "LTSuperior.ttf",
                    textcolor = Color.new(1,1,1,1),
                    backgroundcolor = Color.new(0,0,0,0),
                    size = UDim2.new(1,0,0.2,0)
                },

                goose = imagelabel:new {
                    image = function ()
                        return "img/wingoose"..tostring(self.winframe)..".png"
                    end,
                    backgroundcolor = Color.new(0,0,0,0),
                    size = UDim2.new(0,150,0,150),
                    anchorpoint = Vector2.new(1,0),
                    position = UDim2.new(1,-20,0.2,0)
                },

                message = textlabel:new {
                    text = function ()
                        local minutes = math.floor(gametime / 60)
                        local seconds = math.floor(gametime) - minutes * 60
                        local ms = math.floor((gametime - (math.floor(gametime))) * 1000)

                        return "you beat the level in "..string.format("%02d", minutes)..":"..string.format("%02d", seconds).."."..string.format("%03d", ms).."!"
                    end,
                    textsize = 25,
                    fontpath = "LTSuperior.ttf",
                    textcolor = Color.new(1,1,1,1),
                    backgroundcolor = Color.new(0,0,0,0),
                    size = UDim2.new(0.6,0,0.4,0),
                    position = UDim2.new(0,10,0.3,0)
                },
                
                menu = Button("green", "Back to Menu", UDim2.new(0.25,0,1,-35), function (btn)
                    currentScene = "mainmenu"
                end, UDim2.new(0.5, -20, 0, 60), 25, true),

                restart = Button("blue", "Play Again", UDim2.new(0.75,0,1,-35), function (btn)
                    Level:restart()
                    self:reset()
                end, UDim2.new(0.5,-20,0,60), 25, true)
            }
        }
    }
end

return ui