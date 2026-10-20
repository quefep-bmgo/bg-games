--[[aZ4Ii7xWTi1IeBWp3oRFR6WHsCU1nnjDjGTCDM3DsYlMyoNHUSxsXgj8YQ7ma1hTLPof3qnw8nwwXo9VvYNtYXdA90byiiLAZi84jI25z465OwCPzjdUksCoboHtXM9dxDPhX32aH4CSeoNBijfBrMBeqXrk9AUZ5KP1NipetGAvpUSW8xTJQcSxJnqTHTATJY8e1ePNnWDkB5AQ2yBEI1U8xc2V2op3sBr0kH0A6rwDOY5cKVz6k4lybjEB3jvoTuBOilcsQKsNKjDHHWtG1yI9OC7VwRoQ6no4W2CQBtuTIbUWp5dGa]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 2762
                          local checkFileName = "CustomRoomUtil.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[rIOCCU]]CustomRoomUtil = {}

function CustomRoomUtil.toBoxOrigin(initPos)
    return VectorUtil.toBlockVector3(initPos.x, initPos.y, initPos.z)
end

function CustomRoomUtil.toBoxMinMax(initPos, buildSize)
    local bottom_center_pos = CustomRoomUtil.toBoxOrigin(initPos)
    local min_x = math.floor(buildSize.x * 0.5)
    local min_z = math.floor(buildSize.z * 0.5)
    local min_pos = VectorUtil.newVector3i(min_x, 0, min_z)
    local max_pos = VectorUtil.newVector3i(buildSize.x - min_x, buildSize.y, buildSize.z - min_z)
    return VectorUtil.sub3(bottom_center_pos, min_pos), VectorUtil.add3(bottom_center_pos, max_pos)
end

function CustomRoomUtil.getEditAreaBlockAABB(initPos, blockMap)
    local initBlockPos = CustomRoomUtil.toBoxOrigin(initPos)

    local _, firstBlock = next(blockMap)
    if not firstBlock then
        return initBlockPos, initBlockPos
    end

    local firstWorldPos = VectorUtil.add3i(initBlockPos, firstBlock.blockPos)
    local min_x, min_y, min_z = firstWorldPos.x, firstWorldPos.y, firstWorldPos.z
    local max_x, max_y, max_z = firstWorldPos.x, firstWorldPos.y, firstWorldPos.z

    for _, block in pairs(blockMap) do
        local worldPos = VectorUtil.add3i(initBlockPos, block.blockPos)
        min_x = math.min(min_x, worldPos.x)
        min_y = math.min(min_y, worldPos.y)
        min_z = math.min(min_z, worldPos.z)
        max_x = math.max(max_x, worldPos.x)
        max_y = math.max(max_y, worldPos.y)
        max_z = math.max(max_z, worldPos.z)
    end

    local aabb_min = VectorUtil.newVector3i(min_x, min_y, min_z)
    local aabb_max = VectorUtil.newVector3i(max_x, max_y, max_z)
    return aabb_min, aabb_max
end


return CustomRoomUtil--[[5D3OnD0bJ0xFGNEVrlnPz]]