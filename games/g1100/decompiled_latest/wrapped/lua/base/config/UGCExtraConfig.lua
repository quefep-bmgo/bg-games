--[[G4poHfHKKpE1v897ez2Q2Use9ghRnnquWrJG]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 7879
                          local checkFileName = "UGCExtraConfig.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[vnmSmVEAKlRXHM2UJ2OQG0ViJLTKWY3C79jQGUmlsRzQQ98GloWNg8pKYSuApEF75ZP0of6jKkNuDL885JsltI10CNVdhP5XjndHU7yj0b12L41MiUQLYtMFgPKXjNUU5aQ9qLrmPE5zd8JLnv5F8oG0gz2wcag9KvHQiUkkTFE2q4OqATqgP0hO8mpVpgGsqWhin97QntlveUlrL9nR4LJDWn8nvDoJDrsIjbdwF8XzAMoICV7LhklkQfl]]---@class UGCExtraConfig
local UGCExtraConfig = class("UGCExtraConfig")
local CustomRoomUtil = require "base.util.CustomRoomUtil"
local SafeCallUtil = require "base.util.SafeCallUtil"

---@param initPos Vector3i|nil
---@param extraJsonStr string|nil
function UGCExtraConfig:ctor(initPos, extraJsonStr)
    self.initBlockPos = CustomRoomUtil.toBoxOrigin(initPos or VectorUtil.ZERO)

    self.fileName = "building_" .. tostring(os.time()) .. ".csv"

    self.buildSize = VectorUtil.newVector3i(0, 0, 0)
    self.isEditable = true
    self.primaryTag = ""
    self.secondaryTag = ""
    self.maxBlockCount = 0
    self.disabledBlocks = {}

    self.blockNum = 0
    self.blockMap = {}
    self.firstEditUserId = nil
    self.hasEditArea = false
    self.areaMin = nil
    self.areaMax = nil

    if extraJsonStr == nil or type(extraJsonStr) ~= "string" then
        return
    end

    local trimStr = string.gsub(extraJsonStr, "^%s*(.-)%s*$", "%1")
    if trimStr == "" then
        return
    end

    local ok, extraTable = pcall(json.decode, trimStr)
    if not ok or type(extraTable) ~= "table" then
        return
    end

    -- extraJsonStr 只解析白名单字段，忽略 creativeId 等无关字段
    self.buildSize = VectorUtil.newVector3i(
        extraTable.buildingSizeX,
        extraTable.buildingSizeY,
        extraTable.buildingSizeZ
    )
    self.isEditable = extraTable.isEditable
    self.primaryTag = extraTable.primaryTag
    self.secondaryTag = extraTable.secondaryTag
    self.maxBlockCount = extraTable.maxBlockCount or 0

    extraTable.disabledBlocks = extraTable.disabledBlocks or {}
    for _, v in pairs(extraTable.disabledBlocks) do
        table.insert(self.disabledBlocks, v)
    end
end

function UGCExtraConfig:loadTableConfig(config)
    if config then
        self.initBlockPos = VectorUtil.toVector3i(config.initBlockPos)
        self.buildSize = VectorUtil.toVector3i(config.buildSize)
        self.isEditable = config.isEditable
        self.primaryTag = config.primaryTag
        self.secondaryTag = config.secondaryTag
        self.maxBlockCount = config.maxBlockCount
        self.disabledBlocks = config.disabledBlocks
        self.hasEditArea = config.hasEditArea
        self.blockNum = config.blockNum

        if self.primaryTag and self.primaryTag ~= "" and self.secondaryTag and self.secondaryTag ~= "" then
            self.isOldSo = not SafeCallUtil.hasMethod(DynamicCastHelper, "dynamicCastGuiPlayerInventoryControl")
            if self.isOldSo then
                self.isEditable = false
            end
        end
    end
end

function UGCExtraConfig:loadPrefabConfig(prefabConfig)
    if prefabConfig then
        self.fileName = prefabConfig.fileName
        prefabConfig.blocks = prefabConfig.blocks or {}
        self.blockNum = #prefabConfig.blocks
        for _, block in pairs(prefabConfig.blocks) do
            self.blockMap[self:getBlockKey(VectorUtil.add3i(self.initBlockPos, block.blockPos))] = {
                blockPos = VectorUtil.toVector3i(block.blockPos),
                blockId = block.blockId,
                meta = block.meta
            }
        end
        self.firstEditUserId = prefabConfig.firstEditUserId
        if prefabConfig.buildSize then
            self.buildSize = VectorUtil.toVector3i(prefabConfig.buildSize)
        end
    end
end

function UGCExtraConfig:updateEditArea()
    self.hasEditArea = self.buildSize.x > 0 and self.buildSize.y > 0 and self.buildSize.z > 0
    if self.hasEditArea then
        self.areaMin, self.areaMax = CustomRoomUtil.toBoxMinMax(self.initBlockPos, self.buildSize)
    end
end

function UGCExtraConfig:createPrefab()
    if self.secondaryTag == "building_prefab" then
        self:createPrefabFoundation()
    end
    if self.blockNum > 0 then
        self:createBlocks()
    end
end

function UGCExtraConfig:getTableConfig()
    return {
        initBlockPos = self.initBlockPos,
        buildSize = self.buildSize,
        isEditable = self.isEditable,
        primaryTag = self.primaryTag,
        secondaryTag = self.secondaryTag,
        maxBlockCount = self.maxBlockCount,
        disabledBlocks = self.disabledBlocks,
        hasEditArea = self.hasEditArea,
        blockNum = self.blockNum
    }
end

function UGCExtraConfig:checkOutsideTheEditingArea(pos)
    if self.hasEditArea then
        return pos.x < self.areaMin.x or
            pos.x > self.areaMax.x - 1 or
            pos.y < self.areaMin.y or
            pos.y > self.areaMax.y - 1 or
            pos.z < self.areaMin.z or
            pos.z > self.areaMax.z - 1
    end
    return false
end
function UGCExtraConfig:checkEditingAreaOverflowMaxCount()
    if self.hasEditArea then
        if self.maxBlockCount == 0 then
            return false
        end
        return self.blockNum + 1 > self.maxBlockCount
    end
    return false
end
function UGCExtraConfig:editingAreaBlockBreak(pos)
    if self.hasEditArea or self.maxBlockCount > 0 then
        local key = self:getBlockKey(pos)
        if self.blockMap[key] then
            self.blockNum = self.blockNum - 1
            self.blockMap[key] = nil
            return true
        end
    end
    return false
end
function UGCExtraConfig:editingAreaBlockPlace(pos, itemId, meta)
    if self.hasEditArea or self.maxBlockCount > 0 then
        local key = self:getBlockKey(pos)
        if not self.blockMap[key] then
            self.blockNum = self.blockNum + 1
        end
        self.blockMap[key] = {blockPos = VectorUtil.sub3i(pos, self.initBlockPos), blockId = itemId, meta = meta}
        return true
    end
    return false
end

function UGCExtraConfig:needSaveBlockCsv()
    return self.hasEditArea or self.maxBlockCount > 0
end

function UGCExtraConfig:getBlockMap()
    return self.blockMap or {}
end

function UGCExtraConfig:getBlockKey(blockPos)
    return string.format("%d_%d_%d", blockPos.x, blockPos.y, blockPos.z)
end
function UGCExtraConfig:createPrefabFoundation()
    local min_pos, max_pos = CustomRoomUtil.toBoxMinMax(self.initBlockPos, self.buildSize)

    local max_x = max_pos.x + 10
    local min_x = min_pos.x - 10

    local max_z = max_pos.z + 10
    local min_z = min_pos.z - 10

    local max_y = min_pos.y - 1
    local min_y = max_y - 1

    for x = min_x, max_x do
        for z = min_z, max_z do
            for y = min_y, max_y do
                local pos = VectorUtil.newVector3i(x, y, z)
                if EngineWorld:getBlockId(pos) == BlockID.AIR then
                    EngineWorld:setBlock(pos, BlockID.GRASS, 0)
                end
            end
        end
    end
end
function UGCExtraConfig:createBlocks()
    for _, block in pairs(self.blockMap) do
        local pos = VectorUtil.add3i(self.initBlockPos, block.blockPos)
        EngineWorld:setBlock(pos, block.blockId, block.meta)
    end
end

return UGCExtraConfig
--[[8fhVTJ5vsknueRa]]---