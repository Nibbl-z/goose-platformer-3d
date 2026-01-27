require "global"
local world = {}

WORLD = nil
WORLD_LAVA = nil

function world:updateMesh()
    local verts = {}
    local lavaVerts = {}

    for _, platform in pairs(platforms) do
        
        local px = platform.model.translation[1]
        local py = platform.model.translation[2]
        local pz = platform.model.translation[3]
        local sx = platform.model.scale[1]
        local sy = platform.model.scale[2]
        local sz = platform.model.scale[3]

        for _, v in ipairs(platform.model.verts) do
            
            local vert = {v[1]*sx+px, v[2]*sy+py, v[3]*sz+pz, v[4], v[5], v[6], v[7], v[8]}

            if platform.platformType == PLATFORM_TYPE.default then
                table.insert(verts, vert)
            else
                table.insert(lavaVerts, vert)
            end
            
        end
    end

    if #verts > 0 then
        WORLD = g3d.newModel(verts, "img/goog.png")
    end

    if #lavaVerts > 0 then
        WORLD_LAVA = g3d.newModel(lavaVerts, "img/goog.png")
    end
   
    
end

return world