require "global"

local checkpoint = {}
checkpoint.__index = checkpoint


function checkpoint:new(position)
    local object = {
        model = g3d.newModel("models/checkpoint.obj", assets["img/goog.png"], position:get(), {0,0,0}, {1,1,1}),
        position = position,
        active = false,
        time = 0,
        shader = love.graphics.newShader(g3d.shaderpath, "shaders/checkpoint.glsl"),
        speed = 1
    }
    
    setmetatable(object, self)
    return object
end

function checkpoint:update(dt)
    self.time = self.time + dt * (self.active and 1 or 0.25)
    self.model:setRotation(0, 0, self.model.rotation[3] + dt * self.speed)
    self.shader:send("time", self.time)
    self.shader:send("enabled", self.active)
    self.speed = self.speed + (1 - self.speed) * 0.99
end

function checkpoint:draw()
    self.model:draw(self.shader)
end

return checkpoint