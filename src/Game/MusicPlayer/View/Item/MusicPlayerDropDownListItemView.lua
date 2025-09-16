---
--- Author: Administrator
--- DateTime: 2023-12-08 11:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local COLOR_NORMAL = "828282FF"
local COLOR_SELECTED = "313131"

---@class MusicPlayerDropDownListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field ImgLine UFImage
---@field ImgSelect UFImage
---@field TextContent UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MusicPlayerDropDownListItemView = LuaClass(UIView, true)

function MusicPlayerDropDownListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.ImgLine = nil
	--self.ImgSelect = nil
	--self.TextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MusicPlayerDropDownListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MusicPlayerDropDownListItemView:OnInit()

end

function MusicPlayerDropDownListItemView:OnDestroy()

end

function MusicPlayerDropDownListItemView:OnShow()
	self:UpdateItem(self.Params)
end

function MusicPlayerDropDownListItemView:OnHide()

end

function MusicPlayerDropDownListItemView:OnRegisterUIEvent()

end

function MusicPlayerDropDownListItemView:OnRegisterGameEvent()

end

function MusicPlayerDropDownListItemView:OnRegisterBinder()

end

function MusicPlayerDropDownListItemView:OnSelectChanged(IsSelected)
	UIUtil.SetIsVisible(self.ImgSelect, IsSelected)

	if IsSelected then
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextContent, COLOR_SELECTED)
	else
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextContent, COLOR_NORMAL)
	end
end

function MusicPlayerDropDownListItemView:UpdateItem(Params)
	if nil == Params then
		return
	end

	local Index = Params.Index
	local Adapter = Params.Adapter
	local Data = Params.Data

	self.TextContent:SetText(Data.Name)

	local IconPath = Data.IconPath
	if nil ~= IconPath then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, IconPath)
	end

	UIUtil.SetIsVisible(self.ImgIcon, nil ~= IconPath)
	UIUtil.SetIsVisible(self.ImgLine, Index < Adapter:GetNum())
end

return MusicPlayerDropDownListItemView