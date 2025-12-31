require "global"

local Platform = require("objects.platform")
local Player = require("objects.player")


platforms = {}

function love.load()
    love.mouse.setRelativeMode(true)

    biribiri:LoadSprites("img")

    table.insert(platforms, Platform:new(vec3.new(0,-3,0), vec3.new(5,1,5)))

    -- table.insert(platforms, Platform:new(vec3.new(1, 0, 0)))

    -- table.insert(platforms, Platform:new(vec3.new(0, 1, 0)))

    -- table.insert(platforms, Platform:new(vec3.new(0, 0, 1)))
    
    player = Player:new()
end

function love.mousemoved(x,y, dx,dy)
    player:mousemoved(x,y,dx,dy)
end

function love.wheelmoved(x, y)
    player:wheelmoved(x,y)
end

function love.update(dt)
    player:update(dt)
end

function love.draw()
    for _, v in pairs(platforms) do
       v:draw()
    end

    player:draw()
end