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
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local HonorColorMap = PVPInfoDefine.HonorColorMap
local FLinearColor = _G.UE.FLinearColor

local NotOwnBGPath = "Texture2D'/Game/UI/Texture/PVP/UI_Icon_PVP_BattleInfo_WinListBG2.UI_Icon_PVP_BattleInfo_WinListBG2'"
local OwnBGPath = "Texture2D'/Game/UI/Texture/PVP/UI_Icon_PVP_BattleInfo_WinListBG.UI_Icon_PVP_BattleInfo_WinListBG'"

---@class PVPHonorItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBG UFImage
---@field ImgIcon UFImage
---@field TextCondition UFTextBlock
---@field TextDate UFTextBlock
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPHonorItemView = LuaClass(UIView, true)

function PVPHonorItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBG = nil
	--self.ImgIcon = nil
	--self.TextCondition = nil
	--self.TextDate = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPHonorItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPHonorItemView:OnInit()
	self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "GetDate", UIBinderSetText.New(self, self.TextDate) },
		{ "Condition", UIBinderSetText.New(self, self.TextCondition) },
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "IsOwn", UIBinderValueChangedCallback.New(self, nil, self.OnIsOwnChanged) },
	}
end

function PVPHonorItemView:OnDestroy()

end

function PVPHonorItemView:OnShow()
	
end

function PVPHonorItemView:OnHide()

end

function PVPHonorItemView:OnRegisterUIEvent()

end

function PVPHonorItemView:OnRegisterGameEvent()

end

function PVPHonorItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then return end

	local ViewModel = Params.Data
	if ViewModel == nil then return end

	self:RegisterBinders(ViewModel, self.Binders)
end

function PVPHonorItemView:OnIsOwnChanged(NewValue, OldValue)
	local LinearNameColor, LinearDateColor, BGPath

	if NewValue then
		LinearNameColor = FLinearColor.FromHex(HonorColorMap.OwnNameColor)
		LinearDateColor = FLinearColor.FromHex(HonorColorMap.OwnDateColor)
		BGPath = OwnBGPath
	else
		LinearNameColor = FLinearColor.FromHex(HonorColorMap.NotOwnNameColor)
		LinearDateColor = FLinearColor.FromHex(HonorColorMap.NotOwnDateColor)
		BGPath = NotOwnBGPath
	end

	self.TextName:SetColorAndOpacity(LinearNameColor)
	self.TextDate:SetColorAndOpacity(LinearDateColor)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgBG, BGPath)
end

return PVPHonorItemView