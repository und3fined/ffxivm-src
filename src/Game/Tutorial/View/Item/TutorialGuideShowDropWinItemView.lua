---
--- Author: Administrator
--- DateTime: 2024-07-30 14:57
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class TutorialGuideShowDropWinItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgNormal UFImage
---@field ImgSelect UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TutorialGuideShowDropWinItemView = LuaClass(UIView, true)

function TutorialGuideShowDropWinItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgNormal = nil
	--self.ImgSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TutorialGuideShowDropWinItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TutorialGuideShowDropWinItemView:OnInit()
	self.Binders = {
		{ "IsSelected", UIBinderSetIsVisible.New(self, self.ImgSelect) },
	}

end

function TutorialGuideShowDropWinItemView:OnDestroy()

end

function TutorialGuideShowDropWinItemView:OnShow()

end

function TutorialGuideShowDropWinItemView:OnHide()

end

function TutorialGuideShowDropWinItemView:OnRegisterUIEvent()

end

function TutorialGuideShowDropWinItemView:OnRegisterGameEvent()

end

function TutorialGuideShowDropWinItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function TutorialGuideShowDropWinItemView:OnSelectChanged(bSelected)
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	ViewModel.IsSelected = bSelected
end


return TutorialGuideShowDropWinItemView