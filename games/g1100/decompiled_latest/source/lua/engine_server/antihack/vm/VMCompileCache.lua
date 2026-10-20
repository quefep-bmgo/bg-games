-- 虚拟机编译缓存管理器
-- 缓存编译结果，避免重复编译相同的脚本

local VMCompileCache = T(Global, "VMCompileCache")

function VMCompileCache:init()
    self.cache = {}
    self.cacheStats = {
        hits = 0,
        misses = 0,
        compilations = 0
    }
    self.maxCacheSize = 100  -- 最大缓存条目数
    self.cacheTimeout = 1800 -- 缓存超时时间（30分钟）
    
    -- 定期清理过期缓存
    LuaTimer:schedule(function()
        self:cleanupExpiredCache()
    end, 300 * 1000, 300 * 1000) -- 每5分钟清理一次
end

-- 生成缓存键
function VMCompileCache:generateCacheKey(scriptContent, obfuscationLevel, randomSeed)
    -- 使用脚本内容的哈希 + 配置参数作为缓存键
    local contentHash = self:simpleHash(scriptContent)
    return string.format("%s_%d_%d", contentHash, obfuscationLevel or 1, randomSeed or 0)
end

-- 简单哈希函数
function VMCompileCache:simpleHash(str)
    local hash = 0
    for i = 1, #str do
        hash = (hash * 31 + string.byte(str, i)) % 2147483647
    end
    return tostring(hash)
end

-- 获取缓存
function VMCompileCache:get(cacheKey)
    local entry = self.cache[cacheKey]
    
    if not entry then
        self.cacheStats.misses = self.cacheStats.misses + 1
        return nil
    end
    
    -- 检查是否过期
    local currentTime = os.time()
    if currentTime - entry.timestamp > self.cacheTimeout then
        self.cache[cacheKey] = nil
        self.cacheStats.misses = self.cacheStats.misses + 1
        return nil
    end
    
    -- 更新访问时间
    entry.lastAccess = currentTime
    entry.accessCount = entry.accessCount + 1
    
    self.cacheStats.hits = self.cacheStats.hits + 1
    return entry.data
end

-- 设置缓存
function VMCompileCache:set(cacheKey, data)
    local currentTime = os.time()
    
    -- 检查缓存大小限制
    if self:getCacheSize() >= self.maxCacheSize then
        self:evictLeastRecentlyUsed()
    end
    
    self.cache[cacheKey] = {
        data = data,
        timestamp = currentTime,
        lastAccess = currentTime,
        accessCount = 1
    }
    
    self.cacheStats.compilations = self.cacheStats.compilations + 1
end

-- 获取缓存大小
function VMCompileCache:getCacheSize()
    local count = 0
    for _ in pairs(self.cache) do
        count = count + 1
    end
    return count
end

-- 清理过期缓存
function VMCompileCache:cleanupExpiredCache()
    local currentTime = os.time()
    local expiredKeys = {}
    
    for key, entry in pairs(self.cache) do
        if currentTime - entry.timestamp > self.cacheTimeout then
            table.insert(expiredKeys, key)
        end
    end
    
    for _, key in ipairs(expiredKeys) do
        self.cache[key] = nil
    end
    
    if #expiredKeys > 0 then
        LogUtil.logInfo("[VMCompileCache] 清理过期缓存条目: " .. #expiredKeys)
    end
end

-- 驱逐最少使用的缓存条目
function VMCompileCache:evictLeastRecentlyUsed()
    local oldestKey = nil
    local oldestTime = math.huge
    
    for key, entry in pairs(self.cache) do
        if entry.lastAccess < oldestTime then
            oldestTime = entry.lastAccess
            oldestKey = key
        end
    end
    
    if oldestKey then
        self.cache[oldestKey] = nil
        LogUtil.logInfo("[VMCompileCache] 驱逐LRU缓存条目: " .. oldestKey)
    end
end

-- 清空缓存
function VMCompileCache:clear()
    self.cache = {}
    self.cacheStats = {
        hits = 0,
        misses = 0,
        compilations = 0
    }
    LogUtil.logInfo("[VMCompileCache] 缓存已清空")
end

-- 获取缓存统计
function VMCompileCache:getStats()
    local totalRequests = self.cacheStats.hits + self.cacheStats.misses
    local hitRate = totalRequests > 0 and (self.cacheStats.hits / totalRequests * 100) or 0
    
    return {
        cacheSize = self:getCacheSize(),
        maxCacheSize = self.maxCacheSize,
        hits = self.cacheStats.hits,
        misses = self.cacheStats.misses,
        compilations = self.cacheStats.compilations,
        hitRate = hitRate,
        totalRequests = totalRequests
    }
end

-- 打印缓存统计
function VMCompileCache:printStats()
    local stats = self:getStats()
    LogUtil.logInfo(string.format(
        "[VMCompileCache] 统计信息 - 缓存大小: %d/%d, 命中率: %.2f%%, 命中: %d, 未命中: %d, 编译: %d",
        stats.cacheSize, stats.maxCacheSize, stats.hitRate,
        stats.hits, stats.misses, stats.compilations
    ))
end

-- 设置缓存配置
function VMCompileCache:setConfig(maxSize, timeout)
    self.maxCacheSize = maxSize or self.maxCacheSize
    self.cacheTimeout = timeout or self.cacheTimeout
    LogUtil.logInfo(string.format(
        "[VMCompileCache] 配置更新 - 最大大小: %d, 超时: %d秒",
        self.maxCacheSize, self.cacheTimeout
    ))
end

VMCompileCache:init()

return VMCompileCache
