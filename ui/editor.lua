require "yan"
local Editor = require "editor"

local ui = {}

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
        }
    }
end

return ui