require "global"

local platform = {}
platform.__index = platform

PLATFORM_TYPE = {
    default = 0,
    lava = 1
}

local selectionShader = love.graphics.newShader(g3d.shaderpath, "shaders/selection.glsl")
local textureLookup = {
    [0] = "img/stone.png",
    [1] = "img/lava.png"
}

function platform:new(data)
    

    local object = {
        data = {
            position = data.position,
            size = data.size,
            type = data.type or PLATFORM_TYPE.default,
            collision = data.collision or true
        },
        model = g3d.newModel("models/cube.obj", assets[textureLookup[data.type]], data.position:get(), vec3.new(0,0,0):get(), data.size:get()),
        hovered = false,
        selected = false,
        handles = {
            x = {
                axis = "x",
                positionModel = g3d.newModel("models/movehandle.obj", assets["img/goog.png"], (data.position - vec3.new(data.size.x / 2 + 3, 0, 0)):get(), vec3.new(0,math.rad(90),0):get(), vec3.new(0.5,0.5,0.5):get()),
                scaleModel = g3d.newModel("models/scalehandle.obj", assets["img/goog.png"], (data.position - vec3.new(data.size.x / 2 + 3, 0, 0)):get(), vec3.new(0,math.rad(90),0):get(), vec3.new(0.5,0.5,0.5):get()),
                shader = love.graphics.newShader(g3d.shaderpath, "shaders/solid.glsl"),
                hovered = false
            },
            y = {
                axis = "y",
                positionModel = g3d.newModel("models/movehandle.obj", assets["img/goog.png"], (data.position + vec3.new(0, data.size.y / 2 + 3, 0)):get(), vec3.new(math.rad(90),0,0):get(), vec3.new(0.5,0.5,0.5):get()),
                scaleModel = g3d.newModel("models/scalehandle.obj", assets["img/goog.png"], (data.position + vec3.new(0, data.size.y / 2 + 3, 0)):get(), vec3.new(math.rad(90),0,0):get(), vec3.new(0.5,0.5,0.5):get()),
                shader = love.graphics.newShader(g3d.shaderpath, "shaders/solid.glsl"),
                hovered = false
            },
            z = {
                axis = "z",
                positionModel = g3d.newModel("models/movehandle.obj", assets["img/goog.png"], (data.position + vec3.new(0, data.size.y / 2 + 3, 0)):get(), vec3.new(0,math.rad(180),0):get(), vec3.new(0.5,0.5,0.5):get()),
                scaleModel = g3d.newModel("models/scalehandle.obj", assets["img/goog.png"], (data.position - vec3.new(0, 0, data.size.z / 2 + 3)):get(), vec3.new(0,math.rad(180),0):get(), vec3.new(0.5,0.5,0.5):get()),
                shader = love.graphics.newShader(g3d.shaderpath, "shaders/solid.glsl"),
                hovered = false
            },
            nx = {
                axis = "x",
                negative = true,
                positionModel = g3d.newModel("models/movehandle.obj", assets["img/goog.png"], (data.position - vec3.new(data.size.x / 2 + 3, 0, 0)):get(), vec3.new(0,math.rad(270),0):get(), vec3.new(0.5,0.5,0.5):get()),
                scaleModel = g3d.newModel("models/scalehandle.obj", assets["img/goog.png"], (data.position - vec3.new(data.size.x / 2 + 3, 0, 0)):get(), vec3.new(0,math.rad(270),0):get(), vec3.new(0.5,0.5,0.5):get()),
                shader = love.graphics.newShader(g3d.shaderpath, "shaders/solid.glsl"),
                hovered = false
            },
            ny = {
                axis = "y",
                negative = true,
                positionModel = g3d.newModel("models/movehandle.obj", assets["img/goog.png"], (data.position + vec3.new(0, data.size.y / 2 + 3, 0)):get(), vec3.new(math.rad(270),0,0):get(), vec3.new(0.5,0.5,0.5):get()),
                scaleModel = g3d.newModel("models/scalehandle.obj", assets["img/goog.png"], (data.position + vec3.new(0, data.size.y / 2 + 3, 0)):get(), vec3.new(math.rad(270),0,0):get(), vec3.new(0.5,0.5,0.5):get()),
                shader = love.graphics.newShader(g3d.shaderpath, "shaders/solid.glsl"),
                hovered = false
            },
            nz = {
                axis = "z",
                negative = true,
                positionModel = g3d.newModel("models/movehandle.obj", assets["img/goog.png"], (data.position + vec3.new(0, data.size.y / 2 + 3, 0)):get(), vec3.new(0,math.rad(0),0):get(), vec3.new(0.5,0.5,0.5):get()),
                scaleModel = g3d.newModel("models/scalehandle.obj", assets["img/goog.png"], (data.position - vec3.new(0, 0, data.size.z / 2 + 3)):get(), vec3.new(0,math.rad(0),0):get(), vec3.new(0.5,0.5,0.5):get()),
                shader = love.graphics.newShader(g3d.shaderpath, "shaders/solid.glsl"),
                hovered = false
            },
        }
    }

    setmetatable(object, self)

    return object
end

function platform:destroy()
    self.model = nil
    self.handles = nil
    self = nil
end


function platform:update()
    -- "this is horrible but there wont be any other handle types. I THINK"
    -- he was quickly proven wrong

    self.data.position = vec3.fromg3d(self.model.translation)
    self.data.size = vec3.fromg3d(self.model.scale)

    for k, v in pairs(self.data.position) do
        self.data.position[k] = math.round(v, 0.0001)
    end

    for k, v in pairs(self.data.size) do
        self.data.size[k] = math.round(v, 0.0001)
    end

    for k, handle in pairs(self.handles) do
        for _, model in ipairs({"positionModel", "scaleModel"}) do
            local offset = vec3.new(0,0,0)
            offset[handle.axis] = self.data.size[handle.axis] / 2 + 3

            if handle.axis == "y" then
                offset[handle.axis] = offset[handle.axis] * -1
            end

            if string.sub(k, 1, 1) == "n" then
                offset[handle.axis] = offset[handle.axis] * -1
            end

            handle[model]:setTranslation((self.data.position - offset):getTuple())
        end
    end

    self.model.mesh:setTexture(assets[textureLookup[self.data.type]])
end

local HANDLE_COLORS = {
    x = {1.0, 0.0, 0.0},
    y = {0.0, 1.0, 0.0},
    z = {0.0, 0.0, 1.0}
}

function platform:draw()
    if self.model == nil then return end
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