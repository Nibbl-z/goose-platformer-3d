require "global"

local player = {}
player.__index = player

local CAMERA_DISTANCE = 5
local SENSITIVITY = 0.1

function player:new()
    local object = {
        model = g3d.newModel("models/goose.obj", assets["img/goog.png"], vec3.new(0,0,0), vec3.new(0,0,0)),
        camera = {
            position = vec3.new(0,0,0),
            rotation = vec3.new(0,0,0)
        },
        position = vec3.new(0,0,0)
    }

    setmetatable(object, self)
    return object
end

function player:mousemoved(x, y, dx, dy)
    self.camera.rotation = self.camera.rotation - vec3.new(0, dx * SENSITIVITY, dy * SENSITIVITY)
    self.camera.rotation[2] = math.clamp(self.camera.rotation[2], -90, 90)

    

    --self.model:setRotation(0, 0, math.rad(self.camera.rotation[3]))

    -- print(self.camera.rotation:get())
    -- print(self.camera.position:get())
    -- print("..")
end

function player:update()
    self.camera.position = vec3.new(
        math.cos(math.rad(self.camera.rotation[3])) * math.cos(math.rad(self.camera.rotation[2])) * -CAMERA_DISTANCE, 
        math.sin(math.rad(self.camera.rotation[2])) * -CAMERA_DISTANCE, 
        math.sin(math.rad(self.camera.rotation[3])) * math.cos(math.rad(self.camera.rotation[2])) * -CAMERA_DISTANCE
    ) + self.position

    if love.keyboard.isDown("w") then
        self.position = self.position + vec3.new(
            math.cos(math.rad(self.camera.rotation[3])) * 0.02,
            0,
            math.sin(math.rad(self.camera.rotation[3])) * 0.02
        )
    end

    g3d.camera.lookInDirection(self.camera.position[1], self.camera.position[2], self.camera.position[3], math.rad(self.camera.rotation[3]), math.rad(self.camera.rotation[2]))
    self.model:setTranslation(self.position:get())
end

function player:wheelmoved(x, y)
    CAMERA_DISTANCE = math.clamp(CAMERA_DISTANCE - y, 3, 30)
end

function player:draw()
    self.model:draw()
end

return player