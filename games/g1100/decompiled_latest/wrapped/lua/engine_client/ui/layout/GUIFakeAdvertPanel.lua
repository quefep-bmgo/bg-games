--[[m4rUUna]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 3294
                          local checkFileName = "GUIFakeAdvertPanel.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[ZuMoxeAvUeTG1KWhwb8VZ6eyEgrKITQZvsgmVldjW1g0q]]---@class UIFakeAdvertPanelLayout : IGUILayout
local UIFakeAdvertPanelLayout = class("UIFakeAdvertPanelLayout", IGUILayout)

---@private
function UIFakeAdvertPanelLayout:ctor(parent)
    self.super.ctor(self, "FakeAdvertPanel.json", parent)
end

---@private
function UIFakeAdvertPanelLayout:isDelayLoad()
    return true
end

---@private
function UIFakeAdvertPanelLayout:onCreate()
    self:initCreateEvent()
end

---@private
function UIFakeAdvertPanelLayout:initCreateEvent()

end

---@private
function UIFakeAdvertPanelLayout:onLoad()
    self.siImage = self:getChildWindow("FakeAdvertPanel-Image", GUIType.StaticImage)
    self.stTitle = self:getChildWindow("FakeAdvertPanel-Title", GUIType.StaticText)
    self.llCountdown = self:getChildWindow("FakeAdvertPanel-Countdown", GUIType.Layout)
    self.stCountdownTxt = self:getChildWindow("FakeAdvertPanel-CountdownTxt", GUIType.StaticText)
    self:initView()
    self:initEvent()
end

---@private
function UIFakeAdvertPanelLayout:initView()
    self.rotate = 0
    self.rotateInc = 0.2
    self.stTitle:SetText("测试广告")
end

---@private
function UIFakeAdvertPanelLayout:initEvent()
    self.llCountdown:registerEvent(GUIEvent.Click, function()
        self:onCountdownClick()
    end)
end

function UIFakeAdvertPanelLayout:onCountdownClick()
    if self.countdown <= 0 then
        self:hide()
    else
        CustomDialog.builder()
                    .setContentText("现在退出将不会获得任何奖励！\n你确定要退出吗？")
                    .setRightClickListener(function()
            self:hide()
        end)        .show()
    end
end

function UIFakeAdvertPanelLayout:onShow(callback)
    self.countdown = 5 * 1000
    self.callback = callback
end

function UIFakeAdvertPanelLayout:onTick(frameTime)
    self.countdown = self.countdown - frameTime
    local countdown = math.ceil(self.countdown / 1000)
    if countdown <= 0 then
        self.stCountdownTxt:SetText("已获得奖励")
    else
        self.stCountdownTxt:SetText(DateUtil.getFormatTime(countdown))
    end
    self.llCountdown:SetWidth({ 0, self.stCountdownTxt:GetTextWidth() + 45 })
    self.rotate = self.rotate + self.rotateInc
    self.siImage:SetRotate(self.rotate)
    if self.rotate >= 1 or self.rotate <= -1 then
        self.rotateInc = -self.rotateInc
    end
end

function UIFakeAdvertPanelLayout:onHide()
    if self.countdown <= 0 then
        self.callback()
    end
end

return UIFakeAdvertPanelLayout
--[[eiQy8Bw3IUdE5UgAr8666o3]]