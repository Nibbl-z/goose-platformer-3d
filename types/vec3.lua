vec3 = {}
vec3.__index = vec3

function vec3.new(x, y, z)
    return setmetatable({x, z, y}, vec3)
end

function vec3.__add(a, b)
    return vec3.new(a[1] + b[1], a[3] + b[3], a[2] + b[2])
end

function vec3.__sub(a, b)
    return vec3.new(a[1] - b[1], a[3] - b[3], a[2] - b[2])
end

function vec3:get()
    return self[1], self[2], self[3]
end

function vec3:getRad()
    return math.rad(self[1]), math.rad(self[2]), math.rad(self[3])
end

return vec3