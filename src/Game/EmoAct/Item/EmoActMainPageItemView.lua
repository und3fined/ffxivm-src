---
--- Author: Administrator
--- DateTime: 2023-09-13 20:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class EmoActMainPageItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonRedDot2 CommonRedDot2View
---@field ImgIcon UFImage
---@field ImgSelect UFImage
---@field AnimSelect UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EmoActMainPageItemView = LuaClass(UIView, true)

function EmoActMainPageItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonRedDot2 = nil
	--self.ImgIcon = nil
	--self.ImgSelect = nil
	--self.AnimSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFYs
end

function EmoActMainPageItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EmoActMainPageItemView:OnInit()

	UIUtil.SetIsVisible(self, true, true)

end

function EmoActMainPageItemView:OnDestroy()

end

function EmoActMainPageItemView:OnShow()

	if self.Params.Data.IconPath ~= nil then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, self.Params.Data.IconPath)
	end

	--配置红点路径
	if self.Params.Data.RedDotName ~= nil and self.CommonRedDot2 then
		UIUtil.SetIsVisible( self.CommonRedDot2, true )
		self.CommonRedDot2:SetRedDotNameByString(self.Params.Data.RedDotName)
	end
end

function EmoActMainPageItemView:OnSelectChanged(IsSelected)

	UIUtil.SetIsVisible(self.ImgSelect, IsSelected)

	local DataIcon = self.Params.Data.IconPath
	if IsSelected then
		--替换字符串，设置图标为高亮
		DataIcon = string.gsub(DataIcon, "Off","On")
		UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, DataIcon)

	else
		UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon,DataIcon)
	end
end

function EmoActMainPageItemView:OnHide()

end

function EmoActMainPageItemView:OnRegisterUIEvent()

end

function EmoActMainPageItemView:OnRegisterGameEvent()

end

function EmoActMainPageItemView:OnRegisterBinder()

end

return EmoActMainPageItemView