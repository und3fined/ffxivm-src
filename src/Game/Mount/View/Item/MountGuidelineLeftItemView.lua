---
--- Author: chunfengluo
--- DateTime: 2024-12-26 19:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class MountGuidelineLeftItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field Text UFTextBlock
---@field AnimClick UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MountGuidelineLeftItemView = LuaClass(UIView, true)

function MountGuidelineLeftItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.Text = nil
	--self.AnimClick = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MountGuidelineLeftItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MountGuidelineLeftItemView:OnInit()

end

function MountGuidelineLeftItemView:OnDestroy()

end

function MountGuidelineLeftItemView:OnShow()

end

function MountGuidelineLeftItemView:OnHide()

end

function MountGuidelineLeftItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnBtnClicked)
end

function MountGuidelineLeftItemView:OnRegisterGameEvent()

end

function MountGuidelineLeftItemView:OnRegisterBinder()

end

function MountGuidelineLeftItemView:OnBtnClicked()
	local CustomMadeView = _G.UIViewMgr:FindView(_G.UIViewID.MountCustomMadePanel)
	CustomMadeView:OnClickGuideline(self.ParentView.ViewModel.Index)
	self.Btn:SetVisibility(_G.UE.ESlateVisibility.SelfHitTestInvisible)
end

function MountGuidelineLeftItemView:OnAnimationFinished(Anim)
	if Anim == self.AnimOut1 or Anim == self.AnimClick then
		UIUtil.SetIsVisible(self, false)
	end
end

return MountGuidelineLeftItemView