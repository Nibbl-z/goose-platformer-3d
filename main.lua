require "global"

local Platform = require("objects.platform")
local Player = require("objects.player")
local Editor = require("editor")
local scene = "editor"

local ui = {
    editor = require("ui.editor")
}

platforms = {}

function love.load()
    love.mouse.setRelativeMode(true)

    biribiri:LoadSprites("img")

    table.insert(platforms, Platform:new(vec3.new(0,-60,0), vec3.new(100,10,100), PLATFORM_TYPE.default))

    table.insert(platforms, Platform:new(vec3.new(40,-48,0), vec3.new(30,1,30), PLATFORM_TYPE.default))
    table.insert(platforms, Platform:new(vec3.new(40,-48,0), vec3.new(10,50,10), PLATFORM_TYPE.default))
    table.insert(platforms, Platform:new(vec3.new(70,-28,20), vec3.new(10,50,10), PLATFORM_TYPE.default))
    table.insert(platforms, Platform:new(vec3.new(40,-28,0), vec3.new(30,1,30), PLATFORM_TYPE.default))

    table.insert(platforms, Platform:new(vec3.new(40,-28,40), vec3.new(10,50,10), PLATFORM_TYPE.lava))

    player = Player:new()

    for _, v in pairs(ui) do
        v:init()
    end
end

function love.mousemoved(x,y, dx,dy)
    if scene == "game" then
        player:mousemoved(x,y,dx,dy)
    elseif scene == "editor" then
        Editor:mousemoved(x,y,dx,dy)
    end
end

function love.wheelmoved(x, y)
    player:wheelmoved(x,y)
end

function love.update(dt)
    yan:update(dt)

    if scene == "game" then
        player.active = true
        player:update(dt, platforms)
    elseif scene == "editor" then
        Editor:update(dt, platforms)
        player.active = false
    end
end

function love.textinput(text)
    yan:textinput(text)
end

function love.keypressed(key)
    yan:keypressed(key)

    if key == "z" then
        love.mouse.setRelativeMode(true)
        scene = "game"
    elseif key == "x" then
        scene = "editor"
    end
    if key == "space" and (player.grounded or player.airtime <= 0.2) then
        player.jumpPressed = true
    end
end

function love.draw()
    love.graphics.print(tostring(love.timer.getFPS()), 0, 100)

    yan:draw()

    love.graphics.setBackgroundColor(0.1,0.1,0.1)
    for _, v in pairs(platforms) do
       v:draw()
    end

    player:draw()
    Editor:draw()
end