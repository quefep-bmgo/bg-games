---@class UIDigitalInputLayout : IGUILayout
local UIDigitalInputLayout = class("UIDigitalInputLayout", IGUILayout)

---@private
function UIDigitalInputLayout:ctor(parent)
    self.super.ctor(self, "DigitalInput.json", parent)
end

---@private
function UIDigitalInputLayout:isDelayLoad()
    return true
end

---@private
function UIDigitalInputLayout:onCreate()
    self:initCreateEvent()
end

---@private
function UIDigitalInputLayout:initCreateEvent()

end

---@private
function UIDigitalInputLayout:onLoad()
    self.btnClose = self:getChildWindow("DigitalInput-Close", GUIType.Button)
    self.llKeyboard = self:getChildWindow("DigitalInput-Keyboard", GUIType.Layout)
    self.btnNumberX = self:getChildWindow("DigitalInput-NumberX", GUIType.Button)
    self.btnEnter = self:getChildWindow("DigitalInput-Enter", GUIType.Button)
    self:initView()
    self:initEvent()
end

---@private
function UIDigitalInputLayout:initView()
    self.curNumber = 0
    ---@type GUIButton[]
    self.btnNumbers = {}
    for num = 0, 9 do
        self.btnNumbers[num] = self:getChildWindow("DigitalInput-Number" .. num, GUIType.Button)
        self.btnNumbers[num]:SetText(tostring(num))
    end
end

---@private
function UIDigitalInputLayout:initEvent()
    self.btnClose:registerEvent(GUIEvent.ButtonClick, function()
        self:hide()
    end)
    self.btnNumberX:registerEvent(GUIEvent.ButtonClick, function()
        self:updateCurNumber("x")
        SoundUtil.clickUI()
    end)
    self.btnEnter:registerEvent(GUIEvent.ButtonClick, function()
        self:hide()
        SoundUtil.clickUI()
    end)
    for num, btnNumber in pairs(self.btnNumbers) do
        btnNumber:registerEvent(GUIEvent.ButtonClick, function()
            self:updateCurNumber(num)
            SoundUtil.clickUI()
        end)
    end
end

---@private
function UIDigitalInputLayout:updateCurNumber(num)
    local curNumber
    if num == "x" then
        curNumber = tostring(self.curNumber)
        if #curNumber == 1 then
            self.firstInput = true
        end
        curNumber = string.sub(curNumber, 1, #curNumber - 1)
    else
        if self.firstInput then
            curNumber = num
        else
            curNumber = tostring(self.curNumber) .. num
        end
        self.firstInput = false
    end
    curNumber = tonumber(curNumber) or 0
    local oldNumber = self.curNumber
    if self.maxNumber then
        self.curNumber = math.min(curNumber, self.maxNumber)
    else
        self.curNumber = math.min(curNumber, 999999999999999999)
    end
    if self.minNumber then
        self.curNumber = math.max(self.minNumber, self.curNumber)
    end
    if oldNumber == self.curNumber then
        return
    end
    if self.inputListener then
        self.inputListener(self.curNumber, false)
    end
    self:checkNumberEnable()
end

---@private
function UIDigitalInputLayout:checkNumberEnable()
    local maxNumber = self.maxNumber or 999999999999999999
    for _, btnNumber in pairs(self.btnNumbers) do
        btnNumber:SetEnabled(self.curNumber < maxNumber or self.firstInput)
    end
end

---@param window GUIWindow
function UIDigitalInputLayout:onShow(window, offset)
    local screenSize = self.root:GetPixelSize()
    local keyboardSize = self.llKeyboard:GetPixelSize()
    local screenW, screenH = screenSize.x, screenSize.y
    local keyboardW, keyboardH = keyboardSize.x, keyboardSize.y
    if not window then
        self.llKeyboard:SetXPosition({ 0, (screenW - keyboardW) / 2 })
        self.llKeyboard:SetYPosition({ 0, (screenH - keyboardH) / 2 })
        return
    end
    offset = offset or 16
    local area = window:GetRenderArea()
    local left, top, right, bottom = area[1], area[2], area[3], area[4]
    if (top + bottom) / 2 < screenH / 2 then
        ---附着控件在上半屏，键盘在控件下方
        self.llKeyboard:SetYPosition({ 0, bottom + offset })
    else
        ---附着控件在下半屏，键盘在控件上方
        self.llKeyboard:SetYPosition({ 0, top - keyboardH - offset })
    end
    local centerX = (left + right) / 2
    ---不能超出屏幕
    local xPos = math.min(math.max(offset, centerX - keyboardW / 2), screenW - offset)
    self.llKeyboard:SetXPosition({ 0, xPos })
end

function UIDigitalInputLayout:onHide()
    if self.inputListener then
        self.inputListener(self.curNumber, true)
    end
    self.inputListener = nil
    self.curNumber = 0
    self.maxNumber = nil
    self.root:SetLevel(49)
    self:checkNumberEnable()
end

function UIDigitalInputLayout:setNumberData(curNumber, minNumber, maxNumber)
    self.curNumber = curNumber or 0
    self.minNumber = minNumber
    self.maxNumber = maxNumber
    self.firstInput = true
    self:checkNumberEnable()
end

---@param inputListener fun(number : number, close : boolean)
function UIDigitalInputLayout:setInputListener(inputListener)
    self.inputListener = inputListener
end

return UIDigitalInputLayout
