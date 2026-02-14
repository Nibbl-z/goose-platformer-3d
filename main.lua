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

local SCENES = {}
currentScene = "mainmenu"
currentLevelPath = ""
local lastScene = nil

function love.load()
    uiCanvas = love.graphics.newCanvas()

    biribiri:LoadSprites("img")

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
            Player.position = vec3.new(0,0,0)
            Player.velocity = vec3.new(0,0,0)
            World:updateMesh()
        end,
        -- Update
        function (dt)
            Player.active = true
            Player.menuMode = false
            love.mouse.setRelativeMode(true)
            Player:update(dt, platforms)
            Skybox:update(Player.camera.position)
        end, 
        -- Draw
        function ()
            for _, v in pairs(platforms) do
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
            ui.editor.exitConfirmation = false
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

            Skybox:draw()
            
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

    if key == "=" then
        print(level:export("level"..tostring(love.math.random(1,100000))))
    end

    if key == "-" then
        local result = level:load()
        if type(result) == "table" then
            table.clear(platforms)
            print(table.tostring(result.platforms))
            
        end
    end

    if key == "m" then
        for _, v in ipairs(platforms) do
            print(table.tostring(v.data))
        end
    end
end

function love.draw()
    love.graphics.setColor(1,1,1)
    --love.graphics.print(tostring(love.timer.getFPS()), 0, 100)
    love.graphics.setBackgroundColor(0.1,0.1,0.1,1)

    for k, scene in pairs(SCENES) do
        if k == currentScene then 
            scene:draw()
        end
    end
    
    yan:draw()
    
    if currentScene == "editor" then -- yes, icky hard coding, but this is literally just one edge case i dont want to deal with rn
        Editor:draw()
    end
end