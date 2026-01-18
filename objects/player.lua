require "global"

local player = {}
player.__index = player

local CAMERA_DISTANCE = 5
local SENSITIVITY = 0.1
local RUN_SPEED = 25
local JUMP_HEIGHT = 35

local MOVE_DIRECTIONS = {
    w = 0,
    a = 90,
    s = 180,
    d = 270
}

local GRAVITY = 70

function player:new()
    local object = {
        model = g3d.newModel(g3d.loadObj("models/goose.obj", false, true), assets["img/goose.skin.png"], vec3.new(0,0,0):get(), vec3.new(0,0,0):get()),
        camera = {
            position = vec3.new(0,0,0),
            rotation = vec3.new(0,0,0)
        },
        position = vec3.new(0,0,0),
        lerpPosition = vec3.new(0,0,0),
        modelDirection = 0,
        lastDirection = vec3.new(0,0,0),
        directionAdd = 0,
        acceleration = 0.0,
        velocity = vec3.new(0, -GRAVITY, 0),
        grounded = false
    }

    setmetatable(object, self)
    return object
end

function player:mousemoved(x, y, dx, dy)
    self.camera.rotation = self.camera.rotation - vec3.new(0, dx * SENSITIVITY, dy * SENSITIVITY)
    self.camera.rotation.z = math.clamp(self.camera.rotation.z, -90, 90)
end

function player:isGrounded(platforms)
    -- This is probably bad.
    for _, platform in ipairs(platforms) do
        local _, x, y, z = g3d.collisions.sphereIntersection(platform.model.verts, platform.model, self.position.x, self.position.z, self.position.y - 1.5, 0.1)
        if x ~= nil then
            
            return x + platform.model.translation[1], y + platform.model.translation[3], z + platform.model.translation[2]
        end
    end
end

function player:solveCollision(platforms, dt)
    -- This is probably worse.

    for _, platform in ipairs(platforms) do
        local distance, x, z, _, nx, nz = g3d.collisions.capsuleIntersection(platform.model.verts, platform.model, self.position.x, self.position.z, self.position.y - 1.5, self.position.x, self.position.z, self.position.y + 1.5, 1.0)
        
        if distance ~= nil then  
            self.grounded = true

            self.position.x = self.position.x + nx * math.clamp(dt, 0, 1) * RUN_SPEED
            self.position.z = self.position.z + nz * math.clamp(dt, 0, 1) * RUN_SPEED

        end
    end
end

function player:update(dt, platforms)
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
        self.lastDirection = direction
        self.acceleration = math.clamp(self.acceleration + dt * 4, 0, 1)
        self.modelDirection = modelRotation
    else
        self.acceleration = math.clamp(self.acceleration - dt * 4, 0, 1)
    end

    if self.grounded and love.keyboard.isDown("space") then
        self.grounded = false
        self.velocity.y = JUMP_HEIGHT
    end

    self.model:setRotation(0, 0, self.modelDirection)
    
    self.position = self.position + self.lastDirection:normalize() * dt * RUN_SPEED * self.acceleration

    self.position = self.position + self.velocity * dt

    local gx, gy, gz = self:isGrounded(platforms)
   

    if gx ~= nil then
        self.velocity.y = 0
        self.grounded = true
    else
        self.velocity.y = math.clamp(self.velocity.y - dt * GRAVITY, -40, 40)
    end

    self.lerpPosition:lerp(self.position, 0.4)


    g3d.camera.lookInDirection(self.camera.position.x, self.camera.position.z, self.camera.position.y, math.rad(self.camera.rotation.y), math.rad(self.camera.rotation.z))
    self:solveCollision(platforms, dt)
    self.model:setTranslation(self.position.x, self.position.z, self.position.y)
     
    
end

function player:wheelmoved(x, y)
    CAMERA_DISTANCE = math.clamp(CAMERA_DISTANCE - y, 3, 30)
end

function player:draw()
    love.graphics.print(tostring(self.acceleration))
    self.model:draw()
end

return player