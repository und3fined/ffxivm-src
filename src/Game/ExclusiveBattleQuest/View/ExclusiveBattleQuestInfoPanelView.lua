---
--- Author: Administrator
--- DateTime: 2024-09-06 16:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local MainPanelVM = require("Game/Main/MainPanelVM")
local ExclusiveBattleQuestVM = require ("Game/ExclusiveBattleQuest/VM/ExclusiveBattleQuestVM")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")

local HelpTipsID = 0 -- 帮助按钮弹出对应的ID


---@class ExclusiveBattleQuestInfoPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnFold UToggleButton
---@field BtnTips CommInforBtnView
---@field CommTextSlide CommTextSlideView
---@field ImgDown UFImage
---@field ImgUp UFImage
---@field PanelRegionClear UFCanvasPanel
---@field ProBar UProgressBar
---@field TextProgress UFTextBlock
---@field AnimHighlightIn UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimProgressUpdate UWidgetAnimation
---@field AnimUnfold UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ExclusiveBattleQuestInfoPanelView = LuaClass(UIView, true)

function ExclusiveBattleQuestInfoPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnFold = nil
	--self.BtnTips = nil
	--self.CommTextSlide = nil
	--self.ImgDown = nil
	--self.ImgUp = nil
	--self.PanelRegionClear = nil
	--self.ProBar = nil
	--self.TextProgress = nil
	--self.AnimHighlightIn = nil
	--self.AnimIn = nil
	--self.AnimProgressUpdate = nil
	--self.AnimUnfold = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ExclusiveBattleQuestInfoPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnTips)
	self:AddSubView(self.CommTextSlide)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ExclusiveBattleQuestInfoPanelView:OnInit()
	self.ViewModel = ExclusiveBattleQuestVM.InfoVM
    self.BtnTips.HelpInfoID = HelpTipsID
	self.Binders = {
        {"QuestName", UIBinderValueChangedCallback.New(self, nil, self.OnQuesttNameChanged)},
        {"IsFold", UIBinderSetIsVisible.New(self, self.PanelRegionClear, true)},
        {"IsFold", UIBinderValueChangedCallback.New(self, nil, self.OnIsFoldChanged)},
		{"IsFold", UIBinderSetIsChecked.New(self, self.BtnFold)},
        {"Progress", UIBinderValueChangedCallback.New(self, nil, self.OnProgressChanged)},
		{ "SliderPercent", UIBinderSetPercent.New(self, self.ProBar) },
	}
end

function ExclusiveBattleQuestInfoPanelView:OnDestroy()

end

function ExclusiveBattleQuestInfoPanelView:OnShow()

end

function ExclusiveBattleQuestInfoPanelView:OnHide()

end

function ExclusiveBattleQuestInfoPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnFold, self.OnClickButtonFold)

end

function ExclusiveBattleQuestInfoPanelView:OnRegisterGameEvent()

end

function ExclusiveBattleQuestInfoPanelView:OnRegisterBinder()
    self:RegisterBinders(self.ViewModel, self.Binders)
end

function ExclusiveBattleQuestInfoPanelView:OnClickButtonFold()
	self.ViewModel:SetIsFold(not self.ViewModel:GetIsFold())
end

function ExclusiveBattleQuestInfoPanelView:OnQuesttNameChanged(NewValue, OldValue)
    self.CommTextSlide:ShowSliderText(NewValue)
end

function ExclusiveBattleQuestInfoPanelView:OnIsFoldChanged(IsFold)
	if not IsFold then
		self:PlayAnimation(self.AnimUnfold)
	end

	MainPanelVM:SetFunctionVisible(IsFold)
end

function ExclusiveBattleQuestInfoPanelView:OnProgressChanged(Progress)
	local Str = string.format(_G.LSTR(410001), Progress, self.ViewModel:GetMaxProgress())
	self.TextProgress:SetText(Str)

	self:PlayAnimation(self.AnimProgressUpdate)
end

return ExclusiveBattleQuestInfoPanelView