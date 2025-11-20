---
--- Author: Administrator
--- DateTime: 2025-07-14 19:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")

---@class CommRewardHairstyleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FCanvasPanel_60 UFCanvasPanel
---@field ImgHairstyle UFImage
---@field TextName UFTextBlock
---@field AnimAdditionUpNumber UWidgetAnimation
---@field AnimIn_1 UWidgetAnimation
---@field CurveAddition CurveFloat
---@field ValueAddition float
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommRewardHairstyleItemView = LuaClass(UIView, true)

function CommRewardHairstyleItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FCanvasPanel_60 = nil
	--self.ImgHairstyle = nil
	--self.TextName = nil
	--self.AnimAdditionUpNumber = nil
	--self.AnimIn_1 = nil
	--self.CurveAddition = nil
	--self.ValueAddition = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommRewardHairstyleItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommRewardHairstyleItemView:OnInit()
	self.Binders = {
		{ "ItemNameVisible", UIBinderSetIsVisible.New(self, self.TextName) },
		{ "ItemName", UIBinderSetText.New(self, self.TextName) },
		{ "HairStyleIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgHairstyle) },
		-- RewardItemPlayAnimIn  是用于CommRewardPanelView方便控制 CommRewardItemView 入场动画播放，不需要自己去控制播放
		{ "RewardItemPlayAnimIn", UIBinderValueChangedCallback.New(self, nil, self.OnRewardItemPlayAnimInChanged) }, 
	}
end

function CommRewardHairstyleItemView:OnDestroy()

end

function CommRewardHairstyleItemView:OnShow()
	local RewardPanel = _G.UIViewMgr:FindView(_G.UIViewID.CommonRewardAppHairStylePanel)
	if RewardPanel ~= nil then
		if RewardPanel.PlayedAnimFirstIn then
			UIUtil.SetRenderOpacity(self.FCanvasPanel_60, 0)
		end
	end
end

function CommRewardHairstyleItemView:OnHide()

end

function CommRewardHairstyleItemView:OnRegisterUIEvent()

end

function CommRewardHairstyleItemView:OnRegisterGameEvent()

end

function CommRewardHairstyleItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
			return
	end
	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end
	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end

function CommRewardHairstyleItemView:OnRewardItemPlayAnimInChanged(NewValue)
	if NewValue then 
		self:PlayAnimation(self.AnimIn_1)
	end
end

return CommRewardHairstyleItemView