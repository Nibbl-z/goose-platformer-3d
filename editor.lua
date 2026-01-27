require "global"
local Platform = require "objects.platform"
local World = require "objects.world"

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

local mouseX, mouseY = nil, nil
local debugObjs = {}
local Debug = require("objects.debug")

local chosenPlatform, selectedPlatform
local dragging = false

local history = {}
local MAX_HISTORY = 100

local currentHistory = 1

function camRay(dist,x,y)
    local rotation = camera.rotation

    local dx = (x or love.mouse.getX() - (love.graphics.getWidth() / 2)) * SENSITIVITY
    local dy = (y or love.mouse.getY() - (love.graphics.getHeight() / 2)) * SENSITIVITY

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

function updateHistory()
    local historyPlatforms = {}

    for _, platform in ipairs(platforms) do
        -- todo: this might be painful for when i add more properties to platforms.
        -- maybe there can just be like all the normal properties on a platform
        -- and then stuff like model and handles and selected can be in a _interal table, which isnt transfered
        table.insert(historyPlatforms, {
            position = vec3.fromg3d(platform.model.translation),
            size = vec3.fromg3d(platform.model.scale),
            platformType = platform.platformType
        })
    end

    table.insert(history, 1, historyPlatforms)
    
    if #history >= MAX_HISTORY then
        table.remove(history, 100)
    end
end

function editor:mousemoved(x, y, dx, dy)
    if love.mouse.isDown(2) then
        if mouseX ~= nil then
            love.mouse.setPosition(mouseX, mouseY)
        end

        camera.rotation = camera.rotation - vec3.new(0, dx * SENSITIVITY, dy * SENSITIVITY)
        camera.rotation.z = math.clamp(camera.rotation.z, -90, 90)
    end

    if selectedPlatform == nil then return end
    
    if love.mouse.isDown(1) then
        for k, handle in pairs(selectedPlatform.handles) do
            if handle.hovered then
                if not dragging then
                    updateHistory()
                end
                dragging = true
                local distance = (camera.position - vec3.fromg3d(handle.scaleModel.translation)):magnitude()

                local d = math.sqrt(dx ^ 2 + dy ^ 2)
                local pos = camRay(distance)
                local sign = ((pos - vec3.fromg3d(handle.scaleModel.translation))[handle.axis] < 0) and -1 or 1

                if editorState.tool == EDITOR_TOOLS.scale and handle.axis ~= "y" then -- i dont even know, i dont even want to know, 
                    sign = sign * -1
                end

                local move = d * (distance / 400 * sign)
                
                if editorState.tool == EDITOR_TOOLS.move then
                    selectedPlatform.model:setTranslation((vec3.fromg3d(selectedPlatform.model.translation) + vec3.new(
                        handle.axis == "x" and move or 0,
                        handle.axis == "y" and move or 0,
                        handle.axis == "z" and move or 0
                    )):getTuple())
                else
                    if editorState.tool == EDITOR_TOOLS.scale and string.sub(k, 1, 1) == "n" then
                        move = move * -1
                    end
                    selectedPlatform.model:setScale((vec3.fromg3d(selectedPlatform.model.scale) + vec3.new(
                        handle.axis == "x" and move or 0,
                        handle.axis == "y" and move or 0,
                        handle.axis == "z" and move or 0
                    )):getTuple())

                    selectedPlatform.model:setScale(math.abs(selectedPlatform.model.scale[1]), math.abs(selectedPlatform.model.scale[2]), math.abs(selectedPlatform.model.scale[3]))
                    
                    if editorState.tool == EDITOR_TOOLS.scale and string.sub(k, 1, 1) == "n" then
                        move = move * -1
                    end

                    selectedPlatform.model:setTranslation((vec3.fromg3d(selectedPlatform.model.translation) - vec3.new(
                        handle.axis == "x" and move / 2 or 0,
                        handle.axis == "y" and -move / 2 or 0,
                        handle.axis == "z" and move / 2 or 0
                    )):getTuple())
                end
                

                return
            end
        end
    else
        dragging = false
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

    -- welcome back to Lack of raycast hell
    for _, platform in ipairs(platforms) do
        platform.hovered = false
        for _, handle in pairs(platform.handles) do
            if not dragging then
                handle.hovered = false
            end
        end

        platform:updateHandles()
    end

    local dist = 75
    local handleDist = 75
    local chosenHandle = nil

    local optimizedPlatforms = {}

    for _, v in ipairs(platforms) do
        local pos = vec3.fromg3d(v.model.translation)
        if (pos - camera.position):magnitude() <= 80 then
            table.insert(optimizedPlatforms, v)
        end
    end

    for i = 1, 75, 1 do
        local rayPos = camRay(i)

        for _, platform in ipairs(optimizedPlatforms) do
            if platform.selected then
                for _, handle in pairs(platform.handles) do
                    if vec3.magnitude(rayPos - vec3.fromg3d(handle.positionModel.translation)) <= 6 and not dragging and i <= handleDist then
                        handleDist = i
                        chosenHandle = handle
                    end
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

    if chosenPlatform ~= nil and chosenHandle == nil and not dragging then
        chosenPlatform.hovered = true

        if love.mouse.isDown(1) and not dragging then
            for _, platform in ipairs(platforms) do
                platform.selected = false
            end
            selectedPlatform = chosenPlatform
            chosenPlatform.selected = true
        end
    end

    if chosenHandle ~= nil then
        chosenHandle.hovered = true
    end

    
        
    -- todo: ui for this

    if love.keyboard.isDown("1") then
        editorState.tool = EDITOR_TOOLS.move
    end

    if love.keyboard.isDown("2") then
        editorState.tool = EDITOR_TOOLS.scale
    end

    if love.keyboard.isDown("lctrl") and love.keyboard.isDown("z") then
        print("undo")
        if #history == 0 then return end
        currentHistory = math.clamp(currentHistory + 1, 1, #history)

        for _, v in ipairs(platforms) do
            v:destroy()
        end

        table.clear(platforms)

        for _, data in ipairs(history[currentHistory]) do
            local platform = Platform:new(data.position, data.size, data.platformType)
            table.insert(platforms, platform)
        end
    end

    camera.position = camera.position + direction:normalize() * dt * editorState.camSpeed

    g3d.camera.lookInDirection(camera.position.x, camera.position.z, camera.position.y, math.rad(camera.rotation.y), math.rad(camera.rotation.z))
end

function editor:draw()
    for _, d in ipairs(debugObjs) do
        d:draw()
    end
end

function editor:wheelmoved(x, y)
    editorState.camSpeed = math.clamp(editorState.camSpeed + y, 5, 100)
end

-- external

function editor:createPlatform()
    local pos = camRay(10, 0, 0)
    platform = Platform:new(pos, vec3.new(7,7,7), PLATFORM_TYPE.default)
    updateHistory()
    table.insert(platforms, platform)
end

return editor