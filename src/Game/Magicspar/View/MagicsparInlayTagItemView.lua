---
--- Author: jamiyang
--- DateTime: 2023-04-03 16:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
--local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
--local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIUtil = require("Utils/UIUtil")

---@class MagicsparInlayTagItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FBtn_InlaySlot UFButton
---@field Img_Icon UFImage
---@field Img_Select UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MagicsparInlayTagItemView = LuaClass(UIView, true)

function MagicsparInlayTagItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FBtn_InlaySlot = nil
	--self.Img_Icon = nil
	--self.Img_Select = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MagicsparInlayTagItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MagicsparInlayTagItemView:OnInit()

end

function MagicsparInlayTagItemView:OnDestroy()

end

function MagicsparInlayTagItemView:OnShow()
	self:SetSelectState(false)
end

function MagicsparInlayTagItemView:OnHide()

end

function MagicsparInlayTagItemView:OnRegisterUIEvent()

end

function MagicsparInlayTagItemView:OnRegisterGameEvent()

end

function MagicsparInlayTagItemView:OnRegisterBinder()
	--local Binders = {
		--{ "bSelected", UIBinderSetIsVisible.New(self, self.Img_Select) },
		--{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.Img_Icon)},
	--}
	--self:RegisterBinders(self.ViewModel, Binders)

end

function MagicsparInlayTagItemView:SetIcon(bNormal)
	local IconPath = nil
	if bNormal then
		IconPath = "PaperSprite'/Game/UI/Atlas/Magicspar/Frames/UI_Magicspar_Tag_Circle_Blue_png.UI_Magicspar_Tag_Circle_Blue_png'"
	else
		IconPath = "PaperSprite'/Game/UI/Atlas/Magicspar/Frames/UI_Magicspar_Tag_Circle_Red_png.UI_Magicspar_Tag_Circle_Red_png'"
	end
	UIUtil.ImageSetBrushFromAssetPath(self.Img_Icon, IconPath, false)
end

function MagicsparInlayTagItemView:SetSelectState(bSelected)
	UIUtil.SetIsVisible(self.Img_Select, bSelected)
end
return MagicsparInlayTagItemView