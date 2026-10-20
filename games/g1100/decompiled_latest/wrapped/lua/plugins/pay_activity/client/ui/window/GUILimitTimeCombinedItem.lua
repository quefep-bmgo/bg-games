--[[N3BlVHgiFSkkMxIkHmKwX1KRPKaKkQpRsLhwiNURcjWvHNBjzantbZFdumYUb7tyDsAJeoTnYra3q5s1DkxU1mvLPfXeoZ91ySppZoylQCWgo0zJFY78BD8KjVR85XZKoFg0INeTPwSUNGRmFYHJ7ZKSGT7Nn6y1cPRfpFdZ4lfdMnIqTLXtuNjTHoqpucP5mz7wYR9Dc1OSYuwbl61fRsuJwmTH2IJi2SFX7j7JWGByS9Ek7ptCvShfo9f56O38T1tWd6YWbOqK3Bj0GFZ4eEII1CAMh1]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 3062
                          local checkFileName = "GUILimitTimeCombinedItem.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[Io1doY4cwlMvwiGCuHGMCVl3Vdyw7PdYXXYqFNzmwDqRkE3e1P8w2gXV3NTggFPjNj4R2j7m7Iz6MhJhy]]---@class GUILimitTimeCombinedItemWindow : IGUIWindow
local GUILimitTimeCombinedItemWindow = class("GUILimitTimeCombinedItemWindow", IGUIWindow)

---@private
function GUILimitTimeCombinedItemWindow:ctor(...)
	self.super.ctor(self, "LimitTimeCombinedItem.json", ...)
end

---@private
function GUILimitTimeCombinedItemWindow:onLoad()
	self.llGoodItem = self:getChildWindowByName("LimitTimeCombinedItem-goodItem", GUIType.Layout)
	self.siGoodsBg = self:getChildWindowByName("LimitTimeCombinedItem-goodsBg", GUIType.StaticImage)
	self.siGoodsIcon = self:getChildWindowByName("LimitTimeCombinedItem-goodsIcon", GUIType.StaticImage)
	self.siNumBg = self:getChildWindowByName("LimitTimeCombinedItem-NumBg", GUIType.StaticImage)
	self.stGoodsNum = self:getChildWindowByName("LimitTimeCombinedItem-goodsNum", GUIType.StaticText)
	self.llMask = self:getChildWindowByName("LimitTimeCombinedItem-Mask", GUIType.Layout)
	self.stBought = self:getChildWindowByName("LimitTimeCombinedItem-Bought", GUIType.StaticText)
	self:initView()
	self:initEvent()

end

---@private
function GUILimitTimeCombinedItemWindow:initView()
	self.stGoodsNum:SetText(Lang:getString(""))
	self.stBought:SetText(Lang:getString("gui.limit.time.combined.purchased"))
	self.llMask:SetVisible(false)
end

---@private
function GUILimitTimeCombinedItemWindow:initEvent()
	self.llGoodItem:registerEvent(GUIEvent.Click, function()
		UIHelper.showGameGUILayout("GUIPayActivityRewardDetail", self.data.id)
	end)
end

---@param data PayActivityRewardConfigData
function GUILimitTimeCombinedItemWindow:onDataChanged(data)
	self.data = data
	self.stGoodsNum:SetText("X" .. data.count)
	self.siGoodsIcon:SetImage(data.image)
	self.llMask:SetVisible(data.isHave)
end

return GUILimitTimeCombinedItemWindow
--[[Xh13wZXgOr9WefXXFNobeHbB2G7ZLFof3UqM6W06pprf1pI4Rqj96mxU7nNas9cpvDPcJmMXAo38IJDTqZTIiojpYmYkGcCLq7Jwl7SEwdufeHlPWqqUlLPUyj4npVtnCIgX24U6kvlBsXLW1jmYFvXIbhOkNUXoTjUHAg0fl2MKTj2Ay5ik7S6ZLUt]]