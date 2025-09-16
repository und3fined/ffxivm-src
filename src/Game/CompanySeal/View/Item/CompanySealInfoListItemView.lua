---
--- Author: Administrator
--- DateTime: 2024-06-13 14:36
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")


---@class CompanySealInfoListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EFF UFCanvasPanel
---@field FImage_261 UFImage
---@field IconCompany UFImage
---@field IconMilitaryRank UFImage
---@field ImgBGFocus UFImage
---@field PromotedBtn UFButton
---@field RichTextCondition URichTextBox
---@field SizeBox USizeBox
---@field TextCanbepromoted UFTextBlock
---@field TextCompanySeal UFTextBlock
---@field TextLevel UFTextBlock
---@field TextMilitaryRank UFTextBlock
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CompanySealInfoListItemView = LuaClass(UIView, true)

function CompanySealInfoListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EFF = nil
	--self.FImage_261 = nil
	--self.IconCompany = nil
	--self.IconMilitaryRank = nil
	--self.ImgBGFocus = nil
	--self.PromotedBtn = nil
	--self.RichTextCondition = nil
	--self.SizeBox = nil
	--self.TextCanbepromoted = nil
	--self.TextCompanySeal = nil
	--self.TextLevel = nil
	--self.TextMilitaryRank = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CompanySealInfoListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CompanySealInfoListItemView:OnInit()
	self.Binders = {
		{ "Level", UIBinderSetText.New(self, self.TextLevel) },
		{ "RankIcon", UIBinderSetImageBrush.New(self, self.IconMilitaryRank)},
		{ "TextRank", UIBinderSetText.New(self, self.TextMilitaryRank) },
		{ "CompanySealNum", UIBinderSetText.New(self, self.TextCompanySeal) },
		{ "Condition", UIBinderSetText.New(self, self.RichTextCondition) },
		--{ "SealIconVisible", UIBinderSetIsVisible.New(self, self.IconCompany)},
		--{ "CompanySealIcon", UIBinderSetImageBrush.New(self, self.IconCompany)},
		{ "FImageVisible", UIBinderSetIsVisible.New(self, self.FImage_261)},
		{ "PromotedVisible", UIBinderSetIsVisible.New(self, self.TextCanbepromoted)},
		{ "PromotedText", UIBinderSetText.New(self, self.TextCanbepromoted)},
		{ "UnlockTextVisible", UIBinderSetIsVisible.New(self, self.UnlockText)},
		{ "UnlockText", UIBinderSetText.New(self, self.UnlockText)},
		{ "PromotedBtnVisible", UIBinderSetIsVisible.New(self, self.PromotedBtn, false, true)},
		{ "EffVisible", UIBinderSetIsVisible.New(self, self.EFF)},
		{ "BGFocusVisible", UIBinderSetIsVisible.New(self, self.ImgBGFocus)},	
		{ "PrivilegeText", UIBinderSetText.New(self, self.RichTextPrivilege)},
		{ "ImgUpVisible", UIBinderSetIsVisible.New(self, self.ImgUp)},	
		{ "ImgLockVisible", UIBinderSetIsVisible.New(self, self.ImgLock)},	
		{ "CanbepromotedText", UIBinderSetText.New(self, self.TextCanbepromoted)},	
		{ "CanbepromotedVisible", UIBinderSetIsVisible.New(self, self.TextCanbepromoted)},	
	}
end

function CompanySealInfoListItemView:OnDestroy()

end

function CompanySealInfoListItemView:OnShow()

end

function CompanySealInfoListItemView:OnHide()

end

function CompanySealInfoListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,  self.PromotedBtn, self.OnBtnPromotedBtnClick)
end

function CompanySealInfoListItemView:OnRegisterGameEvent()

end

function CompanySealInfoListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end

	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end

-- function CompanySealInfoListItemView:OnSelectChanged(NewValue)
-- 	UIUtil.SetIsVisible(self.ImgBGFocus, NewValue)
-- end

function CompanySealInfoListItemView:OnBtnPromotedBtnClick()
	_G.CompanySealMgr:OpenPromotionView()
	UIViewMgr:HideView(UIViewID.CompanySealInfoPanelView)
end



return CompanySealInfoListItemView