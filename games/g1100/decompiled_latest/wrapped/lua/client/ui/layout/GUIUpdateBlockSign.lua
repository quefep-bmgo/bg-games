--[[W4yFgM9y3VWzN1xy4UyiMS1awB0AV1XS7QBDf19Uk52zCexslOjXgCO6MVF]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 7839
                          local checkFileName = "GUIUpdateBlockSign.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[EJKAhFLvVx74CoCt6t56TiWgto]]---@class UIUpdateBlockSignLayout : IGUILayout
local UIUpdateBlockSignLayout = class("UIUpdateBlockSignLayout", IGUILayout)

---@private
function UIUpdateBlockSignLayout:ctor(parent)
    self.super.ctor(self, "UpdateBlockSign.json", parent)
end

---@private
function UIUpdateBlockSignLayout:isDelayLoad()
    return true
end

---@private
function UIUpdateBlockSignLayout:onCreate()
    self:initCreateEvent()
end

---@private
function UIUpdateBlockSignLayout:initCreateEvent()

end

---@private
function UIUpdateBlockSignLayout:onLoad()
    self.btnClose = self:getChildWindow("UpdateBlockSign-Close", GUIType.Button)
    self.stTitle = self:getChildWindow("UpdateBlockSign-Title", GUIType.StaticText)
    self.llDescBG = self:getChildWindow("UpdateBlockSign-DescBG", GUIType.Layout)
    self.etDesc = self:getChildWindow("UpdateBlockSign-Desc", GUIType.Edit)
    self.stDescHint = self:getChildWindow("UpdateBlockSign-DescHint", GUIType.StaticText)
    self.stDescText = self:getChildWindow("UpdateBlockSign-DescText", GUIType.StaticText)
    self.btnUpdate = self:getChildWindow("UpdateBlockSign-Update", GUIType.Button)
    self.llMask = self:getChildWindow("UpdateBlockSign-Mask", GUIType.Layout)
    self:initView()
    self:initEvent()
end

---@private
function UIUpdateBlockSignLayout:initView()
    self.stTitle:SetText(Lang:getString("gui_skyblocksign_title_name"))
    self.stDescHint:SetText(Lang:getString("gui_skyblocksign_content_text"))
    self.btnUpdate:SetText(Lang:getString("gui_skyblocksign_apply_btn"))
    self.etDesc:SetAlpha(0, true)
end

---@private
function UIUpdateBlockSignLayout:initEvent()
    self.btnClose:registerEvent(GUIEvent.ButtonClick, function()
        self:hide()
    end)
    self.btnUpdate:registerEvent(GUIEvent.ButtonClick, function()
        self:onUpdateSign()
        SoundUtil.clickUI()
    end)
    self.etDesc:registerEvent(GUIEvent.EditTextInput, function()
        self:checkHintUI()
    end)
end


function UIUpdateBlockSignLayout:onShow(entry)
    self.entry = entry
    local player = PlayerManager:getClientPlayer()
    self.btnUpdate:SetVisible(true)
    self.llMask:SetVisible(not self.btnUpdate:IsVisible())
    self.etDesc:SetText(entry.txt)
    if self.btnUpdate:IsVisible() then
        self.llDescBG:SetHeight({ 1, -185 })
    else
        self.llDescBG:SetHeight({ 1, -110 })
    end
    self:checkHintUI()
end

function UIUpdateBlockSignLayout:checkHintUI()
    self.stDescHint:SetVisible(self.etDesc:GetText() == "" and self.btnUpdate:IsVisible())
    self.stDescText:SetVisible(not self.stDescHint:IsVisible())
    self.stDescText:SetText(self.etDesc:GetText())
end

local function strictValidateUTF8(content)
    local valid = {}
    local i = 1
    local len = #content
    
    while i <= len do
        local b1 = content:byte(i)
        
        -- 单字节字符 (0x00-0x7F)
        if b1 < 0x80 then
            table.insert(valid, b1)
            i = i + 1
        
        -- 多字节字符验证
        else
            local byteCount = 0
            if b1 >= 0xF0 and b1 <= 0xF7 then byteCount = 4  -- 4字节字符
            elseif b1 >= 0xE0 then byteCount = 3             -- 3字节字符
            elseif b1 >= 0xC0 then byteCount = 2             -- 2字节字符
            else
                -- 非法起始字节，跳过
                i = i + 1
                goto continue
            end
            
            -- 检查后续字节是否合法（必须为10xxxxxx）
            local validSeq = true
            for j = 1, byteCount-1 do
                if i + j > len or content:byte(i+j) < 0x80 or content:byte(i+j) > 0xBF then
                    validSeq = false
                    break
                end
            end
            
            if validSeq then
                -- 完整保存合法多字节字符
                for j = 0, byteCount-1 do
                    table.insert(valid, content:byte(i+j))
                end
                i = i + byteCount
            else
                -- 跳过非法序列
                i = i + byteCount
            end
        end
        ::continue::
    end
    
    return string.char(table.unpack(valid))
end

function UIUpdateBlockSignLayout:onUpdateSign()
    local content = self.etDesc:GetText()
    
    -- 限制字符串长度
    local maxLength = 256
    if type(content) ~= "string" or string.len(content) > maxLength then
        -- 可以添加提示UI
        content = string.sub(content, 1, maxLength)
    end
    
    -- 多语言安全字符过滤
	content = strictValidateUTF8(content)
    local safeText = ""
    for _, codepoint in utf8.codes(content) do
        -- 允许以下Unicode区块:
        if (codepoint >= 32 and codepoint <= 126)           -- 基本拉丁字母、数字、标点 (英文)
            or (codepoint >= 0x00A0 and codepoint <= 0x00FF) -- 拉丁字母补充-1 (西欧语言)
            or (codepoint >= 0x0100 and codepoint <= 0x017F) -- 拉丁字母扩展-A (法语、葡萄牙语等)
            or (codepoint >= 0x0180 and codepoint <= 0x024F) -- 拉丁字母扩展-B (德语、荷兰语等)
            or (codepoint >= 0x0400 and codepoint <= 0x04FF) -- 西里尔字母 (俄语)
            or (codepoint >= 0x0500 and codepoint <= 0x052F) -- 西里尔字母补充
            or (codepoint >= 0x0600 and codepoint <= 0x06FF) -- 阿拉伯文
            or (codepoint >= 0x0750 and codepoint <= 0x077F) -- 阿拉伯文补充
            or (codepoint >= 0x1E00 and codepoint <= 0x1EFF) -- 拉丁字母扩展附加 (越南语)
            or (codepoint >= 0x3040 and codepoint <= 0x309F) -- 日文平假名
            or (codepoint >= 0x30A0 and codepoint <= 0x30FF) -- 日文片假名
            or (codepoint >= 0x3100 and codepoint <= 0x312F) -- 注音符号
            or (codepoint >= 0x3130 and codepoint <= 0x318F) -- 韩文兼容字母
            or (codepoint >= 0x4E00 and codepoint <= 0x9FFF) -- 中日韩统一表意文字 (中文、日文汉字)
            or (codepoint >= 0xAC00 and codepoint <= 0xD7AF) -- 韩文音节
            or (codepoint >= 0xFF00 and codepoint <= 0xFFEF) -- 全角ASCII、半角片假名
			or (codepoint >= 0x0900 and codepoint <= 0x097F) -- 新增：梵文（印地语）
            or (codepoint >= 0x0E00 and codepoint <= 0x0E7F) -- 新增：泰语
        then
            safeText = safeText .. utf8.char(codepoint)
        end
    end
    
    -- 如果过滤后为空字符串，返回简单提示
    if safeText == "" then
        safeText = "..."
    end
    
    -- 更新UI显示已过滤内容
    self.etDesc:SetText(safeText)
    self:checkHintUI()
    
    if safeText ~= self.entry.content then
        PlayerManager:getClientPlayer():sendPacket({
            pid = "updateBlockSign",
            data = {
                blockPos = self.entry.blockPos,
                txt = safeText
            }
        })
    end
    self:hide()
end

return UIUpdateBlockSignLayout
--[[KAAUlhGr9aqzOQKVRJiHkBRMZPDuItvsCY35bVTJZ]]---