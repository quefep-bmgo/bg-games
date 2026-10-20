--[[W4f286gO1Adh8fCEgScrXPfE6HH6PzOgaji3F1kBps0L0C0D70T1zMftJZm1n2S3SAJ1FIHNyyZbsmuB70TaqoZZVr9fkzsnAi5acgdNpFdnpmAC]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 2362
                          local checkFileName = "GUIDamageRankItem.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[BtnQNNtwrJhb8aZDwKwjnZ1DCSehaZhUwoPA8tzSa1lMKT3I5Y69M5QAJHtK2yeAkY2qjwpKNK]]---@class GUIDamageRankItemWindow : IGUIWindow
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
--[[iCoFiCA9i]]