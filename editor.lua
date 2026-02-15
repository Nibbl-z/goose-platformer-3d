require "global"
local Platform = require "objects.platform"
local Checkpoint = require "objects.checkpoint"
local Level = require "level"

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
local Keybind = require("objects.keybind")

local chosenItem, selectedItem
local chosenHandle = nil
local extraSelected = {}
local dragging = false
local cameraTurning = false

local history = {}
local stateBeforeUndo = {}
local MAX_HISTORY = 100

local currentHistory = 0

local keybinds = {}

local mouse1, mouse2, mouse1down = false, false, false
local mouse1reset, mouse2reset, mouse1downreset = false, true, true

local clipboard = {}

local saturationValueShader = love.graphics.newShader("shaders/saturationvalue.glsl")
local hueShader = love.graphics.newShader("shaders/hue.glsl")

local hm, sm, vm = 0, 0, 0
local mouseInUi = false

function editor:reset()
    table.clear(history)
    table.clear(stateBeforeUndo)
    currentHistory = 0
    
    hm, sm, vm = 0, 0, 0
    camera.position = vec3.new(0,0,0)
    camera.rotation = vec3.new(0,0,0)
end

function editor:undo()
    if #history == 0 then return end
    if currentHistory == 0 then
        table.clear(stateBeforeUndo)
        for _, platform in ipairs(platforms) do
            table.insert(stateBeforeUndo, platform.data)
        end
    end
    currentHistory = math.clamp(currentHistory + 1, 1, #history)

    table.clear(platforms)

    for _, data in ipairs(history[currentHistory]) do
        local platform = Platform:new(data)
        table.insert(platforms, platform)
    end
end

function editor:redo()
    if #history == 0 then return end
    if currentHistory == 0 then return end
    table.clear(platforms)
    
    if currentHistory == 1 then
        currentHistory = 0
        for _, data in ipairs(stateBeforeUndo) do
            local platform = Platform:new(data)
            table.insert(platforms, platform)
        end
        return
    end

    currentHistory = math.clamp(currentHistory - 1, 1, #history)

    for _, data in ipairs(history[currentHistory]) do
        local platform = Platform:new(data)
        table.insert(platforms, platform)
    end
end

function editor:init()
    saturationValueShader:send("hue", 0)

    -- Ctrl+Z (undo)
    table.insert(keybinds, Keybind:new("z", false, true, function ()
        self:undo()
    end))

    -- Ctrl+Shift+Z (redo)
    table.insert(keybinds, Keybind:new("z", true, true, function ()
        self:redo()
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

    -- Save
    table.insert(keybinds, Keybind:new("s", false, true, function ()
        local result = Level:save(currentLevelPath)
        if result == "Level saved!" then editorState.unsavedChanges = false end
        
        require "ui.editor":addNotif(result) -- icky
    end))

    -- Move Tool
    table.insert(keybinds, Keybind:new("1", false, false, function ()
        editorState.tool = EDITOR_TOOLS.move
        require "ui.editor".screen:get("topbar"):get("movetool").backgroundcolor = Color.fromRgb(10,10,10)
        require "ui.editor".screen:get("topbar"):get("scaletool").backgroundcolor = Color.fromRgb(40,40,40)
    end))

    -- Scale Tool
    table.insert(keybinds, Keybind:new("2", false, false, function ()
        editorState.tool = EDITOR_TOOLS.scale
        require "ui.editor".screen:get("topbar"):get("scaletool").backgroundcolor = Color.fromRgb(10,10,10)
        require "ui.editor".screen:get("topbar"):get("movetool").backgroundcolor = Color.fromRgb(40,40,40)
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

function editor:updateHistory()
    editorState.unsavedChanges = true

    if currentHistory ~= 0 then
        for i = currentHistory, 1, -1 do
            table.remove(history, i)
        end
        currentHistory = 0
    end

    local historyPlatforms = {}

    for _, platform in ipairs(platforms) do
        table.insert(historyPlatforms, table.clone(platform.data))
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
        chosenItem = nil
        if mouseX ~= nil then
            love.mouse.setPosition(mouseX, mouseY)
        end

        camera.rotation = camera.rotation - vec3.new(0, dx * SENSITIVITY, dy * SENSITIVITY)
        camera.rotation.z = math.clamp(camera.rotation.z, -90, 90)
    else
        cameraTurning = false
    end

    if selectedItem == nil then return end
    
    if love.mouse.isDown(1) and chosenHandle ~= nil then
        for _, platform in ipairs({selectedItem, unpack(extraSelected)}) do
            if chosenHandle.hovered then
                if not dragging then
                    self:updateHistory()
                end
                dragging = true
                local distance = (camera.position - vec3.fromg3d(chosenHandle.positionModel.translation)):magnitude()

                local d = math.sqrt(dx ^ 2 + dy ^ 2)
                local pos = camRay(distance)
                local sign = ((pos - vec3.fromg3d(chosenHandle.positionModel.translation))[chosenHandle.axis] < 0) and -1 or 1

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
                elseif editorState.tool == EDITOR_TOOLS.scale and not platform.nonPlatform then
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

    mouse1down = love.mouse.isDown(1) and not mouse1downreset
    mouse1downreset = love.mouse.isDown(1)
    mouse2 = not love.mouse.isDown(2) and not mouse2reset
    mouse2reset = not love.mouse.isDown(2)

    local mousex, mousey = love.mouse.getPosition()

    local ui = require("ui.editor")
    local tx, ty, tsx, tsy = ui.screen:get("topbar"):getdrawingcoordinates()
    local px, py, psx, psy = ui.screen:get("properties"):getdrawingcoordinates()
    mouseInUi = false
    if biribiri.collision(mousex, mousey, 1, 1, tx, ty, tsx, tsy) then
        mouseInUi = true
    end

    if biribiri.collision(mousex, mousey, 1, 1, px, py, psx, psy) then
        mouseInUi = true
    end

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

    for _, platform in ipairs(checkpoints) do
        platform.hovered = false
        for _, handle in pairs(platform.handles) do
            if not dragging then
                handle.hovered = false
            end
        end
    end
    
    local dist = 75
    local handleDist = 75
    

    local optimizedItems = {}
    chosenItems = nil

    for _, v in ipairs(platforms) do
        v.hovered = false
        local pos = vec3.fromg3d(v.model.translation)
        if (pos - camera.position):magnitude() <= 80 then
            table.insert(optimizedItems, v)
        end
    end

    for _, v in ipairs(checkpoints) do
        v.hovered = false
        local pos = vec3.fromg3d(v.model.translation)
        if (pos - camera.position):magnitude() <= 80 then
            table.insert(optimizedItems, v)
        end
    end

    for i = 1, 75, 1 do
        local rayPos = camRay(i)

        for _, item in ipairs(optimizedItems) do
            if item.selected then
                for _, handle in pairs(item.handles) do
                    if vec3.magnitude(rayPos - vec3.fromg3d(handle.positionModel.translation)) <= 6 and not dragging and i <= handleDist and not (editorState.tool == EDITOR_TOOLS.scale and item.nonPlatform) then
                        handleDist = i
                        chosenHandle = handle
                    end
                end
            end

            if g3d.collisions.sphereIntersection(item.model.verts, item.model, rayPos.x, rayPos.z, rayPos.y, 1) then
                if i <= dist then
                    dist = i
                    chosenItem = item
                end
                
                break
            end
        end
    end

    
    
    if chosenItem ~= nil and chosenHandle == nil and not dragging and not mouseInUi then
        chosenItem.hovered = true

        if (mouse1 or (mouse2 and not cameraTurning)) and not dragging then
            
            if not mouse2 then editorState.rightClicked = false end

            if selectedItem ~= nil and love.keyboard.isDown("lshift") and chosenItem.selected == false then
                table.insert(extraSelected, chosenItem) 
            elseif not love.keyboard.isDown("lshift") and chosenItem.selected == false then
                for _, platform in ipairs(platforms) do
                    platform.selected = false
                end
                for _, checkpoint in ipairs(checkpoints) do
                    checkpoint.selected = false
                end
                table.clear(extraSelected)
                selectedItem = chosenItem
                
            end
            
            chosenItem.selected = true

            hm, sm, vm = self:getPlatformColors()
        end
    end

    if mouse2 and not cameraTurning then
        editorState.rightClicked = true
        editorState.rightClickPos = UDim2.new(0, love.mouse.getX(), 0, love.mouse.getY())
    end

    if mouse1 then
        editorState.rightClicked = false
    end

    for _, platform in ipairs(platforms) do
        if platform.selected then
            table.insert(editorState.selectedPlatforms, platform)
        end
    end

    for _, checkpoint in ipairs(checkpoints) do
        if checkpoint.selected then
            table.insert(editorState.selectedPlatforms, checkpoint)
        end
    end
    
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
        self:setPlatformColors(h, s, v, mouse1down)
    end

    if common:checkcollision(svX - 15, svY - 15, 140, 150, love.mouse.getX(), love.mouse.getY(), 1, 1) and love.mouse.isDown(1) then
        local mx, my = math.clamp(love.mouse.getX(), svX, svX + 120), math.clamp(love.mouse.getY(), svY, svY + 120)

        local s = 1 - (svX + 120 - mx) / 120
        local v = (svY + 120 - my) / 120
        sm = s
        vm = v
        self:setPlatformColors(hm, s, v, mouse1down)
    end

    if not editorState.usingTextInput then
        for _, keybind in ipairs(keybinds) do
            keybind:update()
        end
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
    self:updateHistory()
    table.insert(platforms, platform)
end

function editor:createCheckpoint()
    local pos = camRay(10, 0, 0)
    checkpoint = Checkpoint:new(pos)
    self:updateHistory()
    table.insert(checkpoints, checkpoint)
end

function editor:deletePlatforms()
    self:updateHistory()

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
    self:updateHistory()

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

    print(table.tostring(clipboard))
end

function editor:pastePlatforms()
    self:updateHistory()

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

function editor:setPlatformColors(h, s, v, update)
    if update then self:updateHistory() end

    local r, g, b = hsvToRgb(h, s, v)
    for i, platform in ipairs(platforms) do
        if platform.selected then
            platform.data.color = Color.new(r, g, b, 1)
        end
    end
end

function editor:getCam()
    return camera
end

return editor