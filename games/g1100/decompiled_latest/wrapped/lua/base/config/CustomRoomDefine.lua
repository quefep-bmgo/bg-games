--[[V2ISDbbV5nNDaPihTWIZAYQvn6kDb2hDf8dQ2]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 5771
                          local checkFileName = "CustomRoomDefine.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[rI3]]---@type Define
local Define = T(Global, "Define")

Define.CustomRoomSettingType = {
    PVP = 1,
    FLY = 2,
    PLACE_BLOCK = 3,
    BREAK_BLOCK = 4,
    FOOD = 5,
    FAST_BREAK_BLOCK = 6,
    UNLIMIT_ITEM = 7,
    SPECIAL_BLOCK = 8,
    DROP_ITEM_ON_DIE = 9,
    CAN_USE_GUN = 10
  --  SET_PERMISSION = 9
}

Define.CustomGameMode = {
    PVP = 0,
    CREATIVE =1,
    SOCIAL =2,
    RUN = 3,
    EDIT = 4
}

Define.CustomGamePermissionRole = {
    Owner = 0,
    Admin = 1,
    Member = 2,
    Guest  = 3,
    UDefine = 4,
}

-- 从1100108开始
Define.AppToGameEvent={
    GAME_ACTION_CUSTOM_ROOM_CLOSE_GAME = 1100108,
    GAME_ACTION_CUSTOM_ROOM_GET_GAME_SETTING = 1901,
    GAME_ACTION_CUSTOM_ROOM_EDIT_GAME_SETTING = 1902,
    GAME_ACTION_CUSTOM_ROOM_SET_TEAM_POS = 1903,
    GAME_ACTION_CUSTOM_ROOM_SET_TEAM_MARKER = 1904,
    GAME_ACTION_CUSTOM_ROOM_TELEPORT = 1905,
    GAME_ACTION_CUSTOM_ROOM_CR_TEAM_MARKER = 1906,
}

-- 从1100008开始
Define.GameToAppEvent={
    GAME_ACTION_CUSTOM_ROOM_SAVE_MAP_RESULT = 1100008,
    GAME_ACTION_CUSTOM_ROOM_GET_GAME_SETTING = 9101,
    GAME_ACTION_CUSTOM_ROOM_EDIT_GAME_SETTING = 9102,
    GAME_ACTION_CUSTOM_ROOM_SET_TEAM_POS = 9103,
    GAME_ACTION_CUSTOM_ROOM_SET_TEAM_MARKER = 9104,
    GAME_ACTION_CUSTOM_ROOM_TELEPORT = 9105,
    GAME_ACTION_CUSTOM_ROOM_CR_TEAM_MARKER = 9106,
}

Define.GameStatus = {
    WaitingPlayer = 1,
    GameRunning = 2,
    GameOver = 3,
}

Define.OverCondition = {
    CollectNum = 1,     -- 收集物品达到数量
    KillNum = 2,        -- 击败玩家达到数量
    Survival = 3,       -- 生存
    Collect = 4,        -- 游戏时间内收集物品
    Kill = 5,           -- 游戏时间内击败玩家
    Marker = 6,         -- 摧毁标志物
    MarkerAndKill = 7,  -- 摧毁标志物和击败玩家
}

Define.RankBg = {
    "set:new_gui_material.json image:red_icon",
    "set:new_gui_material.json image:yellow_icon",
    "set:new_gui_material.json image:blue_icon"
}

Define.SelectTeam = {
    Position = "POSITION",
    Marker = "MARKER",
}

Define.RankDefaultBg = "set:new_gui_material.json image:brown_icon"

Define.RankNum = {
    ["0"] = "set:new_gui_material.json image:number_zero",
    ["1"] = "set:new_gui_material.json image:number_one",
    ["2"] = "set:new_gui_material.json image:number_two",
    ["3"] = "set:new_gui_material.json image:number_three",
    ["4"] = "set:new_gui_material.json image:number_four",
    ["5"] = "set:new_gui_material.json image:number_five",
    ["6"] = "set:new_gui_material.json image:number_six",
    ["7"] = "set:new_gui_material.json image:number_seven",
    ["8"] = "set:new_gui_material.json image:number_eight",
    ["9"] = "set:new_gui_material.json image:number_nine",
}

Define.TeamFlagColor = {
    "8F2521", --深棕红色
    "476AC3", --蓝紫色
    "C5B518", --暗金色
    "2DA424", --鲜绿色
    "E26A25", --橙红色
    "AF32BA", --紫红色
    "D2738E", --粉紫色
    "4B2C19", --深橄榄棕色
    "151212", --近黑色（深灰棕）
    "DDDCDC", --浅灰色
    "788484", --中灰色（带蓝调）
    "2D3F14", --深灰绿色
}

Define.TeamFlagItem = {
    2800,
    2801,
    2802,
    2803,
    2804,
    2805,
    2806,
    2807,
    2808,
    2809,
    2810,
    2811,
}
Define.TeamFlagActor = {
    "Teamflag_red.actor",
    "Teamflag_blue.actor",
    "Teamflag_yellow.actor",
    "Teamflag_green.actor",
    "Teamflag_orange.actor",
    "Teamflag_purple.actor",
    "Teamflag_pink.actor",
    "Teamflag_brown.actor",
    "Teamflag_black.actor",
    "Teamflag_white.actor",
    "Teamflag_grey.actor",
    "Teamflag_olivegreen.actor",
}
-- 玩家头顶显示的旗子
Define.TeamFlagEffect = {
    "redFlag.effect",
    "blueFlag.effect",
    "yellowFlag.effect",
    "greenFlag.effect",
    "orangeFlag.effect",
    "purpleFlag.effect",
    "pinkFlag.effect",
    "brownFlag.effect",
    "blackFlag.effect",
    "whiteFlag.effect",
    "greyFlag.effect",
    "oliveGreenFlag.effect",
}

--innerCode
Define.RunningConfigErrorCode = {
    None = 0,
    TeamSetting = 10,
    WinCondition = 20,
    GameSetting = 30,
    OtherSetting = 40,
    OtherError0 = 50,
    OtherError1 = 51,
    OtherError2 = 52,
}

-- 游戏状态
Define.GameState = {
    Ready = 0,
    Playing = 1,
    Settlement = 2
}

SoundType = SoundType or {}
SoundType.Kill = 500
SoundType.RunModeBgm = 15000
SoundType.EditModeBgm = 15001

Define.MarkerState = {
    None = 0,
    Alive = 1,
    Destroyed = 2,
}

Define.MarkerStateUIIcon = {
    "set:new_main.json image:img_0_true",
    "set:new_main.json image:img_0_false",
}

Define.MarkerEffect = {
    "mark_Red.effect",
    "mark_Blue.effect",
    "mark_Yellow.effect",
    "mark_Green.effect",
    "mark_Orange.effect",
    "mark_Purple.effect",
    "mark_Pink.effect",
    "mark_Brown.effect",
    "mark_Black.effect",
    "mark_White.effect",
    "mark_Grey.effect",
    "mark_Olive-Green.effect",
}

Define.EyeOffsetFromFoot = 1.62--[[KAAUlhGr9aqzOQKVRJiHkBRMZPDuItvsCY35bVTJZ]]---