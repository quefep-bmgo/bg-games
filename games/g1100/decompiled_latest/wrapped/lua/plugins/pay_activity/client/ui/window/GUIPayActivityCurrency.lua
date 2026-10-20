--[[xYG5Mx9aAdYUzh0js8JkrntgbDAmfklqmkg9NAX7d1oHpE0cgANz]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 2795
                          local checkFileName = "GUIPayActivityCurrency.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[6IFR0tO6ccSbzLnzt77TqESCV3q5nyHW3TP3XRA7wiO7US97aPCQ1zoIHxSQYDs2QYoQNvzyllHxcrTgBkiGV]]---@class GUIPayActivityCurrencyWindow : IGUIWindow
local GUIPayActivityCurrencyWindow = class("GUIPayActivityCurrencyWindow", IGUIWindow)

---@private
function GUIPayActivityCurrencyWindow:ctor(...)
    self.super.ctor(self, "PayActivityCurrency.json", ...)
end

---@private
function GUIPayActivityCurrencyWindow:onLoad()
    self.siIcon = self:getChildWindowByName("PayActivityCurrency-Icon", GUIType.StaticImage)
    self.siAdd = self:getChildWindowByName("PayActivityCurrency-Add", GUIType.StaticImage)
    self.stText = self:getChildWindowByName("PayActivityCurrency-Text", GUIType.StaticText)
    self:initView()
    self:initEvent()
end

---@private
function GUIPayActivityCurrencyWindow:initView()

end

---@private
function GUIPayActivityCurrencyWindow:initEvent()
    self.root:registerEvent(GUIEvent.Click, function()
        if self.currency == CurrencyId.GameCashCoupon then
            UIHelper.showToast(Lang:getString("add.game.cash.coupon.tip"))
        elseif self.currency >= 0 and self.currency <= CurrencyId.Diamonds then
            ClientHelper.onRecharge(1)
        end
        SoundUtil.clickUI()
    end)
end

---@param currency number
function GUIPayActivityCurrencyWindow:onDataChanged(currency)
    self.currency = currency
    self.siIcon:SetImage(PayHelper.getMoneyIcon(self.currency))
    if isArraignmentApp then
        self.siAdd:SetVisible(false)
    else
        self.siAdd:SetVisible(self.currency <= CurrencyId.Diamonds)
    end
end

function GUIPayActivityCurrencyWindow:onTick()
    if self.currency <= CurrencyId.Currency then
        local money = PlayerWallet.getMoneyByCoinId(self.currency)
        self.stText:SetText(money)
    else
        self.stText:SetText("0")
    end
end

return GUIPayActivityCurrencyWindow
--[[mg87u2mwEP0EmicXqyjROQu7NVeTMazUI94qwiPdYhHuoXKbFMx3mQzcFpDXuF73ZJpr0usWSnRvjLuRVo3HE4EwUBuruGyoWzy2KmSpDgvEQtUsEYGT0lqrkRAYHWEwhYW7R7szWCXV44i]]---