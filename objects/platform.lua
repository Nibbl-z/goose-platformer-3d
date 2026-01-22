require "global"

local platform = {}
platform.__index = platform

PLATFORM_TYPE = {
    default = 0,
    lava = 1
}

function platform:new(position, size, platformType)
    local textureLookup = {
        [0] = "img/stone.png",
        [1] = "img/lava.png"
    }

    local object = {
        model = g3d.newModel("models/cube.obj", assets[textureLookup[platformType]], position:get(), vec3.new(0,0,0):get(), size:get()),
        platformType = platformType
    }

    setmetatable(object, self)
    return object
end

function platform:draw()
    self.model:draw()
end

return platform