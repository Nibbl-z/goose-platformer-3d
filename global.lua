require "yan"
require "biribiri"
g3d = require "g3d"

vec3 = require "types.vec3"

EDITOR_TOOLS = {
    move = 1,
    scale = 2
}

editorState = {
    tool = EDITOR_TOOLS.move
}