vec3 = {}
vec3.__index = vec3

function vec3.new(x, y, z)
    return setmetatable({
        x = x,
        y = y,
        z = z
    }, vec3)
end

function vec3.__add(a, b)
    return vec3.new(a.x + b.x, a.y + b.y, a.z + b.z)
end

function vec3.__sub(a, b)
    return vec3.new(a.x - b.x, a.y - b.y, a.z - b.z)
end

function vec3.__mul(a, b)
    return vec3.new(a.x * b, a.y * b, a.z * b)
end

function vec3:get()
    return {self.x, self.z, self.y}
end

function vec3:magnitude()
    return math.sqrt(self.x ^ 2 + self.y ^ 2 + self.z ^ 2)
end

function vec3:normalize()
    local magnitude = self:magnitude()
    if magnitude == 0 then return vec3.new(0,0,0) end
    return vec3.new(self.x / magnitude, self.y / magnitude, self.z / magnitude)
end

function vec3:lerp(to, t)
    self.x = self.x + (to.x - self.x) * t
    self.y = self.y + (to.y - self.y) * t
    self.z = self.z + (to.z - self.z) * t
end

return vec3