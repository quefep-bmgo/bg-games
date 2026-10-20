--[[]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 1050
                          local checkFileName = "WalletUtils.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[sOXw]]---
--- Created by Jimmy.
--- DateTime: 2017/12/12 0012 17:01
---

WalletUtils = {}

function WalletUtils:addCoinMappings(coinMapping)
    for _, mapping in pairs(coinMapping) do
        HostApi.addCoinMapping(mapping.coinId, mapping.itemId)
    end
end

return WalletUtils
--[[bD56yLHGm3hqwn6QGiH8kv5vzFaPd0]]