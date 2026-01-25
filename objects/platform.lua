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
                model = g3d.newModel("models/movehandle.obj", assets["img/goog.png"], (position - vec3.new(size.x / 2 + 5, 0, 0)):get(), vec3.new(0,math.rad(90),0):get(), vec3.new(0.5,0.5,0.5):get()),
                shader = love.graphics.newShader(g3d.shaderpath, "shaders/solid.glsl"),
                hovered = false
            }
        }
    }

    --

    setmetatable(object, self)
    return object
end

function platform:updateHandles()
    local position = vec3.fromg3d(self.model.translation)
    local size = vec3.fromg3d(self.model.scale)
    self.moveHandles.x.model:setTranslation((position - vec3.new(size.x / 2 + 5, 0, 0)):getTuple())
end

function platform:draw()
    self.model:draw((self.hovered or self.selected) and selectionShader or nil)
    if self.selected then
        self.moveHandles.x.shader:send("color", {1.0, 0.0, 0.0, self.moveHandles.x.hovered and 1 or 0.4})
        self.moveHandles.x.model:draw(self.moveHandles.x.shader)
    end
end

return platform