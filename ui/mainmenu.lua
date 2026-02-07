require "yan"
local Level = require "level"

local ui = {}
local levels = {}

function Button(color, text, position, callback, size, textSize)
    return imagelabel:new {
        size = size or UDim2.new(0, 300, 0, 100),
        position = position,
        anchorpoint = Vector2.new(0.5, 0.5),
        image = "img/btn_"..color..".png",
        backgroundcolor = Color.new(0,0,0,0),
        children = {
            label = textlabel:new {
                text = text,
                size = UDim2.new(1,0,1,0),
                textsize = textSize or 45,
                fontpath = "LTSuperior.ttf",
                backgroundcolor = Color.new(0,0,0,0),
                textcolor = Color.new(1,1,1,1)
            }
        },
        mouseenter = function (btn)
            tween:new(btn, TweenInfo.new(0.2, EasingStyle.CubicOut), {size = (size and (size + UDim2.new(0, 5, 0, 5))) or UDim2.new(0, 305, 0, 105)}):play()
        end,
        mouseexit = function (btn)
            btn.image = "img/btn_"..color..".png"
            tween:new(btn, TweenInfo.new(0.2, EasingStyle.CubicOut), {size = size or UDim2.new(0, 300, 0, 100)}):play()
        end,
        mousebutton1down = function (btn)
            btn.image = "img/btn_"..color.."_pressed.png"
            tween:new(btn, TweenInfo.new(0.2, EasingStyle.CubicOut), {size = (size and (size - UDim2.new(0, 10, 0, 5))) or UDim2.new(0, 290, 0, 95)}):play()
        end,
        mousebutton1up = function (btn)
            btn.image = "img/btn_"..color..".png"
            tween:new(btn, TweenInfo.new(0.2, EasingStyle.CubicOut), {size = (size and (size + UDim2.new(0, 5, 0, 5))) or UDim2.new(0, 305, 0, 105)}):play()
            callback(btn)
        end
    }
end

function LevelCard(level)
    return uibase:new {
        size = UDim2.new(1,0,1,0),
        backgroundcolor = Color.new(0,0,0,0),
        toppadding = UDim.new(0,5),
        bottompadding = UDim.new(0,5),
        leftpadding = UDim.new(0,5),
        rightpadding = UDim.new(0,5),
        children = {
            title = textlabel:new {
                text = level.name,
                size = UDim2.new(1,0,0.2,0),
                textsize = 40,
                fontpath = "LTSuperior.ttf",
                textcolor = Color.new(1,1,1,1),
                backgroundcolor = Color.new(0,0,0,0)
            },
            creator = textlabel:new {
                text = "Made by: "..level.creator,
                size = UDim2.new(1,0,0.15,0),
                position = UDim2.new(0,0,0.2,5),
                textsize = 30,
                halign = "left",
                fontpath = "LTSuperior.ttf",
                textcolor = Color.new(0.9,0.9,0.9,1),
                backgroundcolor = Color.new(0,0,0,0)
            },
            description = textlabel:new {
                text = level.desc,
                size = UDim2.new(1,0,0.5,0),
                position = UDim2.new(0,0,0.35,10),
                textsize = 30,
                fontpath = "LTSuperior.ttf",
                halign = "left",
                valign = "top",
                textcolor = Color.new(0.8,0.8,0.8,1),
                backgroundcolor = Color.new(0,0,0,0)
            },
            Button("green", "Play", UDim2.new(0,100,1.2,-80), function ()
                Level:loadGame(level)
            end, UDim2.new(0,200,0,70), 30),
        }
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

function ui:populateLevels()
    local scroller = self.screen:get("levels"):get("levelContainer"):get("scroller")

    table.clear(scroller.children)

    love.filesystem.setIdentity("goose-platformer-3d")

    table.clear(levels)

    for _, filename in ipairs(love.filesystem.getDirectoryItems("")) do
        if filename:match("^.+(%..+)$") == ".goose3d" then
            local level = Level:load(filename) 
            if type(level) == "table" then
                table.insert(levels, level)
            end
        end
    end

    for _, level in ipairs(levels) do
        LevelCard(level):setparent(scroller)
    end
end

function ui:init()
    self.currentLevel = 1

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
        
                play = Button("green", "Play Levels", UDim2.new(0,200,0,300), function (btn)
                    self:populateLevels()
                    tween:new(btn.parent, TweenInfo.new(1, EasingStyle.CubicOut), {position = UDim2.new(-1,0,0,0)}):play()
                    tween:new(self.screen:get("levels"), TweenInfo.new(1, EasingStyle.CubicOut), {position = UDim2.new(0,0,0,0)}):play()
                end),
                create = Button("blue", "Create Levels", UDim2.new(0,200,0,410), function ()
                    currentScene = "editor"
                end),
                quit = Button("red", "Exit", UDim2.new(0,200,0,520), function ()
                    love.event.quit()
                end)
            }
        },
        levels = uibase:new {
            size = UDim2.new(1,0,1,0),
            backgroundcolor = Color.new(0,0,0,0),
            position = UDim2.new(1,0,0,0),
            children = {
                back = Button("red", "Back", UDim2.new(0,105,0,40), function ()
                    tween:new(self.screen:get("main"), TweenInfo.new(1, EasingStyle.CubicOut), {position = UDim2.new(0,0,0,0)}):play()
                    tween:new(self.screen:get("levels"), TweenInfo.new(1, EasingStyle.CubicOut), {position = UDim2.new(1,0,0,0)}):play()
                end, UDim2.new(0,200,0,60)),
                levelContainer = uibase:new {
                    size = UDim2.new(1,-120,0.4,0),
                    position = UDim2.new(0,60,0,80),
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
                            position = UDim2.new(0,0,0,0),
                            backgroundcolor = Color.new(0,0,0,0),
                            children = {

                            }
                        }
                    }
                },

                levelLeft = textlabel:new {
                    size = UDim2.new(0,40,0.4,0),
                    position = UDim2.new(0,10,0,40),
                    backgroundcolor = Color.new(0,0,0,0),
                    textcolor = Color.new(1,1,1,1),
                    text = "<",
                    textsize = 29, -- i dont know
                    mousebutton1down = function (btn)
                        btn.textsize = 20
                    end,
                    mousebutton1up = function (btn)
                        btn.textsize = 30
                        self.currentLevel = self.currentLevel - 1
                        tween:new(self.screen:get("levels"):get("levelContainer"):get("scroller"), TweenInfo.new(0.3, EasingStyle.CubicOut), {position = UDim2.new(-self.currentLevel + 1, 0, 0, 0)}):play()
                    end
                },

                levelRight = textlabel:new {
                    size = UDim2.new(0,40,0.4,0),
                    position = UDim2.new(1,-50,0,40),
                    backgroundcolor = Color.new(0,0,0,0),
                    textcolor = Color.new(1,1,1,1),
                    text = ">",
                    textsize = 29,
                    mousebutton1down = function (btn)
                        btn.textsize = 20
                    end,
                    mousebutton1up = function (btn)
                        btn.textsize = 30
                        self.currentLevel = self.currentLevel + 1
                        tween:new(self.screen:get("levels"):get("levelContainer"):get("scroller"), TweenInfo.new(0.3, EasingStyle.CubicOut), {position = UDim2.new(-self.currentLevel + 1, 0, 0, 0)}):play()
                    end
                }
            }
        }
    }

    self:enterAnim()
    self:populateLevels()
end

return ui