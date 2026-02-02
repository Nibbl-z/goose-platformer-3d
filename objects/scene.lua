require "global"

local scene = {}
scene.__index = scene

function scene:new(ui, update, draw, miscObjects)
    local object = {
        ui = ui,
        updateFunc = update,
        drawFunc = draw,
        miscObjects = miscObjects
    }
    
    setmetatable(object, self)
    return object
end

function scene:update(dt)
    self.updateFunc(dt)
end

function scene:draw()
    self.drawFunc()
end

function scene:wheelmoved(x,y)
    for _, v in ipairs(self.miscObjects) do
        if v.wheelmoved ~= nil then
            v:wheelmoved(x,y)
        end
    end
end

function scene:mousemoved(x,y,dx,dy)
    for _, v in ipairs(self.miscObjects) do
        if v.mousemoved ~= nil then
            v:mousemoved(x,y,dx,dy)
        end
    end
end

return scene