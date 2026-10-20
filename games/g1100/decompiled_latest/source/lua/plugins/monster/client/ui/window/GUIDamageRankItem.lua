---@class GUIDamageRankItemWindow : IGUIWindow
local GUIDamageRankItemWindow = class("GUIDamageRankItemWindow", IGUIWindow)

---@private
function GUIDamageRankItemWindow:ctor(...)
	self.super.ctor(self, "DamageRankItem.json", ...)
end

---@private
function GUIDamageRankItemWindow:onLoad()
	self.stRank = self:getChildWindowByName("DamageRankItem-Rank", GUIType.StaticText)
	self.stName = self:getChildWindowByName("DamageRankItem-Name", GUIType.StaticText)
	self.siIcon = self:getChildWindowByName("DamageRankItem-Icon", GUIType.StaticImage)
	self.stDamage = self:getChildWindowByName("DamageRankItem-Damage", GUIType.StaticText)
	self:initView()
	self:initEvent()
end

---@private
function GUIDamageRankItemWindow:initView()

end

---@private
function GUIDamageRankItemWindow:initEvent()

end

---@param data table
function GUIDamageRankItemWindow:onDataChanged(data)
	if not data[1] then
		self.root:SetVisible(false)
	else
		local cache = UserInfoCache:GetCache(data[1])
		if cache then
			self.root:SetVisible(true)
			self.stName:SetText(cache.nickName)
			self.stRank:SetText(data[3])
			self.stDamage:SetText(math.floor(data[2]))
			if data[4] then
				self.stName:SetTextColor(Color.GREEN)
				self.stRank:SetTextColor(Color.GREEN)
				self.stDamage:SetTextColor(Color.GREEN)
				self.siIcon:SetDrawColor(Color.GREEN)
			end
		else
			self.root:SetVisible(false)
		end
	end
end

return GUIDamageRankItemWindow
