---
--- Author: Administrator
--- DateTime: 2023-06-01 16:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class TutorialGuideShowDropItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgNormal UFImage
---@field ImgSelect UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TutorialGuideShowDropItemView = LuaClass(UIView, true)

function TutorialGuideShowDropItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgNormal = nil
	--self.ImgSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TutorialGuideShowDropItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TutorialGuideShowDropItemView:OnInit()

	self.Binders = {
		{ "IsSelected", UIBinderSetIsVisible.New(self, self.ImgSelect) },
	}
	
end

function TutorialGuideShowDropItemView:OnDestroy()
end

function TutorialGuideShowDropItemView:OnShow()

end

function TutorialGuideShowDropItemView:OnHide()

end

function TutorialGuideShowDropItemView:OnRegisterUIEvent()

end

function TutorialGuideShowDropItemView:OnRegisterGameEvent()

end

function TutorialGuideShowDropItemView:OnRegisterBinder()
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


function TutorialGuideShowDropItemView:OnSelectChanged(bSelected)
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

return TutorialGuideShowDropItemView