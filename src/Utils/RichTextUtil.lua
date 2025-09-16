---
--- Author: anypkvcai
--- DateTime: 2021-11-01 10:33
--- Description:
---

---@class RichTextUtil
local RichTextUtil = {

}

---GetText
---@param Text string
---@param Color string @"#ff0000ff"
---@param OutlineColor string @"#ff0000ff"
---@param OutlineSize number
---@param ShadowColor string @"#ff0000ff"
---@param ShadowOffsetX number
---@param ShadowOffsetY number
---@param FontPath string
function RichTextUtil.GetText(Text, Color, OutlineColor, OutlineSize, ShadowColor, ShadowOffsetX, ShadowOffsetY, FontPath)
	if nil == Text then
		return
	end

	if _G.UIViewMgr and _G.UIViewMgr.bUseAozyFont then
		FontPath = "Font'/Game/UI/Fonts/HingashiExtended_Font.HingashiExtended_Font'"
	end

	local Attribute = RichTextUtil.GetTextAttribute(Color, nil, OutlineColor, OutlineSize, ShadowColor, ShadowOffsetX, ShadowOffsetY, nil, FontPath)

	return string.format("<span%s>%s</>", Attribute, Text)
end

---GetHyperlink
---@param Text string
---@param Color string @"#ff0000ff"
---@param LinkID number @超链接ID
---@param OutlineColor string @"#ff0000ff"
---@param OutlineSize number
---@param ShadowColor string @"#ff0000ff"
---@param ShadowOffsetX number
---@param ShadowOffsetY number
---@param UnderLineTexturePath string @nil: 显示默认下划线 ""：不显示下划线
---@param FontPath string
function RichTextUtil.GetHyperlink(Text, LinkID, Color, OutlineColor, OutlineSize, ShadowColor, ShadowOffsetX, ShadowOffsetY, UnderLineTexturePath, FontPath)
	if nil == Text then
		return
	end

	if _G.UIViewMgr and _G.UIViewMgr.bUseAozyFont then
		FontPath = "Font'/Game/UI/Fonts/HingashiExtended_Font.HingashiExtended_Font'"
	end
	
	local Attribute = RichTextUtil.GetTextAttribute(Color, LinkID, OutlineColor, OutlineSize, ShadowColor, ShadowOffsetX, ShadowOffsetY, UnderLineTexturePath, FontPath)

	return string.format("<a%s>%s</>", Attribute, Text)
end

---GetTexture
---@param Path string
---@param SizeX number
---@param SizeY number
---@param Baseline number
function RichTextUtil.GetTexture(Path, SizeX, SizeY, Baseline)
	if nil == Path then
		return
	end

	local Type = "tex"
	local Attribute = RichTextUtil.GetImageAttribute(Type, Path, SizeX, SizeY, Baseline)

	return string.format("<img%s></>", Attribute)
end

---GetMaterial
---@param Path string
---@param SizeX number
---@param SizeY number
function RichTextUtil.GetMaterial(Path, SizeX, SizeY)
	if nil == Path then
		return
	end

	local Type = "mat"
	local Attribute = RichTextUtil.GetImageAttribute(Type, Path, SizeX, SizeY)

	return string.format("<img%s></>", Attribute)
end

---GetAnimation
---@param Path string
---@param SizeX number
---@param SizeY number
---@param Baseline number
---@param Frame number
---@param FrameRate number
function RichTextUtil.GetAnimation(Path, SizeX, SizeY, Baseline, Frame, FrameRate)
	if nil == Path then
		return
	end

	local Type = "anima"
	local Attribute = RichTextUtil.GetImageAttribute(Type, Path, SizeX, SizeY, Baseline, Frame, FrameRate)

	return string.format("<img%s></>", Attribute)
end

function RichTextUtil.GetTextAttribute(Color, LinkID, OutlineColor, OutlineSize, ShadowColor, ShadowOffsetX, ShadowOffsetY, UnderLineTexturePath, FontPath)
	local List = {}

	if nil ~= Color then
		Color = RichTextUtil.ReviseColor(Color)
		local Attribute = string.format(" color=\"%s\"", Color)
		table.insert(List, Attribute)
	end

	if nil ~= LinkID then
		local Attribute = string.format(" linkid=\"%d\"", LinkID)
		table.insert(List, Attribute)
	end

	if nil ~= OutlineColor then
		OutlineColor = RichTextUtil.ReviseColor(OutlineColor)
		OutlineSize = OutlineSize or 1
		local Attribute = string.format(" outline=\"%d;%s\"", OutlineSize, OutlineColor)
		table.insert(List, Attribute)
	end

	if nil ~= ShadowColor then
		ShadowColor = RichTextUtil.ReviseColor(ShadowColor)
		ShadowOffsetX = ShadowOffsetX or 1
		ShadowOffsetY = ShadowOffsetY or 1
		local Attribute = string.format(" shadow=\"%d;%d;%s\"", ShadowOffsetX, ShadowOffsetY, ShadowColor)
		table.insert(List, Attribute)
	end

	if nil ~= UnderLineTexturePath then
		local Attribute = string.format(" underline=\"%s\"", UnderLineTexturePath)
		table.insert(List, Attribute)
	end

	if nil ~= FontPath then
		local Attribute = string.format(" font=\"%s\"", FontPath)
		table.insert(List, Attribute)
	end

	return table.concat(List)
end

function RichTextUtil.GetImageAttribute(Type, Path, SizeX, SizeY, Baseline, Frame, FrameRate)
	local List = {}

	if nil ~= Type and nil ~= Path then
		local Attribute = string.format(" %s=\"%s\"", Type, Path)
		table.insert(List, Attribute)
	end

	if nil ~= SizeX and nil ~= SizeY then
		local Attribute = string.format(" size=\"%d;%d\"", SizeX, SizeY)
		table.insert(List, Attribute)
	end

	if nil ~= Baseline then
		local Attribute = string.format(" baseline=\"%d\"", Baseline)
		table.insert(List, Attribute)
	end

	if nil ~= Frame then
		local Attribute = string.format(" frame=\"%d\"", Frame)
		table.insert(List, Attribute)
	end

	if nil ~= FrameRate then
		local Attribute = string.format(" frameRate=\"%d\"", FrameRate)
		table.insert(List, Attribute)
	end

	return table.concat(List)
end

---ReviseColor @如果颜色字符串不是以#开头 则在开头添加#
---@param Color string @"#ffffffff" | "ffffffff"
function RichTextUtil.ReviseColor(Color)
	return string.format("#%s", string.gsub(Color, "^#", ""))
end

function RichTextUtil.ClearHyperlinkAttr( Text )
	if string.isnilorempty(Text) then
		return Text
	end

	local Ret = string.gsub(Text, "</>", "")

	for k, _ in string.gmatch(Ret, "(<a .->)") do
		Ret = string.gsub(Ret, k, "")
	end

	return Ret
end

return RichTextUtil
