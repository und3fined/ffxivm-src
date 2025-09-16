---
--- Author: chunfengluo
--- DateTime: 2024-12-26 19:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderCanvasSlotSetPosition = require("Binder/UIBinderCanvasSlotSetPosition")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local MountGuidelineItemVM = require("Game/Mount/VM/MountGuidelineItemVM")

---@class MountGuidelineItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field MountGuidelineLeftItem MountGuidelineLeftItemView
---@field MountGuidelineRightItem MountGuidelineRightItemView
---@field PanelGuideline UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MountGuidelineItemView = LuaClass(UIView, true)

function MountGuidelineItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.MountGuidelineLeftItem = nil
	--self.MountGuidelineRightItem = nil
	--self.PanelGuideline = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MountGuidelineItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.MountGuidelineLeftItem)
	self:AddSubView(self.MountGuidelineRightItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MountGuidelineItemView:OnInit()
	self.Binders = {
		{ "Text", UIBinderSetText.New(self, self.MountGuidelineLeftItem.Text) },
		{ "Text", UIBinderSetText.New(self, self.MountGuidelineRightItem.Text) },
		{ "Offset", UIBinderCanvasSlotSetPosition.New(self, self) },
		{ "Direction", UIBinderValueChangedCallback.New(self, nil, self.OnDirectionChanged)},
	}
	self.ViewModel = MountGuidelineItemVM.New()
end

function MountGuidelineItemView:OnDestroy()

end

function MountGuidelineItemView:OnShow()

end

function MountGuidelineItemView:OnHide()

end

function MountGuidelineItemView:OnRegisterUIEvent()
	
end

function MountGuidelineItemView:OnRegisterGameEvent()

end

function MountGuidelineItemView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function MountGuidelineItemView:OnDirectionChanged(Value)
	UIUtil.SetIsVisible(self.MountGuidelineLeftItem, Value == 1)
	UIUtil.SetIsVisible(self.MountGuidelineRightItem, Value == 2)
	self.MountGuidelineLeftItem.Btn:SetVisibility(_G.UE.ESlateVisibility.Visible)
	self.MountGuidelineRightItem.Btn:SetVisibility(_G.UE.ESlateVisibility.Visible)
end

function MountGuidelineItemView:PlayAnimationClick()
	self.MountGuidelineLeftItem:PlayAnimation(self.MountGuidelineLeftItem.AnimClick)
	self.MountGuidelineRightItem:PlayAnimation(self.MountGuidelineRightItem.AnimClick)
end

function MountGuidelineItemView:PlayAnimationHide()
	if not self.MountGuidelineLeftItem:IsAnimationPlaying(self.MountGuidelineLeftItem.AnimOut1) and
		UIUtil.IsVisible(self.MountGuidelineLeftItem) then
		self.MountGuidelineLeftItem:PlayAnimation(self.MountGuidelineLeftItem.AnimOut1)
	end
	if not self.MountGuidelineRightItem:IsAnimationPlaying(self.MountGuidelineRightItem.AnimOut1) and
		UIUtil.IsVisible(self.MountGuidelineRightItem) then
		self.MountGuidelineRightItem:PlayAnimation(self.MountGuidelineRightItem.AnimOut1)
	end
end

return MountGuidelineItemView