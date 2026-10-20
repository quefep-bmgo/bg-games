--[[aZ4Ii7xWTi1IeBWp3oRFR6WHsCU1nnjDjGTCDM3DsYlMyoNHUSxsXgj8YQ7ma1hTLPof3qnw8nwwXo9VvYNtYXdA90byiiLAZi84jI25z465OwCPzjdUksCoboHtXM9dxDPhX32aH4CSeoNBijfBrMBeqXrk9AUZ5KP1NipetGAvpUSW8xTJQcSxJnqTHTATJY8e1ePNnWDkB5AQ2yBEI1U8xc2V2op3sBr0kH0A6rwDOY5cKVz6k4lybjEB3jvoTuBOilcsQKsNKjDHHWtG1yI9OC7VwRoQ6no4W2CQBtuTIbUWp5dGa]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 6173
                          local checkFileName = "AIPlayerManager.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[ouXGLK3WFKmDSEKVJ43ps4ms0AA50i79WTYj9]]require "engine_server.config.AIAttributeConfig"
require "engine_server.ai.AIPlayer"

AIPlayerManager = {}

---@type AIAttributeConfig
local AIAttributeConfig = T(Global, "AIAttributeConfig")

---@type AIPlayer[]
local AIPlayers = {}

function AIPlayerManager:addAI(ai)
    table.insert(AIPlayers, ai)
end

function AIPlayerManager:subAI(ai)
    for index, player in pairs(AIPlayers) do
        if tostring(player.rakssid) == tostring(ai.rakssid) then
            table.remove(AIPlayers, index)
            return
        end
    end
end

function AIPlayerManager:getAIs()
    return AIPlayers
end

function AIPlayerManager:getAICount()
    return #AIPlayers
end

function AIPlayerManager:getAIByRakssid(rakssid)
    for _, player in pairs(AIPlayers) do
        if player.rakssid == rakssid then
            return player
        end
    end
    return nil
end

function AIPlayerManager:getAIsByTeamId(teamId)
    local teamList = {}
    for _, player in pairs(AIPlayers) do
        if player.luaPlayer.teamId == teamId then
            table.insert(teamList, player)
        end
    end
    return teamList
end

function AIPlayerManager:onGameOver()
    for _, AI in pairs(AIPlayers) do
        AI:removeBtTree()
    end
    self.AIPlayers = {}
end

function AIPlayerManager:isAI(rakssid)
    if tonumber(tostring(rakssid)) <= 500 then
        --AI return
        return true
    end
    return false
end

function AIPlayerManager:isAIByUserId(userId)
    if self:getAIByUserId(userId) ~= nil then
        return true
    end
    return false
end

function AIPlayerManager:getAIByUserId(userId)
    for _, player in pairs(AIPlayers) do
        if tostring(player.userId) == tostring(userId) then
            return player
        end
    end
    return nil
end

function AIPlayerManager:getRealPlayerCount()
    return PlayerManager:getPlayerCount() - #AIPlayers
end

function AIPlayerManager:addPlayer(count)
    if not isTest then
        return
    end
    local userIds = {
        48672, 128, 1207280, 199520, 273792, 1403600, 3536, 16, 176, 10000, 1569872, 592, 87568,
        139184, 254672, 1004, 1005, 1006, 1020, 1021, 1024, 1036, 1037, 1040, 1052, 1053, 1054,
        1056, 1068, 1069, 1072, 1084, 1085, 1088, 1100, 1101, 1102, 1104, 1116, 1117, 1118, 1120,
        1132, 1133, 1134, 1136, 1148, 1149, 1152, 1164, 1165, 1168, 1180, 1181, 1184, 1196, 1197,
        1200, 1212, 1213, 1216, 1228, 1229, 1232, 1245, 1248, 1261, 1262, 1264, 1277, 1280, 1293,
        1296, 1309, 1310, 1312, 1325, 1341, 1344, 1357, 1360, 1373, 1376, 1389, 1392, 1405, 1408,
        1421, 1424, 1437, 1005, 1453, 1456, 1469, 1472, 1485, 1488, 1501, 1504, 1517, 1518, 1520,
        1533, 1536, 1549, 1552, 1565, 1568, 1581, 1584, 1597, 1600, 1613, 1616, 1629, 1630, 1632,
        1645, 1646, 1648, 1661, 1662, 1664, 1677, 1678, 1680, 1693, 1696, 1709, 1710, 1712, 1725,
        1726, 1728, 1741, 1742, 1744, 1757, 1758, 1760, 1773, 1774, 1776, 1789, 1790, 1792, 1805,
        1806, 1808, 1821, 1822, 1824, 1837, 1838, 1840, 1853, 1856, 1869, 1872, 1885, 1886, 1888,
        1902, 1904, 1917, 1918, 1920, 1933, 1934, 1936, 1949, 1950, 1952, 1965, 1966, 1968, 1981,
        1982, 1984, 1997, 1998, 2000, 2013, 2014, 2016, 2029, 2030, 2032, 2045, 2046, 2048, 2061,
        2064, 2077, 2080, 2093, 2096, 2109, 2110, 2112, 2125, 2126, 2128, 2141, 2142, 2144, 2157,
        2160, 2173, 2176, 2189, 2192, 2205, 2208, 2221, 2222, 2224, 2237, 2238, 2240, 2253, 2256,
        2269, 2270, 2272, 2285, 2288, 2301, 2302, 2304, 2317, 2320, 2333, 2336, 2349, 2350, 2352,
        2365, 2366, 2381, 2382, 2384, 2397, 2400, 2413, 2429, 2445, 2461, 2464, 2477, 2493, 2494,
        2509, 2510, 2512, 2525, 2526, 2528, 2541, 2542, 2544, 2557, 2558, 2560, 2573, 2574, 2576,
        2589, 2590, 2592, 2605, 2606, 2608, 2621, 2622, 2624, 2637, 2640, 2653, 2656, 2669, 2672,
        2685, 2688, 2701, 2704, 2717, 2720, 2733, 2736, 2749, 2752, 2765, 2768, 2781, 2784, 2797,
        2800, 2813, 2816, 2829, 2832, 2845, 2848, 2861, 2864, 2877, 2880, 2893, 2896, 2909, 2912,
        2925, 2928, 2941, 2944, 2957, 2960, 2973, 2976, 2989, 2992
    }
    local gameInitPos = {
        g1049 = VectorUtil.newVector3(-107, 131, 24),
        g1066 = VectorUtil.newVector3(358, 64, 532),
    }
    local curCount = 0
    for k, userId in pairs(userIds) do
        local teamId = (k % 2) + 1
        if not PlayerManager:isPlayerFull() and not PlayerManager:getPlayerByUserId(userId) then
            if count ~= 0 and curCount > count then
                break
            end
            local name = "Robot:" .. userId
            local attr = AIAttributeConfig:getAttribute(userId)
            if attr ~= nil then
                name = attr.name
                attr.team = teamId
                GameServer:getRoomManager():addUserAttr(attr)
            end
            AIPlayer.new(userId, name, gameInitPos[GameType])
            curCount = curCount + 1
        end
    end
end--[[uiaRVqof1AwBYNU0Ge0OQpDu4SJD19Xl0Y5yTLgPlqmKXM65MpdE9COsfcQ45Ah9ncwbcOd8suQRl2waP5bN34vBaNUqsigZiEEoOe8Sdk3LTegkzroum7HB36dkmvG9fxlNGMJq2JxEu6MT]]---