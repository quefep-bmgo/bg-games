--[[wUUxWz0oHo]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 1254
                          local checkFileName = "MerchantUtil.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[RtaIpZhegbh42GtU7tWkkfxpgqPXVsiYenCSa6ygOh7xuj9CDh3ZKtj3LNFGi1EgoObWNS3mlnaLJGpDnqglrk0oHZoRQ3ZbN4K2IryVQV0tnpVSG1bO30VUA]]---
--- Created by Jimmy.
--- DateTime: 2017/12/25 0025 11:43
---
MerchantUtil = {}

function MerchantUtil:addCommodity(index, type, goods)
    HostApi.addCommodity(index, type, goods)
end

function MerchantUtil:changeCommodityList(entityId, rakssId, index)
    HostApi.changeCommodityList(entityId, rakssId, index)
end

return MerchantUtil--[[9i8Ro1m9jEUaYXmMs4Gy3ec9A9BqaKwpYi3ZKezX]]