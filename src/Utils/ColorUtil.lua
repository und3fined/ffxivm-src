--
-- Author: anypkvcai
-- Date: 2020-12-30 10:24
-- Description:
--

local ProtoRes = require("Protocol/ProtoRes")

local ITEM_COLOR_TYPE = ProtoRes.ITEM_COLOR_TYPE

local FColor = _G.UE.FColor
local FLinearColor = _G.UE.FLinearColor

---@class ColorUtil
local ColorUtil = {

}

function ColorUtil.GetLinearColorFromHex(HexColor)
	return FLinearColor.FromHex(HexColor)
end

function ColorUtil.GetLinearColorFromSRGB(R, G, B, A)
	local SGRBColor = FColor(R, G, B, A)

	return SGRBColor:ToLinearColor()
end

---GetItemHexColor
---@param Color number @ITEM_COLOR_TYPE
function ColorUtil.GetItemHexColor(Color)
	if ITEM_COLOR_TYPE.ITEM_COLOR_WHITE == Color then
		return "C1C1C1FF"
	elseif ITEM_COLOR_TYPE.ITEM_COLOR_GREEN == Color then
		return "B3E8CCFF"
	elseif ITEM_COLOR_TYPE.ITEM_COLOR_BLUE == Color then
		return "779FD2FF"
	elseif ITEM_COLOR_TYPE.ITEM_COLOR_PURPLE == Color then
		return "B19ADEFF"
	elseif ITEM_COLOR_TYPE.ITEM_COLOR_ORANGE == Color then
		return "9A533DFF"
	elseif ITEM_COLOR_TYPE.ITEM_COLOR_RED == Color then
		return "A94A4AFF"
	else
		return "FFFFFFFF"
	end
end

--Color:	 ProtoRes.RARE_TYPE
function ColorUtil.GetLinearColor(Color)
	local HexColor = ColorUtil.GetItemHexColor(Color)
	local LinearColor = FLinearColor.FromHex(HexColor)

	return LinearColor
end

--文本或者image都可以这样设置
--如果有ViewModel，建议使用UIBinderSetItemColor
function ColorUtil.SetQuality(Color, Widget)
	if Widget then
		local LinearColor = ColorUtil.GetLinearColor(Color)
		ColorUtil.SetQualityByLinearColor(LinearColor, Widget)
	end
end

--如果有ViewModel，建议使用UIBinderSetItemColor
function ColorUtil.SetQualityByLinearColor(LinearColor, Widget)
	if Widget then
		Widget:SetColorAndOpacity(LinearColor)
	end
end

---替换富文本
function ColorUtil.ReplaceRichCode(Str, NewCode)
	if string.isnilorempty(Str) then
		return ""
	end
	return string.gsub(Str, "<span.->", NewCode)
end

---替换物品名称富文本为暗色背景风格
function ColorUtil.ParseItemNameDarkStyle(Str)
	return ColorUtil.ReplaceRichCode(Str, "<span color=\"#d1906dff\">")
end

---替换物品名称富文本为亮色背景风格
function ColorUtil.ParseItemNameBrightStyle(Str)
	return ColorUtil.ReplaceRichCode(Str, "<span color=\"#b56728ff\">")
end

---替换物品名称富文本为场景背景风格
function ColorUtil.ParseItemNameSceneStyle(Str)
	return ColorUtil.ReplaceRichCode(Str, "<span color=\"#ffffff\" outline=\"2;#b56728b2\">")
end

return ColorUtil