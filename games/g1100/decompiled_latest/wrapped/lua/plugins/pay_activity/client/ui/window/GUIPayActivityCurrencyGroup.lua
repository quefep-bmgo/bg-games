--[[N3BlVHgiFSkkMxIkHmKwX1KRPKaKkQpRsLhwiNURcjWvHNBjzantbZFdumYUb7tyDsAJeoTnYra3q5s1DkxU1mvLPfXeoZ91ySppZoylQCWgo0zJFY78BD8KjVR85XZKoFg0INeTPwSUNGRmFYHJ7ZKSGT7Nn6y1cPRfpFdZ4lfdMnIqTLXtuNjTHoqpucP5mz7wYR9Dc1OSYuwbl61fRsuJwmTH2IJi2SFX7j7JWGByS9Ek7ptCvShfo9f56O38T1tWd6YWbOqK3Bj0GFZ4eEII1CAMh1]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 2778
                          local checkFileName = "GUIPayActivityCurrencyGroup.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[noOYYwppQ7vppVuriF3xoT2v4hZPZt2hngJlWtG7xbJ790dohC1gDl9O2uEiUDwr3cdfzPTW9043AVZR8bg2Pu]]---@class GUIPayActivityCurrencyGroupWindow : IGUIWindow
local GUIPayActivityCurrencyGroupWindow = class("GUIPayActivityCurrencyGroupWindow", IGUIWindow)

---@private
function GUIPayActivityCurrencyGroupWindow:ctor(...)
    self.super.ctor(self, "PayActivityCurrencyGroup.json", ...)
end

---@private
function GUIPayActivityCurrencyGroupWindow:onLoad()
    self:initView()
    self:initEvent()
end

---@private
function GUIPayActivityCurrencyGroupWindow:initView()
    ---@type GUICurrencyWindow[]
    self.wCurrencyList = {}
end

---@private
function GUIPayActivityCurrencyGroupWindow:initEvent()

end

---@param currencies number[] | table<number, number[]>
function GUIPayActivityCurrencyGroupWindow:onDataChanged(currencies, itemWidth, rightSpace)
    if TableUtil.isSameTable(self.currencies, currencies) then
        return
    end
    itemWidth = itemWidth or 205
    rightSpace = rightSpace or 22
    self.root:CleanupChildren()
    self.wCurrencyList = {}
    self.currencies = currencies
    local size = #currencies
    for index, currency in pairs(currencies) do
        ---@type GUIPayActivityCurrencyWindow
        local wCurrency = UIHelper.newGameGUIWindow("GUIPayActivityCurrency")
        wCurrency:setXPosition({ 0, -(size - index) * itemWidth - rightSpace })
        wCurrency:onDataChanged(currency)
        self.root:AddChildWindow(wCurrency.root)
        table.insert(self.wCurrencyList, wCurrency)
    end
end

function GUIPayActivityCurrencyGroupWindow:onTick()
    for _, wCurrency in pairs(self.wCurrencyList) do
        wCurrency:onTick()
    end
end

return GUIPayActivityCurrencyGroupWindow
--[[GemE9f1jk4SNstzu3xutoSaImT0]]