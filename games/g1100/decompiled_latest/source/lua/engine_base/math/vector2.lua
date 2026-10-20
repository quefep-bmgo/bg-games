---@class Vector2 : cls
local Vector2 = class('Vector2')
Vector2.tostring_overload = true

local new = Vector2.new

function Vector2:ctor(x, y)
    self.x = x or 0
    self.y = y or 0
end

function Vector2:__add(v2)
    return new(self.x + v2.x, self.y + v2.y)
end

function Vector2:__sub(v2)
    return new(self.x - v2.x, self.y - v2.y)
end

function Vector2.__mul(lhs, rhs)
    if type(lhs) == 'number' then
        return new(lhs * rhs.x, lhs * rhs.y)
    else
        assert(type(rhs) == 'number')
        return new(lhs.x * rhs, lhs.y * rhs)
    end
end

function Vector2:__div(n)
    assert(type(n) == "number")
    return new(self.x / n, self.y / n)
end

function Vector2:__unm()
    return new(-self.x, -self.y)
end

function Vector2:__eq(v2)
    return self.x == v2.x and self.y == v2.y
end

function Vector2:__lt(v2)
    return self.x < v2.x and self.y < v2.y
end

function Vector2:__le(v2)
    return self.x <= v2.x and self.y <= v2.y
end

function Vector2:__tostring()
    return string.format("Vector2: {%s,%s}", self.x, self.y)
end

---@param v2 Vector2
function Vector2:add(v2)
    self.x = self.x + v2.x
    self.y = self.y + v2.y
end

---@param v2 Vector2
function Vector2:sub(v2)
    self.x = self.x - v2.x
    self.y = self.y - v2.y
end

---@param a Vector2
---@param t number
function Vector2:lerp(a, t)
    return self + (a - self) * t
end

function Vector2:mul(n)
    assert(type(n) == "number")
    self.x = self.x * n
    self.y = self.y * n
end

function Vector2:lenSqr()
    return self.x * self.x + self.y * self.y
end

function Vector2:len()
    return math.sqrt(self.x * self.x + self.y * self.y)
end

function Vector2:unpack()
    return self.x, self.y
end

---@return Vector2
function Vector2:copy()
    return new(self.x, self.y)
end

---@return Vector2
function Vector2:clone()
    return self:copy()
end

function Vector2:isZero()
    return self.x == 0 and self.y == 0
end

---@param v2 Vector2
function Vector2:inArea(v2, offset)
    return v2.x >= self.x - offset and v2.x <= self.x + offset
            and v2.y >= self.y - offset and v2.y <= self.y + offset
end

---@param v2 Vector2
function Vector2:inCircleArea(v2, offset)
    return (self - v2):len() <= offset
end

function Vector2:normalize()
    local len = self:len()
    if len > 0 then
        self:mul(1 / len)
    end
    return self
end

---@return Vector2
function Vector2:floorPos()
    return new(math.floor(self.x), math.floor(self.y))
end

---@param vb Vector2
function Vector2:distance(vb)
    return math.sqrt((self.x - vb.x) ^ 2 + (self.y - vb.y) ^ 2)
end

---@param rhs Vector2
function Vector2:dot(rhs)
    return self.x * rhs.x + self.y * rhs.y
end

---@param tv Vector2 | nil
function Vector2:rotation(tv)
    if tv then
        local dir = tv - self
        return math.atan(dir.y, dir.x) * math.rad2deg
    else
        return math.atan(self.y, self.x) * math.rad2deg
    end
end

---@return Vector2
function Vector2:translate(dir, distance)
    local f1 = -math.sin(dir * math.pi / 180)
    local f2 = math.cos(dir * math.pi / 180)
    local dx = f1 * distance
    local dy = f2 * distance
    return new(self.x + dx, self.y + dy)
end

function Vector2:rotate(center, angle)
    local relative = self - center
    local radians = angle * math.deg2rad
    local c = math.cos(radians)
    local s = math.sin(radians)
    local m00, m01, m10, m11 = c, -s, s, c
    local offset = new(relative.x * m00 + relative.y * m10, relative.x * m01 + relative.y * m11)
    return offset + center
end

---@return Vector2
function Vector2.fromTable(v2)
    return new(v2.x, v2.y)
end

return Vector2