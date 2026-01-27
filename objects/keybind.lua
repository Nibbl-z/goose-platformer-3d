require "global"

local keybind = {}
keybind.__index = keybind


function keybind:new(key, shift, ctrl, callback)
    local object = {
        key = key,
        shift = shift or false,
        ctrl = ctrl or false,
        callback = callback,
        pressed = false
    }
    
    setmetatable(object, self)
    return object
end

function keybind:update()
    if love.keyboard.isDown(self.key) and love.keyboard.isDown("lshift") == self.shift and love.keyboard.isDown("lctrl") == self.ctrl then
        if self.pressed then return end
        self.pressed = true
        self.callback()
    else
        self.pressed = false
    end
end

return keybind