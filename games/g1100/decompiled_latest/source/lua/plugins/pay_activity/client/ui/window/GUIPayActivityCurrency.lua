---@class GUIPayActivityCurrencyWindow : IGUIWindow
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
