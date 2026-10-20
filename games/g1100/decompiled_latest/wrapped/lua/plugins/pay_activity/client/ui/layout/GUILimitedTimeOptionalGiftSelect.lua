--[[N3BlVHgiFSkkMxIkHmKwX1KRPKaKkQpRsLhwiNURcjWvHNBjzantbZFdumYUb7tyDsAJeoTnYra3q5s1DkxU1mvLPfXeoZ91ySppZoylQCWgo0zJFY78BD8KjVR85XZKoFg0INeTPwSUNGRmFYHJ7ZKSGT7Nn6y1cPRfpFdZ4lfdMnIqTLXtuNjTHoqpucP5mz7wYR9Dc1OSYuwbl61fRsuJwmTH2IJi2SFX7j7JWGByS9Ek7ptCvShfo9f56O38T1tWd6YWbOqK3Bj0GFZ4eEII1CAMh1]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 5451
                          local checkFileName = "GUILimitedTimeOptionalGiftSelect.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[XoD4BExDhRfsMc52Hm9dUTv]]---@class UILimitedTimeOptionalGiftSelectLayout : IGUILayout
local UILimitedTimeOptionalGiftSelectLayout = class("UILimitedTimeOptionalGiftSelectLayout", IGUILayout)

---@type PayActivityRewardConfig
local PayActivityRewardConfig = T(Global, "PayActivityRewardConfig")

---@private
function UILimitedTimeOptionalGiftSelectLayout:ctor(parent)
	self.super.ctor(self, "LimitedTimeOptionalGiftSelect.json", parent)
end

---@private
function UILimitedTimeOptionalGiftSelectLayout:isDelayLoad()
	return true
end

---@private
function UILimitedTimeOptionalGiftSelectLayout:onCreate()
	self:initCreateEvent()
end

---@private
function UILimitedTimeOptionalGiftSelectLayout:initCreateEvent()

end

---@private
function UILimitedTimeOptionalGiftSelectLayout:onLoad()
	self.llClose = self:getChildWindow("LimitedTimeOptionalGiftSelect-Close", GUIType.Layout)
	self.llContent = self:getChildWindow("LimitedTimeOptionalGiftSelect-Content", GUIType.Layout)
	self.siTop = self:getChildWindow("LimitedTimeOptionalGiftSelect-Top", GUIType.StaticImage)
	self.stTopTitle = self:getChildWindow("LimitedTimeOptionalGiftSelect-Top-Title", GUIType.StaticText)
	self.llPanel = self:getChildWindow("LimitedTimeOptionalGiftSelect-Panel", GUIType.Layout)
	self.llDescBg = self:getChildWindow("LimitedTimeOptionalGiftSelect-Desc-Bg", GUIType.Layout)
	self.stDesc = self:getChildWindow("LimitedTimeOptionalGiftSelect-Desc", GUIType.StaticText)
	self.stTip = self:getChildWindow("LimitedTimeOptionalGiftSelect-Tip", GUIType.StaticText)
	self.btnCloseBtn = self:getChildWindow("LimitedTimeOptionalGiftSelect-Close-Btn", GUIType.Button)
	self.btnBtnOk = self:getChildWindow("LimitedTimeOptionalGiftSelect-BtnOk", GUIType.Button)
	self.tvBtnText = self:getChildWindow("LimitedTimeOptionalGiftSelect-BtnText", GUIType.StaticText)
	self:initView()
	self:initEvent()
end

---@private
function UILimitedTimeOptionalGiftSelectLayout:initView()
	self.stTopTitle:SetText("")
	self.stDesc:SetText("")
	self.stTip:SetText(Lang:getString("gui.pay.activity.reward.detail.tip"))
	self.btnBtnOk:SetText("")
	self.tvBtnText:SetText("")

	self.gvItems = IGUIGridView.new("LimitedTimeOptionalGiftSelect-Panel-List", self.llPanel)
	self.gvItems:setConfig(30, 0, 5)
	---@type LimitedTimeWeekAdapter
	self.adapter = UIHelper.newGameAdapter("LimitedTimeItemInfoAdapter")
	self.gvItems:setAdapter(self.adapter)

end

---@private
function UILimitedTimeOptionalGiftSelectLayout:initEvent()
	self.btnCloseBtn:registerEvent(GUIEvent.ButtonClick, function()
		self:hide()
	end)
	self.btnBtnOk:registerEvent(GUIEvent.ButtonClick, function()
		if not self.selectId then return end
		self:hide()
		if self.callView and self.selectId then
			local config = PayActivityRewardConfig:getCfgById(self.selectId)
			local _config = TableUtil.copyTable(config)
			self.callView:onItemClick(_config)
		end
	end)
end

function UILimitedTimeOptionalGiftSelectLayout:onHide()
end

function UILimitedTimeOptionalGiftSelectLayout:onShow(title, ids, selectId, view, canNext)
	self.itemList = {}
	self.selectId = nil
	self.canNext = canNext or false
	self.callView = view
	local selectConfig = nil
	for _, id in pairs(ids) do
		local config = PayActivityRewardConfig:getCfgById(id)
		local _config = TableUtil.copyTable(config)
		_config.isSelect = false
		if _config.id == selectId then
			selectConfig = _config
		end
		_config.view = self
		table.insert(self.itemList, _config)
	end
	self.stTopTitle:SetText(title)
	self.stDesc:SetText("")
	if selectConfig then
		self:onItemClick(selectConfig)
	else
		self:updateWeekUI(false)
	end
end

function UILimitedTimeOptionalGiftSelectLayout:onItemClick(config)
	for _, _config in pairs(self.itemList or {}) do
		_config.isSelect = (_config.id == config.id)
	end
	self.selectId = config.id
	if config.count <= 1 then
		self.stDesc:SetText(Lang:getString(config.name))
	else
		self.stDesc:SetText(Lang:getString(config.name) .. "x" ..config.count)
	end
	self:updateWeekUI(true)
end

function UILimitedTimeOptionalGiftSelectLayout:updateWeekUI(noReset)
	self.adapter:setData(self.itemList, noReset)
	self.btnBtnOk:SetEnabled(self.selectId ~= nil)
	if self.canNext then
		self.tvBtnText:SetText(Lang:getString("gui.limit.time.optional.gift.btn.next"))
	else
		self.tvBtnText:SetText(Lang:getString("gui.limit.time.optional.gift.btn.sure"))
	end
end

return UILimitedTimeOptionalGiftSelectLayout
--[[bDQJVbmonMX7ACq9fkc]]---