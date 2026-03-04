require "global"

local skybox = {}
skybox.__index = skybox

SKYBOXES = {
    "day",
    "night",
    "space",
    "storm",
    "black",
    "gray",
    "white",
    "red",
    "orange",
    "yellow",
    "green",
    "blue",
    "purple",
    "pink",
}

SKYBOX_COLOR = {
    black = Color.fromRgb(0,0,0,255),
    gray = Color.fromRgb(30,30,30,255),
    white = Color.fromRgb(255,255,255,255),
    red = Color.fromRgb(255, 40, 40, 255),
    orange = Color.fromRgb(255, 127, 40,255),
    yellow = Color.fromRgb(255,255,40,255),
    green = Color.fromRgb(40,255,40,255),
    blue = Color.fromRgb(40,40,255,255),
    purple = Color.fromRgb(127,40,255,255),
    pink = Color.fromRgb(255,40,255,255)
}

function skybox:new()
    local object = {
        model = g3d.newModel(g3d.loadObj("models/skybox.obj", false, true), assets["img/skybox_night.png"], {0,0,0}, {0,0,0}, {5,5,5}),
        visible = true
    }
    
    setmetatable(object, self)
    return object
end

function skybox:set(texture)
    if assets["img/skybox_"..texture..".png"] ~= nil then
        self.visible = true
        self.model.mesh:setTexture(assets["img/skybox_"..texture..".png"])
    else
        love.graphics.setBackgroundColor(SKYBOX_COLOR[texture]:get())
        self.visible = false
    end
end

function skybox:update(position)
    self.model:setTranslation(position:getTuple())
end

function skybox:draw()
    if not self.visible then return end
    self.model:draw()
end

return skybox