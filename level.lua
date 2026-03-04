local level = {}
local Platform = require("objects.platform")
local Checkpoint = require("objects.checkpoint")
local FinishLine = require("objects.finishline")

function level:export(data, filename)
    if data.name == "" then
        return "Level name needs to be at least 1 character!"
    end

    if data.description == "" then
        return "Level description needs to be at least 1 character!"
    end

    if data.creator == "" then
        return "Level creator needs to be at least 1 character!"
    end

    love.filesystem.setIdentity("goose-platformer-3d")

    if filename == nil then
        filename = data.name..".goose3d"
    end

    if love.filesystem.getInfo(filename) ~= nil then
        return "A level already exists with the file name "..filename.."!"
    end

    local contents = {
        name = data.name,
        description = data.description,
        creator = data.creator,
        skybox = data.skybox,
        platforms = {},
        checkpoints = {},
        finishlines = {},
    }
    
    local file = love.filesystem.newFile(filename)
    
    local ok, err = file:open("w")

    if not ok then
        return "Failed to export level: "..err
    end

    local ok, err = file:write(table.tostring(contents))
    if not ok then
        return "Failed to export level: "..err
    end

    local ok = file:close()
    if not ok then
       return "Level exported successfully, but file failed to close. It'll probably still work :P"
    end
end

function level:save(filename)
    local file = love.filesystem.newFile(filename)
    
    local ok, err = file:open("r")
    if not ok then return "Failed to save level: "..err end

    local contents = file:read()
    local data = loadstring("return "..contents)()
    table.clear(data.platforms)
    table.clear(data.checkpoints)
    table.clear(data.finishlines)

    for _, platform in ipairs(platforms) do
        table.insert(data.platforms, table.clone(platform.data))
    end

    for _, pos in ipairs(checkpoints) do
        table.insert(data.checkpoints, table.clone(pos.data.position))
    end

    for _, pos in ipairs(finishlines) do
        table.insert(data.finishlines, table.clone(pos.data.position))
    end

    file:close()

    local ok, err = file:open("w")
    if not ok then return "Failed to save level: "..err end

    local ok, err = file:write(table.tostring(data))
    if not ok then return "Failed to save level: "..err end

    file:close()

    return "Level saved!"
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
    table.clear(checkpoints)
    table.clear(finishlines)

    for _, data in ipairs(data.platforms) do
        table.insert(platforms, Platform:new(data))
    end

    for _, pos in ipairs(data.checkpoints) do
        table.insert(checkpoints, Checkpoint:new(vec3.new(pos.x, pos.y, pos.z)))
    end

    for _, pos in ipairs(data.finishlines) do
        table.insert(finishlines, FinishLine:new(vec3.new(pos.x, pos.y, pos.z)))
    end
    
    Skybox:set(data.skybox)

    currentScene = "game"
end

function level:restart()
    gametime = 0.0
    love.keyboard.setKeyRepeat(false)
    Player.position = vec3.new(0,0,0)
    Player.spawnpoint = vec3.new(0,0,0)
    Player.velocity = vec3.new(0,0,0)
    love.mouse.setRelativeMode(true)

    Player.menuMode = false
    Player.win = false

    for _, checkpoint in ipairs(checkpoints) do
        checkpoint.active = false
    end
end

function level:loadEditor(data)
    table.clear(platforms)
    table.clear(checkpoints)
    table.clear(finishlines)

    for _, data in ipairs(data.platforms) do
        table.insert(platforms, Platform:new(data))
    end

    for _, pos in ipairs(data.checkpoints) do
        table.insert(checkpoints, Checkpoint:new(vec3.new(pos.x, pos.y, pos.z)))
    end

    for _, pos in ipairs(data.finishlines) do
        table.insert(finishlines, FinishLine:new(vec3.new(pos.x, pos.y, pos.z)))
    end

    Skybox:set(data.skybox)

    currentScene = "editor"
end

function level:changeMetadata(newData, filename)
    if newData.name == "" then
        return "Level name needs to be at least 1 character!"
    end

    if newData.description == "" then
        return "Level description needs to be at least 1 character!"
    end

    if newData.creator == "" then
        return "Level creator needs to be at least 1 character!"
    end

    local renameFile = false

    local file = love.filesystem.newFile(filename)

    local ok, err = file:open("r")
    if not ok then
        return "Failed to update level: "..err
    end

    local data = loadstring("return "..file:read())()
    if data.name ~= newData.name then
        renameFile = true
    end
    data.name = newData.name
    data.description = newData.description
    data.creator = newData.creator
    data.skybox = newData.skybox

    local stringedData = table.tostring(data)

    if renameFile then
        local newFile = love.filesystem.newFile(newData.name..".goose3d")

        local ok, err = newFile:open("w")
        if not ok then
            return "Failed to update level: "..err
        end

        local ok, err = newFile:write(stringedData)
        if not ok then
            return "Failed to update level: "..err
        end

        file:close()
        newFile:close()
        love.filesystem.remove(filename)
    else
        file:close()
        local ok, err = file:open("w")

        if not ok then
            return "Failed to update level: "..err
        end

        local ok, err = file:write(stringedData)
        if not ok then
            return "Failed to update level: "..err
        end

        file:close()
    end

    -- local newNamePath = newName..".goose3d"
    -- local info = love.filesystem.getInfo(newNamePath)
    -- print(info)
    -- if info ~= nil then
    --     return "Another level already has the new name!"
    -- end

    -- local oldFile = love.filesystem.newFile(oldName)

    -- local ok, err = oldFile:open("r")
    -- if not ok then
    --     return "Failed to load level data: "..err
    -- end

    -- local data = loadstring("return "..oldFile:read())()
    -- data.name = newName

    -- local stringedData = table.tostring(data)

    -- local newFile = love.filesystem.newFile(newNamePath)
    -- local ok, err = newFile:open("w")
    -- if not ok then
    --     return "Failed to update level name: "..err
    -- end

    -- local ok, err = newFile:write(stringedData)
    -- if not ok then
    --     return "Failed to update level name: "..err
    -- end
end

function level:deleteLevel(path)
    love.filesystem.remove(path)
end

return level