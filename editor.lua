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
local Keybind = require("objects.keybind")

local chosenPlatform, selectedPlatform
local chosenHandle = nil
local extraSelected = {}
local dragging = false
local cameraTurning = false

local history = {}
local stateBeforeUndo = {}
local MAX_HISTORY = 100

local currentHistory = 0

local keybinds = {}

local mouse1, mouse2 = false, false
local mouse1reset, mouse2reset = false, false

local clipboard = {}

local saturationValueShader = love.graphics.newShader("shaders/saturationvalue.glsl")
local hueShader = love.graphics.newShader("shaders/hue.glsl")

local hm, sm, vm = 0, 0, 0

function editor:init()
    saturationValueShader:send("hue", 0)

    -- Ctrl+Z (undo)
    table.insert(keybinds, Keybind:new("z", false, true, function ()
        if #history == 0 then return end
        if currentHistory == 0 then
            for _, platform in ipairs(platforms) do
                table.clear(stateBeforeUndo)
                table.insert(stateBeforeUndo, {
                    position = vec3.fromg3d(platform.model.translation),
                    size = vec3.fromg3d(platform.model.scale),
                    platformType = platform.platformType
                })
            end
        end
        currentHistory = math.clamp(currentHistory + 1, 1, #history)

        table.clear(platforms)

        for _, data in ipairs(history[currentHistory]) do
            local platform = Platform:new(data)
            table.insert(platforms, platform)
        end
    end))

    -- Ctrl+Shift+Z (redo)
    table.insert(keybinds, Keybind:new("z", true, true, function ()
        if #history == 0 then return end
        if currentHistory == 0 then return end

        if currentHistory == 1 then
            currentHistory = 0
            for _, data in ipairs(stateBeforeUndo) do
                local platform = Platform:new(data)
                table.insert(platforms, platform)
            end
            return
        end

        currentHistory = math.clamp(currentHistory - 1, 1, #history)
        table.clear(platforms)

        for _, data in ipairs(history[currentHistory]) do
            local platform = Platform:new(data)
            table.insert(platforms, platform)
        end
    end))

    -- Delete
    table.insert(keybinds, Keybind:new("delete", false, false, function ()
        self:deletePlatforms()
    end))

    -- Duplicate
    table.insert(keybinds, Keybind:new("d", false, true, function ()
        self:duplicatePlatforms()
    end))

    -- Copy
    table.insert(keybinds, Keybind:new("c", false, true, function ()
        self:copyPlatforms()
    end))

    -- Paste
    table.insert(keybinds, Keybind:new("v", false, true, function ()
        self:pastePlatforms()
    end))

    -- Cut
    table.insert(keybinds, Keybind:new("x", false, true, function ()
        self:copyPlatforms()
        self:deletePlatforms()
    end))
end

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
    if currentHistory ~= 0 then
        for i = currentHistory, 1, -1 do
            table.remove(history, i)
        end
        currentHistory = 0
    end

    local historyPlatforms = {}

    for _, platform in ipairs(platforms) do
        table.insert(historyPlatforms, platform.data)
    end

    table.insert(history, 1, historyPlatforms)
    
    if #history >= MAX_HISTORY then
        table.remove(history, 100)
    end
end

function editor:mousemoved(x, y, dx, dy)
    love.mouse.setRelativeMode(love.mouse.isDown(2))
    love.mouse.setGrabbed(love.mouse.isDown(2))
    if love.mouse.isDown(2) then
        cameraTurning = true
        editorState.rightClicked = false
        chosenPlatform = nil
        if mouseX ~= nil then
            love.mouse.setPosition(mouseX, mouseY)
        end

        camera.rotation = camera.rotation - vec3.new(0, dx * SENSITIVITY, dy * SENSITIVITY)
        camera.rotation.z = math.clamp(camera.rotation.z, -90, 90)
    else
        cameraTurning = false
    end

    if selectedPlatform == nil then return end
    
    if love.mouse.isDown(1) and chosenHandle ~= nil then
        for _, platform in ipairs({selectedPlatform, unpack(extraSelected)}) do
            if chosenHandle.hovered then
                if not dragging then
                    updateHistory()
                end
                dragging = true
                local distance = (camera.position - vec3.fromg3d(chosenHandle.scaleModel.translation)):magnitude()

                local d = math.sqrt(dx ^ 2 + dy ^ 2)
                local pos = camRay(distance)
                local sign = ((pos - vec3.fromg3d(chosenHandle.scaleModel.translation))[chosenHandle.axis] < 0) and -1 or 1

                if editorState.tool == EDITOR_TOOLS.scale and chosenHandle.axis ~= "y" then -- i dont even know, i dont even want to know, 
                    sign = sign * -1
                end

                local move = d * (distance / 400 * sign)
                
                if editorState.tool == EDITOR_TOOLS.move then
                    platform.model:setTranslation((vec3.fromg3d(platform.model.translation) + vec3.new(
                        chosenHandle.axis == "x" and move or 0,
                        chosenHandle.axis == "y" and move or 0,
                        chosenHandle.axis == "z" and move or 0
                    )):getTuple())
                else
                    if editorState.tool == EDITOR_TOOLS.scale and chosenHandle.negative == true then
                        move = move * -1
                    end
                    platform.model:setScale((vec3.fromg3d(platform.model.scale) + vec3.new(
                        chosenHandle.axis == "x" and move or 0,
                        chosenHandle.axis == "y" and move or 0,
                        chosenHandle.axis == "z" and move or 0
                    )):getTuple())

                    platform.model:setScale(math.abs(platform.model.scale[1]), math.abs(platform.model.scale[2]), math.abs(platform.model.scale[3]))
                    
                    if editorState.tool == EDITOR_TOOLS.scale and chosenHandle.negative == true then
                        move = move * -1
                    end

                    platform.model:setTranslation((vec3.fromg3d(platform.model.translation) - vec3.new(
                        chosenHandle.axis == "x" and move / 2 or 0,
                        chosenHandle.axis == "y" and -move / 2 or 0,
                        chosenHandle.axis == "z" and move / 2 or 0
                    )):getTuple())
                end
            end
        end
    else
        dragging = false
        chosenHandle = nil
    end
end

function editor:updateMovement(dt)
    local direction = vec3.new(0,0,0)

    if love.mouse.isDown(2) and mouseX == nil and mouseY == nil then
        mouseX = love.mouse.getX()
        mouseY = love.mouse.getY()
    end

    if not love.mouse.isDown(2) then
        mouseX = nil
        mouseY = nil
    end

    if not love.keyboard.isDown("lshift") and not love.keyboard.isDown("lctrl") then
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
    end

    camera.position = camera.position + direction:normalize() * dt * editorState.camSpeed

    g3d.camera.lookInDirection(camera.position.x, camera.position.z, camera.position.y, math.rad(camera.rotation.y), math.rad(camera.rotation.z))
end

function editor:update(dt, platforms)
    -- love2d, add a love.mouse.isDownThisDamnFrameOnlyOnce and my life is yours
    mouse1 = not love.mouse.isDown(1) and not mouse1reset
    mouse1reset = not love.mouse.isDown(1)
    
    mouse2 = not love.mouse.isDown(2) and not mouse2reset
    mouse2reset = not love.mouse.isDown(2)

    self:updateMovement(dt)

    table.clear(editorState.selectedPlatforms)

    -- update platform selection and handle selection
    for _, platform in ipairs(platforms) do
        platform.hovered = false
        for _, handle in pairs(platform.handles) do
            if not dragging then
                handle.hovered = false
            end
        end

        platform:update(dt)
    end
    
    local dist = 75
    local handleDist = 75
    

    local optimizedPlatforms = {}
    chosenPlatform = nil
    for _, v in ipairs(platforms) do
        v.hovered = false
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

            if g3d.collisions.sphereIntersection(platform.model.verts, platform.model, rayPos.x, rayPos.z, rayPos.y, 1) then
                if i <= dist then
                    dist = i
                    chosenPlatform = platform
                end
                
                break
            end
        end
    end

    
    
    if chosenPlatform ~= nil and chosenHandle == nil and not dragging then
        chosenPlatform.hovered = true

        if (mouse1 or (mouse2 and not cameraTurning)) and not dragging then
            
            if not mouse2 then editorState.rightClicked = false end

            if selectedPlatform ~= nil and love.keyboard.isDown("lshift") and chosenPlatform.selected == false then
                table.insert(extraSelected, chosenPlatform) 
            elseif not love.keyboard.isDown("lshift") and chosenPlatform.selected == false then
                for _, platform in ipairs(platforms) do
                    platform.selected = false
                end
                table.clear(extraSelected)
                selectedPlatform = chosenPlatform
                
            end
            
            chosenPlatform.selected = true

            hm, sm, vm = self:getPlatformColors()
        end

        if mouse2 and not cameraTurning then
            editorState.rightClicked = true
            editorState.rightClickPos = UDim2.new(0, love.mouse.getX(), 0, love.mouse.getY())
        end
    end

    for _, platform in ipairs(platforms) do
        if platform.selected then
            table.insert(editorState.selectedPlatforms, platform)
        end
        
    end

    local ui = require("ui.editor")
    ui:updateProperties()

    if chosenHandle ~= nil then
        chosenHandle.hovered = true
    end

    local hueX, hueY = ui.screen:get("properties"):get("colorpicker"):get("h"):getdrawingcoordinates()
    local svX, svY = ui.screen:get("properties"):get("colorpicker"):get("sv"):getdrawingcoordinates()
    -- woo hardcoding again
    if common:checkcollision(hueX, hueY - 5, 30, 125, love.mouse.getX(), love.mouse.getY(), 1, 1) and love.mouse.isDown(1) then
        local my = math.clamp(love.mouse.getY(), hueY, hueY + 120)
        local _, s, v = self:getPlatformColors()
        local h = 1 - (hueY + 120 - my) / 120
        hm = h
        self:setPlatformColors(h, s, v)
    end

    if common:checkcollision(svX - 15, svY - 15, 140, 150, love.mouse.getX(), love.mouse.getY(), 1, 1) and love.mouse.isDown(1) then
        local mx, my = math.clamp(love.mouse.getX(), svX, svX + 120), math.clamp(love.mouse.getY(), svY, svY + 120)

        local s = 1 - (svX + 120 - mx) / 120
        local v = (svY + 120 - my) / 120
        sm = s
        vm = v
        self:setPlatformColors(hm, s, v)
    end

    for _, keybind in ipairs(keybinds) do
        keybind:update()
    end

    if love.keyboard.isDown("1") then
        editorState.tool = EDITOR_TOOLS.move
    end

    if love.keyboard.isDown("2") then
        editorState.tool = EDITOR_TOOLS.scale
    end
end

function editor:draw()
    local ui = require("ui.editor")

    -- debugging renderer i used for making undo/redo history work, just gonna keep this just in case
    -- love.graphics.print(tostring(currentHistory).."::"..tostring(#history), 100, 50)
    -- for i, v in ipairs(history) do
    --     if #history - currentHistory >= i then
    --         love.graphics.setColor(1,0,0,1)
    --     else
    --         love.graphics.setColor(1,1,1,1)
    --     end
    --     love.graphics.print(tostring(i)..table.tostring(v), 100, 100 + i * 20)
    -- end

    for _, d in ipairs(debugObjs) do
        d:draw()
    end

    saturationValueShader:send("hue", hm)

    love.graphics.setShader(saturationValueShader)

    local x, y = ui.screen:get("properties"):get("colorpicker"):get("sv"):getdrawingcoordinates()
    local x1, y1 = ui.screen:get("properties"):get("colorpicker"):get("h"):getdrawingcoordinates()
    
    love.graphics.draw(assets["img/goog.png"], x, y, 0, 120/128)
    love.graphics.setShader(hueShader)
    love.graphics.draw(assets["img/goog.png"], x1, y1, 0, 25/128, 120/128)
    love.graphics.setShader()

    love.graphics.circle("fill", x + (sm * 120), y + ((1 - vm) * 120), 2)
    love.graphics.rectangle("fill", x1, y1 + (hm * 120), 25, 2)
end

function editor:wheelmoved(x, y)
    editorState.camSpeed = math.clamp(editorState.camSpeed + y, 5, 100)
end

-- external

function editor:createPlatform()
    local pos = camRay(10, 0, 0)
    platform = Platform:new({
        position = pos, 
        size = vec3.new(7,7,7), 
        type = PLATFORM_TYPE.default
    })
    updateHistory()
    table.insert(platforms, platform)
end

function editor:deletePlatforms()
    updateHistory()

    for _, platform in ipairs(platforms) do
        if platform.selected then
            table.remove(platforms, table.find(platforms, platform))
            platform:destroy()
        end
    end

    for _, platform in ipairs(platforms) do
        if platform.selected then
            table.remove(platforms, table.find(platforms, platform))
            platform:destroy()
        end
    end

    -- i dont know
end

function editor:duplicatePlatforms()
    updateHistory()

    table.clear(extraSelected)
    selectedPlatform = nil

    local newPlatforms = {}

    for _, platform in ipairs(platforms) do
        if platform.selected then
            platform.selected = false
            data = platform.data
            data.position = data.position + vec3.new(0, data.size.y, 0)
            local newPlatform = Platform:new(data)
            newPlatform.selected = true
            table.insert(newPlatforms, newPlatform)

            if #newPlatforms == 1 then
                selectedPlatform = newPlatform
            else
                table.insert(extraSelected, newPlatform)
            end
        end
    end

    for _, v in ipairs(newPlatforms) do
        table.insert(platforms, v)
    end
end

function editor:copyPlatforms()
    table.clear(clipboard)

    for _, platform in ipairs(platforms) do
        if platform.selected then
            table.insert(clipboard, table.clone(platform.data))
        end
    end
end

function editor:pastePlatforms()
    updateHistory()

    table.clear(extraSelected)
    selectedPlatform = nil

    for _, platform in ipairs(platforms) do
        platform.selected = false
    end

    for i, data in ipairs(clipboard) do
        local newPlatform = Platform:new(data)
        newPlatform.selected = true
        table.insert(newPlatform, platform)

        if i == 1 then
            selectedPlatform = newPlatform
        else
            table.insert(extraSelected, newPlatform)
        end

        table.insert(platforms, newPlatform)
    end
end

function editor:getPlatformColors()
    local h, s, v = 1, 1, 1
    local i = 1
    for _, platform in ipairs(platforms) do
        if platform.selected then
            if i == 1 then
                h, s, v = rgbToHsv(platform.data.color:get())
            else
                local h2, s2, v2 = rgbToHsv(platform.data.color:get())
                if h2 ~= h then h = 1 end
                if s2 ~= s then s = 1 end
                if v2 ~= v then v = 1 end
            end
            i = i + 1
        end
    end

    return h, s, v
end

function editor:setPlatformColors(h, s, v)
    local r, g, b = hsvToRgb(h, s, v)
    for i, platform in ipairs(platforms) do
        if platform.selected then
            platform.data.color = Color.new(r, g, b, 1)
        end
    end
end

return editor