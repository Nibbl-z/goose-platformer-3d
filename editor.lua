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

function editor:mousemoved(x, y, dx, dy)
    
    if love.mouse.isDown(2) then
        if mouseX ~= nil then
            love.mouse.setPosition(mouseX, mouseY)
        end
        camera.rotation = camera.rotation - vec3.new(0, dx * SENSITIVITY, dy * SENSITIVITY)
        camera.rotation.z = math.clamp(camera.rotation.z, -90, 90)
    end
end

function editor:update(dt)
    love.mouse.setRelativeMode(love.mouse.isDown(2))
    love.mouse.setGrabbed(love.mouse.isDown(2))
    love.mouse.setVisible(true)
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

            print(camera.rotation.y)
        end
    end

    if love.keyboard.isDown("e") then
        direction.y = 1
    end

    if love.keyboard.isDown("q") then
        direction.y = -1
    end
    --print(direction:normalize().x, direction:normalize().y, direction:normalize().z)
    camera.position = camera.position + direction:normalize() * dt * CAMERA_SPEED

    g3d.camera.lookInDirection(camera.position.x, camera.position.z, camera.position.y, math.rad(camera.rotation.y), math.rad(camera.rotation.z))
end

return editor