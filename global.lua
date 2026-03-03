require "yan"
require "biribiri"
g3d = require "g3d"

vec3 = require "types.vec3"

EDITOR_TOOLS = {
    move = 1,
    scale = 2
}

editorState = {
    tool = EDITOR_TOOLS.move,
    camSpeed = 30,
    rightClicked = false,
    rightClickPos = UDim2.new(0,0,0,0),
    usingTextInput = false,
    selectedPlatforms = {},
    unsavedChanges = false,
    snap = false,
    snapAmount = 0
}

gametime = 0.0
paused = false


function intersect3d(pos1, size1, pos2, size2)
    local minx1, miny1, minz1 = pos1.x - size1.x / 2, pos1.y - size1.y / 2, pos1.z - size1.z / 2
    local maxx1, maxy1, maxz1 = pos1.x + size1.x / 2, pos1.y + size1.y / 2, pos1.z + size1.z / 2
    local minx2, miny2, minz2 = pos2.x - size2.x / 2, pos2.y - size2.y / 2, pos2.z - size2.z / 2
    local maxx2, maxy2, maxz2 = pos2.x + size2.x / 2, pos2.y + size2.y / 2, pos2.z + size2.z / 2

    return 
        minx1 <= maxx2 and
        maxx1 >= minx2 and
        miny1 <= maxy2 and
        maxy1 >= miny2 and
        minz1 <= maxz2 and
        maxz1 >= minz2
end

function point3d(point, pos, size)
    local minx, miny, minz = pos.x - size.x / 2, pos.y - size.y / 2, pos.z - size.z / 2
    local maxx, maxy, maxz = pos.x + size.x / 2, pos.y + size.y / 2, pos.z + size.z / 2
    return 
        point.x >= minx and
        point.x <= maxx and
        point.y >= miny and
        point.y <= maxy and
        point.z >= minz and
        point.z <= maxz
end

-- source: https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua (because. why do this myself. again.)
-- (edited to input 0-1 rgb instead of 0-255 rgb)

function rgbToHsv(r, g, b, a)
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, v
    v = max

    local d = max - min
    if max == 0 then s = 0 else s = d / max end

    if max == min then
    h = 0 -- achromatic
    else
    if max == r then
    h = (g - b) / d
    if g < b then h = h + 6 end
    elseif max == g then h = (b - r) / d + 2
    elseif max == b then h = (r - g) / d + 4
    end
    h = h / 6
    end

    return h, s, v, a
end

function hsvToRgb(h, s, v, a)
    local r, g, b

    local i = math.floor(h * 6);
    local f = h * 6 - i;
    local p = v * (1 - s);
    local q = v * (1 - f * s);
    local t = v * (1 - (1 - f) * s);

    i = i % 6

    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end

    return r, g, b, a
end