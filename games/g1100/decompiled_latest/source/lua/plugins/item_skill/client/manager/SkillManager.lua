---@class CSkillManager
local CSkillManager = T(Global, "SkillManager")
local skills = {}

function CSkillManager:init()
    -- ---@type UIItemSkillMainLayout
    -- self.itemSkillMainLayout = UIHelper.newGameGUILayout("GUIItemSkillMain")
    -- self.itemSkillMainLayout:show()
    BaseListener.registerCallBack(CEvents.GameMainTickEvent, function(frameTime)
        if isGameStart then
            CSkillManager:onTick()
        end
    end)
end

function CSkillManager:onTick()
    for _, class in pairs(skills) do
        if class.onTick then
            class:onTick()
        end
    end
end

function CSkillManager:toItemSkillPacket(packet)
    local funcName = packet.funcName
    for _, class in pairs(skills) do
        local func = class[funcName]
        if type(func) == "function" then
            func(class, packet)
        end
    end
end

CSkillManager:init()