local editor = {}

local camera = {
    position = vec3.new(0,0,0),
    rotation = vec3.new(0,0,0)
}

local SENSITIVITY = 0.1
local MOVE_DIRECTIONS = {
    w = 0,
    a = 90,
    s = 180,
    d = 270
}
local CAMERA_SPEED = 30

local mouseX, mouseY = nil, nil
local debugObjs = {}
local Debug = require("objects.debug")

local chosenPlatform, selectedPlatform

function camRay(dist)
    local rotation = camera.rotation

    local dx = (love.mouse.getX() - (love.graphics.getWidth() / 2)) * SENSITIVITY
    local dy = (love.mouse.getY() - (love.graphics.getHeight() / 2)) * SENSITIVITY

    local xmin = (-love.graphics.getWidth() / 2) * SENSITIVITY
    local xmax = (love.graphics.getWidth() / 2) * SENSITIVITY
    local ymin = (-love.graphics.getHeight() / 2) * SENSITIVITY
    local ymax = (love.graphics.getHeight() / 2) * SENSITIVITY

    local f = 90 / (math.pi / 2)

    local dxn = ((dx - xmin) / (xmax - xmin)) * (f - -f) + -f
    local dyn = ((dy - ymin) / (ymax - ymin)) * (f - -f) + -f

    rotation = rotation - vec3.new(0, dxn, dyn)

    return vec3.new(
        math.cos(math.rad(rotation.y)) * math.cos(math.rad(rotation.z)) * dist, 
        math.sin(math.rad(rotation.z)) * dist, 
        math.sin(math.rad(rotation.y)) * math.cos(math.rad(rotation.z)) * dist
    ) + camera.position
end

function editor:mousemoved(x, y, dx, dy)
    if love.mouse.isDown(2) then
        if mouseX ~= nil then
            love.mouse.setPosition(mouseX, mouseY)
        end

        camera.rotation = camera.rotation - vec3.new(0, dx * SENSITIVITY, dy * SENSITIVITY)
        camera.rotation.z = math.clamp(camera.rotation.z, -90, 90)
    end

    if love.mouse.isDown(1) then
        if selectedPlatform.moveHandles.x.hovered then
            local distance = (camera.position - vec3.fromg3d(selectedPlatform.moveHandles.x.model.translation)):magnitude()

            local d = math.sqrt(dx ^ 2 + dy ^ 2)
            local pos = camRay(distance)
            local m = ((pos - vec3.fromg3d(selectedPlatform.moveHandles.x.model.translation)).x < 0) and -1 or 1

            selectedPlatform.model:setTranslation( (vec3.fromg3d(selectedPlatform.model.translation) + vec3.new(d * (distance / 700 * m), 0, 0)):getTuple() )
            selectedPlatform.model:setTranslation( (vec3.fromg3d(selectedPlatform.model.translation) + vec3.new(d * (distance / 700 * m), 0, 0)):getTuple() )
        end
    end
end

function editor:update(dt, platforms)
    love.mouse.setRelativeMode(love.mouse.isDown(2))
    love.mouse.setGrabbed(love.mouse.isDown(2))

    local direction = vec3.new(0,0,0)

    if love.mouse.isDown(2) and mouseX == nil and mouseY == nil then
        mouseX = love.mouse.getX()
        mouseY = love.mouse.getY()
    end

    if not love.mouse.isDown(2) then
        mouseX = nil
        mouseY = nil
    end

    for key, r in pairs(MOVE_DIRECTIONS) do
        if love.keyboard.isDown(key) then
            direction = direction + vec3.new(
                math.cos(math.rad(camera.rotation.y + r)),
                (key == "a" or key == "d") and 0 or math.sin(math.rad(camera.rotation.z + r)),
                math.sin(math.rad(camera.rotation.y + r))
            )
        end
    end

    if love.keyboard.isDown("e") then
        direction.y = 1
    end

    if love.keyboard.isDown("q") then
        direction.y = -1
    end

    --if love.keyboard.isDown("1") then
        -- welcome back to Lack of raycast hell
    for _, platform in ipairs(platforms) do
        platform.hovered = false
        platform.moveHandles.x.hovered = false
        platform:updateHandles()
    end

    local dist = 100
    
    
    for i = 0.1, 50, 0.2 do
        local rayPos = camRay(i)

        for _, platform in ipairs(platforms) do
            if platform.selected then
                if vec3.magnitude(rayPos - vec3.fromg3d(platform.moveHandles.x.model.translation)) <= 6 then
                    platform.moveHandles.x.hovered = true
                end
            end

            if g3d.collisions.sphereIntersection(platform.model.verts, platform.model, rayPos.x, rayPos.z, rayPos.y, 0.1) then
                if i <= dist then
                    dist = i
                    chosenPlatform = platform
                end
                
                break
            end
        end
    end
    
    if dist == 100 then chosenPlatform = nil end

    if chosenPlatform ~= nil then
        chosenPlatform.hovered = true

        if love.mouse.isDown(1) then
            for _, platform in ipairs(platforms) do
                platform.selected = false
                
            end
            selectedPlatform = chosenPlatform
            chosenPlatform.selected = true
        end
    end
        
    --end
    
    camera.position = camera.position + direction:normalize() * dt * CAMERA_SPEED

    g3d.camera.lookInDirection(camera.position.x, camera.position.z, camera.position.y, math.rad(camera.rotation.y), math.rad(camera.rotation.z))
end

function editor:draw()
    for _, d in ipairs(debugObjs) do
        d:draw()
    end
end

return editor