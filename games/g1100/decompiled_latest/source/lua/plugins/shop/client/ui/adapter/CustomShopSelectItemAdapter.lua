---@class CustomShopSelectItemAdapter : IDataAdapter
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

return CustomShopSelectItemAdapter