require "yan"
local Editor = require "editor"
local Level = require "level"

local ui = {}

function RightClickButton(text, image, shortcut, callback)
    return uibase:new {
        size = UDim2.new(1,0,0,25),
        backgroundcolor = Color.fromRgb(30,30,30),
        children = {
            icon = imagelabel:new {
                image = image,
                size = UDim2.new(0,25,0,25),
                backgroundcolor = Color.new(0,0,0,0)
            },
            label = textlabel:new {
                size = UDim2.new(1,-30,1,0),
                position = UDim2.new(0,30,0,0),
                textsize = 15,
                halign = "left",
                text = text,
                textcolor = Color.new(1,1,1,1),
                backgroundcolor = Color.new(0,0,0,0),
            },
            shortcut = textlabel:new {
                size = UDim2.new(1,-30,1,0),
                position = UDim2.new(0,30,0,0),
                textsize = 10,
                halign = "right",
                text = shortcut,
                textcolor = Color.new(0.7,0.7,0.7,1),
                backgroundcolor = Color.new(0,0,0,0),
            }
        },
        mousebutton1up = function ()
            callback()
            editorState.rightClicked = false
        end,
        mouseenter = function(btn) btn.backgroundcolor = Color.fromRgb(50,50,50) end,
        mouseexit = function(btn) btn.backgroundcolor = Color.fromRgb(30,30,30) end
    }
end

function PropertiesVec3(property, isVector)
    function setAxis(prop, axis, value, isv)
        -- uggghhh
        Editor:updateHistory()

        if prop == "size" and value <= 0 then return end
        if prop == "color" then
            value = math.clamp(value, 0, 255)
        end
        for _, platform in ipairs(platforms) do
            if platform.selected then
                if isv then
                    -- this is becoming a disaster but whatever
                    local funcs = {position = platform.model.setTranslation, size = platform.model.setScale}
                    -- this is what happens when i try to force my desired ways of doing stuff upon g3d
                    -- and now we have this mess

                    -- hi, it's getting worse :heart:

                    local vector = vec3.new(platform.data[prop].x, platform.data[prop].y, platform.data[prop].z)
                    vector[axis] = value

                    platform.data[prop] = vector

                    funcs[prop](platform.model, platform.data[prop]:getTuple()) -- <3
                else
                    -- i love assuming itll only be an rgb because thats all im adding anyway
                    local color = Color.new(platform.data[prop].r, platform.data[prop].g, platform.data[prop].b)
                    color[axis] = value

                    platform.data[prop] = color
                end
                
    
                -- please enjoy
            end
        end
    end

    return uibase:new {
        size = UDim2.new(1,0,0,100),
        backgroundcolor = Color.new(0,0,0,0),
        layout = "list",
        children = {
            title = textlabel:new {
                size = UDim2.new(1,0,0,25),
                textcolor = Color.new(0.8,0.8,0.8,1),
                backgroundcolor = Color.new(0,0,0,0),
                textsize = 14,
                text = property,
                halign = "left"
            }, 
            -- X
            x = textinput:new {
                size = UDim2.new(1,0,0,25),
                textcolor = Color.new(1,0.2,0.2,1),
                backgroundcolor = Color.fromRgb(50,50,50),
                placeholdertext = isVector and "x" or "r",
                textsize = 16,
                placeholdertextcolor = Color.new(0.5,0.2,0.2,1),
                halign = "left",
                onenter = function (self)
                    if tonumber(self.text) ~= nil then
                        setAxis(property, isVector and "x" or "r", tonumber(self.text), isVector)
                    end
                end
            }, 
            -- Y
            y = textinput:new {
                size = UDim2.new(1,0,0,25),
                textcolor = Color.new(0.2,1,0.2,1),
                backgroundcolor = Color.fromRgb(50,50,50),
                placeholdertext = isVector and "y" or "g",
                textsize = 16,
                placeholdertextcolor = Color.new(0.2,0.5,0.2,1),
                halign = "left",
                onenter = function (self)
                    if tonumber(self.text) ~= nil then
                        setAxis(property, isVector and "y" or "g", tonumber(self.text), isVector)
                    end
                end
            }, 
            -- Z
            z = textinput:new {
                size = UDim2.new(1,0,0,25),
                textcolor = Color.new(0.2,0.2,1,1),
                backgroundcolor = Color.fromRgb(50,50,50),
                placeholdertext = isVector and "z" or "b",
                textsize = 16,
                placeholdertextcolor = Color.new(0.2,0.2,0.5,1),
                halign = "left",
                onenter = function (self)
                    if tonumber(self.text) ~= nil then
                        setAxis(property, isVector and "z" or "b", tonumber(self.text), isVector)
                    end
                end
            }
        }
    }
end

function PropertiesCheckbox(title, callbackOn, callbackOff, condition)
    return uibase:new {
        size = UDim2.new(1,0,0,25),
        backgroundcolor = Color.new(0,0,0,0),
        children = {
            title = textlabel:new {
                size = UDim2.new(1,0,0,25),
                textcolor = Color.new(0.8,0.8,0.8,1),
                backgroundcolor = Color.new(0,0,0,0),
                textsize = 14,
                text = title,
                halign = "left"
            },
            checkbox = imagelabel:new {
                size = UDim2.new(0,25,0,25),
                position = UDim2.new(1,0,0,0),
                anchorpoint = Vector2.new(1,0),
                image = function ()
                    return condition() and "img/checkbox_on.png" or "img/checkbox_off.png"
                end,
                mousebutton1up = function (self)
                    Editor:updateHistory()
                    if condition() then
                        callbackOff()
                    else
                        callbackOn()
                    end
                end
            }
        }
    }
end

function ui:addNotif(text)
    local label = textlabel:new {
        text = text,
        size = UDim2.new(0.6,0,0,12),
        textsize = 12,
        backgroundcolor = Color.new(0,0,0,0),
        textcolor = Color.new(1,1,1,1),
        halign = "left",
    }

    label:setparent(self.screen:get("bottombar"))

    biribiri:CreateAndStartTimer(3, function ()
        print(label.backgroundcolor:get())
        tween:new(label, TweenInfo.new(0.5), {textcolor = Color.new(1,1,1,0)}):play()
        biribiri:CreateAndStartTimer(0.5, function ()
            table.remove(self.screen:get("bottombar").children, table.find(self.screen:get("bottombar").children, label))
        end)
    end)
end

function ui:init()
    self.exitConfirmation = false
    self.tooltipActive = false
    self.tooltipTitle = ""
    self.tooltipDescription = ""
    self.tooltipKeybind = ""

    local function exit(btn)
        btn.backgroundcolor = Color.fromRgb(40,40,40)
        self.tooltipTitle = ""
        self.tooltipDescription = ""
        self.tooltipKeybind = ""
        self.tooltipActive = false
    end

    self.screen = screen:new {
        topbar = uibase:new {
            size = UDim2.new(1, 0, 0, 36),
            backgroundcolor = Color.fromRgb(30,30,30),
            layout = "list",
            listdirection = "horizontal",
            listvalign = "center",
            listpadding = 4,
            leftpadding = UDim.new(0,4),
            children = {
                exit = imagelabel:new {
                    size = UDim2.new(0,32,0,32),
                    image = "img/exit.png",
                    backgroundcolor = Color.fromRgb(40,40,40),
                    mousebutton1up = function (v)
                        if editorState.unsavedChanges then
                            self.exitConfirmation = true
                        else
                            currentScene = "mainmenu"
                        end
                    end,
                    mouseenter = function (btn) 
                        btn.backgroundcolor = Color.fromRgb(60,60,60) 
                        self.tooltipTitle = "Exit"
                        self.tooltipDescription = "Returns to the main menu"
                        self.tooltipKeybind = ""
                        self.tooltipActive = true
                    end,
                    mouseexit = function (btn) exit(btn) end
                },
                save = imagelabel:new {
                    size = UDim2.new(0,32,0,32),
                    image = "img/save.png",
                    backgroundcolor = Color.fromRgb(40,40,40),
                    mousebutton1up = function (v)
                        local result = Level:save(currentLevelPath)
                        if result == "Level saved!" then editorState.unsavedChanges = false end
                        
                        self:addNotif(result)
                    end,
                    mouseenter = function (btn) 
                        btn.backgroundcolor = Color.fromRgb(60,60,60) 
                        self.tooltipTitle = "Save"
                        self.tooltipDescription = "Saves your changes to the level file"
                        self.tooltipKeybind = "Ctrl+S"
                        self.tooltipActive = true
                    end,
                    mouseexit = function (btn) exit(btn) end
                },
                movetool = imagelabel:new {
                    size = UDim2.new(0,32,0,32),
                    image = "img/tool_move.png",
                    backgroundcolor = Color.fromRgb(10,10,10),
                    mousebutton1up = function (v)
                        editorState.tool = EDITOR_TOOLS.move
                        v.backgroundcolor = Color.fromRgb(10,10,10)
                        v.parent:get("scaletool").backgroundcolor = Color.fromRgb(40,40,40)
                    end,
                    mouseenter = function (btn) 
                        btn.backgroundcolor = Color.fromRgb(60,60,60) 
                        self.tooltipTitle = "Move tool"
                        self.tooltipDescription = "Allows you to move platforms"
                        self.tooltipKeybind = "1"
                        self.tooltipActive = true
                    end,
                    mouseexit = function (btn)
                        exit(btn)
                        if editorState.tool == EDITOR_TOOLS.move then btn.backgroundcolor = Color.fromRgb(10,10,10) end
                    end
                },
                scaletool = imagelabel:new {
                    size = UDim2.new(0,32,0,32),
                    image = "img/tool_scale.png",
                    backgroundcolor = Color.fromRgb(40,40,40),
                    mousebutton1up = function (v)
                        editorState.tool = EDITOR_TOOLS.scale
                        v.backgroundcolor = Color.fromRgb(10,10,10)
                        v.parent:get("movetool").backgroundcolor = Color.fromRgb(40,40,40)
                    end,
                    mouseenter = function (btn) 
                        btn.backgroundcolor = Color.fromRgb(60,60,60) 
                        self.tooltipTitle = "Scale tool"
                        self.tooltipDescription = "Allows you to scale platforms"
                        self.tooltipKeybind = "2"
                        self.tooltipActive = true
                    end,
                    mouseexit = function (btn)
                        exit(btn)
                        if editorState.tool == EDITOR_TOOLS.scale then btn.backgroundcolor = Color.fromRgb(10,10,10) end
                    end
                },
                addtool = imagelabel:new {
                    size = UDim2.new(0,32,0,32),
                    image = "img/tool_add.png",
                    backgroundcolor = Color.fromRgb(40,40,40),
                    mousebutton1up = function (v)
                        Editor:createPlatform()
                    end,
                    mouseenter = function (btn) 
                        btn.backgroundcolor = Color.fromRgb(60,60,60) 
                        self.tooltipTitle = "Create platform"
                        self.tooltipDescription = "Creates a platform where you are looking"
                        self.tooltipKeybind = ""
                        self.tooltipActive = true
                    end,
                    mouseexit = function (btn) exit(btn) end
                },
                checkpointtool = imagelabel:new {
                    size = UDim2.new(0,32,0,32),
                    image = "img/tool_checkpoint.png",
                    backgroundcolor = Color.fromRgb(40,40,40),
                    mousebutton1up = function (v)
                        Editor:createCheckpoint()
                    end,
                    mouseenter = function (btn) 
                        btn.backgroundcolor = Color.fromRgb(60,60,60) 
                        self.tooltipTitle = "Create checkpoint"
                        self.tooltipDescription = "Creates a checkpoint where you are looking"
                        self.tooltipKeybind = ""
                        self.tooltipActive = true
                    end,
                    mouseexit = function (btn) exit(btn) end
                },
                undo = imagelabel:new {
                    size = UDim2.new(0,32,0,32),
                    image = "img/undo.png",
                    backgroundcolor = Color.fromRgb(40,40,40),
                    mousebutton1up = function (v)
                        Editor:undo()
                    end,
                    mouseenter = function (btn) 
                        btn.backgroundcolor = Color.fromRgb(60,60,60) 
                        self.tooltipTitle = "Undo"
                        self.tooltipDescription = "Undoes one change"
                        self.tooltipKeybind = "Ctrl+Z"
                        self.tooltipActive = true
                    end,
                    mouseexit = function (btn) exit(btn) end
                },
                redo = imagelabel:new {
                    size = UDim2.new(0,32,0,32),
                    image = "img/redo.png",
                    backgroundcolor = Color.fromRgb(40,40,40),
                    mousebutton1up = function (v)
                        Editor:redo()
                    end,
                    mouseenter = function (btn) 
                        btn.backgroundcolor = Color.fromRgb(60,60,60) 
                        self.tooltipTitle = "Redo"
                        self.tooltipDescription = "Redoes one change"
                        self.tooltipKeybind = "Ctrl+Shift+Z"
                        self.tooltipActive = true
                    end,
                    mouseexit = function (btn) exit(btn) end
                },
                camSpeed = textlabel:new {
                    text = function ()
                        return "Camera speed: "..tostring(editorState.camSpeed)
                    end,
                    halign = "left",
                    size = UDim2.new(0,150,1,0),
                    backgroundcolor = Color.new(0,0,0,0),
                    textsize = 12,
                    textcolor = Color.new(1,1,1,1)
                }
            }
        },

        topbarTooltip = uibase:new {
            size = UDim2.new(0,180,0,60),
            position = function ()
                return UDim2.new(0, love.mouse.getX() + 10, 0, love.mouse.getY() + 10)
            end,
            backgroundcolor = Color.fromRgb(30,30,30),
            leftpadding = UDim.new(0,5),
            rightpadding = UDim.new(0,5),
            toppadding = UDim.new(0,5),
            bottompadding = UDim.new(0,5),
            visible = function ()
                return self.tooltipActive
            end,
            children = {
                title = textlabel:new {
                    textcolor = Color.new(1,1,1,1),
                    backgroundcolor = Color.new(0,0,0,0),
                    size = UDim2.new(1,0,0.3,0),
                    text = function ()
                        return self.tooltipTitle
                    end,
                    halign = "left",
                    valign = "top",
                    textsize = 16,
                },
                keybind = textlabel:new {
                    textcolor = Color.new(0.6,0.6,0.6,1),
                    backgroundcolor = Color.new(0,0,0,0),
                    size = UDim2.new(1,0,0.3,0),
                    text = function ()
                        return self.tooltipKeybind
                    end,
                    halign = "right",
                    valign = "top",
                    textsize = 13,
                },
                desc = textlabel:new {
                    textcolor = Color.new(1,1,1,1),
                    backgroundcolor = Color.new(0,0,0,0),
                    size = UDim2.new(1,0,0.6,0),
                    position = UDim2.new(0,0,0.3,10),
                    text = function ()
                        return self.tooltipDescription
                    end,
                    halign = "left",
                    valign = "top",
                    textsize = 12,
                },
            }
        },

        exitConfirmation = uibase:new {
            size = UDim2.new(0,200,0,100),
            position = UDim2.new(0,0,0,54),
            backgroundcolor = Color.fromRgb(30,30,30),
            leftpadding = UDim.new(0,5),
            rightpadding = UDim.new(0,5),
            toppadding = UDim.new(0,5),
            bottompadding = UDim.new(0,5),
            visible = function ()
                return self.exitConfirmation
            end,
            children = {
                message = textlabel:new {
                    textcolor = Color.new(1,1,1,1),
                    backgroundcolor = Color.new(0,0,0,0),
                    size = UDim2.new(1,0,0.6,0),
                    text = "Are you sure you want to exit the editor? Unsaved changes will be lost!",
                    halign = "left",
                    valign = "top",
                    textsize = 14,
                },
                exit = textlabel:new {
                    textcolor = Color.new(1,0,0,1),
                    backgroundcolor = Color.fromRgb(40,40,40),
                    size = UDim2.new(0.5,-2,0.3,0),
                    position = UDim2.new(0,0,1,0),
                    anchorpoint = Vector2.new(0,1),
                    text = "Exit",
                    mousebutton1up = function ()
                        currentScene = "mainmenu"
                    end
                },
                cancel = textlabel:new {
                    textcolor = Color.new(1,1,1,1),
                    backgroundcolor = Color.fromRgb(40,40,40),
                    size = UDim2.new(0.5,-2,0.3,0),
                    position = UDim2.new(1,0,1,0),
                    anchorpoint = Vector2.new(1,1),
                    text = "Cancel",
                    mousebutton1up = function ()
                        self.exitConfirmation = false
                    end
                }
            }
        },

        bottombar = uibase:new {
            size = UDim2.new(1, 0, 0, 24),
            position = UDim2.new(0,0,1,0),
            anchorpoint = Vector2.new(0,1),
            backgroundcolor = Color.new(0,0,0,0),
            layout = "list",
            listdirection = "vertical",
            listvalign = "bottom",
            listhalign = "left",
            listpadding = 8,
            leftpadding = UDim.new(0,8),
            children = {
                
            }
        },

        rightclick = uibase:new {
            size = UDim2.new(0,150,0,150),
            backgroundcolor = Color.fromRgb(20,20,20),
            zindex = 50,
            visible = function ()
                return editorState.rightClicked
            end,
            position = function ()
                return editorState.rightClickPos
            end,
            leftpadding = UDim.new(0,4),
            rightpadding = UDim.new(0,4),
            toppadding = UDim.new(0,4),
            bottompadding = UDim.new(0,4),
            layout = "list",
            listpadding = 4,
            listdirection = "vertical",
            children = {
                delete = RightClickButton("Delete", "img/delete.png", "Delete", function ()
                    Editor:deletePlatforms()
                end),
                duplicate = RightClickButton("Duplicate", "img/copy.png", "Ctrl+D", function ()
                    Editor:duplicatePlatforms()
                end),
                copy = RightClickButton("Copy", "img/copy.png", "Ctrl+C", function ()
                    Editor:copyPlatforms()
                end),
                cut = RightClickButton("Cut", "img/cut.png", "Ctrl+X", function ()
                    Editor:copyPlatforms()
                    Editor:deletePlatforms()
                end),
                paste = RightClickButton("Paste", "img/paste.png", "Ctrl+V", function ()
                    Editor:pastePlatforms()
                end),
            }
        },

        properties = uibase:new {
            anchorpoint = Vector2.new(1,0),
            position = UDim2.new(1,0,0,0),
            size = UDim2.new(0,160,0,600),
            backgroundcolor = Color.fromRgb(30,30,30),
            layout = "list",
            listpadding = 5,
            leftpadding = UDim.new(0,5),
            rightpadding = UDim.new(0,5),
            children = {
                header = textlabel:new {
                    text = function ()
                        local selectedText = ""
                        if #editorState.selectedPlatforms > 0 then
                            selectedText = " - "..tostring(#editorState.selectedPlatforms).." platform"..(#editorState.selectedPlatforms == 1 and "" or "s")
                        end

                        return "Properties"..selectedText
                    end,
                    size = UDim2.new(1,0,0,25),
                    textsize = 12,
                    backgroundcolor = Color.new(0,0,0,0),
                    textcolor = Color.new(1,1,1,1)
                },

                position = PropertiesVec3("position", true),
                size = PropertiesVec3("size", true),
                isLava = PropertiesCheckbox("lava", function ()
                    for _, platform in ipairs(editorState.selectedPlatforms) do
                        platform.data.type = PLATFORM_TYPE.lava
                    end
                end, function ()
                    for _, platform in ipairs(editorState.selectedPlatforms) do
                        platform.data.type = PLATFORM_TYPE.default
                    end
                end, function ()
                    local condition = true

                    for _, platform in ipairs(editorState.selectedPlatforms) do
                        condition = platform.data.type == PLATFORM_TYPE.lava
                    end

                    return condition
                end),
                collision = PropertiesCheckbox("collision", function ()
                    for _, platform in ipairs(editorState.selectedPlatforms) do
                        platform.data.collision = true
                    end
                end, function ()
                    for _, platform in ipairs(editorState.selectedPlatforms) do
                        platform.data.collision = false
                    end
                end, function ()
                    local condition = true

                    for _, platform in ipairs(editorState.selectedPlatforms) do
                        condition = platform.data.collision
                    end

                    return condition
                end),
                color = PropertiesVec3("color", false),
                colorpicker = uibase:new {
                    size = UDim2.new(1,0,0,120),
                    backgroundcolor = Color.new(0,0,0,0),
                    children = {
                        sv = uibase:new {
                            size = UDim2.new(0,120,0,120)
                        },
                        h = uibase:new {
                            size = UDim2.new(0,25,0,120),
                            position = UDim2.new(0,125,0,0)
                        }
                    }
                },
                materialLabel = textlabel:new {
                    size = UDim2.new(1,0,0,25),
                    textcolor = Color.new(0.8,0.8,0.8,1),
                    backgroundcolor = Color.new(0,0,0,0),
                    textsize = 14,
                    text = "material",
                    halign = "left"
                },
                materialPicker = uibase:new {
                    size = UDim2.new(1,0,0,25),
                    backgroundcolor = Color.new(0,0,0,0),
                    children = {
                        left = textlabel:new {
                            text = "<",
                            textsize = 14,
                            size = UDim2.new(0,25,0,25),
                            textcolor = Color.new(0.8,0.8,0.8,1),
                            backgroundcolor = Color.new(0,0,0,0),
                            mousebutton1up = function ()
                                cycleMaterial(-1)
                            end
                        },
                        right = textlabel:new {
                            text = ">",
                            position = UDim2.new(1,0,0,0),
                            anchorpoint = Vector2.new(1,0),
                            textsize = 14,
                            size = UDim2.new(0,25,0,25),
                            textcolor = Color.new(0.8,0.8,0.8,1),
                            backgroundcolor = Color.new(0,0,0,0),
                            mousebutton1up = function ()
                                cycleMaterial(1)
                            end
                        },
                        material = textlabel:new {
                            text = function ()
                                local material = ""
                                local i = 1
                                for _, v in ipairs(platforms) do
                                    if v.selected then
                                        if i == 1 then
                                            material = v.data.material
                                        else
                                            if v.data.material ~= material then
                                                material = ""
                                                break
                                            end
                                        end
                                        i = i + 1
                                    end
                                end

                                return material
                            end,
                            position = UDim2.new(.5,0,0,0),
                            anchorpoint = Vector2.new(.5,0),
                            textsize = 14,
                            size = UDim2.new(0,100,0,25),
                            textcolor = Color.new(0.8,0.8,0.8,1),
                            backgroundcolor = Color.new(0,0,0,0),
                        },
                    }
                }

            }
        },
    }
end

function ui:updateProperties()
    local px, py, pz
    local sx, sy, sz
    local r, g, b

    for i, platform in ipairs(editorState.selectedPlatforms) do
        local pos = platform.data.position
        local size = platform.data.size
        local color = platform.data.color

        if i == 1 then
            px, pz, py = pos:getTuple()
            sx, sz, sy = size:getTuple()
            r, g, b = color:get()
            r = math.ceil(r * 255)
            g = math.ceil(g * 255)
            b = math.ceil(b * 255)
        else
            if px ~= pos.x then px = nil end
            if py ~= pos.y then py = nil end
            if pz ~= pos.z then pz = nil end
            if sx ~= size.x then sx = nil end
            if sy ~= size.y then sy = nil end
            if sz ~= size.z then sz = nil end
            if r ~= math.ceil(color.r * 255) then r = nil end
            if g ~= math.ceil(color.g * 255) then g = nil end
            if b ~= math.ceil(color.b * 255) then b = nil end
        end
    end

    local pos = self.screen:get("properties"):get("position")

    if pos:get("x")._typing == false then pos:get("x").text = tostring(px or "") end
    if pos:get("y")._typing == false then pos:get("y").text = tostring(py or "") end
    if pos:get("z")._typing == false then pos:get("z").text = tostring(pz or "") end

    local size = self.screen:get("properties"):get("size")

    if size:get("x")._typing == false then size:get("x").text = tostring(sx or "") end
    if size:get("y")._typing == false then size:get("y").text = tostring(sy or "") end
    if size:get("z")._typing == false then size:get("z").text = tostring(sz or "") end

    local color = self.screen:get("properties"):get("color")

    if color:get("x")._typing == false then color:get("x").text = tostring(r or "") end
    if color:get("y")._typing == false then color:get("y").text = tostring(g or "") end
    if color:get("z")._typing == false then color:get("z").text = tostring(b or "") end

    for _, v in ipairs({pos, size, color}) do
        for _, v2 in ipairs({"x", "y", "z"}) do
            editorState.usingTextInput = v:get(v2)._typing
            if v:get(v2)._typing then return end
        end
    end
end

function cycleMaterial(direction)
    Editor:updateHistory()
    local material = "stone"
    local i = 1

    for _, v in ipairs(platforms) do
        if v.selected then
            if i == 1 then
                material = v.data.material
            else
                if v.data.material ~= material then
                    material = "stone"
                    break
                end
            end
            i = i + 1
        end
    end

    local id = table.find(MATERIAL, material)
    id = id + direction

    if id == 0 then id = #MATERIAL end
    if id > #MATERIAL then id = 1 end

    for _, v in ipairs(platforms) do
        if v.selected then
            v.data.material = MATERIAL[id]
        end
    end
end

return ui