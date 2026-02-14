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
    unsavedChanges = false
}

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