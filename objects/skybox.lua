require "global"

local skybox = {}
skybox.__index = skybox

SKYBOXES = {
    "skybox_day",
    "skybox_night"
}

function skybox:new()
    local object = {
        model = g3d.newModel(g3d.loadObj("models/skybox.obj", false, true), assets["img/skybox_night.png"], {0,0,0}, {0,0,0}, {5,5,5}),
    }
    
    setmetatable(object, self)
    return object
end

function skybox:update(position)
    self.model:setTranslation(position:getTuple())
end

function skybox:draw()
    self.model:draw()
end

return skybox