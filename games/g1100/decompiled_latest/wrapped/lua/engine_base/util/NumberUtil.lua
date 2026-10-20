--[[O3bJSklb9s0DwCoKThfEsvZnhW7EYMWunwmavOftqFNguVOQhpGqBpkApwYVp24W0PQEUdxgim1r7Lp]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 1281
                          local checkFileName = "NumberUtil.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[kN8]]---
--- Created by Jimmy.
--- DateTime: 2018/3/8 0008 10:42
---
NumberUtil = {}

function NumberUtil.getIntPart(num)
    if num <= 0 then
        return math.ceil(num);
    end
    if math.ceil(num) == num then
        num = math.ceil(num);
    else
        num = math.ceil(num) - 1;
    end
    return num;
end

function NumberUtil.int64ToNumber(num)
    return tonumber(tostring(num))
end

return NumberUtil--[[PiFXnV2PXoNKfarMSfBoqqu4TQgkag5eoPK49sN3kRHe6aawh]]---