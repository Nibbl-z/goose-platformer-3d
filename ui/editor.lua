require "yan"
local Editor = require "editor"

local ui = {}

local lastCamSpeed = editorState.camSpeed

function RightClickButton(text, image, callback)
    return textlabel:new {
        size = UDim2.new(1,0,0,25),
        textsize = 15,
        halign = "right",
        text = text,
        textcolor = Color.new(1,1,1,1),
        backgroundcolor = Color.new(0,0,0,0),
        children = {
            icon = imagelabel:new {
                image = image,
                size = UDim2.new(0,25,0,25),
                backgroundcolor = Color.new(0,0,0,0)
            }
        },
        mousebutton1up = function ()
            callback()
            editorState.rightClicked = false
        end
    }
end

function PropertiesVec3(property)
    function setAxis(prop, axis, value)
        -- uggghhh

        if prop == "size" and value <= 0 then return end

        for _, platform in ipairs(platforms) do
            if platform.selected then
                -- this is becoming a disaster but whatever
                local funcs = {position = platform.model.setTranslation, size = platform.model.setScale}
                -- this is what happens when i try to force my desired ways of doing stuff upon g3d
                -- and now we have this mess
                platform.data[prop][axis] = value
                funcs[prop](platform.model, platform.data[prop]:getTuple()) -- <3
    
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
                textcolor = Color.new(1,0,0,1),
                backgroundcolor = Color.fromRgb(50,50,50),
                placeholdertext = "x",
                textsize = 16,
                placeholdertextcolor = Color.new(0.5,0,0,1),
                halign = "left",
                onenter = function (self)
                    if tonumber(self.text) ~= nil then
                        setAxis(property, "x", tonumber(self.text))
                    end
                end
            }, 
            -- Y
            y = textinput:new {
                size = UDim2.new(1,0,0,25),
                textcolor = Color.new(0,1,0,1),
                backgroundcolor = Color.fromRgb(50,50,50),
                placeholdertext = "y",
                textsize = 16,
                placeholdertextcolor = Color.new(0,0.5,0,1),
                halign = "left",
                onenter = function (self)
                    if tonumber(self.text) ~= nil then
                        setAxis(property, "y", tonumber(self.text))
                    end
                end
            }, 
            -- Z
            z = textinput:new {
                size = UDim2.new(1,0,0,25),
                textcolor = Color.new(0,0,1,1),
                backgroundcolor = Color.fromRgb(50,50,50),
                placeholdertext = "z",
                textsize = 16,
                placeholdertextcolor = Color.new(0,0,0.5,1),
                halign = "left",
                onenter = function (self)
                    if tonumber(self.text) ~= nil then
                        setAxis(property, "z", tonumber(self.text))
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

function ui:init()
    self.screen = screen:new {
        topbar = uibase:new {
            size = UDim2.new(1, 0, 0, 48),
            backgroundcolor = Color.fromRgb(30,30,30),
            layout = "list",
            listdirection = "horizontal",
            listvalign = "center",
            listpadding = 8,
            leftpadding = UDim.new(0,8),
            children = {
                movetool = imagelabel:new {
                    size = UDim2.new(0,32,0,32),
                    image = "img/tool_move.png",
                    backgroundcolor = function (v)
                        if editorState.tool == EDITOR_TOOLS.move then
                            return Color.fromRgb(10,10,10)
                        else
                            return Color.fromRgb(40,40,40)
                        end
                        
                    end,
                    mousebutton1up = function (v)
                        editorState.tool = EDITOR_TOOLS.move
                    end,
                },
                scaletool = imagelabel:new {
                    size = UDim2.new(0,32,0,32),
                    image = "img/tool_scale.png",
                    backgroundcolor = function (v)
                        if editorState.tool == EDITOR_TOOLS.scale then
                            return Color.fromRgb(10,10,10)
                        else
                            return Color.fromRgb(40,40,40)
                        end
                        
                    end,
                    mousebutton1up = function (v)
                        editorState.tool = EDITOR_TOOLS.scale
                    end,
                },
                addtool = imagelabel:new {
                    size = UDim2.new(0,32,0,32),
                    image = "img/tool_add.png",
                    backgroundcolor = Color.fromRgb(40,40,40),
                    mousebutton1up = function (v)
                        Editor:createPlatform()
                    end,
                }
            }
        },

        bottombar = uibase:new {
            size = UDim2.new(1, 0, 0, 24),
            position = UDim2.new(0,0,1,0),
            anchorpoint = Vector2.new(0,1),
            backgroundcolor = Color.new(0,0,0,0),
            layout = "list",
            listdirection = "horizontal",
            listvalign = "center",
            listpadding = 8,
            leftpadding = UDim.new(0,8),
            children = {
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

        rightclick = uibase:new {
            size = UDim2.new(0,150,0,300),
            backgroundcolor = Color.fromRgb(30,30,30),
            
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
                delete = RightClickButton("Delete", "img/delete.png", function ()
                    Editor:deletePlatforms()
                end),
                duplicate = RightClickButton("Duplicate", "img/copy.png", function ()
                    Editor:duplicatePlatforms()
                end),
                copy = RightClickButton("Copy", "img/copy.png", function ()
                    Editor:copyPlatforms()
                end),
                cut = RightClickButton("Cut", "img/cut.png", function ()
                    Editor:copyPlatforms()
                    Editor:deletePlatforms()
                end),
                paste = RightClickButton("Paste", "img/paste.png", function ()
                    Editor:pastePlatforms()
                end),
            }
        },

        properties = uibase:new {
            anchorpoint = Vector2.new(1,1),
            position = UDim2.new(1,0,1,0),
            size = UDim2.new(0,150,0,300),
            backgroundcolor = Color.fromRgb(30,30,30),
            layout = "list",
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

                position = PropertiesVec3("position"),
                size = PropertiesVec3("size"),
                isLava = PropertiesCheckbox("Lava", function ()
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
                end)
            }
        }
    }
end

function ui:updateProperties()
    local px, py, pz
    local sx, sy, sz

    for i, platform in ipairs(editorState.selectedPlatforms) do
        local pos = platform.data.position
        local size = platform.data.size

        if i == 1 then
            px, pz, py = pos:getTuple()
            sx, sz, sy = size:getTuple()
        else
            if px ~= pos.x then px = nil end
            if py ~= pos.y then py = nil end
            if pz ~= pos.z then pz = nil end
            if sx ~= size.x then sx = nil end
            if sy ~= size.y then sy = nil end
            if sz ~= size.z then sz = nil end
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
end

return ui