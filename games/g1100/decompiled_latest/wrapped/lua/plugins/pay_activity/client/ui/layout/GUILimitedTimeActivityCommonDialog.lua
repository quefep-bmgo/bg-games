--[[V2ISDbbV5nNDaPihTWIZAYQvn6kDb2hDf8dQ2]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 5179
                          local checkFileName = "GUILimitedTimeActivityCommonDialog.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[rI3]]---@class UILimitedTimeActivityCommonDialogLayout : IGUILayout
local UILimitedTimeActivityCommonDialogLayout = class("UILimitedTimeActivityCommonDialogLayout", IGUILayout)

---@type PayActivityRewardConfig
local PayActivityRewardConfig = T(Global, "PayActivityRewardConfig")

---@private
function UILimitedTimeActivityCommonDialogLayout:ctor(parent)
	self.super.ctor(self, "LimitedTimeActivityCommonDialog.json", parent)
end

---@private
function UILimitedTimeActivityCommonDialogLayout:isDelayLoad()
	return true
end

---@private
function UILimitedTimeActivityCommonDialogLayout:onCreate()
	self:initCreateEvent()
end

---@private
function UILimitedTimeActivityCommonDialogLayout:initCreateEvent()

end

---@private
function UILimitedTimeActivityCommonDialogLayout:onLoad()
	self.llMask = self:getChildWindow("LimitedTimeActivityCommonDialog-mask", GUIType.Layout)
	self.llWnd = self:getChildWindow("LimitedTimeActivityCommonDialog-wnd", GUIType.Layout)
	self.siWndBg = self:getChildWindow("LimitedTimeActivityCommonDialog-wnd_bg", GUIType.StaticImage)
	self.siTopImg = self:getChildWindow("LimitedTimeActivityCommonDialog-topImg", GUIType.StaticImage)
	self.stTitle = self:getChildWindow("LimitedTimeActivityCommonDialog-title", GUIType.StaticText)
	self.btnClose = self:getChildWindow("LimitedTimeActivityCommonDialog-close", GUIType.Button)
	self.siCloseImg = self:getChildWindow("LimitedTimeActivityCommonDialog-closeImg", GUIType.StaticImage)
	self.siDetailsBg = self:getChildWindow("LimitedTimeActivityCommonDialog-details_bg", GUIType.StaticImage)
	self.gvDetails = self:getChildWindow("LimitedTimeActivityCommonDialog-details", GUIType.GridView)
	self.stDetailsText = self:getChildWindow("LimitedTimeActivityCommonDialog-details_text", GUIType.StaticText)
	self.llItemPool = self:getChildWindow("LimitedTimeActivityCommonDialog-itemPool", GUIType.Layout)
	self:initView()
	self:initEvent()
end

---@private
function UILimitedTimeActivityCommonDialogLayout:initView()
	self.stTitle:SetText(Lang:getString(""))
	self.stDetailsText:SetText(Lang:getString(""))
end

---@private
function UILimitedTimeActivityCommonDialogLayout:initEvent()
	self.btnClose:registerEvent(GUIEvent.ButtonClick, function()
		self:hide()
	end)
end

function UILimitedTimeActivityCommonDialogLayout:onShow(params)
	if not params then
		return
	end
	self.params=params
	self.siDetailsBg:SetVisible(false)
	self.llItemPool:SetVisible(false)
	if params.title then
		self.stTitle:SetText(Lang:getString(params.title))
	end

	if params.type == PayActivityDefine.LIMITED_TIME_ACTIVITY_COMMON_DIALOG_TYPE.POND then
		self.rewardIdList=params.rewardIdList
		self:updateGiftList()
	elseif params.type == PayActivityDefine.LIMITED_TIME_ACTIVITY_COMMON_DIALOG_TYPE.TEXT then
		self:updateText()
	end
end

function UILimitedTimeActivityCommonDialogLayout:updateGiftList()
	if not self.rewardIdList then
		return
	end
	self.llItemPool:SetVisible(true)

	if not self.giftAdapter then
		self.gvGiftList = IGUIGridView.new("LimitTimeActivityCommon-List", self.llItemPool)
		self.gvGiftList:setArea({ 0, 20 }, { 0, 0 }, { 1, 0 }, { 1, 0 })
		self.gvGiftList:setConfig(50, 25, 4)
		---@type LimitedTimeCombinedAdapter
		self.giftAdapter = UIHelper.newGameAdapter("LimitedTimeCommonDialogAdapter")
		self.gvGiftList:setAdapter(self.giftAdapter)
	end
	local giftList={}
	for _, v in pairs(self.rewardIdList) do
		local reward=PayActivityRewardConfig:getCfgById(v)
		if reward then
			--local temp=TableUtil.copyTable(reward)
			--if hasRewardItemInf then
			--	temp.isHave=hasRewardItemInf[reward.id]
			--end
			table.insert(giftList,reward)
		end
	end
	table.sort(giftList,function (a,b)
		if a.quality>b.quality then
			return true
		elseif a.quality<b.quality then
			return false
		else
			return a.id<b.id
		end
	end)
	--LogUtil.pv(giftList)
	self.giftAdapter:setData(giftList)
end

function UILimitedTimeActivityCommonDialogLayout:updateText()
	self.siDetailsBg:SetVisible(true)
	if self.params.dec then
		self.stDetailsText:SetText(Lang:getString(self.params.dec))
	end
	if self.stDetailsText:GetPixelSize().y > self.gvDetails:GetPixelSize().y then
		self.gvDetails:SetMoveAble(true)
	else
		self.gvDetails:SetMoveAble(false)
	end
end

return UILimitedTimeActivityCommonDialogLayout
--[[ef1QDgr8L4NlYGCdeDmplxogylUaVy8iUM8Mb3MJY4eEhqgopAjszu4ukD12xHjW7bw2HCWqBbuA1uqFDu45H7hovhge1us26Cxqs5cfyV8AByUx7N39duobxV]]---