---
--- Author: Administrator
--- DateTime: 2024-11-18 11:06
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PVPInfoDefine = require("Game/PVP/PVPInfoDefine")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local HonorColorMap = PVPInfoDefine.HonorColorMap
local FLinearColor = _G.UE.FLinearColor

---@class PVPInfoHonorItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field ImgNotOwnBG UFImage
---@field ImgOwnBG UFImage
---@field TextDate UFTextBlock
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPInfoHonorItemView = LuaClass(UIView, true)

function PVPInfoHonorItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.ImgNotOwnBG = nil
	--self.ImgOwnBG = nil
	--self.TextDate = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPInfoHonorItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPInfoHonorItemView:OnInit()
	self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "GetDate", UIBinderSetText.New(self, self.TextDate) },
		{ "IsSelected", UIBinderSetIsVisible.New(self, self.ImgSelect) },
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "IsOwn", UIBinderValueChangedCallback.New(self, nil, self.OnIsOwnChanged) },
	}
end

function PVPInfoHonorItemView:OnDestroy()

end

function PVPInfoHonorItemView:OnShow()

end

function PVPInfoHonorItemView:OnHide()

end

function PVPInfoHonorItemView:OnRegisterUIEvent()

end

function PVPInfoHonorItemView:OnRegisterGameEvent()

end

function PVPInfoHonorItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then return end

	local ViewModel = Params.Data
	if ViewModel == nil then return end

	self:RegisterBinders(ViewModel, self.Binders)
end

function PVPInfoHonorItemView:OnIsOwnChanged(NewValue, OldValue)
	local LinearNameColor, LinearDateColor

	if NewValue then
		LinearNameColor = FLinearColor.FromHex(HonorColorMap.OwnNameColor)
		LinearDateColor = FLinearColor.FromHex(HonorColorMap.OwnDateColor)
	else
		LinearNameColor = FLinearColor.FromHex(HonorColorMap.NotOwnNameColor)
		LinearDateColor = FLinearColor.FromHex(HonorColorMap.NotOwnDateColor)
	end

	self.TextName:SetColorAndOpacity(LinearNameColor)
	self.TextDate:SetColorAndOpacity(LinearDateColor)
	UIUtil.SetIsVisible(self.ImgOwnBG, NewValue)
	UIUtil.SetIsVisible(self.ImgNotOwnBG, not NewValue)
end

return PVPInfoHonorItemView