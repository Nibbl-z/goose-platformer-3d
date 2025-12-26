require "global"

local platform = {}
platform.__index = platform

function platform:new(position, size)
    local object = {
        model = g3d.newModel("models/cube.obj", assets["img/goog.png"], position, vec3.new(0,0,0), size)
    }

    setmetatable(object, self)
    return object
end

function platform:draw()
    self.model:draw()
end

return platform