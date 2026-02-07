local level = {}
local Platform = require("objects.platform")

function level:export(filename)
    local contents = {
        name = filename,
        description = "this is the description, so cool",
        creator = "nibbles !",
        platforms = {}
    }

    for _, platform in ipairs(platforms) do
        table.insert(contents.platforms, table.clone(platform.data))
    end

    love.filesystem.setIdentity("goose-platformer-3d")

    local file = love.filesystem.newFile(filename..".goose3d")
    
    local ok, err = file:open("w")
    print(ok, err)
    if not ok then
        return "Failed to export level: "..err
    end

    local ok, err = file:write(table.tostring(contents))
    if not ok then
        return "Failed to export level: "..err
    end
    print(ok, err)

    local ok = file:close()
    if not ok then
       return "Level exported successfully, but file failed to close. It'll probably still work :P"
    end
    print(ok)

    return "Level exported successfully!"
end

function level:load(filename)
    love.filesystem.setIdentity("goose-platformer-3d")

    local file = love.filesystem.newFile(filename)

    local ok, err = file:open("r")
    if not ok then
        return "Failed to load level: "..err
    end

    local contents = file:read()
    local data = loadstring("return "..contents)()

    return data
end

function level:loadGame(data)
    table.clear(platforms)

    for _, data in ipairs(data.platforms) do
        table.insert(platforms, Platform:new(data))
    end

    currentScene = "game"
end

return level