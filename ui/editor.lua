require "yan"
local Editor = require "editor"

local ui = {}

local lastCamSpeed = editorState.camSpeed

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
            children = {
                delete = textlabel:new {
                    size = UDim2.new(1,0,0,25),
                    textsize = 20,
                    halign = "right",
                    text = "Delete",
                    textcolor = Color.new(1,1,1,1),
                    backgroundcolor = Color.new(0,0,0,0),
                    children = {
                        icon = imagelabel:new {
                            image = "img/delete.png",
                            size = UDim2.new(0,25,0,25),
                            backgroundcolor = Color.new(0,0,0,0)
                        }
                    },
                    mousebutton1up = function ()
                        Editor:deletePlatforms()
                        editorState.rightClicked = false
                    end
                }
            }
        }
    }
end

return ui