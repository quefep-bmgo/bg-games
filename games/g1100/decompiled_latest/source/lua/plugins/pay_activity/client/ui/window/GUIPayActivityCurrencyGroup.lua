---@class GUIPayActivityCurrencyGroupWindow : IGUIWindow
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
