require "yan"
local Level = require "level"

local ui = {}
local levels = {}

local popupOpen = false

local INPUT_FIELD = {
    TextField = 1,
    Label = 2
}

function Button(color, text, position, callback, size, textSize, isPopup)
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
                textsize = textSize or 40,
                fontpath = "LTSuperior.ttf",
                backgroundcolor = Color.new(0,0,0,0),
                textcolor = Color.new(1,1,1,1)
            }
        },
        mouseenter = function (btn)
            if popupOpen and not isPopup then return end
            tween:new(btn, TweenInfo.new(0.2, EasingStyle.CubicOut), {size = (size and (size + UDim2.new(0, 5, 0, 5))) or UDim2.new(0, 305, 0, 105)}):play()
        end,
        mouseexit = function (btn)
            btn.image = "img/btn_"..color..".png"
            tween:new(btn, TweenInfo.new(0.2, EasingStyle.CubicOut), {size = size or UDim2.new(0, 300, 0, 100)}):play()
        end,
        mousebutton1down = function (btn)
            if popupOpen and not isPopup then return end
            btn.image = "img/btn_"..color.."_pressed.png"
            tween:new(btn, TweenInfo.new(0.2, EasingStyle.CubicOut), {size = (size and (size - UDim2.new(0, 10, 0, 5))) or UDim2.new(0, 290, 0, 95)}):play()
        end,
        mousebutton1up = function (btn)
            if popupOpen and not isPopup then return end
            btn.image = "img/btn_"..color..".png"
            tween:new(btn, TweenInfo.new(0.2, EasingStyle.CubicOut), {size = (size and (size + UDim2.new(0, 5, 0, 5))) or UDim2.new(0, 305, 0, 105)}):play()
            callback(btn)
        end
    }
end

function ui:LevelCard(level, filename)
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
            Button("green", "Play", UDim2.new(0,60,1.2,-70), function ()
                currentLevelPath = filename
                Level:loadGame(level)
            end, UDim2.new(0,110,0,50), 25),
            Button("blue", "Edit", UDim2.new(0,180,1.2,-70), function ()
                currentLevelPath = filename
                Level:loadEditor(level)
            end, UDim2.new(0,110,0,50), 25),
            Button("orange", "Rename", UDim2.new(0,300,1.2,-70), function ()
                self:createPopup({
                    title = "Rename Level",
                    buttonText = "Confirm",
                    inputs = {
                        name = {type = INPUT_FIELD.TextField, data = {label = "New Name"}, order = 1},
                    },
                    callback = function (inputs)
                        local result = Level:renameLevel(filename, inputs.name)
                        if result ~= nil then
                            self:createPopup({
                                title = "Error",
                                inputs = {
                                    label = {type = INPUT_FIELD.Label, data = {label = result, height = 100}, order = 1}
                                },
                                buttonText = "Ok",
                            })
                        else
                            ui:populateLevels()
                            
                            for i, level in ipairs(levels) do
                                if level.name == inputs.name then
                                    self.currentLevel = i
                                    tween:new(self.screen:get("levels"):get("levelContainer"):get("scroller"), TweenInfo.new(0.3, EasingStyle.CubicOut), {position = UDim2.new(-self.currentLevel + 1, 0, 0, 0)}):play()
                                    break
                                end
                            end
                        end
                    end
                })
            end, UDim2.new(0,110,0,50), 25),
            Button("red", "Delete", UDim2.new(0,420,1.2,-70), function ()
                self:createPopup({
                    title = "Delete Level",
                    buttonText = "Cancel",
                    danger = true,
                    inputs = {
                        label = {type = INPUT_FIELD.Label, data = {label = "Are you sure you want to delete "..level.name.."?", height = 100}, order = 1},
                        label2 = {type = INPUT_FIELD.Label, data = {label = "This action cannot be undone.", height = 100}, order = 2}
                    },
                    dangerText = "Confirm",
                    dangerCallback = function ()
                        Level:deleteLevel(filename)
                        self:populateLevels()
                        if self.totalLevels ~= 0 then
                            self.currentLevel = math.clamp(self.currentLevel, 1, self.totalLevels)
                        end
                        tween:new(self.screen:get("levels"):get("levelContainer"):get("scroller"), TweenInfo.new(0.3, EasingStyle.CubicOut), {position = UDim2.new(-self.currentLevel + 1, 0, 0, 0)}):play()
                    end
                })
            end, UDim2.new(0,110,0,50), 25),
        }
    }
end



function Popup(data)
    local title = data.title
    local buttonText = data.buttonText
    local callback = data.callback or function (_) end
    local danger = data.danger or false
    local dangerText = data.dangerText
    local dangerCallback = data.dangerCallback or function (_) end
    local inputs = data.inputs or {}

    popupOpen = true

    local function TextField(data)
        return uibase:new {
            size = UDim2.new(1,0,0,40),
            backgroundcolor = Color.new(0,0,0,0),
            children = {
                input = textinput:new {
                    size = UDim2.new(0.7,0,1,0),
                    position = UDim2.new(0.3,0,0,0),
                    fontpath = "LTSuperior.ttf",
                    backgroundcolor = Color.new(0,0,0,0.5),
                    textcolor = Color.new(1,1,1,1),
                    textsize = 16,
                },
                label = textlabel:new {
                    size = UDim2.new(0.25,0,1,0),
                    backgroundcolor = Color.new(0,0,0,0),
                    text = data.label,
                    fontpath = "LTSuperior.ttf",
                    textcolor = Color.new(1,1,1,1),
                    textsize = 16,
                }
            }
        }
    end

    local function LabelField(data)
        return textlabel:new {
            size = UDim2.new(1,0,0,data.height),
            backgroundcolor = Color.new(0,0,0,0),
            text = data.label,
            fontpath = "LTSuperior.ttf",
            textcolor = Color.new(1,1,1,1),
            textsize = 24,
        }
    end

    local popup = uibase:new {
        size = UDim2.new(0.5,0,0.5,0),
        position = UDim2.new(0.5,0,0.5,30),
        anchorpoint = Vector2.new(0.5, 0.5),
        backgroundcolor = Color.new(0.1,0.1,0.1,0.98),
        cornerradius = UDim.new(0,16),
        bordercolor = Color.new(1,1,1,0.5),
        bordersize = 4,
        zindex = 15,
        children = {
            title = textlabel:new {
                text = title,
                textsize = 40,
                fontpath = "LTSuperior.ttf",
                textcolor = Color.new(1,1,1,1),
                backgroundcolor = Color.new(0,0,0,0),
                size = UDim2.new(1,0,0.2,0)
            },
            inputs = uibase:new {
                size = UDim2.new(1,0,0.8,-70),
                position = UDim2.new(0,0,0.2,0),
                layout = "list",
                listpadding = 2,
                backgroundcolor = Color.new(0,0,0,0),
                children = {
                    -- name = TextField("Level Name"),
                    -- description = TextField("Description"),
                    -- creator = TextField("Level Creator (that's you!)")
                }
            },
            play = Button("green", buttonText, not danger and UDim2.new(0.5,0,1,-35) or UDim2.new(0.25,0,1,-35), function (btn)
                popupOpen = false
                table.clear(btn.parent.parent.children)

                local inputValues = {}

                for _, v in pairs(btn.parent:get("inputs").children) do
                    if v:get("input") ~= nil then
                        inputValues[v.name] = v:get("input").text
                    end
                end

                callback(inputValues)
            end, UDim2.new(0.5,danger and -20 or 0,0,60), nil, true),
            
        }
    }

    if danger then
        Button("red", dangerText, UDim2.new(0.75,0,1,-35), function (btn)
            popupOpen = false
            table.clear(btn.parent.parent.children)

            local inputValues = {}

            for _, v in pairs(btn.parent:get("inputs").children) do
                if v:get("input") ~= nil then
                    inputValues[v.name] = v:get("input").text
                end
            end

            dangerCallback(inputValues)
        end, UDim2.new(0.5,-20,0,60), nil, true):setparent(popup)
    end

    for k, input in pairs(inputs) do
        local lookup = {
            [INPUT_FIELD.TextField] = TextField,
            [INPUT_FIELD.Label] = LabelField
        }

        local instance = lookup[input.type](input.data)
        instance.name = k
        instance.layoutorder = input.order
        instance:setparent(popup:get("inputs"))
    end

    tween:new(popup, TweenInfo.new(0.4, EasingStyle.CubicOut), {position = UDim2.new(0.5,0,0.5,0)}):play()

    return popup
end

function ui:enterAnim()
    self.screen:get("main").position = UDim2.new(0,0,0,0)
    self.screen:get("levels").position = UDim2.new(1,0,0,0)

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
    self.totalLevels = 0
    local scroller = self.screen:get("levels"):get("levelContainer"):get("scroller")

    table.clear(scroller.children)

    love.filesystem.setIdentity("goose-platformer-3d")

    table.clear(levels)

    for _, filename in ipairs(love.filesystem.getDirectoryItems("")) do
        if filename:match("^.+(%..+)$") == ".goose3d" then
            local level = Level:load(filename) 
            if type(level) == "table" then
                table.insert(levels, level)
                self:LevelCard(level, filename):setparent(scroller)
                self.totalLevels = self.totalLevels + 1
            end
        end
    end

    if self.totalLevels == 0 then
        local message = uibase:new {
            backgroundcolor = Color.new(0,0,0,0),
            size = UDim2.new(1,0,1,0),
            children = {
                label = textlabel:new {
                    text = "No custom levels found! Create one by clicking the New Level button, or by putting .goose3d files in %appdata%/goose-platformer-3d", -- todo: change text for web build i guess?
                    size = UDim2.new(0.8,0,0.8,0),
                    position = UDim2.new(0.5,0,0.5,0),
                    anchorpoint = Vector2.new(0.5,0.5),
                    backgroundcolor = Color.new(0,0,0,0),
                    textcolor = Color.new(1,1,1,1),
                    textsize = 30,
                    fontpath = "LTSuperior.ttf"
                }
            }
        }

        message:setparent(scroller)
    end

    if self.totalLevels ~= 0 then
        self.currentLevel = math.clamp(self.currentLevel, 1, self.totalLevels) -- failsafe if levels are removed :P
    end
end

function ui:createPopup(data)
    Popup(data):setparent(self.screen:get("popup"))
end

function ui:init()
    self.currentLevel = 1
    self.totalLevels = 0

    self.screen = screen:new {
        popupTint = uibase:new {
            size = UDim2.new(1,0,1,0),
            backgroundcolor = Color.new(0,0,0,0.8),
            zindex = 2,
            visible = function ()
                return popupOpen
            end
        },
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
        
                play = Button("green", "Play Levels", UDim2.new(0,200,0,300), function ()
                    
                end),
                create = Button("blue", "Custom Levels", UDim2.new(0,200,0,410), function ()
                    self.currentLevel = 1
                    self.screen:get("levels"):get("levelContainer"):get("scroller").position = UDim2.new(0,0,0,0)   
                    self:populateLevels()
                    tween:new(self.screen:get("main"), TweenInfo.new(1, EasingStyle.CubicOut), {position = UDim2.new(-1,0,0,0)}):play()
                    tween:new(self.screen:get("levels"), TweenInfo.new(1, EasingStyle.CubicOut), {position = UDim2.new(0,0,0,0)}):play()
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
                back = Button("red", "Back", UDim2.new(0,85,0,40), function ()
                    tween:new(self.screen:get("main"), TweenInfo.new(1, EasingStyle.CubicOut), {position = UDim2.new(0,0,0,0)}):play()
                    tween:new(self.screen:get("levels"), TweenInfo.new(1, EasingStyle.CubicOut), {position = UDim2.new(1,0,0,0)}):play()
                end, UDim2.new(0,150,0,60)),
                create = Button("green", "New Level", UDim2.new(0,245,0,40), function ()
                    self:createPopup({
                        title = "Create Level",
                        buttonText = "Confirm",
                        inputs = {
                            name = {type = INPUT_FIELD.TextField, data = {label = "Level Name"}, order = 1},
                            description = {type = INPUT_FIELD.TextField, data = {label = "Description"}, order = 2},
                            creator = {type = INPUT_FIELD.TextField, data = {label = "Level Creator (that's you!)"}, order = 3},
                        },
                        callback = function (inputs)
                            inputs.platforms = {}
                            Level:export(inputs)
                            ui:populateLevels()
                            for i, level in ipairs(levels) do
                                if level.name == inputs.name then
                                    self.currentLevel = i
                                    tween:new(self.screen:get("levels"):get("levelContainer"):get("scroller"), TweenInfo.new(0.3, EasingStyle.CubicOut), {position = UDim2.new(-self.currentLevel + 1, 0, 0, 0)}):play()
                                    break
                                end
                            end
                        end
                    })
                end, UDim2.new(0,150,0,60), 29),
                levelContainer = uibase:new {
                    size = UDim2.new(1,-120,0.4,0),
                    anchorpoint = Vector2.new(0,1),
                    position = UDim2.new(0,60,1,-20),
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
                    anchorpoint = Vector2.new(0,1),
                    position = UDim2.new(0,10,1,-20),
                    backgroundcolor = Color.new(0,0,0,0),
                    textcolor = Color.new(1,1,1,1),
                    text = "<",
                    visible = function ()
                        return self.currentLevel > 1
                    end,
                    textsize = 29, -- i dont know
                    mousebutton1down = function (btn)
                        if popupOpen then return end
                        btn.textsize = 20
                    end,
                    mousebutton1up = function (btn)
                        if self.totalLevels == 0 then return end
                        if popupOpen then return end
                        btn.textsize = 30
                        self.currentLevel = math.clamp(self.currentLevel - 1, 1, self.totalLevels)
                        tween:new(self.screen:get("levels"):get("levelContainer"):get("scroller"), TweenInfo.new(0.3, EasingStyle.CubicOut), {position = UDim2.new(-self.currentLevel + 1, 0, 0, 0)}):play()
                    end
                },

                levelRight = textlabel:new {
                    size = UDim2.new(0,40,0.4,0),
                    anchorpoint = Vector2.new(1,1),
                    position = UDim2.new(1,-10,1,-20),
                    backgroundcolor = Color.new(0,0,0,0),
                    textcolor = Color.new(1,1,1,1),
                    text = ">",
                    textsize = 29,
                    visible = function ()
                        return self.currentLevel < self.totalLevels
                    end,
                    mousebutton1down = function (btn)
                        if popupOpen then return end
                        btn.textsize = 20
                    end,
                    mousebutton1up = function (btn)
                        if self.totalLevels == 0 then return end
                        if popupOpen then return end
                        btn.textsize = 30
                        self.currentLevel = math.clamp(self.currentLevel + 1, 1, self.totalLevels)
                        tween:new(self.screen:get("levels"):get("levelContainer"):get("scroller"), TweenInfo.new(0.3, EasingStyle.CubicOut), {position = UDim2.new(-self.currentLevel + 1, 0, 0, 0)}):play()
                    end
                }
            }
        },
        popup = uibase:new {
            size = UDim2.new(1,0,1,0),
            backgroundcolor = Color.new(0,0,0,0),
            zindex = 100,
            children = {

            }
        }
    }

    self:enterAnim()
    self:populateLevels()
end

return ui