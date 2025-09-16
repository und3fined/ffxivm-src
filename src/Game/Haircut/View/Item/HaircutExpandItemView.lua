---
--- Author: jamiyang
--- DateTime: 2024-01-23 09:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class HaircutExpandItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnStretch UFButton
---@field ImgArrowExpand UFImage
---@field ImgArrowRetract UFImage
---@field TextStretch_1 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HaircutExpandItemView = LuaClass(UIView, true)

function HaircutExpandItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnStretch = nil
	--self.ImgArrowExpand = nil
	--self.ImgArrowRetract = nil
	--self.TextStretch_1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HaircutExpandItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HaircutExpandItemView:OnInit()

end

function HaircutExpandItemView:OnDestroy()

end

function HaircutExpandItemView:OnShow()
	UIUtil.SetIsVisible(self.ImgArrowExpand, true)
	UIUtil.SetIsVisible(self.ImgArrowRetract,  false)
	self.TextStretch_1:SetText(_G.LSTR(1250018)) --"展开"
end

function HaircutExpandItemView:OnHide()

end

function HaircutExpandItemView:OnRegisterUIEvent()

end

function HaircutExpandItemView:OnRegisterGameEvent()

end

function HaircutExpandItemView:OnRegisterBinder()

end

function HaircutExpandItemView:SetExpandState(IsExpanded)
	UIUtil.SetIsVisible(self.ImgArrowExpand, not IsExpanded)
	UIUtil.SetIsVisible(self.ImgArrowRetract, IsExpanded)
	local Text = IsExpanded == true and _G.LSTR("1250019") or _G.LSTR("1250018") --"收起" "展开"
	self.TextStretch_1:SetText(Text)
end

return HaircutExpandItemView