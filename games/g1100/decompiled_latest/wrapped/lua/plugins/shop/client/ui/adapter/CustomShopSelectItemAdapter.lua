--[[]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 1529
                          local checkFileName = "CustomShopSelectItemAdapter.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[Yse0UwcSWwMYGiHOKdTMN90I3aZNOWZKSb9wuj21QGkc1Qo]]---@class CustomShopSelectItemAdapter : IDataAdapter
local CustomShopSelectItemAdapter = class("CustomShopSelectItemAdapter", IDataAdapter)

function CustomShopSelectItemAdapter:setItemSize(width, height)
    self.width = width
    self.height = height
end

function CustomShopSelectItemAdapter:getWindowClass()
    return UIHelper.requireGUIWindow("GUICustomShopSelectItem")
end

function CustomShopSelectItemAdapter:getJsonName()
    return "CustomShopSelectItem.json"
end

function CustomShopSelectItemAdapter:getItemWidth()
    return { 0, self.width }
end

function CustomShopSelectItemAdapter:getItemHeight()
    return { 0, self.height }
end

return CustomShopSelectItemAdapter--[[9i8Ro1m9jEUaYXmMs4Gy3ec9A9BqaKwpYi3ZKezX]]---