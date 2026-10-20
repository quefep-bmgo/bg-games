--[[e6RXHBBftDPt8jrPTAFeMqMLe7gvAa4jroDLBfNGxEXMuRkMsrRi3]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 2207
                          local checkFileName = "vardump.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[Io1doY4cwlMvwiGCuHGMCVl3Vdyw7PdYXXYqFNzmwDqRkE3e1P8w2gXV3NTggFPjNj4R2j7m7Iz6MhJhy]]--region vardump.lua
--此文件由[BabeLua]插件自动生成

function var_dump(_t)   
    local szRet = "{"  
    function doT2S(_i, _v)  
        if "number" == type(_i) then  
            szRet = szRet .. "[" .. _i .. "] = "  
            if "number" == type(_v) then  
                szRet = szRet .. _v .. ","  
            elseif "string" == type(_v) then  
                szRet = szRet .. '"' .. _v .. '"' .. ","  
            elseif "table" == type(_v) then  
                szRet = szRet .. var_dump(_v) .. ","  
            else  
                szRet = szRet .. "nil,"  
            end  
        elseif "string" == type(_i) then  
            szRet = szRet .. '["' .. _i .. '"] = '  
            if "number" == type(_v) then  
                szRet = szRet .. _v .. ","  
            elseif "string" == type(_v) then  
                szRet = szRet .. '"' .. _v .. '"' .. ","  
            elseif "table" == type(_v) then  
                szRet = szRet .. var_dump(_v) .. ","  
            else  
                szRet = szRet .. "nil,"  
            end  
        end  
    end  
    table.foreach(_t, doT2S)  
    szRet = szRet .. "}"  
    return szRet  
end  

VarDump = var_dump
return VarDump
--endregion
--[[WgxgYMuKTjiKKnojRSoA7SkCZ0KieLGwgaBsHRHzYU3ab910OzWiBOABFapX0HLzjs2FWXB9vQMQKRm5v08xNA6fKESU9WlJgQwcPNjVh]]---