---
--- Author: Administrator
--- DateTime: 2023-06-06 10:37
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class TutorialGuideListKeywordsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconLocation UFImage
---@field TextPlace UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TutorialGuideListKeywordsItemView = LuaClass(UIView, true)

function TutorialGuideListKeywordsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconLocation = nil
	--self.TextPlace = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TutorialGuideListKeywordsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TutorialGuideListKeywordsItemView:OnInit()
    self.Binders = 
    {
        {"TextPlace",UIBinderSetText.New(self, self.TextPlace)},
    }
end

function TutorialGuideListKeywordsItemView:OnDestroy()

end

function TutorialGuideListKeywordsItemView:OnShow()

end

function TutorialGuideListKeywordsItemView:OnHide()

end

function TutorialGuideListKeywordsItemView:OnRegisterUIEvent()

end

function TutorialGuideListKeywordsItemView:OnRegisterGameEvent()

end

function TutorialGuideListKeywordsItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function TutorialGuideListKeywordsItemView:OnStateChangedEvent(View, State)
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return 
	end

	--TutorialGuidePanelVM:SelectedItem(ViewModel.Index, State)
end

return TutorialGuideListKeywordsItemView