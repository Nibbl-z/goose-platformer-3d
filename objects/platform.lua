require "global"

local platform = {}
platform.__index = platform

PLATFORM_TYPE = {
    default = 0,
    lava = 1
}

local selectionShader = love.graphics.newShader(g3d.shaderpath, "shaders/selection.glsl")

function platform:new(position, size, platformType)
    local textureLookup = {
        [0] = "img/stone.png",
        [1] = "img/lava.png"
    }

    local object = {
        model = g3d.newModel("models/cube.obj", assets[textureLookup[platformType]], position:get(), vec3.new(0,0,0):get(), size:get()),
        platformType = platformType,
        hovered = false,
        selected = false,
        handles = {
            x = {
                axis = "x",
                positionModel = g3d.newModel("models/movehandle.obj", assets["img/goog.png"], (position - vec3.new(size.x / 2 + 3, 0, 0)):get(), vec3.new(0,math.rad(90),0):get(), vec3.new(0.5,0.5,0.5):get()),
                scaleModel = g3d.newModel("models/scalehandle.obj", assets["img/goog.png"], (position - vec3.new(size.x / 2 + 3, 0, 0)):get(), vec3.new(0,math.rad(90),0):get(), vec3.new(0.5,0.5,0.5):get()),
                shader = love.graphics.newShader(g3d.shaderpath, "shaders/solid.glsl"),
                hovered = false
            },
            y = {
                axis = "y",
                positionModel = g3d.newModel("models/movehandle.obj", assets["img/goog.png"], (position + vec3.new(0, size.y / 2 + 3, 0)):get(), vec3.new(math.rad(90),0,0):get(), vec3.new(0.5,0.5,0.5):get()),
                scaleModel = g3d.newModel("models/scalehandle.obj", assets["img/goog.png"], (position + vec3.new(0, size.y / 2 + 3, 0)):get(), vec3.new(math.rad(90),0,0):get(), vec3.new(0.5,0.5,0.5):get()),
                shader = love.graphics.newShader(g3d.shaderpath, "shaders/solid.glsl"),
                hovered = false
            },
            z = {
                axis = "z",
                positionModel = g3d.newModel("models/movehandle.obj", assets["img/goog.png"], (position + vec3.new(0, size.y / 2 + 3, 0)):get(), vec3.new(0,math.rad(180),0):get(), vec3.new(0.5,0.5,0.5):get()),
                scaleModel = g3d.newModel("models/scalehandle.obj", assets["img/goog.png"], (position - vec3.new(0, 0, size.z / 2 + 3)):get(), vec3.new(0,math.rad(180),0):get(), vec3.new(0.5,0.5,0.5):get()),
                shader = love.graphics.newShader(g3d.shaderpath, "shaders/solid.glsl"),
                hovered = false
            },
            nx = {
                axis = "x",
                positionModel = g3d.newModel("models/movehandle.obj", assets["img/goog.png"], (position - vec3.new(size.x / 2 + 3, 0, 0)):get(), vec3.new(0,math.rad(270),0):get(), vec3.new(0.5,0.5,0.5):get()),
                scaleModel = g3d.newModel("models/scalehandle.obj", assets["img/goog.png"], (position - vec3.new(size.x / 2 + 3, 0, 0)):get(), vec3.new(0,math.rad(270),0):get(), vec3.new(0.5,0.5,0.5):get()),
                shader = love.graphics.newShader(g3d.shaderpath, "shaders/solid.glsl"),
                hovered = false
            },
            ny = {
                axis = "y",
                positionModel = g3d.newModel("models/movehandle.obj", assets["img/goog.png"], (position + vec3.new(0, size.y / 2 + 3, 0)):get(), vec3.new(math.rad(270),0,0):get(), vec3.new(0.5,0.5,0.5):get()),
                scaleModel = g3d.newModel("models/scalehandle.obj", assets["img/goog.png"], (position + vec3.new(0, size.y / 2 + 3, 0)):get(), vec3.new(math.rad(270),0,0):get(), vec3.new(0.5,0.5,0.5):get()),
                shader = love.graphics.newShader(g3d.shaderpath, "shaders/solid.glsl"),
                hovered = false
            },
            nz = {
                axis = "z",
                positionModel = g3d.newModel("models/movehandle.obj", assets["img/goog.png"], (position + vec3.new(0, size.y / 2 + 3, 0)):get(), vec3.new(0,math.rad(0),0):get(), vec3.new(0.5,0.5,0.5):get()),
                scaleModel = g3d.newModel("models/scalehandle.obj", assets["img/goog.png"], (position - vec3.new(0, 0, size.z / 2 + 3)):get(), vec3.new(0,math.rad(0),0):get(), vec3.new(0.5,0.5,0.5):get()),
                shader = love.graphics.newShader(g3d.shaderpath, "shaders/solid.glsl"),
                hovered = false
            },
        }
    }

    setmetatable(object, self)
    return object
end


function platform:updateHandles()
    local position = vec3.fromg3d(self.model.translation)
    local size = vec3.fromg3d(self.model.scale)
    -- "this is horrible but there wont be any other handle types. I THINK"
    -- he was quickly proven wrong

    for k, handle in pairs(self.handles) do
        for _, model in ipairs({"positionModel", "scaleModel"}) do
            local offset = vec3.new(0,0,0)
            offset[handle.axis] = size[handle.axis] / 2 + 3

            if handle.axis == "y" then
                offset[handle.axis] = offset[handle.axis] * -1
            end

            if string.sub(k, 1, 1) == "n" then
                offset[handle.axis] = offset[handle.axis] * -1
            end

            handle[model]:setTranslation((position - offset):getTuple())
        end
    end

    -- self.handles.x.positionModel:setTranslation((position - vec3.new(size.x / 2 + 3, 0, 0)):getTuple())
    -- self.handles.y.positionModel:setTranslation((position + vec3.new(0, size.y / 2 + 3, 0)):getTuple())
    -- self.handles.z.positionModel:setTranslation((position - vec3.new(0, 0, size.z / 2 + 3)):getTuple())
    -- self.handles.x.scaleModel:setTranslation((position - vec3.new(size.x / 2 + 3, 0, 0)):getTuple())
    -- self.handles.y.scaleModel:setTranslation((position + vec3.new(0, size.y / 2 + 3, 0)):getTuple())
    -- self.handles.z.scaleModel:setTranslation((position - vec3.new(0, 0, size.z / 2 + 3)):getTuple())
end

local HANDLE_COLORS = {
    x = {1.0, 0.0, 0.0},
    y = {0.0, 1.0, 0.0},
    z = {0.0, 0.0, 1.0}
}

function platform:draw()
    self.model:draw((self.hovered or self.selected) and selectionShader or nil)
    if self.selected then
        for k, handle in pairs(self.handles) do
            handle.shader:send("color", {HANDLE_COLORS[handle.axis][1], HANDLE_COLORS[handle.axis][2], HANDLE_COLORS[handle.axis][3], handle.hovered and 1 or 0.4})

            if editorState.tool == EDITOR_TOOLS.move then
                handle.positionModel:draw(handle.shader)
            else
                handle.scaleModel:draw(handle.shader)
            end
            
        end
    end
end

return platform