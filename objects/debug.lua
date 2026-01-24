require "global"

local debug = {}
debug.__index = debug


function debug:new(position)
    local object = {
        model = g3d.newModel("models/cube.obj", assets["img/lava.png"], position:get(), vec3.new(0,0,0):get(), {0.1, 0.1, 0.1}),
    }
    
    setmetatable(object, self)
    return object
end

function debug:draw()
    self.model:draw()
end

return debug