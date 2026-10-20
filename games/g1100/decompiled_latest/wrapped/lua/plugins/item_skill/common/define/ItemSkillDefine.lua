--[[e3mkpQdCvWIAM6c8sCaVAujhU1RyGbDVOXhYZgnXrRb]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 4005
                          local checkFileName = "ItemSkillDefine.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[ZuMoxeAvUeTG1KWhwb8VZ6eyEgrKITQZvsgmVldjW1g0q]]Define = T(Global, "Define")

Define.SkillType = {
    -- WaterBall = "1", --水球
    BridgeEgg = "6", --搭桥蛋
    -- EnderDragon = "8", --骑乘龙
    -- Withered = "9", --骑乘凋零
    -- BackPearl = "10", --回溯珍珠
    FireBomb = "11", --火焰弹
    -- EnderPearl = "12", --末影珍珠
    -- DropTNTSkill = "15", --掉落TNT
    -- RescueSkill = "17", --救援平台
    -- VoodooPotion = "18", --巫毒药水
    -- TownPortal = "19", --回城卷轴
    -- IronPuppet = "20", --铁傀儡
    -- SnowBallInsect = "21", --囊虫
    -- Alarm = "22", --报警器
    -- DoubleDummy = "23", --替身傀儡
    -- DiamondMine = "24", --钻石地雷
    -- FrozenClip = "25", --冰冻夹子
    -- DoubleDummyTeleport = "26", --傀儡传送
    -- Springboard = "27", --跳板
    -- Gliding = "28", --滑翔翼
    -- FireworksHand = "29", --手持烟花
    -- FireworksGround = "30", --地上烟花
    -- BuffFood = "31", --Buff食物
    -- CuttlefishBomb = "32", --墨鱼手雷
    -- CamouflagePotion = "33", --伪装药水
    -- BuffBomb = "34", --Buff炸弹
    -- BananaPeel = "35", --香蕉皮
    -- ArmorSuit = "36", --防具套装
    -- Farm = "37", --绿宝石农田
    -- Fan = "38", --电风扇
    -- TpPearl = "39", --传送珍珠
    -- Joker = "40", --小丑
    -- ThunderBook = "41", --雷电魔法书
    -- WitheredStaves = "42", --凋零之杖
    -- MagmaStaff = "43", --熔岩法杖
    -- HealingTotem = "44", --范围治疗
    -- Blocker = "45", --方块拦截者
    -- BuffWerewolf = "46", --狼人药水
    -- GhostShaper = "47", --鬼魂变身器
    -- TntEgg = "48", --tnt蛋
    -- SpiderWeb = "49", --蜘蛛网
    -- NewGliding = "50", --新滑翔伞
    -- NewBackPearl = "51", --新回溯珍珠
    -- EffectBomb = "52",  --效果炸弹
    -- Earthquake = "53",  --地震装置
    -- BlockBomb = "54",  --地震装置
    -- EnemyFinding = "55",  --索敌球
    -- TeammateTeleport = "56",  --传送器
    -- BuffPotion = "57",  --buff药水
    -- TrackBombTower = "58",  --固定炮台(追踪)
}

Define.MonsterType = {
    ServerMonster = 0,
    -- IronGolem = 1, ---铁傀儡
    -- SnowBallInsect = 2, ---囊虫
    -- Alarm = 3, ---报警器
    -- DoubleDummy = 4, ---替身傀儡
    -- DiamondMine = 5, ---钻石地雷
    -- FrozenClip = 6, ---冰冻夹子
    -- Springboard = 7, ---跳板
    -- BananaPeel = 8, ---香蕉皮
    -- Farm = 9, ---绿宝石农田
    -- ArcherTower = 10, ---箭塔
    -- Bomb = 11, ---炸弹
    -- Bear = 12, ---熊
    -- HealingTotem = 13,  ---治疗图腾
    -- Blocker = 14,  ---方块拦截者
    -- HalloweenBoss = 15,  ---万圣节boss
    -- HalloweenGhost = 16,  ---万圣节幽灵
    -- PumpkinCube = 17,  ---南瓜方块
    -- Cloned = 18, ---分身
    -- SpiderWeb = 19, ---蜘蛛网
    -- ExplosionTrap = 20, ---炸弹陷阱
    -- Earthquake = 21, ---地震装置
    -- PuppetWarrior = 22, ---傀儡战士
    -- HalloweenFixed = 23, ---万圣节固定怪
    -- Balloon = 24, ---周年庆气球
    -- TimeBomb = 25, ---定时炸弹
    -- TrackBombTower = 26, ---固定炮台(追踪)
}

Define.PropBlockId = {
    BlockBomb = 1601
}--[[DCTL]]---