---
--- Author: peterxie
--- DateTime:
--- Description: 水晶冲突比赛结果
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PVPColosseumRecordVM = require("Game/PVP/Record/VM/PVPColosseumRecordVM")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local PVPColosseumMgr = _G.PVPColosseumMgr

---@class PVPColosseumRecordItemView : UIView
---@field ViewModel PVPColosseumRecordItemVM
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGood UFButton
---@field IconGood UFImage
---@field IconJob UFImage
---@field ImgLight UFImage
---@field PanelKDA UFCanvasPanel
---@field PanelRecord UFCanvasPanel
---@field TextA UFTextBlock
---@field TextD UFTextBlock
---@field TextGood UFTextBlock
---@field TextHurt UFTextBlock
---@field TextInTreatment UFTextBlock
---@field TextInjured UFTextBlock
---@field TextK UFTextBlock
---@field TextName UFTextBlock
---@field TextTime UFTextBlock
---@field AnimIconGood UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPColosseumRecordItemView = LuaClass(UIView, true)

function PVPColosseumRecordItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGood = nil
	--self.IconGood = nil
	--self.IconJob = nil
	--self.ImgLight = nil
	--self.PanelKDA = nil
	--self.PanelRecord = nil
	--self.TextA = nil
	--self.TextD = nil
	--self.TextGood = nil
	--self.TextHurt = nil
	--self.TextInTreatment = nil
	--self.TextInjured = nil
	--self.TextK = nil
	--self.TextName = nil
	--self.TextTime = nil
	--self.AnimIconGood = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPColosseumRecordItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPColosseumRecordItemView:OnInit()
	self.Binders =
	{
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "ProfID", UIBinderSetProfIcon.New(self, self.IconJob) },

		{ "KillCount", UIBinderSetText.New(self, self.TextK) },
		{ "DeadCount", UIBinderSetText.New(self, self.TextD) },
		{ "AssistCount", UIBinderSetText.New(self, self.TextA) },
		{ "EscortTime", UIBinderSetText.New(self, self.TextTime) },

		{ "Damage", UIBinderSetText.New(self, self.TextHurt) },
		{ "Damaged", UIBinderSetText.New(self, self.TextInjured) },
		{ "Heal", UIBinderSetText.New(self, self.TextInTreatment) },

		{ "IsMajor", UIBinderSetIsVisible.New(self, self.ImgLight) },

		{ "ShowLikeCount", UIBinderSetIsVisible.New(self, self.TextGood) },
		{ "LikeCount", UIBinderSetText.New(self, self.TextGood) },
		{ "IconLikePath", UIBinderSetBrushFromAssetPath.New(self, self.IconGood) },
		{ "ShowIconLike", UIBinderValueChangedCallback.New(self, nil, self.OnShowIconLikeChanged) },
		{ "ShowBtnLike", UIBinderSetIsVisible.New(self, self.BtnGood, nil, true) },
	}

	self.BindersShowData =
	{
		{ "ShowData", UIBinderSetIsVisible.New(self, self.PanelRecord) },
		{ "ShowData", UIBinderSetIsVisible.New(self, self.PanelKDA, true) },
	}
end

function PVPColosseumRecordItemView:OnDestroy()

end

function PVPColosseumRecordItemView:OnShow()

end

function PVPColosseumRecordItemView:OnHide()

end

function PVPColosseumRecordItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGood, self.OnClickedBtnGood)
end

function PVPColosseumRecordItemView:OnRegisterGameEvent()

end

function PVPColosseumRecordItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end
	self.ViewModel = ViewModel
	self:RegisterBinders(self.ViewModel, self.Binders)
	self:RegisterBinders(PVPColosseumRecordVM, self.BindersShowData)
end

function PVPColosseumRecordItemView:OnShowIconLikeChanged(NewValue, OldValue)
	if NewValue and self.ViewModel.IsMajor == false then
		self:PlayAnimation(self.AnimIconGood)
	end
	
	UIUtil.SetIsVisible(self.IconGood, NewValue)
end

-- 点赞
function PVPColosseumRecordItemView:OnClickedBtnGood()
	if nil == self.ViewModel then return end

	if PVPColosseumRecordVM:GetCanLike() then
		local ToLikeRoleID = self.ViewModel.RoleID
		PVPColosseumMgr:RequestLikeRole(PVPColosseumRecordVM.SceneInstID, ToLikeRoleID)
		PVPColosseumRecordVM:SetCanLike(false)
	end
end

return PVPColosseumRecordItemView