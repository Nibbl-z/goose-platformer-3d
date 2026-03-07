require "global"
local level = require "level"


local Platform = require("objects.platform")
local player = require("objects.player")
local Editor = require("editor")
local World = require("objects.world")
local skybox = require("objects.skybox")
local Scene = require("objects.scene")

local ui = {
    editor = require("ui.editor"),
    mainmenu = require("ui.mainmenu"),
    game = require("ui.game")
}

platforms = {}
checkpoints = {}
finishlines = {}

local SCENES = {}
currentScene = "mainmenu"
currentLevelPath = ""
local lastScene = nil

fade = {
    value = 0
}

function love.load()
    uiCanvas = love.graphics.newCanvas()

    biribiri:LoadSprites("img")
    biribiri:LoadAudio("sfx", "static")

    Player = player:new()
    Skybox = skybox:new()
    Editor:init()

    for _, v in pairs(ui) do
        v:init()
    end

    SCENES["mainmenu"] = Scene:new(
        ui.mainmenu, 
        -- Init
        function ()
            tween:new(fade, TweenInfo.new(0.2), {value = 0}):play()

            love.keyboard.setKeyRepeat(true)

            Skybox:set("night")

            ui.mainmenu:enterAnim()

            Player.position = vec3.new(4.5,20,-2)
            Player.modelDirection = 1.8

            g3d.camera.lookAt(0,0,0,5,0,0)

            table.clear(platforms)

            table.insert(platforms, Platform:new({
                position = vec3.new(5,-7,-2.2),
                size = vec3.new(4,10,4),
            }))

            for _, v in ipairs(platforms) do
                v:update(0.1)
            end

            World:updateMesh()
        end,
        -- Update
        function (dt)
            Player.menuMode = true
            Player.active = true
            love.mouse.setRelativeMode(false)
            Player:update(dt, platforms)
        end, 
        -- Draw
        function ()
            -- this should probably be a yan feature, but alas
            if ui.mainmenu.screen:get("main"):get("logo")._loadedImage then
                ui.mainmenu.screen:get("main"):get("logo")._loadedImage:setFilter("nearest", "nearest")
            end
            --love.graphics.setCanvas({uiCanvas, depth=true})
            --love.graphics.clear(0,0,0,0)
            for _, v in pairs(platforms) do
                v:draw()
            end
            
            Skybox:draw()
            Player:draw()
            love.graphics.setCanvas()
        end,
        {}
    )

    SCENES["game"] = Scene:new(
        ui.game, 
        -- Init
        function ()
            tween:new(fade, TweenInfo.new(0.5), {value = 0}):play()

            gametime = 0.0
            love.keyboard.setKeyRepeat(false)
            Player.position = vec3.new(0,0,0)
            Player.spawnpoint = vec3.new(0,0,0)
            Player.velocity = vec3.new(0,0,0)
            love.mouse.setRelativeMode(true)
            World:updateMesh()
            Player.menuMode = false
            Player.win = false
            ui.game:reset()
        end,
        -- Update
        function (dt)
            Player.active = true
            if not Player.win and not paused then
                gametime = gametime + dt
            end
            
            Player:update(dt, platforms)
            Skybox:update(Player.camera.position)
            for _, v in pairs(checkpoints) do
                v:update(dt)
            end
        end, 
        -- Draw
        function ()
            for _, v in pairs(platforms) do
                v:draw()
            end

            for _, v in pairs(checkpoints) do
                v:draw()
            end

            for _, v in pairs(finishlines) do
                v:draw()
            end

            Skybox:draw()
            Player:draw()
        end,
        {Player}
    )

    SCENES["editor"] = Scene:new(
        ui.editor,
        -- Init
        function ()
            tween:new(fade, TweenInfo.new(0.5), {value = 0}):play()

            love.keyboard.setKeyRepeat(true)
            ui.editor.exitConfirmation = false
            editorState.unsavedChanges = false
            Editor:reset()
        end,
        -- Update
        function (dt)
            Player.active = false
            Editor:update(dt, platforms)
            Skybox:update(Editor:getCam().position)
        end, 
        -- Draw
        function ()
            for _, v in pairs(platforms) do
                v:draw()
            end

            for _, v in pairs(checkpoints) do
                v:draw()
            end

            for _, v in pairs(finishlines) do
                v:draw()
            end

            Skybox:draw()
            Editor:drawGhost()
        end,
        {Editor}
    )
end

function love.mousemoved(x, y, dx, dy)
    for k, scene in pairs(SCENES) do
        if k == currentScene then
            scene:mousemoved(x, y, dx, dy)
        end
    end
end

function love.wheelmoved(x, y)
    for k, scene in pairs(SCENES) do
        if k == currentScene then
            scene:wheelmoved(x, y)
        end
    end
end

function love.update(dt)
    biribiri:Update(dt)
    yan:update(dt)

    if lastScene ~= currentScene then
        SCENES[currentScene]:init()
    end

    lastScene = currentScene

    for k, scene in pairs(SCENES) do
        if k == currentScene then
            scene.ui.screen.enabled = true
            scene:update(dt)
        else
            scene.ui.screen.enabled = false
        end
    end

    -- if scene == "game" then
    --     Player.active = true
    --     Player:update(dt, platforms)
    --     Skybox:update(player.camera.position)
    -- elseif scene == "editor" then
    --     Editor:update(dt, platforms)
    --     Player.active = false
    --     Skybox:update(Editor:getCam().position)
    -- end
end

function love.textinput(text)
    yan:textinput(text)
end

function love.keypressed(key)
    yan:keypressed(key)

    if key == "escape" and currentScene == "game" then
        paused = not paused

        if paused then
            love.mouse.setRelativeMode(false)
            ui.game:pause()
        else
            love.mouse.setRelativeMode(true)
            ui.game:unpause()
        end
    end

    if key == "," then
        love.mouse.setRelativeMode(true)
        currentScene = "game"
        World:updateMesh()
    elseif key == "." then
        currentScene = "editor"
    elseif key == "/" then
        currentScene = "mainmenu"
    end
    if key == "space" and (Player.grounded or Player.airtime <= 0.2) then
        Player.jumpPressed = true
    end
end

function love.draw()
    love.graphics.setColor(1,1,1)
    --love.graphics.print(tostring(love.timer.getFPS()), 0, 100)

    for k, scene in pairs(SCENES) do
        if k == currentScene then 
            scene:draw()
        end
    end
    
    yan:draw()
    
    if currentScene == "editor" then -- yes, icky hard coding, but this is literally just one edge case i dont want to deal with rn
        Editor:draw()
    end

    love.graphics.setColor(0,0,0,fade.value)
    love.graphics.rectangle("fill", 0,0,800,600)
end