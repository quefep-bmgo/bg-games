--[[O3bJSklb9s0DwCoKThfEsvZnhW7EYMWunwmavOftqFNguVOQhpGqBpkApwYVp24W0PQEUdxgim1r7Lp]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 1597
                          local checkFileName = "CustomShopGoodsAdapter.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[kN8]]---@class CustomShopGoodsAdapter : IDataAdapter
local CustomShopGoodsAdapter = class("CustomShopGoodsAdapter", IDataAdapter)

function CustomShopGoodsAdapter:setItemSize(width, height)
    self.width = width
    self.height = height
end

function CustomShopGoodsAdapter:getWindowClass()
    return UIHelper.requireGUIWindow("GUICustomShopGoods")
end

function CustomShopGoodsAdapter:getJsonName()
    return "CustomShopGoods.json"
end

function CustomShopGoodsAdapter:getItemWidth()
    return { 0, self.width }
end

function CustomShopGoodsAdapter:getItemHeight()
    return { 0, self.height }
end

return CustomShopGoodsAdapter--[[5BOdKVS8LJqVVmyEFl7Gn5Wl53R3OaupWaGm9HU4lKDdl60cqoclCv83P1RIDCFokoDZFCovCS4bUvmbALhQEEyr5BSvemQi9lCnCOU3zH59MKgPDMIbmWia5JQBG7yKwnpqO]]---