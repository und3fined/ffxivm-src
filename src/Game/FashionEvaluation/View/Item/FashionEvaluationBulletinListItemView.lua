---
--- Author: Administrator
--- DateTime: 2024-02-20 17:09
--- Description:主界面 进度奖励列表Item
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class FashionEvaluationBulletinListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Icon UFImage
---@field IconRound UFImage
---@field IconSwitch UFWidgetSwitcher
---@field Icon_1 UFImage
---@field TextQuantity UFTextBlock
---@field TextTtile UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionEvaluationBulletinListItemView = LuaClass(UIView, true)

function FashionEvaluationBulletinListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Icon = nil
	--self.IconRound = nil
	--self.IconSwitch = nil
	--self.Icon_1 = nil
	--self.TextQuantity = nil
	--self.TextTtile = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionEvaluationBulletinListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionEvaluationBulletinListItemView:OnInit()
	self.Binders = {
		{"IsGetProgress", UIBinderValueChangedCallback.New(self, nil, self.OnIsGetProgressChanged)},
		{"ProgressName", UIBinderSetText.New(self, self.TextTtile)},
		{"AwardIcon", UIBinderSetBrushFromAssetPath.New(self, self.Icon_1)},
		{"AwardNum", UIBinderSetText.New(self, self.TextQuantity)},
	}
end

function FashionEvaluationBulletinListItemView:OnDestroy()

end

function FashionEvaluationBulletinListItemView:OnShow()

end

function FashionEvaluationBulletinListItemView:OnHide()

end

function FashionEvaluationBulletinListItemView:OnRegisterUIEvent()

end

function FashionEvaluationBulletinListItemView:OnRegisterGameEvent()

end

function FashionEvaluationBulletinListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	self.ViewModel = Params.Data
	if nil == self.ViewModel then
		return
	end
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function FashionEvaluationBulletinListItemView:OnIsGetProgressChanged(IsGetProgress)
	local Index = IsGetProgress and 0 or 1
	self.IconSwitch:SetActiveWidgetIndex(Index)
end

return FashionEvaluationBulletinListItemView