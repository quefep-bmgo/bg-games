--[[CYPZje2CwJqQQbpXGcE18l2bMlUWNzTOOJZ71RfmfD2c1bHCXaoKZsVQ7MVET6LHGftJ0zLzDJvu6D]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 9194
                          local checkFileName = "VectorUtil.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[6IFR0tO6ccSbzLnzt77TqESCV3q5nyHW3TP3XRA7wiO7US97aPCQ1zoIHxSQYDs2QYoQNvzyllHxcrTgBkiGV]]---
--- Created by Jimmy.
--- DateTime: 2017/10/19 0019 10:38
---
local function float2int(value)
    if value == nil or value ~= value then
        --- nan ~= nan
        return 0
    end
    if value > 0 then
        return math.floor(value)
    end
    local newValue = math.floor(value)
    if newValue == value then
        return value
    end
    return math.floor(newValue) + 1
end

---@class Vector3i
---@field x
---@field y
---@field z

---@class Vector3Yaw
---@field x
---@field y
---@field z
---@field yaw

VectorUtil = {}

---@return Vector2
function VectorUtil.newVector2(x, y)
    local vec2 = {}
    vec2.x = tonumber(x)
    vec2.y = tonumber(y)
    return vec2
end

---@return Vector2
function VectorUtil.str2Vector2(str, reps)
    reps = reps or ","
    local vec2 = StringUtil.split(str, reps)
    return VectorUtil.newVector2(vec2[1], vec2[2])
end

---@return Vector3i
function VectorUtil.newVector3i(x, y, z)
    local vec = {}
    vec.x = float2int(tonumber(x))
    vec.y = float2int(tonumber(y))
    vec.z = float2int(tonumber(z))
    return vec
end

---@return Vector3i
function VectorUtil.str2Vector3i(str, reps)
    reps = reps or ","
    local vec3 = StringUtil.split(str, reps)
    return VectorUtil.newVector3i(vec3[1], vec3[2], vec3[3])
end

---@return Vector3
function VectorUtil.newVector3(x, y, z)
    local vec3 = {
        x = tonumber(x) or 0,
        y = tonumber(y) or 0,
        z = tonumber(z) or 0,
    }
    return vec3
end

---@return Vector3
function VectorUtil.str2Vector3(str, reps)
    reps = reps or ","
    local vec3 = StringUtil.split(str, reps)
    return VectorUtil.newVector3(vec3[1], vec3[2], vec3[3])
end

---@return Vector4
function VectorUtil.newVector4(x, y, z, w)
    local vec4 = {
        x = tonumber(x) or 0,
        y = tonumber(y) or 0,
        z = tonumber(z) or 0,
        w = tonumber(w) or 0,
    }
    return vec4
end

---@return Vector4
function VectorUtil.str2Vector4(str, reps)
    reps = reps or ","
    local vec4 = StringUtil.split(str, reps)
    return VectorUtil.newVector4(vec4[1], vec4[2], vec4[3], vec4[4])
end

---@return Vector3
function VectorUtil.vector4ToVector3(vec4)
    local vec3 = {}
    vec3.x = vec4.x
    vec3.y = vec4.y
    vec3.z = vec4.z
    return vec3
end

---@return Vector3
function VectorUtil.toVector3(vec3i)
    local vec3 = {}
    vec3.x = vec3i.x
    vec3.y = vec3i.y
    vec3.z = vec3i.z
    return vec3
end

---@return Vector3i
function VectorUtil.toVector3i(vec3)
    local vec3i = {}
    vec3i.x = float2int(vec3.x)
    vec3i.y = float2int(vec3.y)
    vec3i.z = float2int(vec3.z)
    return vec3i
end

---@param vec3 Vector3
function VectorUtil.hashVector3(vec3, reps)
    reps = reps or ":"
    return vec3.x .. reps .. vec3.y .. reps .. vec3.z
end

---@param vec4 Vector4
function VectorUtil.hashVector4(vec4, reps)
    reps = reps or ":"
    return vec4.x .. reps .. vec4.y .. reps .. vec4.z .. reps .. vec4.w
end

---@return Vector3i
function VectorUtil.decodeVec3i(code)
    local x = code >> 32
    code = code - (x << 32)
    local y = code >> 16
    local z = code - (y << 16)
    return VectorUtil.newVector3i(x, y, z)
end

---@return Vector3i
function VectorUtil.encodeVec3i(vec3i)
    return (math.floor(vec3i.x) << 32) + (math.floor(vec3i.y) << 16) + vec3i.z
end

function VectorUtil.toBlockVector3(x, y, z)
    if x < 0 then
        x = x - 1
    end
    if y < 0 then
        y = y - 1
    end
    if z < 0 then
        z = z - 1
    end
    return VectorUtil.newVector3i(x, y, z)
end

function VectorUtil.equal(vec3_1, vec3_2)
    if vec3_1 and vec3_2 then
        return vec3_1.x == vec3_2.x and vec3_1.y == vec3_2.y and vec3_1.z == vec3_2.z
    else
        return false
    end
end

function VectorUtil.add3(vec3_1, vec3_2)
    return VectorUtil.newVector3(vec3_1.x + vec3_2.x, vec3_1.y + vec3_2.y, vec3_1.z + vec3_2.z)
end

function VectorUtil.add3i(vec3_1, vec3_2)
    return VectorUtil.newVector3i(vec3_1.x + vec3_2.x, vec3_1.y + vec3_2.y, vec3_1.z + vec3_2.z)
end

function VectorUtil.sub3(vec3_1, vec3_2)
    return VectorUtil.newVector3(vec3_1.x - vec3_2.x, vec3_1.y - vec3_2.y, vec3_1.z - vec3_2.z)
end

function VectorUtil.sub3i(vec3_1, vec3_2)
    return VectorUtil.newVector3i(vec3_1.x - vec3_2.x, vec3_1.y - vec3_2.y, vec3_1.z - vec3_2.z)
end

function VectorUtil.midpoint3(vec3_1, vec3_2)
    return VectorUtil.newVector3((vec3_1.x + vec3_2.x) / 2, (vec3_1.y + vec3_2.y) / 2, (vec3_1.z + vec3_2.z) / 2)
end

function VectorUtil.midpoint3i(vec3_1, vec3_2)
    return VectorUtil.newVector3i((vec3_1.x + vec3_2.x) / 2, (vec3_1.y + vec3_2.y) / 2, (vec3_1.z + vec3_2.z) / 2)
end

function VectorUtil.getPosX(vec3i, size)
    size = size or 1
    return VectorUtil.newVector3i(vec3i.x + size, vec3i.y, vec3i.z)
end

function VectorUtil.getNegX(vec3i, size)
    size = size or 1
    return VectorUtil.newVector3i(vec3i.x - size, vec3i.y, vec3i.z)
end

function VectorUtil.getPosY(vec3i, size)
    size = size or 1
    return VectorUtil.newVector3i(vec3i.x, vec3i.y + size, vec3i.z)
end

function VectorUtil.getNegY(vec3i, size)
    size = size or 1
    return VectorUtil.newVector3i(vec3i.x, vec3i.y - size, vec3i.z)
end

function VectorUtil.getPosZ(vec3i, size)
    size = size or 1
    return VectorUtil.newVector3i(vec3i.x, vec3i.y, vec3i.z + size)
end

function VectorUtil.getNegZ(vec3i, size)
    size = size or 1
    return VectorUtil.newVector3i(vec3i.x, vec3i.y, vec3i.z - size)
end

function VectorUtil.distance(pos1, pos2)
    local x = pos1.x - pos2.x
    local y = pos1.y - pos2.y
    local z = pos1.z - pos2.z
    return math.sqrt(x * x + y * y + z * z)
end

function VectorUtil.distanceByXYZ(x1, y1, z1, x2, y2, z2)
    local x = x1 - x2
    local y = y1 - y2
    local z = z1 - z2
    return math.sqrt(x * x + y * y + z * z)
end

function VectorUtil.distanceXZ(pos1, pos2)
    local x = pos1.x - pos2.x
    local z = pos1.z - pos2.z
    return math.sqrt(x * x + z * z)
end

---@param vec3 Vector3
function VectorUtil.normalize(vec3)
    local len = math.sqrt(vec3.x * vec3.x + vec3.y * vec3.y + vec3.z * vec3.z)
    vec3.x = vec3.x / len
    vec3.y = vec3.y / len
    vec3.z = vec3.z / len
end

---@param pos1 Vector3
---@param pos2 Vector3
function VectorUtil.dot(pos1, pos2)
    return pos1.x * pos2.x + pos1.y * pos2.y + pos1.z * pos2.z
end

---@param pos1 Vector3
---@param pos2 Vector3
---@return Vector3
function VectorUtil.cross(pos1, pos2)
    local vec = {
        x = pos1.y * pos2.z - pos1.z * pos2.y,
        y = pos1.z * pos2.x - pos1.x * pos2.z,
        z = pos1.x * pos2.y - pos1.y * pos2.x,
    }
    return vec
end

---@param pos1 Vector3
---@param pos2 Vector3
function VectorUtil.minVector3(pos1, pos2)
    return VectorUtil.newVector3(math.min(pos1.x, pos2.x), math.min(pos1.y, pos2.y), math.min(pos1.z, pos2.z))
end

---@param pos1 Vector3
---@param pos2 Vector3
function VectorUtil.maxVector3(pos1, pos2)
    return VectorUtil.newVector3(math.max(pos1.x, pos2.x), math.max(pos1.y, pos2.y), math.max(pos1.z, pos2.z))
end

---坐标保留小数点后几（digits）位
---@param pos Vector3
function VectorUtil.keepDecimalsPos(pos, digits)
    digits = math.max(digits or 2, 0)
    local size = math.pow(10, digits)
    return VectorUtil.newVector3(math.floor(pos.x * size) / size, math.floor(pos.y * size) / size, math.floor(pos.z * size) / size)
end

function VectorUtil.getDirection(startPos, endPos)
    local vector = math.atan2(endPos.x - startPos.x, endPos.z - startPos.z)
    return vector / math.pi * -180
end

function VectorUtil.getPointPitch(startPos, endPos)
    local direction = VectorUtil.sub3(endPos, startPos)
    return math.atan2(-direction.y, math.sqrt(direction.x * direction.x + direction.z * direction.z)) * MathUtil.RAD2DEG
end

VectorUtil.ZERO = VectorUtil.newVector3(0, 0, 0)
VectorUtil.ONE = VectorUtil.newVector3(1, 1, 1)
VectorUtil.UNIT_X = VectorUtil.newVector3(1, 0, 0)
VectorUtil.UNIT_Y = VectorUtil.newVector3(0, 1, 0)
VectorUtil.UNIT_Z = VectorUtil.newVector3(0, 0, 1)
VectorUtil.NEG_UNIT_X = VectorUtil.newVector3(-1, 0, 0)
VectorUtil.NEG_UNIT_Y = VectorUtil.newVector3(0, -1, 0)
VectorUtil.NEG_UNIT_Z = VectorUtil.newVector3(0, 0, -1)
VectorUtil.INVALID = VectorUtil.newVector3(3.402823466e+38, 3.402823466e+38, 3.402823466e+38)

return VectorUtil--[[1jMxgxHtsBiNXS8B3Me9FFv2cIl2pjDmHdbHP]]