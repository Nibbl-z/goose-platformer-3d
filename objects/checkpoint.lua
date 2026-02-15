require "global"

local checkpoint = {}
checkpoint.__index = checkpoint


function checkpoint:new(position)
    local data = {
        position = position,
        size = vec3.new(2,4,2)
    } -- watcha s the nibbles refuses to properly refactor this to work with everything

    local object = {
        model = g3d.newModel("models/checkpoint.obj", assets["img/goog.png"], position:get(), {0,0,0}, {1,1,1}),
        data = {
            position = position
        },
        active = false,
        time = 0,
        hovered = false,
        selected = false,
        shader = love.graphics.newShader(g3d.shaderpath, "shaders/checkpoint.glsl"),
        speed = 1,
        nonPlatform = true,
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
    
    setmetatable(object, self)
    return object
end

function checkpoint:update(dt)
    self.data.position = vec3.fromg3d(self.model.translation)
    self.time = self.time + dt * (self.active and 1 or 0.25)
    self.model:setRotation(0, 0, self.model.rotation[3] + dt * self.speed)

    self.shader:send("time", self.time)
    self.shader:send("enabled", self.active)
    self.shader:send("hovered", self.hovered)
    self.shader:send("selected", self.selected)

    self.speed = self.speed + (1 - self.speed) * 0.99

    for k, v in pairs(self.data.position) do
        self.data.position[k] = math.round(v, 0.0001)
    end

    local checkpointSize = vec3.new(2,4,2)

    for k, handle in pairs(self.handles) do
        local offset = vec3.new(0,0,0)
        offset[handle.axis] = checkpointSize[handle.axis] / 2 + 3

        if handle.axis == "y" then
            offset[handle.axis] = offset[handle.axis] * -1
        end

        if string.sub(k, 1, 1) == "n" then
            offset[handle.axis] = offset[handle.axis] * -1
        end

        handle.positionModel:setTranslation((self.data.position - offset):getTuple())
    end
end

local HANDLE_COLORS = {
    x = {1.0, 0.0, 0.0},
    y = {0.0, 1.0, 0.0},
    z = {0.0, 0.0, 1.0}
}

function checkpoint:draw()
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

return checkpoint