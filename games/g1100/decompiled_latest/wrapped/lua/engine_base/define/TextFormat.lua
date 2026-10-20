--[[83Ps43szQBiJSJzU3DkxavRtv]]
						  if not File_Len_Check_Cache then 
							 File_Len_Check_Cache = {} 
                          end 
						  if not F_L_Check_C_NEW then 
							  F_L_Check_C_NEW = {} 
                          end 
                          local len  = 1966
                          local checkFileName = "TextFormat.lua"
						  if not File_Len_Check_Cache[checkFileName] then 
						     File_Len_Check_Cache[checkFileName] = {} 
	                      end 
						  if not F_L_Check_C_NEW[checkFileName] then 
						     F_L_Check_C_NEW[checkFileName] = {} 
	                      end 
	                      table.insert(File_Len_Check_Cache[checkFileName], len-200)
						  table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[wtcz1h0K8fOhggkPWp0RWasJQyKwsKywKFXCTcrlYqX]]---
--- Created by Jimmy.
--- DateTime: 2017/10/12 0012 10:10
---

TextFormat = {}

TextFormat.argsSplit = "\t"
TextFormat.argsTipType = "#"

TextFormat.colorStart = "▢"
TextFormat.colorEnd = "▥"

TextFormat.colorRed = TextFormat.colorStart .. "FFFF0000"
TextFormat.colorBlue = TextFormat.colorStart .. "FF0000FF"
TextFormat.colorBlack = TextFormat.colorStart .. "FF000000"
TextFormat.colorWrite = TextFormat.colorStart .. "FFFFFFFF"
TextFormat.colorGreen = TextFormat.colorStart .. "FF00FF00"
TextFormat.colorYellow = TextFormat.colorStart .. "FFFFFF00"
TextFormat.colorPurple = TextFormat.colorStart .. "FF884898"
TextFormat.colorPink = TextFormat.colorStart .. "FFFF1B89"
TextFormat.colorOrange = TextFormat.colorStart .. "FFFF8000"
TextFormat.colorGold = TextFormat.colorStart .. "FFFFD700"
TextFormat.colorAqua = TextFormat.colorStart .. "FF00FFFF"

function TextFormat:getTipType(num)
	return TextFormat.argsTipType .. num .. TextFormat.argsTipType
end

function TextFormat:getTipType2(num)
	return TextFormat.argsTipType .. TextFormat.argsTipType .. num .. TextFormat.argsTipType .. TextFormat.argsTipType
end

return TextFormat--[[TCemMWHYzJlv97Cxs1]]