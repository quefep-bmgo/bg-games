---@class Vector4 : cls
local Vector4 = class("Vector4")
Vector4.tostring_overload = true

local new = Vector4.new

function Vector4:ctor(x, y, z, w)
    self.x = x or 0
    self.y = y or 0
    self.z = z or 0
    self.w = w or 0
end

function Vector4:__add(v4)
    return new(self.x + v4.x, self.y + v4.y, self.z + v4.z, self.w + v4.w)
end

function Vector4:__sub(v4)
    return new(self.x - v4.x, self.y - v4.y, self.z - v4.z, self.w - v4.w)
end

function Vector4:__mul(n)
    assert(type(n) == "number")
    return new(self.x * n, self.y * n, self.z * n, self.w * n)
end

function Vector4:__div(n)
    assert(type(n) == "number")
    return new(self.x / n, self.y / n, self.z / n, self.w / n)
end

function Vector4:__unm()
    return new(-self.x, -self.y, -self.z, -self.w)
end

function Vector4:__eq(v4)
    return self.x == v4.x and self.y == v4.y and self.z == v4.z and self.w == v4.w
end

function Vector4:__lt(v4)
    return self.x < v4.x and self.y < v4.y and self.z < v4.z and self.w < v4.w
end

function Vector4:__le(v4)
    return self.x <= v4.x and self.y <= v4.y and self.z <= v4.z and self.w <= v4.w
end

function Vector4:__tostring()
    return string.format("Vector4: {%s,%s,%s,%s}", self.x, self.y, self.z, self.w)
end

function Vector4:add(v4)
    self.x = self.x + v4.x
    self.y = self.y + v4.y
    self.z = self.z + v4.z
    self.w = self.w + v4.w
end

function Vector4:sub(v4)
    self.x = self.x - v4.x
    self.y = self.y - v4.y
    self.z = self.z - v4.z
    self.w = self.w - v4.w
end

---@param a Vector4
---@param t number
function Vector4:lerp(a, t)
    return self + (a - self) * t
end

function Vector4:mul(n)
    assert(type(n) == "number")
    self.x = self.x * n
    self.y = self.y * n
    self.z = self.z * n
    self.w = self.w * n
end

function Vector4:lenSqr()
    return self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w
end

function Vector4:len()
    return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w)
end

function Vector4:unpack()
    return self.x, self.y, self.z, self.w
end

function Vector4:copy()
    return new(self.x, self.y, self.z, self.w)
end

function Vector4:isZero()
    return self.x == 0 and self.y == 0 and self.z == 0 and self.w == 0
end

---@param v4 Vector4
function Vector4:inArea(v4, offset)
    return v4.x >= self.x - offset and v4.x <= self.x + offset
            and v4.y >= self.y - offset and v4.y <= self.y + offset
            and v4.z >= self.z - offset and v4.z <= self.z + offset
            and v4.w >= self.w - offset and v4.w <= self.w + offset
end

---@param v4 Vector4
function Vector4:inCircleArea(v4, offset)
    return (self - v4):len() <= offset
end

function Vector4:normalize()
    local len = self:len()
    if len > 0 then
        self:mul(1 / len)
    end
end

function Vector4:floorPos()
    return new(math.floor(self.x), math.floor(self.y), math.floor(self.z), math.floor(self.w))
end

function Vector4:distance(vb)
    return math.sqrt((self.x - vb.x) ^ 2 + (self.y - vb.y) ^ 2 + (self.z - vb.z) ^ 2 + (self.w - vb.w) ^ 2)
end

return Vector4