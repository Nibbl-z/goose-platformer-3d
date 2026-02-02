require "global"

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
local currentScene = "mainmenu"

function love.load()
    uiCanvas = love.graphics.newCanvas()

    biribiri:LoadSprites("img")

    Player = player:new()
    Skybox = skybox:new()
    Editor:init()

    Player.position = vec3.new(4.5,20,-2)
    Player.modelDirection = 1.8
    table.insert(platforms, Platform:new({
        position = vec3.new(5,-7,-2.2),
        size = vec3.new(4,10,4),
    }))

    for _, v in ipairs(platforms) do
        v:update(0.1)
    end

    World:updateMesh()

    for _, v in pairs(ui) do
        v:init()
    end

    SCENES["mainmenu"] = Scene:new(
        ui.mainmenu, 
        -- Update
        function (dt)
            Player.menuMode = true
            Player:update(dt, platforms)
        end, 
        -- Draw
        function ()
            -- this should probably be a yan feature, but alas
            if ui.mainmenu.screen:get("logo")._loadedImage then
                ui.mainmenu.screen:get("logo")._loadedImage:setFilter("nearest", "nearest")
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
        -- Update
        function (dt)
            Player.active = true
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
            Editor:draw()
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
    yan:update(dt)

    for k, scene in pairs(SCENES) do
        if k == currentScene then
            scene.ui.screen.enabled = true
            scene:update(dt)
        else
            scene.ui.screen.enabled = false
            -- ..?
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
    end
    if key == "space" and (Player.grounded or Player.airtime <= 0.2) then
        Player.jumpPressed = true
    end

    if key == "m" then
        for _, v in ipairs(platforms) do
            print(table.tostring(v.data))
        end
    end
end

function love.draw()
    love.graphics.setColor(1,1,1)
    love.graphics.print(tostring(love.timer.getFPS()), 0, 100)
    love.graphics.setBackgroundColor(0.1,0.1,0.1,1)

    for k, scene in pairs(SCENES) do
        if k == currentScene then
            scene:draw()
        end
    end

    yan:draw()
end