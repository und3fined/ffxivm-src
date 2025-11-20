---
--- Author: Administrator
--- DateTime: 2025-07-16 16:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class PVPColosseumStarItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgStar UFImage
---@field ImgStarEmpty UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPColosseumStarItemView = LuaClass(UIView, true)

function PVPColosseumStarItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgStar = nil
	--self.ImgStarEmpty = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPColosseumStarItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPColosseumStarItemView:OnInit()
	self.Binders = {
		{ "IsGlow", UIBinderValueChangedCallback.New(self, nil, self.SetStarGlow) },
	}
end

function PVPColosseumStarItemView:OnDestroy()

end

function PVPColosseumStarItemView:OnShow()

end

function PVPColosseumStarItemView:OnHide()

end

function PVPColosseumStarItemView:OnRegisterUIEvent()

end

function PVPColosseumStarItemView:OnRegisterGameEvent()

end

function PVPColosseumStarItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then return end

	local ViewModel = Params.Data
	if ViewModel == nil then return end

	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end

function PVPColosseumStarItemView:SetStarGlow(IsGlow)
	UIUtil.SetIsVisible(self.ImgStar, IsGlow)
	UIUtil.SetIsVisible(self.ImgStarEmpty, not IsGlow)
end

return PVPColosseumStarItemView