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
        moveHandles = {
            x = {
                model = g3d.newModel("models/movehandle.obj", assets["img/goog.png"], (position - vec3.new(size.x / 2 + 3, 0, 0)):get(), vec3.new(0,math.rad(90),0):get(), vec3.new(0.5,0.5,0.5):get()),
                shader = love.graphics.newShader(g3d.shaderpath, "shaders/solid.glsl"),
                hovered = false
            },
            y = {
                model = g3d.newModel("models/movehandle.obj", assets["img/goog.png"], (position + vec3.new(0, size.y / 2 + 3, 0)):get(), vec3.new(math.rad(90),0,0):get(), vec3.new(0.5,0.5,0.5):get()),
                shader = love.graphics.newShader(g3d.shaderpath, "shaders/solid.glsl"),
                hovered = false
            },
            z = {
                model = g3d.newModel("models/movehandle.obj", assets["img/goog.png"], (position - vec3.new(0, 0, size.z / 2 + 3)):get(), vec3.new(0,math.rad(180),0):get(), vec3.new(0.5,0.5,0.5):get()),
                shader = love.graphics.newShader(g3d.shaderpath, "shaders/solid.glsl"),
                hovered = false
            },
        }
    }

    --

    setmetatable(object, self)
    return object
end

function platform:updateHandles()
    local position = vec3.fromg3d(self.model.translation)
    local size = vec3.fromg3d(self.model.scale)
    self.moveHandles.x.model:setTranslation((position - vec3.new(size.x / 2 + 3, 0, 0)):getTuple())
    self.moveHandles.y.model:setTranslation((position + vec3.new(0, size.y / 2 + 3, 0)):getTuple())
    self.moveHandles.z.model:setTranslation((position - vec3.new(0, 0, size.z / 2 + 3)):getTuple())
end

local HANDLE_COLORS = {
    x = {1.0, 0.0, 0.0},
    y = {0.0, 1.0, 0.0},
    z = {0.0, 0.0, 1.0}
}

function platform:draw()
    self.model:draw((self.hovered or self.selected) and selectionShader or nil)
    if self.selected then
        for k, handle in pairs(self.moveHandles) do
            handle.shader:send("color", {HANDLE_COLORS[k][1], HANDLE_COLORS[k][2], HANDLE_COLORS[k][3], handle.hovered and 1 or 0.4})
            handle.model:draw(handle.shader)
        end
    end
end

return platform