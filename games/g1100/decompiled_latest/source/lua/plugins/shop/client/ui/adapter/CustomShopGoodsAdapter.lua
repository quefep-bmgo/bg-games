---@class CustomShopGoodsAdapter : IDataAdapter
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

return CustomShopGoodsAdapter