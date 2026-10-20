-- 真正的Lua到虚拟机指令转换器
-- 严格按照需求：解析Lua脚本并转换为虚拟机指令

local RealLuaToVMConverter = class("RealLuaToVMConverter")
local LuaVM = T(Global, "LuaVM")
function RealLuaToVMConverter:ctor()
    self:reset()
end

-- 解析一元表达式（支持 not, ~, #，右结合）
function RealLuaToVMConverter:parseUnaryExpression(tokens, i)
    if i <= #tokens and tokens[i].type == "keyword" and tokens[i].value == "not" then
        local expr, nextI = self:parseUnaryExpression(tokens, i + 1)
        return { type = "unary_operation", operator = "not", expression = expr }, nextI
    elseif i <= #tokens and tokens[i].type == "operator" and tokens[i].value == "#" then
        local expr, nextI = self:parseUnaryExpression(tokens, i + 1)
        return { type = "unary_operation", operator = "#", expression = expr }, nextI
    elseif i <= #tokens and tokens[i].type == "operator" and tokens[i].value == "~" then
        local expr, nextI = self:parseUnaryExpression(tokens, i + 1)
        return { type = "unary_operation", operator = "~", expression = expr }, nextI
    end
    return self:parsePrimaryExpression(tokens, i)
end

function RealLuaToVMConverter:reset()
    self.instructions = {}
    self.constants = {}
    self.constantMap = {}
    self.variables = {}
    self.localFunctions = {}  -- 本地函数列表
    self.nextConstId = 1
    self.nextVarId = 1
    self.currentLine = 1
end

-- 支持的语法限制说明：
-- 1. 变量声明：local var = value 或 var = value
-- 2. 函数调用：func(arg1, arg2, ...)
-- 3. 表操作：{}, table[key], table.key
-- 4. 字符串操作：string.find, string.sub, string.len等
-- 5. 数学运算：+, -, *, /, %
-- 6. 比较运算：==, ~=, <, >, <=, >=
-- 7. 逻辑运算：and, or, not
-- 8. 位运算：&(位与), |(位或), ~(位异或/位取反), <<(左移), >>(右移)
-- 9. 条件语句：if condition then ... end
-- 10. 循环语句：for i=1,10 do ... end, for k,v in pairs(t) do ... end
-- 11. return语句：return value

-- 主转换入口
function RealLuaToVMConverter:convertScript(luaCode)
    self:reset()
    
    -- 词法分析：将代码分解为token
    local tokens = self:tokenize(luaCode)
    
    -- 语法分析：构建AST
    local ast = self:parse(tokens)
    
    -- 代码生成：转换为虚拟机指令
    self:generateCode(ast)
    
    return {
        instructions = self.instructions,
        constants = self.constants,
        variables = self.variables
    }
end

-- 词法分析器
function RealLuaToVMConverter:tokenize(code)
    local tokens = {}
    local i = 1
    
    -- 移除注释
    code = code:gsub("%-%-[^\r\n]*", "")
    code = code:gsub("%-%-%[%[.-%]%]", "")
    
    while i <= #code do
        local char = code:sub(i, i)
        
        -- 跳过空白字符
        if char:match("%s") then
            i = i + 1
            
        -- 字符串字面量
        elseif char == '"' or char == "'" then
            local quote = char
            local str = ""
            i = i + 1
            while i <= #code and code:sub(i, i) ~= quote do
                str = str .. code:sub(i, i)
                i = i + 1
            end
            i = i + 1 -- 跳过结束引号
            table.insert(tokens, {type = "string", value = str})
            
        -- 数字字面量
        elseif char:match("%d") then
            local num = ""
            -- 检查是否是十六进制数字 (0x 或 0X)
            if char == "0" and i + 1 <= #code then
                local nextChar = code:sub(i + 1, i + 1)
                if nextChar == "x" or nextChar == "X" then
                    -- 十六进制数字
                    num = num .. char .. nextChar
                    i = i + 2
                    while i <= #code and code:sub(i, i):match("[%da-fA-F]") do
                        num = num .. code:sub(i, i)
                        i = i + 1
                    end
                    table.insert(tokens, {type = "number", value = tonumber(num)})
                else
                    -- 普通十进制数字
                    while i <= #code and code:sub(i, i):match("[%d%.]") do
                        num = num .. code:sub(i, i)
                        i = i + 1
                    end
                    table.insert(tokens, {type = "number", value = tonumber(num)})
                end
            else
                -- 普通十进制数字
                while i <= #code and code:sub(i, i):match("[%d%.]") do
                    num = num .. code:sub(i, i)
                    i = i + 1
                end
                table.insert(tokens, {type = "number", value = tonumber(num)})
            end
            
        -- 标识符和关键字
        elseif char:match("[%a_]") then
            local ident = ""
            while i <= #code and code:sub(i, i):match("[%w_]") do
                ident = ident .. code:sub(i, i)
                i = i + 1
            end
            
            -- 检查是否是关键字
            -- 检查是否是关键字
            local keywords = {
                ["local"] = true, ["if"] = true, ["then"] = true, ["else"] = true,['elseif'] = true,
                ["end"] = true, ["for"] = true, ["do"] = true, ["while"] = true, ["break"] = true,
                ["function"] = true, ["return"] = true, ["true"] = true, ["false"] = true,
                ["nil"] = true, ["and"] = true, ["or"] = true, ["not"] = true, ["self"] = true,
                ["in"] = true, ["pairs"] = true, ["ipairs"] = true, ["goto"] = true,
                ["continue"] = true, ["until"] = true, ["repeat"] = true,["unpack"] = true,
                ["error"] = true
            }
            
            if keywords[ident] then
                table.insert(tokens, {type = "keyword", value = ident})
            else
                table.insert(tokens, {type = "identifier", value = ident})
            end
            
        -- 运算符和符号
        elseif char == "=" then
            if i < #code and code:sub(i+1, i+1) == "=" then
                table.insert(tokens, {type = "operator", value = "=="})
                i = i + 2
            else
                table.insert(tokens, {type = "operator", value = "="})
                i = i + 1
            end
            
        elseif char == "~" then
            if i < #code and code:sub(i+1, i+1) == "=" then
                table.insert(tokens, {type = "operator", value = "~="})
                i = i + 2
            else
                table.insert(tokens, {type = "operator", value = "~"})
                i = i + 1
            end
            
        elseif char == "<" then
            if i < #code and code:sub(i+1, i+1) == "=" then
                table.insert(tokens, {type = "operator", value = "<="})
                i = i + 2
            elseif i < #code and code:sub(i+1, i+1) == "<" then
                table.insert(tokens, {type = "operator", value = "<<"})
                i = i + 2
            else
                table.insert(tokens, {type = "operator", value = "<"})
                i = i + 1
            end
            
        elseif char == ">" then
            if i < #code and code:sub(i+1, i+1) == "=" then
                table.insert(tokens, {type = "operator", value = ">="})
                i = i + 2
            elseif i < #code and code:sub(i+1, i+1) == ">" then
                table.insert(tokens, {type = "operator", value = ">>"})
                i = i + 2
            else
                table.insert(tokens, {type = "operator", value = ">"})
                i = i + 1
            end
            
        elseif char == "-" then
            -- 检查是否是负数
            if i + 1 <= #code then
                local nextChar = code:sub(i + 1, i + 1)
                -- 判断是否应该解析为负数：下一个字符是数字，且前面不是数字、标识符或右括号
                local shouldBeNegativeNumber = nextChar:match("%d") and self:shouldParseAsNegativeNumber(tokens)
                
                if shouldBeNegativeNumber then
                    -- 解析负数
                    local num = "-"
                    i = i + 1 -- 跳过减号
                    local digitChar = code:sub(i, i)
                    
                    -- 检查是否是十六进制数字 (0x 或 0X)
                    if digitChar == "0" and i + 1 <= #code then
                        local nextChar2 = code:sub(i + 1, i + 1)
                        if nextChar2 == "x" or nextChar2 == "X" then
                            -- 负十六进制数字
                            num = num .. digitChar .. nextChar2
                            i = i + 2
                            while i <= #code and code:sub(i, i):match("[%da-fA-F]") do
                                num = num .. code:sub(i, i)
                                i = i + 1
                            end
                            table.insert(tokens, {type = "number", value = tonumber(num)})
                        else
                            -- 负十进制数字
                            while i <= #code and code:sub(i, i):match("[%d%.]") do
                                num = num .. code:sub(i, i)
                                i = i + 1
                            end
                            table.insert(tokens, {type = "number", value = tonumber(num)})
                        end
                    else
                        -- 负十进制数字
                        while i <= #code and code:sub(i, i):match("[%d%.]") do
                            num = num .. code:sub(i, i)
                            i = i + 1
                        end
                        table.insert(tokens, {type = "number", value = tonumber(num)})
                    end
                else
                    -- 作为减法运算符处理
                    table.insert(tokens, {type = "operator", value = char})
                    i = i + 1
                end
            else
                -- 行末的减号，作为运算符处理
                table.insert(tokens, {type = "operator", value = char})
                i = i + 1
            end
            
        elseif char:match("[%+%*/%%]") then
            table.insert(tokens, {type = "operator", value = char})
            i = i + 1
            
        elseif char == "&" then
            table.insert(tokens, {type = "operator", value = "&"})
            i = i + 1
            
        elseif char == "|" then
            table.insert(tokens, {type = "operator", value = "|"})
            i = i + 1
            
        elseif char == "#" then
            table.insert(tokens, {type = "operator", value = "#"})
            i = i + 1
            
        elseif char:match("[%(%)%{%}%[%]]") then
            table.insert(tokens, {type = "delimiter", value = char})
            i = i + 1
            
        elseif char == "," then
            table.insert(tokens, {type = "comma", value = ","})
            i = i + 1
            
        elseif char == "." then
            -- 支持字符串连接操作符 .. 与属性访问 . 的区分
            if i < #code and code:sub(i+1, i+1) == "." then
                table.insert(tokens, {type = "operator", value = ".."})
                i = i + 2
            else
                table.insert(tokens, {type = "dot", value = "."})
                i = i + 1
            end
            
        elseif char == ":" then
            table.insert(tokens, {type = "colon", value = ":"})
            i = i + 1
            
        else
            i = i + 1 -- 跳过未知字符
        end
    end
    
    return tokens
end

-- 判断减号是否应该被解析为负数的一部分
function RealLuaToVMConverter:shouldParseAsNegativeNumber(tokens)
    if #tokens == 0 then
        return true -- 代码开始处的减号应该是负数
    end
    
    local lastToken = tokens[#tokens]
    
    -- 如果前一个token是以下类型之一，则减号应该被解析为负数：
    -- 运算符（除了右括号类的）、关键字（如return, =等）、逗号、左括号等
    if lastToken.type == "operator" or 
       lastToken.type == "keyword" or 
       lastToken.type == "comma" or
       (lastToken.type == "delimiter" and lastToken.value:match("[%(%{%[]")) then
        return true
    end
    
    -- 如果前一个token是数字、标识符或右括号，则减号应该是减法运算符
    if lastToken.type == "number" or 
       lastToken.type == "identifier" or
       (lastToken.type == "delimiter" and lastToken.value:match("[%)%}%]]")) then
        return false
    end
    
    -- 默认情况下解析为负数
    return true
end

-- 语法分析器
function RealLuaToVMConverter:parse(tokens)
    local ast = {type = "chunk", statements = {}}
    local i = 1
    
    while i <= #tokens do
        local stmt, nextI = self:parseStatement(tokens, i)
        if stmt then
            table.insert(ast.statements, stmt)
        end
        i = nextI
    end
    
    return ast
end

-- 解析语句
function RealLuaToVMConverter:parseStatement(tokens, i)
    if i > #tokens then
        return nil, i
    end
    
    local token = tokens[i]
    
    -- local 变量声明
    if token.type == "keyword" and token.value == "local"  then
        if (i + 1 <= #tokens and tokens[i+1].type == "keyword" and tokens[i+1].value == "function") then
                return self:parseLocalFunctionDefinition(tokens, i)
           else
                return self:parseLocalAssignment(tokens, i)
           end
    -- 变量赋值 a = ...
    elseif token.type == "identifier" and i + 1< #tokens and tokens[i+1].type == "operator" and tokens[i+1].value == "=" then
        return self:parseAssignment(tokens, i)
    --表 a[b]=..赋值
    elseif token.type == "identifier" and i +1 < #tokens and tokens[i+1].type == "delimiter" and tokens[i+1].value == "[" then 
        return self:parseAssignment(tokens, i)
    --表 a.b = aa赋值
    elseif token.type == "identifier" and i< #tokens and i + 1 < #tokens and tokens[i+1].type == "dot" and tokens[i+3].value == "=" then 
        return self:parseAssignment(tokens, i)
    -- if语句
    elseif token.type == "keyword" and token.value == "if" then
        return self:parseIfStatement(tokens, i)
        
    -- for循环
    elseif token.type == "keyword" and token.value == "for" then
        return self:parseForStatement(tokens, i)
        
    -- while循环
    elseif token.type == "keyword" and token.value == "while" then
        return self:parseWhileStatement(tokens, i)
        
    -- return语句
    elseif token.type == "keyword" and token.value == "return" then
        return self:parseReturnStatement(tokens, i)
        
    -- 函数调用语句
    elseif token.type == "identifier" then
        local expr, nextI = self:parseExpression(tokens, i)
        if expr and expr.type == "function_call" then
            return {type = "expression_statement", expression = expr}, nextI
        end
        return nil, nextI
        
    else
        return nil, i + 1
    end
end

-- 解析local赋值
function RealLuaToVMConverter:parseLocalAssignment(tokens, i)
    -- 支持：
    -- 1) local a = expr
    -- 2) local a, b = expr1, expr2
    if i + 1 <= #tokens and tokens[i].value == "local" and tokens[i+1].type == "identifier" then
        -- 检查是否为两个变量
        if i + 2 <= #tokens and tokens[i+2].type == "comma" then
            -- local a, b = expr
            if i + 3 <= #tokens and tokens[i+3].type == "identifier" and i + 4 <= #tokens and tokens[i+4].value == "=" then
                local var1 = tokens[i+1].value
                local var2 = tokens[i+3].value
                -- 解析右侧表达式
                local expr1, nextI = self:parseExpression(tokens, i+5)
                return {
                    type = "local_assignment",
                    variable = { var1 = var1, var2 = var2 },
                    expression = expr1
                }, nextI
            else
                error("invalid local assignment", tokens[i].value)
            end
        elseif i + 2 <= #tokens and tokens[i+2].value == "=" then
            -- local a = expr
            local varName = tokens[i+1].value
            local expr, nextI = self:parseExpression(tokens, i+3)
            return {
                type = "local_assignment",
                variable = {var1 = varName, var2 = nil},
                expression = expr
            }, nextI
        else
            error("invalid local assignment 2", tokens[i].value)
        end
    end
    return nil, i + 1
end

-- 解析赋值
function RealLuaToVMConverter:parseAssignment(tokens, i)
    -- var = expr 或 table[key] = expr 或 table.key = expr
    local varName = tokens[i].value
    local nextI = i + 2 -- 跳过 var =
    
    -- 检查是否是表赋值
    if i + 1 < #tokens and tokens[i+1].type == "delimiter" and tokens[i+1].value == "[" then
        -- table[key] = expr
        local key, keyNextI = self:parseExpression(tokens, i+2)
        if keyNextI <= #tokens and tokens[keyNextI].value == "]" and 
           keyNextI + 1 <= #tokens and tokens[keyNextI + 1].value == "=" then
            local expr, exprNextI = self:parseExpression(tokens, keyNextI + 2)
            return {
                type = "table_assignment",
                table = varName,
                key = key,
                expression = expr
            }, exprNextI
        end
    elseif i + 1 < #tokens and tokens[i+1].type == "dot" then
        -- table.key = expr
        if i + 2 < #tokens and tokens[i+2].type == "identifier" and
           i + 3 <= #tokens and tokens[i+3].value == "=" then
            local key = tokens[i+2].value
            local expr, exprNextI = self:parseExpression(tokens, i+4)
            return {
                type = "table_assignment",
                table = varName,
                key = {type = "string_literal", value = key},
                expression = expr
            }, exprNextI
        end
    end
    
    -- 普通变量赋值
    -- 是否是多变量赋值
    -- 多变量赋值 a, b = ...
    local var2 = nil
    if i + 1 <= #tokens and tokens[i+1].type == "comma" then
        if i + 2 <= #tokens and tokens[i+2].type == "identifier" then
            var2 = tokens[i+2].value
            nextI = i + 4 -- 调过 =
        end
    end

    local expr, exprNextI = self:parseExpression(tokens, nextI)
    return {
        type = "assignment",
        variable =   {var1 = varName, var2 = var2},
        expression = expr
    }, exprNextI
end


-- 解析if语句
function RealLuaToVMConverter:parseIfStatement(tokens, i)
    -- if condition then statements end
    local condition, condNextI = self:parseExpression(tokens, i + 1)
    
    -- 查找then
    local thenI = condNextI
    while thenI <= #tokens and not (tokens[thenI].type == "keyword" and tokens[thenI].value == "then") do
        thenI = thenI + 1
    end
    
    if thenI > #tokens then
        return nil, i + 1
    end
    
    -- 解析then部分的语句
    local thenStatements = {}
    local stmtI = thenI + 1
    while stmtI <= #tokens and 
          not (tokens[stmtI].type == "keyword" and (tokens[stmtI].value == "else" or tokens[stmtI].value == "end")) do
        local stmt, nextI = self:parseStatement(tokens, stmtI)
        if stmt then
            table.insert(thenStatements, stmt)
        end
        stmtI = nextI
    end
    
    -- 检查是否有else分支
    local elseStatements = {}
    if stmtI <= #tokens and tokens[stmtI].type == "keyword" and tokens[stmtI].value == "else" then
        -- 解析else部分的语句
        stmtI = stmtI + 1 -- 跳过else关键字
        while stmtI <= #tokens and not (tokens[stmtI].type == "keyword" and tokens[stmtI].value == "end") do
            local stmt, nextI = self:parseStatement(tokens, stmtI)
            if stmt then
                table.insert(elseStatements, stmt)
            end
            stmtI = nextI
        end
    end
    
    return {
        type = "if_statement",
        condition = condition,
        then_statements = thenStatements,
        else_statements = elseStatements
    }, stmtI + 1
end

-- 解析for语句
function RealLuaToVMConverter:parseForStatement(tokens, i)
    -- for i=1,10 do ... end 或 for k,v in pairs(t) do ... end
    if i + 2 <= #tokens and tokens[i+2].value == "=" then
        -- 数值for循环
        local var = tokens[i+1].value
        local start, startNextI = self:parseExpression(tokens, i+3)
        
        -- 查找逗号
        local commaI = startNextI
        while commaI <= #tokens and tokens[commaI].type ~= "comma" do
            commaI = commaI + 1
        end
        
        if commaI > #tokens then
            return nil, i + 1
        end
        
        local stop, stopNextI = self:parseExpression(tokens, commaI + 1)
        
        -- 查找do
        local doI = stopNextI
        while doI <= #tokens and not (tokens[doI].type == "keyword" and tokens[doI].value == "do") do
            doI = doI + 1
        end
        
        -- 解析循环体
        local statements = {}
        local stmtI = doI + 1
        while stmtI <= #tokens and not (tokens[stmtI].type == "keyword" and tokens[stmtI].value == "end") do
            local stmt, nextI = self:parseStatement(tokens, stmtI)
            if stmt then
                table.insert(statements, stmt)
            end
            stmtI = nextI
        end
        
        return {
            type = "for_numeric",
            variable = var,
            start = start,
            stop = stop,
            statements = statements
        }, stmtI + 1
    end
    
    -- 泛型for：for k, v in pairs(t) do ... end
    -- 仅支持 pairs(t) 形式（需求所述）
    if i + 1 <= #tokens and tokens[i+1].type == "identifier" then
        local var1 = tokens[i+1].value
        local nextI = i + 2
        local var2 = nil
        if nextI <= #tokens and tokens[nextI].type == "comma" then
            if nextI + 1 <= #tokens and tokens[nextI + 1].type == "identifier" then
                var2 = tokens[nextI + 1].value
                nextI = nextI + 2
            else
                return nil, i + 1
            end
        end

        -- 期望关键字 in
        if nextI <= #tokens and tokens[nextI].type == "keyword" and tokens[nextI].value == "in" then
            nextI = nextI + 1

            -- 支持 pairs/ipairs 以及任意函数调用作为迭代器
            if nextI <= #tokens and tokens[nextI].type == "keyword" and (tokens[nextI].value == "pairs" or tokens[nextI].value == "ipairs") then
                local iteratorKw = tokens[nextI].value
                nextI = nextI + 1
                -- 左括号
                if nextI <= #tokens and tokens[nextI].type == "delimiter" and tokens[nextI].value == "(" then
                    -- 解析表达式作为被迭代表
                    local tableExpr, tableNextI = self:parseExpression(tokens, nextI + 1)
                    -- 右括号
                    if tableNextI <= #tokens and tokens[tableNextI].type == "delimiter" and tokens[tableNextI].value == ")" then
                        nextI = tableNextI + 1
                    else
                        nextI = tableNextI
                    end

                    -- 查找 do
                    local doI = nextI
                    while doI <= #tokens and not (tokens[doI].type == "keyword" and tokens[doI].value == "do") do
                        doI = doI + 1
                    end
                    if doI > #tokens then
                        return nil, i + 1
                    end

                    -- 解析循环体直到 end
                    local statements = {}
                    local stmtI = doI + 1
                    while stmtI <= #tokens and not (tokens[stmtI].type == "keyword" and tokens[stmtI].value == "end") do
                        local stmt, sNext = self:parseStatement(tokens, stmtI)
                        if stmt then
                            table.insert(statements, stmt)
                        end
                        stmtI = sNext
                    end

                    return {
                        type = "for_generic",
                        var1 = var1,
                        var2 = var2,
                        iterator = iteratorKw, -- "pairs" 或 "ipairs"
                        tableExpr = tableExpr,
                        statements = statements
                    }, stmtI + 1
                end
            elseif nextI <= #tokens and tokens[nextI].type == "identifier" then
                -- 支持任意函数调用作为迭代器：for file in lfs.dir(path) do
                local iteratorExpr, iterNextI = self:parseExpression(tokens, nextI)
                
                -- 查找 do
                local doI = iterNextI
                while doI <= #tokens and not (tokens[doI].type == "keyword" and tokens[doI].value == "do") do
                    doI = doI + 1
                end
                if doI > #tokens then
                    return nil, i + 1
                end

                -- 解析循环体直到 end
                local statements = {}
                local stmtI = doI + 1
                while stmtI <= #tokens and not (tokens[stmtI].type == "keyword" and tokens[stmtI].value == "end") do
                    local stmt, sNext = self:parseStatement(tokens, stmtI)
                    if stmt then
                        table.insert(statements, stmt)
                    end
                    stmtI = sNext
                end

                return {
                    type = "for_iterator",
                    var1 = var1,
                    var2 = var2,
                    iteratorExpr = iteratorExpr, -- 任意迭代器表达式
                    statements = statements
                }, stmtI + 1
            end
        end
    end
    
    return nil, i + 1
end

-- 解析while语句
function RealLuaToVMConverter:parseWhileStatement(tokens, i)
    -- while condition do statements end
    local condition, condNextI = self:parseExpression(tokens, i + 1)
    
    -- 查找do
    local doI = condNextI
    while doI <= #tokens and not (tokens[doI].type == "keyword" and tokens[doI].value == "do") do
        doI = doI + 1
    end
    
    if doI > #tokens then
        return nil, i + 1
    end
    
    -- 解析循环体
    local statements = {}
    local stmtI = doI + 1
    while stmtI <= #tokens and not (tokens[stmtI].type == "keyword" and tokens[stmtI].value == "end") do
        local stmt, nextI = self:parseStatement(tokens, stmtI)
        if stmt then
            table.insert(statements, stmt)
        end
        stmtI = nextI
    end
    
    return {
        type = "while_statement",
        condition = condition,
        statements = statements
    }, stmtI + 1
end

-- 解析return语句
function RealLuaToVMConverter:parseReturnStatement(tokens, i)
    if i + 1 <= #tokens then
        local expr, nextI = self:parseExpression(tokens, i + 1)
        return {
            type = "return_statement",
            expression = expr
        }, nextI
    else
        return {
            type = "return_statement",
            expression = nil
        }, i + 1
    end
end

-- 解析本地函数定义
function RealLuaToVMConverter:parseLocalFunctionDefinition(tokens, i)
    -- local function name(params) body end
    local funcName = tokens[i + 2].value -- 跳过 local function
    local nextI = i + 3
    
    -- 解析参数列表
    local params = {}
    if nextI <= #tokens and tokens[nextI].type == "delimiter" and tokens[nextI].value == "(" then
        nextI = nextI + 1 -- 跳过 (
        
        while nextI <= #tokens and not (tokens[nextI].type == "delimiter" and tokens[nextI].value == ")") do
            if tokens[nextI].type == "identifier" then
                table.insert(params, tokens[nextI].value)
                nextI = nextI + 1
                
                -- 跳过逗号
                if nextI <= #tokens and tokens[nextI].type == "delimiter" and tokens[nextI].value == "," then
                    nextI = nextI + 1
                end
            else
                nextI = nextI + 1
            end
        end
        
        if nextI <= #tokens and tokens[nextI].type == "delimiter" and tokens[nextI].value == ")" then
            nextI = nextI + 1 -- 跳过 )
        end
    end
    
    -- 解析函数体
    local body = {type = "chunk", statements = {}}
    while nextI <= #tokens do
        if tokens[nextI].type == "keyword" and tokens[nextI].value == "end" then
            nextI = nextI + 1 -- 跳过 end
            break
        end
        
        local stmt, stmtNextI = self:parseStatement(tokens, nextI)
        if stmt then
            table.insert(body.statements, stmt)
        end
        nextI = stmtNextI
    end
    
    return {
        type = "local_function_definition",
        name = funcName,
        params = params,
        body = body
    }, nextI
end

-- 解析表达式
function RealLuaToVMConverter:parseExpression(tokens, i)
    return self:parseOrExpression(tokens, i)
end

-- 解析or表达式
function RealLuaToVMConverter:parseOrExpression(tokens, i)
    local left, nextI = self:parseAndExpression(tokens, i)
    
    while nextI <= #tokens and tokens[nextI].type == "keyword" and tokens[nextI].value == "or" do
        local right, rightNextI = self:parseAndExpression(tokens, nextI + 1)
        left = {
            type = "binary_operation",
            operator = "or",
            left = left,
            right = right
        }
        nextI = rightNextI
    end
    
    return left, nextI
end

-- 解析and表达式
function RealLuaToVMConverter:parseAndExpression(tokens, i)
    local left, nextI = self:parseComparisonExpression(tokens, i)
    
    while nextI <= #tokens and tokens[nextI].type == "keyword" and tokens[nextI].value == "and" do
        local right, rightNextI = self:parseComparisonExpression(tokens, nextI + 1)
        left = {
            type = "binary_operation",
            operator = "and",
            left = left,
            right = right
        }
        nextI = rightNextI
    end
    
    return left, nextI
end

-- 解析比较表达式
function RealLuaToVMConverter:parseComparisonExpression(tokens, i)
    local left, nextI = self:parseBitwiseOrExpression(tokens, i)
    
    while nextI <= #tokens and tokens[nextI].type == "operator" and 
          (tokens[nextI].value == "==" or tokens[nextI].value == "~=" or
           tokens[nextI].value == "<" or tokens[nextI].value == ">" or
           tokens[nextI].value == "<=" or tokens[nextI].value == ">=") do
        
        local op = tokens[nextI].value
        local right, rightNextI = self:parseBitwiseOrExpression(tokens, nextI + 1)
        left = {
            type = "binary_operation",
            operator = op,
            left = left,
            right = right
        }
        nextI = rightNextI
    end
    
    return left, nextI
end

-- 解析位或表达式 (|)
function RealLuaToVMConverter:parseBitwiseOrExpression(tokens, i)
    local left, nextI = self:parseBitwiseXorExpression(tokens, i)
    
    while nextI <= #tokens and tokens[nextI].type == "operator" and tokens[nextI].value == "|" do
        local right, rightNextI = self:parseBitwiseXorExpression(tokens, nextI + 1)
        left = {
            type = "binary_operation",
            operator = "|",
            left = left,
            right = right
        }
        nextI = rightNextI
    end
    
    return left, nextI
end

-- 解析位异或表达式 (~)
function RealLuaToVMConverter:parseBitwiseXorExpression(tokens, i)
    local left, nextI = self:parseBitwiseAndExpression(tokens, i)
    
    while nextI <= #tokens and tokens[nextI].type == "operator" and tokens[nextI].value == "~" do
        local right, rightNextI = self:parseBitwiseAndExpression(tokens, nextI + 1)
        left = {
            type = "binary_operation",
            operator = "~",
            left = left,
            right = right
        }
        nextI = rightNextI
    end
    
    return left, nextI
end

-- 解析位与表达式 (&)
function RealLuaToVMConverter:parseBitwiseAndExpression(tokens, i)
    local left, nextI = self:parseBitwiseShiftExpression(tokens, i)
    
    while nextI <= #tokens and tokens[nextI].type == "operator" and tokens[nextI].value == "&" do
        local right, rightNextI = self:parseBitwiseShiftExpression(tokens, nextI + 1)
        left = {
            type = "binary_operation",
            operator = "&",
            left = left,
            right = right
        }
        nextI = rightNextI
    end
    
    return left, nextI
end

-- 解析位移表达式 (<<, >>)
function RealLuaToVMConverter:parseBitwiseShiftExpression(tokens, i)
    local left, nextI = self:parseConcatExpression(tokens, i)
    
    while nextI <= #tokens and tokens[nextI].type == "operator" and 
          (tokens[nextI].value == "<<" or tokens[nextI].value == ">>") do
        local op = tokens[nextI].value
        local right, rightNextI = self:parseConcatExpression(tokens, nextI + 1)
        left = {
            type = "binary_operation",
            operator = op,
            left = left,
            right = right
        }
        nextI = rightNextI
    end
    
    return left, nextI
end

-- 解析字符串连接表达式（..），右结合，优先级低于 + -，高于比较
function RealLuaToVMConverter:parseConcatExpression(tokens, i)
    local left, nextI = self:parseArithmeticExpression(tokens, i)
    if nextI <= #tokens and tokens[nextI].type == "operator" and tokens[nextI].value == ".." then
        -- 右结合：a .. b .. c 解析为 a .. (b .. c)
        local right, rightNextI = self:parseConcatExpression(tokens, nextI + 1)
        return {
            type = "binary_operation",
            operator = "..",
            left = left,
            right = right
        }, rightNextI
    end
    return left, nextI
end

-- 解析算术表达式
function RealLuaToVMConverter:parseArithmeticExpression(tokens, i)
    local left, nextI = self:parseTermExpression(tokens, i)
    
    while nextI <= #tokens and tokens[nextI].type == "operator" and 
          (tokens[nextI].value == "+" or tokens[nextI].value == "-") do
        
        local op = tokens[nextI].value
        local right, rightNextI = self:parseTermExpression(tokens, nextI + 1)
        left = {
            type = "binary_operation",
            operator = op,
            left = left,
            right = right
        }
        nextI = rightNextI
    end
    
    return left, nextI
end

-- 解析项表达式
function RealLuaToVMConverter:parseTermExpression(tokens, i)
    local left, nextI = self:parseUnaryExpression(tokens, i)
    
    while nextI <= #tokens and tokens[nextI].type == "operator" and 
          (tokens[nextI].value == "*" or tokens[nextI].value == "/" or tokens[nextI].value == "%") do
        
        local op = tokens[nextI].value
        local right, rightNextI = self:parseUnaryExpression(tokens, nextI + 1)
        left = {
            type = "binary_operation",
            operator = op,
            left = left,
            right = right
        }
        nextI = rightNextI
    end
    
    return left, nextI
end

-- 解析基本表达式
function RealLuaToVMConverter:parsePrimaryExpression(tokens, i)
    if i > #tokens then
        return nil, i
    end
    
    local token = tokens[i]
    
    -- 字符串字面量
    if token.type == "string" then
        return {type = "string_literal", value = token.value}, i + 1
        
    -- 数字字面量
    elseif token.type == "number" then
        return {type = "number_literal", value = token.value}, i + 1
        
    -- 布尔和nil字面量
    elseif token.type == "keyword" and (token.value == "true" or token.value == "false") then
        return {type = "boolean_literal", value = token.value == "true"}, i + 1
        
    elseif token.type == "keyword" and token.value == "nil" then
        return {type = "nil_literal", value = nil}, i + 1
        
    -- 表构造
    elseif token.type == "delimiter" and token.value == "{" then
        return self:parseTableConstructor(tokens, i)
        
    -- 标识符（变量、表访问或函数调用）
    elseif token.type == "identifier" then
        return self:parseIdentifierChain(tokens, i)
        
    -- 括号表达式
    elseif token.type == "delimiter" and token.value == "(" then
        local expr, nextI = self:parseExpression(tokens, i + 1)
        if nextI <= #tokens and tokens[nextI].value == ")" then
            return expr, nextI + 1
        end
        return expr, nextI
        
    else
        error("parsePrimaryExpression error: " .. token.value)
        return nil, i + 1
    end
end

-- 解析表构造
function RealLuaToVMConverter:parseTableConstructor(tokens, i)
    local elements = {}
    local nextI = i + 1 -- 跳过 {
    
    while nextI <= #tokens and tokens[nextI].value ~= "}" do
        if tokens[nextI].type == "comma" then
            nextI = nextI + 1
        else
            local expr, exprNextI = self:parseExpression(tokens, nextI)
            if expr then
                table.insert(elements, expr)
            end
            nextI = exprNextI
        end
    end
    
    return {
        type = "table_constructor",
        elements = elements
    }, nextI + 1 -- 跳过 }
end

-- 解析标识符链（支持 obj.method()、obj:method()、obj.prop 等）
function RealLuaToVMConverter:parseIdentifierChain(tokens, i)
    local base = {type = "variable", name = tokens[i].value}
    local nextI = i + 1
    
    -- 处理链式访问
    while nextI <= #tokens do
        local token = tokens[nextI]
        
        if token.type == "dot" then
            -- 处理 obj.prop 或 obj.method()
            if nextI + 1 <= #tokens and tokens[nextI + 1].type == "identifier" then
                local propName = tokens[nextI + 1].value
                nextI = nextI + 2
                
                -- 检查是否是函数调用
                if nextI <= #tokens and tokens[nextI].type == "delimiter" and tokens[nextI].value == "(" then
                    local args, argsNextI = self:parseFunctionArgs(tokens, nextI)
                    return {
                        type = "function_call",
                        table = base,
                        method = propName,
                        args = args,
                        call_type = "dot" -- table.func() 调用
                    }, argsNextI
                else
                    -- 普通属性访问
                    base = {
                        type = "table_access",
                        table = base,
                        key = {type = "string_literal", value = propName}
                    }
                end
            else
                break
            end
            
        elseif token.type == "colon" then
            -- 处理 obj:method()
            if nextI + 1 <= #tokens and tokens[nextI + 1].type == "identifier" then
                local methodName = tokens[nextI + 1].value
                nextI = nextI + 2
                
                -- 方法调用必须有括号
                if nextI <= #tokens and tokens[nextI].type == "delimiter" and tokens[nextI].value == "(" then
                    local args, argsNextI = self:parseFunctionArgs(tokens, nextI)
                    return {
                        type = "function_call",
                        table = base,
                        method = methodName,
                        args = args,
                        call_type = "colon" -- obj:method() 调用
                    }, argsNextI
                else
                    error("方法调用缺少括号: " .. methodName)
                end
            else
                break
            end
            
        elseif token.type == "delimiter" and token.value == "[" then
            -- 处理 obj[key]
            local key, keyNextI = self:parseExpression(tokens, nextI + 1)
            if keyNextI <= #tokens and tokens[keyNextI].value == "]" then
                base = {
                    type = "table_access",
                    table = base,
                    key = key
                }
                nextI = keyNextI + 1
            else
                break
            end
            
        elseif token.type == "delimiter" and token.value == "(" then
            -- 直接函数调用 func()
            local args, argsNextI = self:parseFunctionArgs(tokens, nextI)
            return {
                type = "function_call",
                table = nil,
                method = base.name,
                args = args,
                call_type = "direct" -- 直接调用
            }, argsNextI
            
        else
            break
        end
    end
    
    return base, nextI
end

-- 解析函数参数
function RealLuaToVMConverter:parseFunctionArgs(tokens, i)
    local args = {}
    local nextI = i + 1 -- 跳过 (
    
    while nextI <= #tokens and tokens[nextI].value ~= ")" do
        if tokens[nextI].value == "," then
            nextI = nextI + 1
        else
            local arg, argNextI = self:parseExpression(tokens, nextI)
            table.insert(args, arg)
            nextI = argNextI
        end
    end
    
    return args, nextI + 1 -- 跳过 )
end

-- 解析函数调用（保留用于兼容性）
function RealLuaToVMConverter:parseFunctionCall(tokens, i)
    local funcName = tokens[i].value
    local args = {}
    local nextI = i + 2 -- 跳过 func(
    
    while nextI <= #tokens and tokens[nextI].value ~= ")" do
        if tokens[nextI].type == "comma" then
            nextI = nextI + 1
        else
            local expr, exprNextI = self:parseExpression(tokens, nextI)
            if expr then
                table.insert(args, expr)
            end
            nextI = exprNextI
        end
    end
    
    return {
        type = "function_call",
        name = funcName,
        args = args
    }, nextI + 1 -- 跳过 )
end

-- 解析表访问 table.key
function RealLuaToVMConverter:parseTableAccess(tokens, i)
    local tableName = tokens[i].value
    local key = tokens[i+2].value -- 跳过 table.
    
    return {
        type = "table_access",
        table = tableName,
        key = {type = "string_literal", value = key}
    }, i + 3
end

-- 解析表索引 table[key]
function RealLuaToVMConverter:parseTableIndex(tokens, i)
    local tableName = tokens[i].value
    local key, keyNextI = self:parseExpression(tokens, i + 2) -- 跳过 table[
    
    return {
        type = "table_access",
        table = tableName,
        key = key
    }, keyNextI + 1 -- 跳过 ]
end

-- 代码生成：将AST转换为虚拟机指令
function RealLuaToVMConverter:generateCode(ast)
    self.varLifeFloor = 1 -- 变量的生命周期层次
    for _, stmt in ipairs(ast.statements) do
        self:generateStatement(stmt)
    end
    
    -- 添加停机指令
    self:addInstruction(LuaVM.OpCode.HALT)
end

-- 生成语句指令
function RealLuaToVMConverter:generateStatement(stmt)
    if stmt.type == "local_assignment" then
        local retCount = stmt.variable.var2 and 2 or 1
        self:generateExpression(stmt.expression, retCount)
        local varId = self:createVariable(stmt.variable.var1)
        self:addInstruction(LuaVM.OpCode.STORE_VAR, varId)
        if stmt.variable.var2 then
            local varId2 = self:createVariable(stmt.variable.var2)
            self:addInstruction(LuaVM.OpCode.STORE_VAR, varId2)
        end

        
    elseif stmt.type == "assignment" then
        local retCount = stmt.variable.var2 and 2 or 1
        self:generateExpression(stmt.expression, retCount)
        local varId = self:getVariable(stmt.variable.var1)
        self:addInstruction(LuaVM.OpCode.STORE_VAR, varId)
        if stmt.variable.var2 then
            local varId2 = self:getVariable(stmt.variable.var2)
            self:addInstruction(LuaVM.OpCode.STORE_VAR, varId2)
        end
        

    elseif stmt.type == "table_assignment" then
        local tableId = self:getVariable(stmt.table)
        self:addInstruction(LuaVM.OpCode.LOAD_VAR, tableId)
        self:generateExpression(stmt.key, 1) -- table[] 如果是函数需要一个返回值
        self:generateExpression(stmt.expression, 1) -- table[]=..  如果是函数需要一个返回值
        self:addInstruction(LuaVM.OpCode.TBL_SET)
        self:addInstruction(LuaVM.OpCode.STORE_VAR, tableId)
        
    elseif stmt.type == "if_statement" then
        self.varLifeFloor = self.varLifeFloor + 1
        self:generateExpression(stmt.condition, 1) -- 如果是函数需要一个返回值
        local jumpToElse = #self.instructions + 1 -- 下一条指令就是条件跳转
        self:addInstruction(LuaVM.OpCode.JMP_FALSE, 0) -- 占位符，稍后填充
        
        -- 生成then分支的代码
        for _, thenStmt in ipairs(stmt.then_statements) do
            self:generateStatement(thenStmt)
        end
        
        -- 检查是否有else分支
        if stmt.else_statements and #stmt.else_statements > 0 then
            -- 如果有else分支，then分支执行完后需要跳过else分支
            local jumpOverElse = #self.instructions + 1 ---下一条指令就是跳转指令
            self:addInstruction(LuaVM.OpCode.JMP, 0) -- 占位符，稍后填充
        
            -- 回填条件跳转地址（跳转到else分支开始）
            self.instructions[jumpToElse][2] = #self.instructions + 1
            
            -- 生成else分支的代码
            for _, elseStmt in ipairs(stmt.else_statements) do
                self:generateStatement(elseStmt)
            end
            
            -- 回填跳过else分支的跳转地址
            self.instructions[jumpOverElse][2] = #self.instructions + 1
        else
            -- 没有else分支，条件跳转直接跳到if语句结束
            self.instructions[jumpToElse][2] = #self.instructions + 1
        end

        self:removeVarriable(self.varLifeFloor)
        self.varLifeFloor = self.varLifeFloor - 1
    elseif stmt.type == "for_numeric" then
        self.varLifeFloor = self.varLifeFloor + 1
        -- for i=start,stop do ... end
        local varId = self:createVariable(stmt.variable)
        
        -- 初始化循环变量
        self:generateExpression(stmt.start, 1) -- 如果是函数需要一个返回值
        self:addInstruction(LuaVM.OpCode.STORE_VAR, varId)
        
        -- 循环开始标记
        local loopStart = #self.instructions + 1
        
        -- 检查循环条件
        self:addInstruction(LuaVM.OpCode.LOAD_VAR, varId)
        self:generateExpression(stmt.stop, 1) -- 如果是函数需要一个返回值
        self:addInstruction(LuaVM.OpCode.LE)
        
        local jumpEnd = #self.instructions + 1
        self:addInstruction(LuaVM.OpCode.JMP_FALSE, 0) -- 占位符
        
        -- 循环体
        for _, loopStmt in ipairs(stmt.statements) do
            self:generateStatement(loopStmt)
        end
        
        -- 递增循环变量
        self:addInstruction(LuaVM.OpCode.LOAD_VAR, varId)
        local oneConst = self:addConstant(1)
        self:addInstruction(LuaVM.OpCode.LOAD_CONST, oneConst)
        self:addInstruction(LuaVM.OpCode.ADD)
        self:addInstruction(LuaVM.OpCode.STORE_VAR, varId)
        
        -- 跳回循环开始
        self:addInstruction(LuaVM.OpCode.JMP, loopStart)
        
        -- 回填跳转地址
        self.instructions[jumpEnd][2] = #self.instructions + 1
        self:removeVarriable(self.varLifeFloor)
        self.varLifeFloor = self.varLifeFloor - 1
        
    elseif stmt.type == "while_statement" then

        self.varLifeFloor = self.varLifeFloor + 1
        -- while condition do ... end
        local loopStart = #self.instructions + 1
        
        -- 检查循环条件
        self:generateExpression(stmt.condition, 1) -- 如果是函数需要一个返回值
        
        local jumpEnd = #self.instructions + 1
        self:addInstruction(LuaVM.OpCode.JMP_FALSE, 0) -- 占位符
        
        -- 循环体
        for _, loopStmt in ipairs(stmt.statements) do
            self:generateStatement(loopStmt)
        end
        
        -- 跳回循环开始
        self:addInstruction(LuaVM.OpCode.JMP, loopStart)
        
        -- 回填跳转地址
        self.instructions[jumpEnd][2] = #self.instructions + 1
        self:removeVarriable(self.varLifeFloor)
        self.varLifeFloor = self.varLifeFloor - 1
        
    elseif stmt.type == "for_generic" then
        -- 支持：for k, v in pairs(t) do ... end 以及 for i, v in ipairs(t) do ... end
        self.varLifeFloor = self.varLifeFloor + 1

        -- 创建循环局部变量（用户变量）
        local var1Id = self:createVariable(stmt.var1)
        local var2Id = stmt.var2 and self:createVariable(stmt.var2) or nil

        -- 创建内部临时变量
        local iterTblName = "__iter_tbl_" .. tostring(self.nextVarId)
        local iterTblId = self:createVariable(iterTblName)

        -- 保存被迭代表
        self:generateExpression(stmt.tableExpr, 1)
        self:addInstruction(LuaVM.OpCode.STORE_VAR, iterTblId)

        if stmt.iterator == "pairs" then
            -- 使用 next(table, lastKey) 来迭代
            local lastKeyName = "__iter_key_" .. tostring(self.nextVarId)
            local lastKeyId = self:createVariable(lastKeyName)
            local nilConst = self:addConstant(nil)
            self:addInstruction(LuaVM.OpCode.LOAD_CONST, nilConst)
            self:addInstruction(LuaVM.OpCode.STORE_VAR, lastKeyId)

            local loopStart = #self.instructions + 1

            -- 调用 next(iterTbl, lastKey)，返回下一个key（单返回）
            self:addInstruction(LuaVM.OpCode.LOAD_VAR, lastKeyId) -- 虚拟机 栈顶的值放到table前面的。
            self:addInstruction(LuaVM.OpCode.LOAD_VAR, iterTblId)
            local funcName = self:addConstant("next")
            self:addInstruction(LuaVM.OpCode.LOAD_CONST, funcName)
            self:addInstruction(LuaVM.OpCode.SYS_CALL, 2, 2)--栈 1 value 2 key

            -- 保存lastKey = key，并检查是否为nil
            self:addInstruction(LuaVM.OpCode.DUP) -- 栈 1 value 2 key 3 key
            self:addInstruction(LuaVM.OpCode.STORE_VAR, lastKeyId) --栈 1 value 2 key 

            -- if key == nil then break
            self:addInstruction(LuaVM.OpCode.DUP) --- 栈 1 value 2 key 3 key 
            self:addInstruction(LuaVM.OpCode.LOAD_CONST, nilConst) -- 栈 1 value 2 key 3 key 4 nil
            self:addInstruction(LuaVM.OpCode.EQ) -- 栈 1 value 2 key
            local jmpEndIdx = #self.instructions + 1
            self:addInstruction(LuaVM.OpCode.JMP_TRUE, 0) -- 占位，回填

            -- 赋值给用户变量 var1 = key（使用保存的lastKeyId，避免依赖栈顺序）
            self:addInstruction(LuaVM.OpCode.POP) -- 丢弃当前栈上的key副本 -- 栈 1 value 
            self:addInstruction(LuaVM.OpCode.LOAD_VAR, lastKeyId) -- 栈 1 value 2 key
            self:addInstruction(LuaVM.OpCode.STORE_VAR, var1Id) -- 栈 1 value 

            -- 计算 var2 = iterTbl[lastKey]
            self:addInstruction(LuaVM.OpCode.LOAD_VAR, iterTblId) -- 表 栈 1 value 2 table 
            self:addInstruction(LuaVM.OpCode.LOAD_VAR, lastKeyId) -- 键 栈 1 value 2 table 3 key
            self:addInstruction(LuaVM.OpCode.TBL_GET) -- 键 栈 1 value 2 value 
            if var2Id then
                self:addInstruction(LuaVM.OpCode.STORE_VAR, var2Id) -- 栈 1 value 
            else
                self:addInstruction(LuaVM.OpCode.POP) -- 安全丢弃值  -- 栈 1 value 
            end

            -- 循环体
            for _, loopStmt in ipairs(stmt.statements) do
                self:generateStatement(loopStmt)
            end

            -- 跳回循环开始
            self:addInstruction(LuaVM.OpCode.JMP, loopStart)

            -- 回填结束跳转地址
            self.instructions[jmpEndIdx][2] = #self.instructions + 1

        elseif stmt.iterator == "ipairs" then
            -- 使用递增下标 1..n，遇到nil则终止
            local idxName = "__iter_idx_" .. tostring(self.nextVarId)
            local idxId = self:createVariable(idxName)
            local oneConst = self:addConstant(1)
            local nilConst = self:addConstant(nil)

            -- idx = 1
            self:addInstruction(LuaVM.OpCode.LOAD_CONST, oneConst)
            self:addInstruction(LuaVM.OpCode.STORE_VAR, idxId)

            local loopStart = #self.instructions + 1

            -- v = iterTbl[idx]; 若v==nil则结束
            self:addInstruction(LuaVM.OpCode.LOAD_VAR, iterTblId)
            self:addInstruction(LuaVM.OpCode.LOAD_VAR, idxId)
            self:addInstruction(LuaVM.OpCode.TBL_GET)

            self:addInstruction(LuaVM.OpCode.DUP)
            self:addInstruction(LuaVM.OpCode.LOAD_CONST, nilConst)
            self:addInstruction(LuaVM.OpCode.EQ)
            local jmpEndIdx = #self.instructions + 1
            self:addInstruction(LuaVM.OpCode.JMP_TRUE, 0) -- 占位，回填

            -- var2 = v（若存在），var1 = idx
            if var2Id then
                self:addInstruction(LuaVM.OpCode.STORE_VAR, var2Id)
            else
                self:addInstruction(LuaVM.OpCode.POP)
            end

            self:addInstruction(LuaVM.OpCode.LOAD_VAR, idxId)
            self:addInstruction(LuaVM.OpCode.STORE_VAR, var1Id)

            -- 循环体
            for _, loopStmt in ipairs(stmt.statements) do
                self:generateStatement(loopStmt)
            end

            -- idx = idx + 1
            self:addInstruction(LuaVM.OpCode.LOAD_VAR, idxId)
            self:addInstruction(LuaVM.OpCode.LOAD_CONST, oneConst)
            self:addInstruction(LuaVM.OpCode.ADD)
            self:addInstruction(LuaVM.OpCode.STORE_VAR, idxId)

            -- 跳回循环开始
            self:addInstruction(LuaVM.OpCode.JMP, loopStart)

            -- 回填结束跳转地址
            self.instructions[jmpEndIdx][2] = #self.instructions + 1
        end

        self:removeVarriable(self.varLifeFloor)
        self.varLifeFloor = self.varLifeFloor - 1
        
    elseif stmt.type == "for_iterator" then
        -- 支持任意迭代器函数：for file in lfs.dir(path) do
        self.varLifeFloor = self.varLifeFloor + 1

        -- 创建循环局部变量
        local var1Id = self:createVariable(stmt.var1)
        local var2Id = stmt.var2 and self:createVariable(stmt.var2) or nil

        -- 创建迭代器状态变量
        local iterStateName = "__iter_state_" .. tostring(self.nextVarId)
        local iterStateId = self:createVariable(iterStateName)

        -- 初始化迭代器：调用迭代器函数获得迭代器状态
        self:generateExpression(stmt.iteratorExpr, 1)
        self:addInstruction(LuaVM.OpCode.ITER_INIT)
        self:addInstruction(LuaVM.OpCode.STORE_VAR, iterStateId)

        local loopStart = #self.instructions + 1

        -- 获取下一个迭代值
        self:addInstruction(LuaVM.OpCode.LOAD_VAR, iterStateId)
        self:addInstruction(LuaVM.OpCode.ITER_NEXT)
        
        -- 检查是否迭代结束（返回nil）
        self:addInstruction(LuaVM.OpCode.DUP)
        local nilConst = self:addConstant(nil)
        self:addInstruction(LuaVM.OpCode.LOAD_CONST, nilConst)
        self:addInstruction(LuaVM.OpCode.EQ)
        local jmpEndIdx = #self.instructions + 1
        self:addInstruction(LuaVM.OpCode.JMP_TRUE, 0) -- 占位，回填

        -- 赋值给循环变量
        self:addInstruction(LuaVM.OpCode.STORE_VAR, var1Id)
        if var2Id then
            -- 如果有第二个变量，暂时设为nil（可根据需要扩展）
            self:addInstruction(LuaVM.OpCode.LOAD_CONST, nilConst)
            self:addInstruction(LuaVM.OpCode.STORE_VAR, var2Id)
        end

        -- 循环体
        for _, loopStmt in ipairs(stmt.statements) do
            self:generateStatement(loopStmt)
        end

        -- 跳回循环开始
        self:addInstruction(LuaVM.OpCode.JMP, loopStart)

        -- 回填结束跳转地址
        self.instructions[jmpEndIdx][2] = #self.instructions + 1

        self:removeVarriable(self.varLifeFloor)
        self.varLifeFloor = self.varLifeFloor - 1
        
    elseif stmt.type == "return_statement" then
        if stmt.expression then
            self:generateExpression(stmt.expression)
        end
        self:addInstruction(LuaVM.OpCode.HALT)

    elseif stmt.type == "local_function_definition" then
        -- 记录本地函数名
        self.localFunctions[stmt.name] = true
        
        -- 执行的时候 需要先跳过函数定义
        self:addInstruction(LuaVM.OpCode.JMP, #self.instructions + 1) -- 占位符，稍后填充
        local jmpDefAddr = #self.instructions
        -- 记录函数开始位置
        local funcStartAddr = #self.instructions + 1
        
        -- 将参数保存为变量
        for i, param in ipairs(stmt.params) do
            local varId = self:createVariable(param)
            self:addInstruction(LuaVM.OpCode.STORE_VAR, varId)
        end
        -- 生成函数体指令
        for _, bodyStmt in ipairs(stmt.body.statements) do
            self:generateStatement(bodyStmt)
        end
        
        -- 记录函数结束位置
        local funcEndAddr = #self.instructions
        
        -- 创建函数定义数据
        local funcData = {funcStartAddr,funcEndAddr}
        
        -- 回填跳过函数定义的跳转地址 但是需要执行函数定义指令 保存函数数据
        self.instructions[jmpDefAddr][2] = #self.instructions + 1

        -- 生成函数定义指令
        local funcNameConst = self:addConstant(stmt.name)
        local funcDataConst = self:addConstant(funcData)
        self:addInstruction(LuaVM.OpCode.FUNC_DEF, funcNameConst, funcDataConst)


    elseif stmt.type == "expression_statement" then
        self:generateExpression(stmt.expression)
    end
end

-- 生成表达式指令
function RealLuaToVMConverter:generateExpression(expr, retCount)
    if not expr then
        return
    end
    
    if expr.type == "string_literal" then
        local constId = self:addConstant(expr.value)
        self:addInstruction(LuaVM.OpCode.LOAD_CONST, constId)
        
    elseif expr.type == "number_literal" then
        local constId = self:addConstant(expr.value)
        self:addInstruction(LuaVM.OpCode.LOAD_CONST, constId)
        
    elseif expr.type == "boolean_literal" then
        local constId = self:addConstant(expr.value)
        self:addInstruction(LuaVM.OpCode.LOAD_CONST, constId)
        
    elseif expr.type == "nil_literal" then
        local constId = self:addConstant(nil)
        self:addInstruction(LuaVM.OpCode.LOAD_CONST, constId)
        
    elseif expr.type == "variable" then
        local varId = self:getVariable(expr.name)
        self:addInstruction(LuaVM.OpCode.LOAD_VAR, varId)
        
    elseif expr.type == "table_constructor" then
        self:addInstruction(LuaVM.OpCode.TBL_NEW)
        for i, element in ipairs(expr.elements) do
            self:addInstruction(LuaVM.OpCode.DUP) -- 复制表引用
            local indexConst = self:addConstant(i)
            self:addInstruction(LuaVM.OpCode.LOAD_CONST, indexConst)
            self:generateExpression(element)
            self:addInstruction(LuaVM.OpCode.TBL_SET)
        end
        
    elseif expr.type == "table_access" then
        -- 生成表表达式
        self:generateExpression(expr.table)
        -- 生成键表达式
        self:generateExpression(expr.key, 1)
        -- 执行表访问
        self:addInstruction(LuaVM.OpCode.TBL_GET)
        
    elseif expr.type == "function_call" then
        if expr.call_type == "direct" then
            -- 直接函数调用 func()
            -- 压入参数（逆序）
            for i = #expr.args, 1, -1 do
                self:generateExpression(expr.args[i])
            end
            
            -- 检查是否为本地函数或系统函数
            local funcNameConst = self:addConstant(expr.method)
            self:addInstruction(LuaVM.OpCode.LOAD_CONST, funcNameConst)
            if self:isLocalFunction(expr.method) then
                -- 本地函数调用
                self:addInstruction(LuaVM.OpCode.LOCAL_FUNC_CALL,  #expr.args, retCount)
            else
                -- 系统调用
                self:addInstruction(LuaVM.OpCode.SYS_CALL, #expr.args, retCount)
            end
            
        elseif expr.call_type == "dot" then
            -- table.func() 调用
            -- 压入参数（逆序）
            for i = #expr.args, 1, -1 do
                self:generateExpression(expr.args[i])
            end
            -- 压入函数名
            local methodConst = self:addConstant(expr.method)
            self:addInstruction(LuaVM.OpCode.LOAD_CONST, methodConst)
            -- 压入表
            self:generateExpression(expr.table)
            -- 执行函数调用
            self:addInstruction(LuaVM.OpCode.FUNC_CALL, #expr.args, retCount)
            
        elseif expr.call_type == "colon" then
            -- obj:method() 调用
            -- 压入参数（逆序）
            for i = #expr.args, 1, -1 do
                self:generateExpression(expr.args[i])
            end
            -- 压入方法名
            local methodConst = self:addConstant(expr.method)
            self:addInstruction(LuaVM.OpCode.LOAD_CONST, methodConst)
            -- 压入对象
            self:generateExpression(expr.table)
            -- 执行方法调用
            self:addInstruction(LuaVM.OpCode.METHOD_CALL, #expr.args, retCount)
        end
        
    elseif expr.type == "binary_operation" then
        self:generateExpression(expr.left,  1)
        self:generateExpression(expr.right, 1)
        
        if expr.operator == "+" then
            self:addInstruction(LuaVM.OpCode.ADD)
        elseif expr.operator == "-" then
            self:addInstruction(LuaVM.OpCode.SUB)
        elseif expr.operator == "*" then
            self:addInstruction(LuaVM.OpCode.MUL)
        elseif expr.operator == "/" then
            self:addInstruction(LuaVM.OpCode.DIV)
        elseif expr.operator == "%" then
            self:addInstruction(LuaVM.OpCode.MOD)
        elseif expr.operator == "==" then
            self:addInstruction(LuaVM.OpCode.EQ)
        elseif expr.operator == "~=" then
            self:addInstruction(LuaVM.OpCode.NE)
        elseif expr.operator == "<" then
            self:addInstruction(LuaVM.OpCode.LT)
        elseif expr.operator == "<=" then
            self:addInstruction(LuaVM.OpCode.LE)
        elseif expr.operator == ">" then
            self:addInstruction(LuaVM.OpCode.GT)
        elseif expr.operator == ">=" then
            self:addInstruction(LuaVM.OpCode.GE)
        elseif expr.operator == ".." then
            self:addInstruction(LuaVM.OpCode.STR_CONCAT)
        elseif expr.operator == "and" then
            self:addInstruction(LuaVM.OpCode.AND)
        elseif expr.operator == "or" then
            self:addInstruction(LuaVM.OpCode.OR)
        -- 位操作
        elseif expr.operator == "&" then
            self:addInstruction(LuaVM.OpCode.BIT_AND)
        elseif expr.operator == "|" then
            self:addInstruction(LuaVM.OpCode.BIT_OR)
        elseif expr.operator == "~" then
            self:addInstruction(LuaVM.OpCode.BIT_XOR)
        elseif expr.operator == "<<" then
            self:addInstruction(LuaVM.OpCode.BIT_LSHIFT)
        elseif expr.operator == ">>" then
            self:addInstruction(LuaVM.OpCode.BIT_RSHIFT)
        end 
    elseif expr.type == "unary_operation" then
        if expr.operator == "not" then
            self:generateExpression(expr.expression, 1)
            self:addInstruction(LuaVM.OpCode.NOT)
        elseif expr.operator == "#" then
            self:generateExpression(expr.expression, 1)
            self:addInstruction(LuaVM.OpCode.LEN)
        elseif expr.operator == "~" then
            self:generateExpression(expr.expression, 1)
            self:addInstruction(LuaVM.OpCode.BIT_NOT)
        end
    end
end

-- 添加常量
function RealLuaToVMConverter:addConstant(value)
    local key = tostring(value) .. "_" .. type(value)
    if self.constantMap[key] then
        return self.constantMap[key]
    end
    
    local id = self.nextConstId
    self.constants[id] = value
    self.constantMap[key] = id
    self.nextConstId = self.nextConstId + 1
    return id
end

-- 获取或创建变量
function RealLuaToVMConverter:createVariable(name)
    if self.variables[self.varLifeFloor] and self.variables[self.varLifeFloor][name] then
        print("variable already exists", name)
        return self.variables[self.varLifeFloor][name]
    end
    
    -- 本地变量使用数字ID
    local id = self.nextVarId
    if not self.variables[self.varLifeFloor] then 
        self.variables[self.varLifeFloor] = {}
    end
    self.variables[self.varLifeFloor][name] = id
    self.nextVarId = self.nextVarId + 1
    return id
end

function RealLuaToVMConverter:removeVarriable(floor)
    if self.variables[floor] then
        self.variables[floor] = nil
    end
end

function RealLuaToVMConverter:getVariable(name)
    if self:isGlobalVariable(name) then
        -- 全局变量使用加密后的字符串名称
        if not self.variables[self.varLifeFloor] then 
            self.variables[self.varLifeFloor] = {}
        end
        local CodeEncoder = T(Global, "CodeEncoder")
        self.variables[self.varLifeFloor][name] = CodeEncoder:encryptIdentifier(name)
        return self.variables[self.varLifeFloor][name]
    end

    -- 往上层查找
    local varLifeFloor = self.varLifeFloor
    while(varLifeFloor > 1) do
        if self.variables[varLifeFloor] and self.variables[varLifeFloor][name] then
            return self.variables[varLifeFloor][name]
        end
        varLifeFloor = varLifeFloor - 1
    end

    --最上层
    if self.variables[varLifeFloor] and self.variables[varLifeFloor][name] then
        return self.variables[varLifeFloor][name]
    end

    --找不到报错
    error("variable not found", name)
    return nil
end

-- 检查是否为全局变量
function RealLuaToVMConverter:isGlobalVariable(name)
    local globalVars = {
        "T", "Global", "StringUtil", "json", "CGame", "misc", "split",
        "LuaTimer", "PacketSender", "PlayerManager", "HackReport",
        "print", "tostring", "tonumber", "type", "pairs", "ipairs",
        "next", "table", "string", "math", "os", "io", "bit32", "utf8", "pcall", "_G", "debug", "VFS2"
    }
    
    for _, globalVar in ipairs(globalVars) do
        if name == globalVar then
            return true
        end
    end
    
    return false
end

-- 检查是否为本地函数
function RealLuaToVMConverter:isLocalFunction(name)
    return self.localFunctions[name] == true
end

-- 添加指令
function RealLuaToVMConverter:addInstruction(opcode, operand1, operand2)
    table.insert(self.instructions, {opcode, operand1, operand2})
    return #self.instructions
end

return RealLuaToVMConverter
