require "global"

local finishline = {}
finishline.__index = finishline


function finishline:new(position)
    local data = {
        position = position,
        size = vec3.new(2,4,2)
    }

    local object = {
        model = g3d.newModel(g3d.loadObj("models/finishline.obj", false, true), assets["img/finishline.skin.png"], (position - vec3.new(0,2,0)):get(), {0,0,-1}, {0.5,0.5,0.5}),
        data = {
            position = position
        },
        shader = love.graphics.newShader(g3d.shaderpath, "shaders/finishline.glsl"),
        hovered = false,
        selected = false,
        nonPlatform = true,
        _type = "finishline",
        _incomingMove = vec3.new(0,0,0),
        _incomingMoveSnapped = vec3.new(0,0,0),
        handles = {
            x = {
                axis = "x",
                positionModel = g3d.newModel("models/movehandle.obj", assets["img/goog.png"], (data.position - vec3.new(data.size.x / 2 + 3, 0, 0)):get(), vec3.new(0,math.rad(90),0):get(), vec3.new(0.5,0.5,0.5):get()),
                shader = love.graphics.newShader(g3d.shaderpath, "shaders/solid.glsl"),
                hovered = false
            },
            y = {
                axis = "y",
                positionModel = g3d.newModel("models/movehandle.obj", assets["img/goog.png"], (data.position + vec3.new(0, data.size.y / 2 + 3, 0)):get(), vec3.new(math.rad(90),0,0):get(), vec3.new(0.5,0.5,0.5):get()),
                shader = love.graphics.newShader(g3d.shaderpath, "shaders/solid.glsl"),
                hovered = false
            },
            z = {
                axis = "z",
                positionModel = g3d.newModel("models/movehandle.obj", assets["img/goog.png"], (data.position + vec3.new(0, data.size.y / 2 + 3, 0)):get(), vec3.new(0,math.rad(180),0):get(), vec3.new(0.5,0.5,0.5):get()),
                shader = love.graphics.newShader(g3d.shaderpath, "shaders/solid.glsl"),
                hovered = false
            },
            nx = {
                axis = "x",
                negative = true,
                positionModel = g3d.newModel("models/movehandle.obj", assets["img/goog.png"], (data.position - vec3.new(data.size.x / 2 + 3, 0, 0)):get(), vec3.new(0,math.rad(270),0):get(), vec3.new(0.5,0.5,0.5):get()),   
                shader = love.graphics.newShader(g3d.shaderpath, "shaders/solid.glsl"),
                hovered = false
            },
            ny = {
                axis = "y",
                negative = true,
                positionModel = g3d.newModel("models/movehandle.obj", assets["img/goog.png"], (data.position + vec3.new(0, data.size.y / 2 + 3, 0)):get(), vec3.new(math.rad(270),0,0):get(), vec3.new(0.5,0.5,0.5):get()),
                shader = love.graphics.newShader(g3d.shaderpath, "shaders/solid.glsl"),
                hovered = false
            },
            nz = {
                axis = "z",
                negative = true,
                positionModel = g3d.newModel("models/movehandle.obj", assets["img/goog.png"], (data.position + vec3.new(0, data.size.y / 2 + 3, 0)):get(), vec3.new(0,math.rad(0),0):get(), vec3.new(0.5,0.5,0.5):get()),
                shader = love.graphics.newShader(g3d.shaderpath, "shaders/solid.glsl"),
                hovered = false
            },
        }
    }

    for _, v in pairs(object.handles) do
        v._position = vec3.fromg3d(v.positionModel.translation)
    end
    
    setmetatable(object, self)
    return object
end

function finishline:update(dt)
    self._incomingMoveSnapped = vec3.new(
        math.round(self._incomingMove.x, editorState.snap and editorState.snapAmount or 0),
        math.round(self._incomingMove.y, editorState.snap and editorState.snapAmount or 0),
        math.round(self._incomingMove.z, editorState.snap and editorState.snapAmount or 0)
    )

    --self.data.position = vec3.fromg3d(self.model.translation) + vec3.new(0, 2, 0)
    self.shader:send("hovered", self.hovered)
    self.shader:send("selected", self.selected)

    for k, v in pairs(self.data.position) do
        self.data.position[k] = math.round(v, 0.0001)
    end

    local finishlineSize = vec3.new(2,4,2)

    local pos = vec3.fromg3d(self.model.translation) + vec3.new(0,2,0)

    for k, handle in pairs(self.handles) do
        local offset = vec3.new(0,0,0)
        offset[handle.axis] = finishlineSize[handle.axis] / 2 + 3

        if handle.axis == "y" then
            offset[handle.axis] = offset[handle.axis] * -1
        end

        if string.sub(k, 1, 1) == "n" then
            offset[handle.axis] = offset[handle.axis] * -1
        end

        handle._position = pos - offset
        handle.positionModel:setTranslation((pos - offset):getTuple())
    end
end

local HANDLE_COLORS = {
    x = {1.0, 0.0, 0.0},
    y = {0.0, 1.0, 0.0},
    z = {0.0, 0.0, 1.0}
}

function finishline:draw()
    self.model:draw(self.shader)

    if self.selected then
        for k, handle in pairs(self.handles) do
            handle.shader:send("color", {HANDLE_COLORS[handle.axis][1], HANDLE_COLORS[handle.axis][2], HANDLE_COLORS[handle.axis][3], handle.hovered and 1 or 0.4})

            if editorState.tool == EDITOR_TOOLS.move then
                handle.positionModel:draw(handle.shader)
            end
        end
    end
end

function finishline:destroy()
    self.model = nil
    self.handles = nil
    self = nil
end

return finishline