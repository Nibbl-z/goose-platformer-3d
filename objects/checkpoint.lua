require "global"

local checkpoint = {}
checkpoint.__index = checkpoint


function checkpoint:new(position)
    local object = {
        model = g3d.newModel("models/checkpoint.obj", assets["img/goog.png"], position:get(), {0,0,0}, {1,1,1}),
        position = position,
        active = false,
        time = 0,
        shader = love.graphics.newShader(g3d.shaderpath, "shaders/checkpoint.glsl")
    }
    
    setmetatable(object, self)
    return object
end

function checkpoint:update(dt)
    self.time = self.time + dt
    self.model:setRotation(0, 0, self.model.rotation[3] + dt)
    self.shader:send("time", self.time)
end

function checkpoint:draw()
    self.model:draw(self.shader)
end

return checkpoint