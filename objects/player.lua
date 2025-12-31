require "global"

local player = {}
player.__index = player

local CAMERA_DISTANCE = 5
local SENSITIVITY = 0.1
local RUN_SPEED = 15
local MOVE_DIRECTIONS = {
    w = 0,
    a = 90,
    s = 180,
    d = 270
}

function player:new()
    local object = {
        model = g3d.newModel("models/goose.obj", assets["img/goog.png"], vec3.new(0,0,0):get(), vec3.new(0,0,0):get()),
        camera = {
            position = vec3.new(0,0,0),
            rotation = vec3.new(0,0,0)
        },
        position = vec3.new(0,0,0),
        lerpPosition = vec3.new(0,0,0),
        modelDirection = 0,
        lastDirection = 0,
        directionAdd = 0,
    }

    setmetatable(object, self)
    return object
end

function player:mousemoved(x, y, dx, dy)
    self.camera.rotation = self.camera.rotation - vec3.new(0, dx * SENSITIVITY, dy * SENSITIVITY)
    self.camera.rotation.z = math.clamp(self.camera.rotation.z, -90, 90)

    

    

    -- print(self.camera.rotation:get())
    -- print(self.camera.position:get())
    -- print("..")
end

function player:update(dt)
    self.camera.position = vec3.new(
        math.cos(math.rad(self.camera.rotation.y)) * math.cos(math.rad(self.camera.rotation.z)) * -CAMERA_DISTANCE, 
        math.sin(math.rad(self.camera.rotation.z)) * -CAMERA_DISTANCE, 
        math.sin(math.rad(self.camera.rotation.y)) * math.cos(math.rad(self.camera.rotation.z)) * -CAMERA_DISTANCE
    ) + self.lerpPosition + vec3.new(0,1,0)

    local direction = vec3.new(0,0,0)
    local keysDown = 0
    for key, r in pairs(MOVE_DIRECTIONS) do
        if love.keyboard.isDown(key) then
            keysDown = keysDown + 1
            direction = direction + vec3.new(
                math.cos(math.rad(self.camera.rotation.y + r)),
                0,
                math.sin(math.rad(self.camera.rotation.y + r))
            )
        end
    end

    modelRotation = math.atan(direction.z / direction.x)

    if direction.x < 0 then
        modelRotation = modelRotation - math.rad(180)
    end

    if direction.x == 0 then
        modelRotation = 0
    end
    

    if keysDown > 0 then
        -- if self.lastDirection > 0 and modelRotation < 0 then
        --     print("correcting left turn")
        --     self.directionAdd = self.directionAdd + math.rad(180)
        -- end

        -- if self.lastDirection < 0 and modelRotation > 0 then
        --     print("correcting right turn")
        --     self.directionAdd = self.directionAdd - math.rad(180)
        -- end

        -- Oh my god.

        self.modelDirection = modelRotation
    end
    
    
    self.model:setRotation(0, 0, self.modelDirection)

    self.position = self.position + direction:normalize() * dt * RUN_SPEED
    self.lerpPosition:lerp(self.position, dt * 30)
    g3d.camera.lookInDirection(self.camera.position.x, self.camera.position.z, self.camera.position.y, math.rad(self.camera.rotation.y), math.rad(self.camera.rotation.z))
    
    
    self.model:setTranslation(self.position.x, self.position.z, self.position.y)

    self.lastDirection = modelRotation
end

function player:wheelmoved(x, y)
    CAMERA_DISTANCE = math.clamp(CAMERA_DISTANCE - y, 3, 30)
end

function player:draw()
    love.graphics.print(tostring(math.deg(self.modelDirection)).." .. "..tostring(math.deg((self.directionAdd))))
    self.model:draw()
end

return player