---
--- Author: Administrator
--- DateTime: 2024-06-19 17:17
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LeveQuestPaySettingsWinVM = require("Game/LeveQuest/VM/Item/LeveQuestPaySettingsWinVM")
local UIBinderSetIsChecked =  require("Binder/UIBinderSetIsChecked")
local LeveQuestDefine = require("Game/LeveQuest/LeveQuestDefine")

---@class LeveQuestPaySettingsWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCancel CommBtnLView
---@field BtnSave CommBtnLView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field ImgBox UFImage
---@field ImgBox2 UFImage
---@field ImgCheck UFImage
---@field ImgCheck2 UFImage
---@field TextMultiple UFTextBlock
---@field TextMultiple_1 UFTextBlock
---@field TextSingle UFTextBlock
---@field ToggleButton1 UToggleButton
---@field ToggleButton2 UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LeveQuestPaySettingsWinView = LuaClass(UIView, true)

function LeveQuestPaySettingsWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCancel = nil
	--self.BtnSave = nil
	--self.Comm2FrameM_UIBP = nil
	--self.ImgBox = nil
	--self.ImgBox2 = nil
	--self.ImgCheck = nil
	--self.ImgCheck2 = nil
	--self.TextMultiple = nil
	--self.TextMultiple_1 = nil
	--self.TextSingle = nil
	--self.ToggleButton1 = nil
	--self.ToggleButton2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LeveQuestPaySettingsWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnSave)
	self:AddSubView(self.Comm2FrameM_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LeveQuestPaySettingsWinView:OnInit()
	self.VM = LeveQuestPaySettingsWinVM.New()

	self.Binders = {
		{ "PaySingle",UIBinderSetIsChecked.New(self, self.ToggleButton1) },
		{ "PayMost", UIBinderSetIsChecked.New(self, self.ToggleButton2) },
	}
end

function LeveQuestPaySettingsWinView:OnDestroy()

end

function LeveQuestPaySettingsWinView:OnShow()

	local SignleOrMost = _G.LeveQuestMgr:GetPaySingleOrMost()
	local State = SignleOrMost == LeveQuestDefine.PayType.Single
	self.VM:UpdateToggleState(State, not State)

end

function LeveQuestPaySettingsWinView:OnHide()
end

function LeveQuestPaySettingsWinView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleButton1, self.OnPaySettingSingle)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleButton2, self.OnPaySettingMore )
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnClickedBtnCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnSave, self.OnClickedBtnSave)
end

function LeveQuestPaySettingsWinView:OnRegisterGameEvent()
end

function LeveQuestPaySettingsWinView:OnRegisterBinder()
	self:RegisterBinders(self.VM, self.Binders)
end

function LeveQuestPaySettingsWinView:OnPaySettingSingle(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	self.VM:UpdateToggleState(IsChecked, not IsChecked)
end

function LeveQuestPaySettingsWinView:OnPaySettingMore(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	self.VM:UpdateToggleState(not IsChecked,  IsChecked)
end

function LeveQuestPaySettingsWinView:OnClickedBtnSave()
	local State = self.VM.PaySingle
	_G.LeveQuestMgr:SetPaySingleOrMost(State)
	_G.EventMgr:SendEvent(_G.EventID.LeveQuestHideListWin)
	self:Hide()
end

function LeveQuestPaySettingsWinView:OnClickedBtnCancel()
	_G.EventMgr:SendEvent(_G.EventID.LeveQuestHideListWin)
	self:Hide()
end


return LeveQuestPaySettingsWinView