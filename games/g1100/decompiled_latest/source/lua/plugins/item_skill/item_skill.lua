---起床专属插件 ， 为了功能模块化
local handlers = {}

Plugins.Require("item_skill", "common.define.ItemSkillDefine")
Plugins.Require("item_skill", "common.event.ItemSkillEvents")
Plugins.Require("item_skill", "common.config.MonsterConfig")
Plugins.Require("item_skill", "common.config.MountConfig")
Plugins.Require("item_skill", "common.config.SkillConfig")

if isClient then
    handlers = Plugins.Require("item_skill", "client.item_skill_client")
else
    handlers = Plugins.Require("item_skill", "server.item_skill_server")
end

return function(name, ...)
    if type(handlers[name]) ~= "function" then
        return
    end
    handlers[name](...)
end