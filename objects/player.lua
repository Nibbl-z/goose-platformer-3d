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

local ANIMATIONS = {
    idle = {
        [0] = {
            root = {
                rotation = vec3.new(0,0,0)
            }
        },
        [5] = {
            root = {
                rotation = vec3.new(0,0,0.01),
                position = vec3.new(0.01,-0.02,0)
            }
        },
        [10] = {
            root = {
                rotation = vec3.new(0,0,0.02),
                position = vec3.new(0.02,-0.04,0)
            }
        },
        [15] = {
            root = {
                rotation = vec3.new(0,0,0.01),
                position = vec3.new(0.01,-0.02,0)
            }
        },
        [20] = "END"
    },
    run = {
        -- left back, right front
        [0] = {
            leftLeg = {
                rotation = vec3.new(0,0,0.4),
                position = vec3.new(-0.3, -0.1, 0)
            },
            rightLeg = {
                rotation = vec3.new(0,0,-0.5),
                position = vec3.new(0.3, -0.1, 0)
            },
            root = {position = vec3.new(0,-0.1,0)}
        },
        -- inbetween
        [2] = {
            leftLeg = {
                rotation = vec3.new(0,0,0.2),
                position = vec3.new(-0.1, 0, 0)
            },
            rightLeg = {
                rotation = vec3.new(0,0,-0.1),
                position = vec3.new(0.1, -0.05, 0)
            },
            root = {position = vec3.new(0,-0.05,0)}
        },
        -- middle
        [4] = {
            leftLeg = {
                rotation = vec3.new(0,0,0)
            },
            rightLeg = {
                rotation = vec3.new(0,0,-0)
            }
        },

        -- inbetween

        [6] = {
            leftLeg = {
                rotation = vec3.new(0,0,-0.3),
                position = vec3.new(0.1, -0.05, 0)
            },
            rightLeg = {
                rotation = vec3.new(0,0,0.2),
                position = vec3.new(-0.1, 0, 0)
            },
            root = {position = vec3.new(0,-0.05,0)}
        },

        -- right back, left front

        [8] = {
            leftLeg = {
                rotation = vec3.new(0,0,-0.5),
                position = vec3.new(0.3, -0.1, 0)
            },
            rightLeg = {
                rotation = vec3.new(0,0,0.4),
                position = vec3.new(-0.3, -0.1, 0)
            },
            root = {position = vec3.new(0,-0.1,0)}
        },

        -- inbetween

        [10] = {
            leftLeg = {
                rotation = vec3.new(0,0,-0.1),
                position = vec3.new(0.1, -0.05, 0)
            },
            rightLeg = {
                rotation = vec3.new(0,0,0.2),
                position = vec3.new(-0.1, 0, 0)
            },
            root = {position = vec3.new(0,-0.05,0)}
        },

        -- middle

        [12] = {
            leftLeg = {
                rotation = vec3.new(0,0,0)
            },
            rightLeg = {
                rotation = vec3.new(0,0,-0)
            }
        },

        -- inbetween

        [14] = {
            leftLeg = {
                rotation = vec3.new(0,0,0.2),
                position = vec3.new(-0.1, 0, 0)
            },
            rightLeg = {
                rotation = vec3.new(0,0,-0.3),
                position = vec3.new(0.1, -0.05, 0)
            },
            root = {position = vec3.new(0,-0.05,0)}
        },

        [16] = "END"
    },
    fall = {
        [0] = {
            root = {
                rotation = vec3.new(0,0,-0.1)
            },
            leftLeg = {
                rotation = vec3.new(0.15,0,0)
            },
            rightLeg = {
                rotation = vec3.new(-0.15,0,0)
            }
        },
        [3] = {
            root = {
                rotation = vec3.new(0,0,-0.15),
            },
            leftLeg = {
                rotation = vec3.new(0.075,0,0)
            },
            rightLeg = {
                rotation = vec3.new(-0.075,0,0)
            }
        },
        [6] = {
            root = {
                rotation = vec3.new(0,0,-0.1),
            },
            leftLeg = {
                rotation = vec3.new(0.05,0,0)
            },
            rightLeg = {
                rotation = vec3.new(-0.05,0,0)
            }
        },
        [9] = {
            root = {
                rotation = vec3.new(0,0,-0.15),
            },
            leftLeg = {
                rotation = vec3.new(0.075,0,0)
            },
            rightLeg = {
                rotation = vec3.new(-0.075,0,0)
            }
        },
        [12] = "END"
    }
}

local ANIM_LENGTHS = {}

function player:new()
    local object = {
        active = true,
        root = g3d.newModel(g3d.loadObj("models/goose.obj", false, true), assets["img/goose.skin.png"], vec3.new(0,0,0):get(), vec3.new(0,0,0):get()),
        leftLeg = g3d.newModel(g3d.loadObj("models/leftleg.obj", false, true), assets["img/goose.skin.png"], vec3.new(0,0,0):get(), vec3.new(0,0,0):get()),
        rightLeg = g3d.newModel(g3d.loadObj("models/rightleg.obj", false, true), assets["img/goose.skin.png"], vec3.new(0,0,0):get(), vec3.new(0,0,0):get()),
        camera = {
            position = vec3.new(0,0,0),
            rotation = vec3.new(0,0,0)
        },
        position = vec3.new(0,0,0),
        lerpPosition = vec3.new(0,0,0),
        modelDirection = 0,
        wraparoundCompensation = 0,
        lastModelRotation = 0,
        lastDirection = vec3.new(0,0,0),
        directionAdd = 0,
        acceleration = 0.0,
        velocity = vec3.new(0, -GRAVITY, 0),
        grounded = false,
        jumpPressed = false,
        airtime = 0.0,

        currentAnimation = "idle",
        currentFrame = -1,
        currentFrameData = nil,
        currentFrameTimer = 0.0
    }

    for k, anim in pairs(ANIMATIONS) do
        local max = 0
        for num, v in pairs(anim) do
            if v == "END" then 
                max = num
            end
        end

        ANIM_LENGTHS[k] = max
    end

    setmetatable(object, self)

    

    return object
end

function player:mousemoved(x, y, dx, dy)
    self.camera.rotation = self.camera.rotation - vec3.new(0, dx * SENSITIVITY, dy * SENSITIVITY)
    self.camera.rotation.z = math.clamp(self.camera.rotation.z, -90, 90)
end

function player:isGrounded(platforms)
    local lava = g3d.collisions.sphereIntersection(WORLD_LAVA.verts, WORLD_LAVA, self.position.x, self.position.z, self.position.y - 1.5, 0.1)
    if lava then
        self:reset()
        return
    end

    local _, x, y, z = g3d.collisions.sphereIntersection(WORLD.verts, WORLD, self.position.x, self.position.z, self.position.y - 1.5, 0.1)
    if x ~= nil then
        -- if platform.platformType == PLATFORM_TYPE.lava then
        --     self:reset()
        -- end
        return x, y, z
    end
end

function player:solveCollision(platforms, dt)
    local lava = g3d.collisions.capsuleIntersection(WORLD_LAVA.verts, WORLD_LAVA, self.position.x, self.position.z, self.position.y - 1.5, self.position.x, self.position.z, self.position.y + 1.5, 1.0)
    if lava then
        self:reset()
        return
    end

    local distance, x, z, y, nx, nz = g3d.collisions.capsuleIntersection(WORLD.verts, WORLD, self.position.x, self.position.z, self.position.y - 1.5, self.position.x, self.position.z, self.position.y + 1.5, 1.0)
    
    if distance ~= nil then 
        -- if platform.platformType == PLATFORM_TYPE.lava then
        --     self:reset()
        --     return
        -- end
        self.grounded = true

        self.position.x = self.position.x + nx * math.clamp(dt, 0, 1) * RUN_SPEED
        self.position.z = self.position.z + nz * math.clamp(dt, 0, 1) * RUN_SPEED
    end

    local above = g3d.collisions.sphereIntersection(WORLD.verts, WORLD, self.position.x, self.position.z, self.position.y + 1.5, 0.1)

    if above ~= nil then
        self.grounded = false
        self.velocity.y = -7
        self.position.y = self.position.y - GRAVITY * dt
    end
end

function player:reset()
    self.position = vec3.new(0,0,0)
    self.grounded = false
    self.airtime = 0

end

function player:updateModel()
    for k, v in pairs({root = self.root, leftLeg = self.leftLeg, rightLeg = self.rightLeg}) do
        local data = nil

        if self.currentFrameData ~= nil then
            data = self.currentFrameData[k]
        end

        local rx, ry, rz = 0,0,0
        local px, py, pz = 0,0,0

        if data ~= nil then
            
            if data["rotation"] ~= nil then
                rx = data["rotation"].x
                ry = data["rotation"].z
                rz = data["rotation"].y
            end

            if data["position"] ~= nil then
                px = data["position"].x
                py = data["position"].z
                pz = data["position"].y
            end
        end

        local x = px * math.cos(self.modelDirection) - py * math.sin(self.modelDirection)
        local y = px * math.sin(self.modelDirection) + py * math.cos(self.modelDirection)

        v:setRotation(0 + rx, 0 + ry, self.modelDirection + rz)
        v:setTranslation(self.position.x + x, self.position.z + y, self.position.y + pz)
    end
end

function player:updateCameraDistance(platforms)
    -- i have suffered for so long.
    -- rayIntersection just DOESNT WORK <3 YAY!!!!!!!!!!!!!!!!!!!

    -- thus enjoy this disaster

    for i = 0, CAMERA_DISTANCE, 1 do
        local camPos = (vec3.new(
            math.cos(math.rad(self.camera.rotation.y)) * math.cos(math.rad(self.camera.rotation.z)) * -i, 
            math.sin(math.rad(self.camera.rotation.z)) * -i, 
            math.sin(math.rad(self.camera.rotation.y)) * math.cos(math.rad(self.camera.rotation.z)) * -i
        ) + self.position + vec3.new(0,1,0))

        if g3d.collisions.sphereIntersection(WORLD.verts, WORLD, camPos.x, camPos.z, camPos.y, 0.1) then
            return i - 1
        end
    end
end

function player:update(dt, platforms)
    if not self.active then return end

    local distance = self:updateCameraDistance(platforms) or CAMERA_DISTANCE
    self.camera.position = vec3.new(
        math.cos(math.rad(self.camera.rotation.y)) * math.cos(math.rad(self.camera.rotation.z)) * -distance, 
        math.sin(math.rad(self.camera.rotation.z)) * -distance, 
        math.sin(math.rad(self.camera.rotation.y)) * math.cos(math.rad(self.camera.rotation.z)) * -distance
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
        
        if math.abs(math.deg(self.lastModelRotation - modelRotation)) >= 300 then
            if math.deg(self.lastModelRotation - modelRotation) > 0 then
                self.wraparoundCompensation = self.wraparoundCompensation + math.rad(360)
            else
                self.wraparoundCompensation = self.wraparoundCompensation - math.rad(360)
            end
        end
        self.lastModelRotation = modelRotation
        self.modelDirection = self.modelDirection + ((modelRotation + self.wraparoundCompensation) - self.modelDirection) * 0.1
    else
        self.currentAnimation = "idle"
        self.acceleration = math.clamp(self.acceleration - dt * 4, 0, 1)
    end

    if not self.grounded then
        self.currentAnimation = "fall"
    else
        if keysDown > 0 then
            self.currentAnimation = "run"
        else
            self.currentAnimation = "idle"
        end
    end

    if (self.grounded or self.airtime <= 0.2) and self.jumpPressed then
        self.jumpPressed = false
        self.grounded = false
        self.velocity.y = JUMP_HEIGHT
    end
    
    self.position = self.position + self.lastDirection:normalize() * dt * RUN_SPEED * self.acceleration

    self.position = self.position + self.velocity * dt

    local gx = self:isGrounded(platforms)

    if gx ~= nil then
        self.airtime = 0
        self.velocity.y = 0
        self.grounded = true
    else
        self.grounded = false
        self.velocity.y = math.clamp(self.velocity.y - dt * GRAVITY, -40, 40)
        self.airtime = self.airtime + dt
    end

    self.lerpPosition:lerp(self.position, 0.4)

    g3d.camera.lookInDirection(self.camera.position.x, self.camera.position.z, self.camera.position.y, math.rad(self.camera.rotation.y), math.rad(self.camera.rotation.z))
    self:solveCollision(platforms, dt)
    
    self.currentFrameTimer = self.currentFrameTimer + dt

    if self.currentFrameTimer >= 1/20 then
        self.currentFrameTimer = self.currentFrameTimer - 1/20
        self.currentFrame = self.currentFrame + 1

        if self.currentFrame > ANIM_LENGTHS[self.currentAnimation] then
            self.currentFrame = 0
        end

        if ANIMATIONS[self.currentAnimation][self.currentFrame] ~= nil then
            local data = ANIMATIONS[self.currentAnimation][self.currentFrame]
            if data == "END" then
                self.currentFrame = 0
                self.currentFrameData = ANIMATIONS[self.currentAnimation][0]
            elseif data ~= nil then
                self.currentFrameData = data
            end
        end
    end

    self:updateModel()
end

function player:wheelmoved(x, y)
    CAMERA_DISTANCE = math.clamp(CAMERA_DISTANCE - y, 3, 30)
end

function player:draw()
    if not self.active then return end
    self.root:draw()
    self.leftLeg:draw()
    self.rightLeg:draw()
end

return player