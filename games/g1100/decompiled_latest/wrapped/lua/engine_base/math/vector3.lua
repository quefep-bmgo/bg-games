--[[SbfLUWWBZ4XZBLNBS28mxZ3UdWb6q9igNm4ZWkZbyi53ghpqQrTA1I3A0tQJFzOEJT1JFaBjy3d4U]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 5872
                          local checkFileName = "vector3.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[THopcBi5FuGGs4lSuQMGam4vVE2mTq]]---@class Vector3 : cls
local Vector3 = class('Vector3')
Vector3.tostring_overload = true

local new = Vector3.new

function Vector3:ctor(x, y, z)
    self.x = x or 0
    self.y = y or 0
    self.z = z or 0
end

---@return Vector3
function Vector3:__add(v3)
    return new(self.x + v3.x, self.y + v3.y, self.z + v3.z)
end

---@return Vector3
function Vector3:__sub(v3)
    return new(self.x - v3.x, self.y - v3.y, self.z - v3.z)
end

---@return Vector3
function Vector3.__mul(lhs, rhs)
    if type(lhs) == 'number' then
        return new(lhs * rhs.x, lhs * rhs.y, lhs * rhs.z)
    else
        assert(type(rhs) == 'number')
        return new(lhs.x * rhs, lhs.y * rhs, lhs.z * rhs)
    end
end

---@return Vector3
function Vector3:__div(n)
    assert(type(n) == "number")
    return new(self.x / n, self.y / n, self.z / n)
end

---@return Vector3
function Vector3:__unm()
    return new(-self.x, -self.y, -self.z)
end

---@return Vector3
function Vector3:__eq(v3)
    return self.x == v3.x and self.y == v3.y and self.z == v3.z
end

---@return Vector3
function Vector3:__lt(v3)
    return self.x < v3.x and self.y < v3.y and self.z < v3.z
end

---@return Vector3
function Vector3:__le(v3)
    return self.x <= v3.x and self.y <= v3.y and self.z <= v3.z
end

---@return Vector3
function Vector3:__tostring()
    return string.format("Vector3: {%s,%s,%s}", self.x, self.y, self.z)
end

---@param v3 Vector3
function Vector3:add(v3)
    self.x = self.x + v3.x
    self.y = self.y + v3.y
    self.z = self.z + v3.z
end

---@param v3 Vector3
function Vector3:sub(v3)
    self.x = self.x - v3.x
    self.y = self.y - v3.y
    self.z = self.z - v3.z
end

---@param a Vector3
---@param t number
function Vector3:lerp(a, t)
    return self + (a - self) * t
end

function Vector3:mul(n)
    assert(type(n) == "number")
    self.x = self.x * n
    self.y = self.y * n
    self.z = self.z * n
end

function Vector3:lenSqr()
    return self.x * self.x + self.y * self.y + self.z * self.z
end

function Vector3:len()
    return math.sqrt(self:lenSqr())
end

function Vector3:unpack()
    return self.x, self.y, self.z
end

---@return Vector3
function Vector3:copy()
    return new(self.x, self.y, self.z)
end

---@return Vector3
function Vector3:clone()
    return self:copy()
end

function Vector3:isZero()
    return self.x == 0 and self.y == 0 and self.z == 0
end

---@param v3 Vector3
function Vector3:inArea(v3, offset)
    return v3.x >= self.x - offset and v3.x <= self.x + offset
            and v3.y >= self.y - offset and v3.y <= self.y + offset
            and v3.z >= self.z - offset and v3.z <= self.z + offset
end

---@param v3 Vector3
function Vector3:inCircleArea(v3, offset)
    return (self - v3):len() <= offset
end

function Vector3:normalize()
    local len = self:len()
    if len > 0 then
        self:mul(1 / len)
    end
    return self
end

---@return Vector3
function Vector3:floorPos()
    return new(math.floor(self.x), math.floor(self.y), math.floor(self.z))
end

---@param vb Vector3
function Vector3:distance(vb)
    return math.sqrt((self.x - vb.x) ^ 2 + (self.y - vb.y) ^ 2 + (self.z - vb.z) ^ 2)
end

---@param rhs Vector3
function Vector3:dot(rhs)
    return self.x * rhs.x + self.y * rhs.y + self.z * rhs.z
end

---@param tv Vector3 | nil
function Vector3:rotation(tv)
    if tv then
        local dir = tv - self
        return math.atan(dir.z, dir.x) * math.rad2deg
    else
        return math.atan(self.z, self.x) * math.rad2deg
    end
end

---@param tv Vector3 | nil
function Vector3:rotationY(tv)
    if tv then
        local dir = tv - self
        return math.atan(-dir.y, math.sqrt(dir.x * dir.x + dir.z * dir.z)) * math.rad2deg
    else
        return math.atan(-self.y, math.sqrt(self.x * self.x + self.z * self.z)) * math.rad2deg
    end
end

---@return Vector3
function Vector3:cross(rhs)
    return new(
            self.y * rhs.z - self.z * rhs.y,
            self.z * rhs.x - self.x * rhs.z,
            self.x * rhs.y - self.y * rhs.x
    )
end

function Vector3:perpendicular()
    local temp = Vector3.new(1, 0, 0)
    local result = self:cross(temp)
    if result:isZero() then
        temp.x = 0
        temp.y = 1
        result = self:cross(temp)
    end
    result:normalize()
    return result
end

---@return Vector3
function Vector3.fromTable(v3)
    return new(v3.x, v3.y, v3.z)
end

function Vector3.angle(v1, v2)
    local s = math.sqrt(Vector3.lenSqr(v1) * Vector3.lenSqr(v2))
    return math.acos(Vector3.dot(v1, v2) / s)
end

function Vector3.distance(va, vb)
    return math.sqrt((va.x - vb.x) ^ 2 + (va.y - vb.y) ^ 2 + (va.z - vb.z) ^ 2)
end

function Vector3.dot(lhs, rhs)
    return (((lhs.x * rhs.x) + (lhs.y * rhs.y)) + (lhs.z * rhs.z))
end

function Vector3.cross(lhs, rhs)
    local x = lhs.y * rhs.z - lhs.z * rhs.y
    local y = lhs.z * rhs.x - lhs.x * rhs.z
    local z = lhs.x * rhs.y - lhs.y * rhs.x
    return Vector3.new(x, y, z)
end

return Vector3--[[mhCVHGPH8XPR6YJNgrjtwFl6qmRH4UWDg3iKllBnr041EDZgIF9Xgqkv74lal9OvmgBDn81ufA5diDMrQNRfZft5jly60MPqggLOhWCYS]]