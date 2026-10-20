--[[DR]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 28551
                          local checkFileName = "init_vm.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[tSgflKRSYfil5FdC8JWmVX7YQSQm0PrcUBTCYORIz0RqFFsQeqtOlQnIvXleTn56]]local InitVmLua = class("InitVmLuaScript", require "engine_server.antihack.dynamic_script.check_base")

-- 从VM/luaVm.lua中复制过来的
local VMScript =[[

-- Lua虚拟机实现
-- 用于保护反外挂检测代码，防止明文传输被破解
-- 支持位操作：&(位与)、|(位或)、~(位异或)、<<(左移)、>>(右移)

local function dec2hex(input)
    return string.format('%X', tonumber(input) or 0)
end

local function randString(len)
    local ret = ''
    while (#ret <= len) do
        local byte = MathUtil:randomIntNoRepeat(48, 107, 1)[1]
        if (byte >= 58 and byte <= 83) then
            byte = byte + 7
        elseif (byte >= 84) then
            byte = byte + 13
        end 
        ret = ret .. string.char(byte)
    end 
    return ret
end

local function explode(delim, input)
    if (input == nil) then
        local ret = {}
        for i = 1, #delim do
            table.insert(ret, delim:sub(i, i))
        end 
        return ret
    else
        local cinput, ret, cache = '', {}, ''
        for i = 1, #input do
            cinput = input:sub(i, i)
            if (cinput == delim) then
                table.insert(ret, cache)
                cache = ''
            elseif (cinput ~= '' and cinput ~= ' ') then
                cache = cache .. cinput
            end 
        end 
        if (cache ~= '' and cache ~= ' ') then
            table.insert(ret, cache)
        end 
        return ret
    end
end
--  位操作
local bit32Op = {}

-- 向右旋转函数
function bit32Op.rrotate(n, b)
    local w = bit32Op.band(n, 0xffffffff) -- 确保数字在32位范围内
    b = b % 32 -- 旋转的位数不能超过32
    return bit32Op.bor(bit32Op.lshift(w, b), bit32Op.rshift(w, 32 - b))
end

-- 向左旋转函数
function bit32Op.lrotate(n, b)
    local w = bit32Op.band(n, 0xffffffff) -- 确保数字在32位范围内
    b = b % 32 -- 旋转的位数不能超过32
    local left = bit32Op.lshift(w, b) -- 左移
    local right = bit32Op.rshift(w, 32 - b) -- 右移
    return bit32Op.bor(left, right) -- 合并左移和右移的结果
end

-- 位与操作
function bit32Op.band(a, b)
    return a & b
end

-- 位或操作
function bit32Op.bor(a, b)
    return a | b
end

-- 位异或操作
function bit32Op.bxor(a, b)
    return a ~ b
end

-- 左移操作
function bit32Op.lshift(a, b)
    return a << b
end

-- 右移操作
function bit32Op.rshift(a, b)
    return a >> b
end

local function vmStrDecrypt(input, key)
    if(#input == 0) then return "" end
    if(input == '\\n') then return input end
    local ret, key1Index, key2Index, iv1Index, iv2Index = '', 1, 1, 1, 1
    local key1 = key:sub(1, string.find(key, ':') - 1)
    local key2 = key:sub(string.find(key, ':') + 1)
    local iv1 = input:sub(string.find(input, ';') + 1, string.find(input, ';', string.find(input, ';') + 5) - 1)
    local iv2 = input:sub(string.find(input, ';', string.find(input, ';') + 5) + 1)
    local input = explode(':', input:sub(1, string.find(input, ';') - 1))

    for i = 1, #input do
        local inputByte = tonumber('0x' .. input[i])
        local key1Byte = string.byte(key1:sub(key1Index, key1Index))
        local key2Byte = string.byte(key2:sub(key2Index, key2Index))
        local iv1Byte = string.byte(iv1:sub(iv1Index, iv1Index))
        local iv2Byte = string.byte(iv2:sub(iv2Index, iv2Index))

        local bit32 = bit32Op

        local step7 = bit32.bxor(inputByte, bit32.bxor(bit32.bxor(key2Byte, iv1Byte), iv2Byte))
        --local step6 = bit32.rrotate(step7, 10)
        local step6 = step7
        local step5 = bit32.bxor(step6, (i - 1))
        --local step4 = bit32.rrotate(step5, 10)
        local step4 = step5
        local step3 = bit32.bxor(step4, bit32.bxor(bit32.bxor(key1Byte, iv2Byte), iv1Byte))
        --local step2 = bit32.rrotate(step3, 10)
        local step2 = step3
        local step1 = bit32.bxor(step2, bit32.bxor(bit32.bxor(key2Byte, iv1Byte), iv2Byte))

        ret = ret .. string.char(step1)

        key1Index = key1Index + 1
        if (key1Index >= #key1) then
            key1Index = 1
        end
        key2Index = key2Index + 1
        if (key2Index >= #key2) then
            key2Index = 1
        end
        iv1Index = iv1Index + 1
        if (iv1Index >= #iv1) then
            iv1Index = 1
        end
        iv2Index = iv2Index + 1
        if (iv2Index >= #iv2) then
            iv2Index = 1
        end
    end
    return ret
end

local gVar = _G['Global']
local LuaVM = {}
gVar["LuaVM"] = LuaVM

-- 虚拟机指令集定义
LuaVM.OpCode = {
    -- 基础操作
    NOP = 0,        -- 空操作
    HALT = 1,       -- 停机
    
    -- 数据操作
    LOAD_CONST = 10,    -- 加载常量到栈
    LOAD_VAR = 11,      -- 加载变量到栈
    STORE_VAR = 12,     -- 存储栈顶到变量
    
    -- 栈操作
    PUSH = 20,          -- 压栈
    POP = 21,           -- 出栈
    DUP = 22,           -- 复制栈顶
    SWAP = 23,          -- 交换栈顶两元素
    
    -- 算术运算
    ADD = 30,           -- 加法
    SUB = 31,           -- 减法
    MUL = 32,           -- 乘法
    DIV = 33,           -- 除法
    MOD = 34,           -- 取模
    
    -- 比较操作
    EQ = 40,            -- 相等
    NE = 41,            -- 不等
    LT = 42,            -- 小于
    LE = 43,            -- 小于等于
    GT = 44,            -- 大于
    GE = 45,            -- 大于等于
    
    -- 逻辑操作
    AND = 50,           -- 逻辑与
    OR = 51,            -- 逻辑或
    NOT = 52,           -- 逻辑非
    
    -- 位操作
    BIT_AND = 53,       -- 位与 (&)
    BIT_OR = 54,        -- 位或 (|)
    BIT_XOR = 55,       -- 位异或 (~)
    BIT_NOT = 56,       -- 位取反 (~)
    BIT_LSHIFT = 57,    -- 左移 (<<)
    BIT_RSHIFT = 58,    -- 右移 (>>)
    
    -- 控制流
    JMP = 60,           -- 无条件跳转
    JMP_TRUE = 61,      -- 条件跳转(真)
    JMP_FALSE = 62,     -- 条件跳转(假)
    
    -- 函数调用
    CALL = 70,          -- 调用函数
    RET = 71,           -- 返回
    
    -- 字符串操作
    STR_CONCAT = 80,    -- 字符串连接
    STR_FIND = 81,      -- 字符串查找
    STR_SUB = 82,       -- 字符串截取
    STR_LEN = 83,       -- 字符串长度
    
    -- 表操作
    TBL_NEW = 90,       -- 创建新表
    TBL_GET = 91,       -- 获取表元素
    TBL_SET = 92,       -- 设置表元素
    TBL_LEN = 93,       -- 获取表长度
    LEN = 94,           -- 通用长度（字符串/表）
    
    -- IO操作
    IO_OPEN = 100,      -- 打开文件
    IO_READ = 101,      -- 读取文件
    IO_CLOSE = 102,     -- 关闭文件
    
    -- 函数调用
    FUNC_CALL = 110,    -- 函数调用 (table.func 方式)
    METHOD_CALL = 111,  -- 方法调用 (obj:method 方式)
    LOCAL_FUNC_CALL = 112, -- 本地函数调用
    
    -- 函数定义
    FUNC_DEF = 115,     -- 函数定义
    
    -- 系统调用
    SYS_CALL = 120,     -- 系统调用
    
    -- 迭代器操作
    ITER_INIT = 130,    -- 初始化迭代器
    ITER_NEXT = 131,    -- 获取下一个迭代值
}

function LuaVM:new()
    self:reset()
        -- 指令分发表，避免长elseif链
    self.instructionHandlers = self:buildInstructionHandlers()
    self:initSysCall()
end

function LuaVM:reset()
    self.stack = {}         -- 操作栈
    self.stackTop = 0       -- 栈顶指针，避免使用#操作符
    self.variables = {}     -- 变量表
    self.constants = {}     -- 常量表
    self.functions = {}     -- 函数表
    self.pc = 1            -- 程序计数器
    self.instructions = {} -- 指令序列
    self.callStack = {}    -- 调用栈
    self.running = false   -- 运行状态
    
    -- 性能优化：预分配栈空间
    for i = 1, 1000 do
        self.stack[i] = nil
    end
    
end

-- 加载指令序列
function LuaVM:vmExecute(instructions, constants)
    self:reset()
    self.instructions = instructions or {}
    self.constants = constants or {}
    self.decreptConstants = {}
    self.decreptGloablVariables = {}
    self.pc = 1
    
    -- 性能优化：预解密所有字符串常量
    self:preDecryptConstants()
    
    local success, rt = pcall(self.doExecute, self)
    if not success then
        return "vm error: "..rt
    end
    return rt
end

-- 预解密所有字符串常量，避免运行时解密
function LuaVM:preDecryptConstants()
    -- 方法1: 使用pairs遍历所有键值对（适用于稀疏数组）
    for i, value in pairs(self.constants) do
        if type(i) == "number" then  -- 确保索引是数字
            if type(value) == "string" then
                self.decreptConstants[i] = vmStrDecrypt(value, "string_encode_key")
            else
                self.decreptConstants[i] = value
            end
        end
    end
end

-- 优化的栈操作：使用栈顶指针，避免table.insert/remove
function LuaVM:stackPush(value)
    self.stackTop = self.stackTop + 1
    self.stack[self.stackTop] = value
end

function LuaVM:stackPop()
    if self.stackTop <= 0 then
        return nil
    end
    local value = self.stack[self.stackTop]
    self.stack[self.stackTop] = nil  -- 清理引用，避免内存泄漏
    self.stackTop = self.stackTop - 1
    return value
end

-- 快速获取栈顶元素，不弹出
function LuaVM:stackTopUp()
    if self.stackTop <= 0 then
        return nil
    end
    return self.stack[self.stackTop]
end

-- 优化变量操作：移除nil_proxy机制，直接使用nil
function LuaVM:varGet(index)
    return self.variables[index]
end

function LuaVM:varSet(index, value)
    self.variables[index] = value
end

-- 优化的常量获取：直接返回预解密的值
function LuaVM:constGet(index)
    return self.decreptConstants[index]
end

-- 构建指令处理函数表，提高分发效率
function LuaVM:buildInstructionHandlers()
    local handlers = {}
    
    handlers[self.OpCode.HALT] = function(self, op1, op2)
        self.running = false
    end
    
    handlers[self.OpCode.LOAD_CONST] = function(self, op1, op2)
        self:stackPush(self:constGet(op1))
    end
    
    handlers[self.OpCode.LOAD_VAR] = function(self, op1, op2)
        local value = self:varGet(op1)
        if value == nil and type(op1) == "string" then
            value = self:getGlobalVariable(op1)
        end
        self:stackPush(value)
    end
    
    handlers[self.OpCode.STORE_VAR] = function(self, op1, op2)
        self:varSet(op1, self:stackPop())
    end
    
    handlers[self.OpCode.POP] = function(self, op1, op2)
        self:stackPop()
    end
    
    handlers[self.OpCode.DUP] = function(self, op1, op2)
        local value = self:stackTopUp()
        self:stackPush(value)
    end
    
    -- 算术运算
    handlers[self.OpCode.ADD] = function(self, op1, op2)
        local b = self:stackPop()
        local a = self:stackPop()
        self:stackPush(a + b)
    end
    
    handlers[self.OpCode.SUB] = function(self, op1, op2)
        local b = self:stackPop()
        local a = self:stackPop()
        self:stackPush(a - b)
    end
    
    handlers[self.OpCode.MUL] = function(self, op1, op2)
        local b = self:stackPop()
        local a = self:stackPop()
        self:stackPush(a * b)
    end
    
    handlers[self.OpCode.DIV] = function(self, op1, op2)
        local b = self:stackPop()
        local a = self:stackPop()
        self:stackPush(a / b)
    end
    
    handlers[self.OpCode.MOD] = function(self, op1, op2)
        local b = self:stackPop()
        local a = self:stackPop()
        self:stackPush(a % b)
    end
    
    -- 比较操作
    handlers[self.OpCode.EQ] = function(self, op1, op2)
        local b = self:stackPop()
        local a = self:stackPop()
        self:stackPush(a == b)
    end
    
    handlers[self.OpCode.NE] = function(self, op1, op2)
        local b = self:stackPop()
        local a = self:stackPop()
        self:stackPush(a ~= b)
    end
    
    handlers[self.OpCode.LT] = function(self, op1, op2)
        local b = self:stackPop()
        local a = self:stackPop()
        self:stackPush(a < b)
    end
    
    handlers[self.OpCode.LE] = function(self, op1, op2)
        local b = self:stackPop()
        local a = self:stackPop()
        self:stackPush(a <= b)
    end
    
    handlers[self.OpCode.GT] = function(self, op1, op2)
        local b = self:stackPop()
        local a = self:stackPop()
        self:stackPush(a > b)
    end
    
    handlers[self.OpCode.GE] = function(self, op1, op2)
        local b = self:stackPop()
        local a = self:stackPop()
        self:stackPush(a >= b)
    end
    
    -- 逻辑操作
    handlers[self.OpCode.AND] = function(self, op1, op2)
        local b = self:stackPop()
        local a = self:stackPop()
        self:stackPush(a and b)
    end
    
    handlers[self.OpCode.OR] = function(self, op1, op2)
        local b = self:stackPop()
        local a = self:stackPop()
        self:stackPush(a or b)
    end
    
    handlers[self.OpCode.NOT] = function(self, op1, op2)
        local a = self:stackPop()
        self:stackPush(not a)
    end
    
    -- 位操作
    handlers[self.OpCode.BIT_AND] = function(self, op1, op2)
        local b = self:stackPop()
        local a = self:stackPop()
        self:stackPush(bit32Op.band(a, b))
    end
    
    handlers[self.OpCode.BIT_OR] = function(self, op1, op2)
        local b = self:stackPop()
        local a = self:stackPop()
        self:stackPush(bit32Op.bor(a, b))
    end
    
    handlers[self.OpCode.BIT_XOR] = function(self, op1, op2)
        local b = self:stackPop()
        local a = self:stackPop()
        self:stackPush(bit32Op.bxor(a, b))
    end
    
    handlers[self.OpCode.BIT_NOT] = function(self, op1, op2)
        local a = self:stackPop()
        self:stackPush(bit32Op.bxor(a, 0xffffffff))
    end
    
    handlers[self.OpCode.BIT_LSHIFT] = function(self, op1, op2)
        local b = self:stackPop()
        local a = self:stackPop()
        self:stackPush(bit32Op.lshift(a, b))
    end
    
    handlers[self.OpCode.BIT_RSHIFT] = function(self, op1, op2)
        local b = self:stackPop()
        local a = self:stackPop()
        self:stackPush(bit32Op.rshift(a, b))
    end
    
    -- 跳转指令
    handlers[self.OpCode.JMP] = function(self, op1, op2)
        self.pc = op1 - 1
    end
    
    handlers[self.OpCode.JMP_TRUE] = function(self, op1, op2)
        local condition = self:stackPop()
        if condition then
            self.pc = op1 - 1
        end
    end
    
    handlers[self.OpCode.JMP_FALSE] = function(self, op1, op2)
        local condition = self:stackPop()
        if not condition then
            self.pc = op1 - 1
        end
    end
    
    -- 其他指令保持原有实现...
    handlers[self.OpCode.FUNC_CALL] = function(self, op1, op2)
        self:executeFunctionCall(op1, false, op2)
    end
    
    handlers[self.OpCode.METHOD_CALL] = function(self, op1, op2)
        self:executeFunctionCall(op1, true, op2)
    end
    
    handlers[self.OpCode.LOCAL_FUNC_CALL] = function(self, op1, op2)
        self:executeLocalFunctionCall(op1, op2)
    end
    
    handlers[self.OpCode.SYS_CALL] = function(self, op1, op2)
        self:executeSysCall(op1, op2)
    end
    
    -- 字符串操作
    handlers[self.OpCode.STR_CONCAT] = function(self, op1, op2)
        local b = self:stackPop()
        local a = self:stackPop()
        self:stackPush(tostring(a) .. tostring(b))
    end
    
    handlers[self.OpCode.STR_FIND] = function(self, op1, op2)
        local pattern = self:stackPop()
        local str = self:stackPop()
        local pos = string.find(tostring(str), tostring(pattern))
        self:stackPush(pos)
    end
    
    handlers[self.OpCode.STR_SUB] = function(self, op1, op2)
        local endPos = self:stackPop()
        local startPos = self:stackPop()
        local str = self:stackPop()
        local result = string.sub(tostring(str), startPos, endPos)
        self:stackPush(result)
    end
    
    handlers[self.OpCode.STR_LEN] = function(self, op1, op2)
        local str = self:stackPop()
        self:stackPush(string.len(tostring(str)))
    end
    
    -- 表操作
    handlers[self.OpCode.TBL_NEW] = function(self, op1, op2)
        self:stackPush({})
    end
    
    handlers[self.OpCode.TBL_GET] = function(self, op1, op2)
        local key = self:stackPop()
        local tbl = self:stackPop()
        local value = nil
        if tbl and type(tbl) == "table" then
            value = tbl[key]
        end
        self:stackPush(value)
    end
    
    handlers[self.OpCode.TBL_SET] = function(self, op1, op2)
        local value = self:stackPop()
        local key = self:stackPop()
        local tbl = self:stackPop()
        if tbl and type(tbl) == "table" then
            tbl[key] = value
        end
        self:stackPush(tbl)
    end
    
    handlers[self.OpCode.TBL_LEN] = function(self, op1, op2)
        local tbl = self:stackPop()
        if type(tbl) == "table" then
            self:stackPush(#tbl)
        else
            self:stackPush(nil)
        end
    end
    
    handlers[self.OpCode.LEN] = function(self, op1, op2)
        local v = self:stackPop()
        local t = type(v)
        if t == "string" then
            self:stackPush(string.len(v))
        elseif t == "table" then
            self:stackPush(#v)
        else
            self:stackPush(nil)
        end
    end
    
    -- IO操作
    handlers[self.OpCode.IO_OPEN] = function(self, op1, op2)
        local mode = self:stackPop()
        local filename = self:stackPop()
        local file = io.open(filename, mode)
        self:stackPush(file)
    end
    
    handlers[self.OpCode.IO_READ] = function(self, op1, op2)
        local format = self:stackPop()
        local file = self:stackPop()
        local content = file and file:read(format)
        self:stackPush(content)
    end
    
    handlers[self.OpCode.IO_CLOSE] = function(self, op1, op2)
        local file = self:stackPop()
        if file and file.close then file:close() end
    end
    
    -- 函数定义
    handlers[self.OpCode.FUNC_DEF] = function(self, op1, op2)
        self:defineFunctionCall(self:constGet(op1), self:constGet(op2))
    end
    
    -- 迭代器操作
    handlers[self.OpCode.ITER_INIT] = function(self, op1, op2)
        local iteratorFunc = self:stackPop()
        local iteratorState = self:createIteratorState(iteratorFunc)
        self:stackPush(iteratorState)
    end
    
    handlers[self.OpCode.ITER_NEXT] = function(self, op1, op2)
        local iteratorState = self:stackPop()
        local nextValue = self:getNextIteratorValue(iteratorState)
        self:stackPush(nextValue)
    end
    
    -- 空操作
    handlers[self.OpCode.NOP] = function(self, op1, op2)
        -- 什么都不做
    end
    
    return handlers
end

-- 优化的执行虚拟机：完全使用指令分发表
function LuaVM:doExecute()
    self.running = true
    local result = nil
    local instructions = self.instructions
    local handlers = self.instructionHandlers
    
    while self.running and self.pc <= #instructions do
        local instruction = instructions[self.pc]
        if not instruction then
            break
        end
        
        local opcode = instruction[1]
        local handler = handlers[opcode]
        
        if handler then
            -- 使用分发表直接调用处理函数
            handler(self, instruction[2], instruction[3])
        else
            -- 未知指令错误
            self.running = false
            error("Unknown opcode: " .. tostring(opcode))
        end
        
        self.pc = self.pc + 1
    end
    
    -- 返回栈顶结果
    if self.stackTop > 0 then
        result = self.stack[self.stackTop]
    end
    
    return result
end


-- 执行函数调用
function LuaVM:executeFunctionCall(argCount, isMethodCall, retCount)

        --- 流程跟压入的时候相反
        -- 获取函数名和表/对象
        local tableOrObj = self:stackPop()
        local funcName = self:stackPop()
        -- 收集参数
        local args = {}
        for i = 1, argCount do
            table.insert(args, i, self:stackPop()) -- 逆序收集
        end

        -- 检查表和函数是否存在
        local objType =  type(tableOrObj)
        if objType == "string" then
            table.insert(args, 1, tableOrObj)
            tableOrObj = string
            isMethodCall = false
        elseif not tableOrObj or  (objType ~= "table" and objType ~= "userdata") then
            error("error func: " .. tostring(funcName))
        end
        
        local func = tableOrObj[funcName]
        if not func or type(func) ~= "function" then
            error("error func: " .. tostring(funcName))
        end
        
        -- 执行函数调用
        local result1 = nil
        local result2 = nil
        if isMethodCall then
            -- 方法调用，第一个参数是对象本身
            result1, result2 = func(tableOrObj, unpack(args))
        else
            -- 普通函数调用
            result1, result2 = func(unpack(args))
        end
        
        -- 将结果压栈
        if retCount == 1 then
            self:stackPush( result1)
        elseif retCount == 2 then
            self:stackPush( result2)
            self:stackPush( result1)
        end
end

-- 执行本地函数调用
function LuaVM:executeLocalFunctionCall(argCount, retCount)
        -- 查找函数定义
        local funcName = self:stackPop()
        local funcDef = self.functions[funcName]
        if not funcDef then
            error("error func local: " .. tostring(funcName))
        end
        
        -- 保存当前状态
        local savedPC = self.pc
        local savedVars = {}
        
        -- 此时堆栈上应该是函数的参数。函数的前面指令会加载参数到变量里面
        -- 跳转到函数体
        self.pc = funcDef[1]

        --保存变量表
        local tempVarList = self.variables
        self.variables = {}
        --print("tempVarList 111: " .. StringUtil.v2s(self.variables))
        -- 执行函数体直到遇到RETURN或函数结束
        local result = nil
        local handlers = self.instructionHandlers
        
        while self.pc <= funcDef[2] and self.running do
            local instruction = self.instructions[self.pc]
            if not instruction then break end
            
            local opcode = instruction[1]
            if opcode == self.OpCode.HALT then
                -- 函数返回
                if self.stackTop > 0 then
                    result = self:stackPop()
                end
                break
            end
            
            -- 使用指令分发表执行指令
            local handler = handlers[opcode]
            if handler then
                handler(self, instruction[2], instruction[3])
            else
                self.running = false
                error("Unknown opcode in local function: " .. tostring(opcode))
            end

            self.pc = self.pc + 1
        end
  
        
        -- 恢复PC
        self.pc = savedPC
        self.variables = tempVarList
        --print("tempVarList : " .. StringUtil.v2s(self.variables))
        
        -- 将结果压栈 -- 只支持返回 0个 或者 一个结果
        if retCount ~=0 then
            self:stackPush(result)
        end
end

-- 定义函数
function LuaVM:defineFunctionCall(funcName, funcData)
    self.functions[funcName] = funcData
end

function LuaVM:initSysCall()
    self.sysCallTable = {}
    self.sysCallTable["print"] = function(self, args)
        print(unpack(args))
    end
    self.sysCallTable["tostring"] = function(self, args)
        return tostring(args[1])
    end
    self.sysCallTable["tonumber"] = function(self, args)
        return tonumber(args[1])
    end
    self.sysCallTable["type"] = function(self, args)
        return type(args[1])
    end
    self.sysCallTable["string.find"] = function(self, args)
        return string.find(args[1], args[2])
    end
    self.sysCallTable["string.sub"] = function(self, args)
        return string.sub(args[1], args[2], args[3])
    end
    self.sysCallTable["string.len"] = function(self, args)
        return string.len(args[1])
    end

    self.sysCallTable["next"] = function (self, args)
        return  next(args[1], args[2])
    end

    self.sysCallTable["split"] = function (self, args)
        return self:splitProcInfo(args[1], args[2], args[3])
    end

end

-- 执行系统调用
function LuaVM:executeSysCall(argCount, retCount)
    local funcName = self:stackPop()
    local args = {}
    for i = 1, argCount or 0 do
        table.insert(args, i, self:stackPop()) -- 逆序收集
    end
    
    local result1 = nil
    local result2 = nil
    -- 系统调用白名单
    local func = self.sysCallTable[funcName]
    if func then 
        result1, result2 = func(self, args)
    end
    
    if retCount ==1 then
        self:stackPush(result1)
    elseif retCount == 2 then
        self:stackPush(result2)
        self:stackPush(result1)
    end
end

function LuaVM:splitProcInfo(info, taga, tagb)
    local lines = StringUtil.split(info, "\n")
    local result = {}
    for i, v in pairs(lines) do
        if string.find(v, taga) or string.find(v, tagb) then
            table.insert(result, v)
        end
    end
    return result
end

-- 优化的全局变量获取：预计算和缓存
function LuaVM:getGlobalVariable(name)
    if name == "_G" then
        return _G
    end
    
    -- 使用缓存避免重复解密
    local decName = self.decreptGloablVariables[name]
    if not decName then
        decName = vmStrDecrypt(name, "string_encode_key")
        self.decreptGloablVariables[name] = decName
    end
    
    return _G[decName]
end

-- 创建迭代器状态
function LuaVM:createIteratorState(iteratorFunc)
    if type(iteratorFunc) == "function" then
        -- 对于函数类型的迭代器，创建状态对象
        return {
            type = "function_iterator",
            func = iteratorFunc,
            finished = false
        }
    else
        -- 对于其他类型，尝试作为表处理
        return {
            type = "table_iterator", 
            data = iteratorFunc,
            finished = true  -- 非函数类型直接标记为结束
        }
    end
end

-- 获取下一个迭代值
function LuaVM:getNextIteratorValue(iteratorState)
    if not iteratorState or iteratorState.finished then
        return nil
    end
    
    if iteratorState.type == "function_iterator" then
        -- 调用迭代器函数获取下一个值
        local success, result = pcall(iteratorState.func)
        if success and result ~= nil then
            return result
        else
            iteratorState.finished = true
            return nil
        end
    else
        -- 其他类型的迭代器
        iteratorState.finished = true
        return nil
    end
end

LuaVM:new()

return "ok"
]]
function InitVmLua:getContent()
    local CodeEncoder = T(Global, "CodeEncoder")
    return CodeEncoder:encodeLua(VMScript)
end

function InitVmLua:getReportHackInfo()
    local HackReport = T(Global, "HackReport", nil)
    return HackReport.actionType.useOldClientLua, self.hackDesc
end

function InitVmLua:needKickoutPlayer()
    local AntiHackConfig = T(Global, "AntiHackConfig")
    if AntiHackConfig:getConfig().kickOutOldClientLua then 
        return true
    end
    return false
end

function InitVmLua:onReciveResult(playerId, result)
    self.super:onReciveResult(playerId, result)
    return false
end

function InitVmLua:onSend(playerId, id)
   self.super:onSend(playerId, id)
end

return InitVmLua--[[p88pYbxBhY8Oj]]---