---
--- Author: Administrator
--- DateTime: 2024-09-10 11:42
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetCheckedState = require("Binder/UIBinderSetCheckedState")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local GoldSauserMainPanelMainVM = require("Game/GoldSauserMainPanel/VM/GoldSauserMainPanelMainVM")
local EToggleButtonState = _G.UE.EToggleButtonState
local UIViewMgr
local UIViewID = _G.UIViewID
local LSTR = _G.LSTR

---@class GoldSaucerMainPanelChallengeNotesListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconTask UFImage
---@field TableViewSlot UTableView
---@field TextBtnDisabled UFTextBlock
---@field TextBtnNoraml UFTextBlock
---@field TextBtnRocom UFTextBlock
---@field TextSchedule URichTextBox
---@field TextTask UFTextBlock
---@field ToggleBtn UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerMainPanelChallengeNotesListItemView = LuaClass(UIView, true)

function GoldSaucerMainPanelChallengeNotesListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconTask = nil
	--self.TableViewSlot = nil
	--self.TextBtnDisabled = nil
	--self.TextBtnNoraml = nil
	--self.TextBtnRocom = nil
	--self.TextSchedule = nil
	--self.TextTask = nil
	--self.ToggleBtn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerMainPanelChallengeNotesListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerMainPanelChallengeNotesListItemView:InitConstStringInfo()
	self.TextBtnRocom:SetText(LSTR(350045))
	self.TextBtnNoraml:SetText(LSTR(350034))
end

function GoldSaucerMainPanelChallengeNotesListItemView:OnInit()
	self.AdapterRewardList = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot)
	UIViewMgr = _G.UIViewMgr
	self:InitConstStringInfo()
end

function GoldSaucerMainPanelChallengeNotesListItemView:OnDestroy()

end

function GoldSaucerMainPanelChallengeNotesListItemView:OnShow()

end

function GoldSaucerMainPanelChallengeNotesListItemView:OnHide()

end

function GoldSaucerMainPanelChallengeNotesListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleBtn, self.OnToggleBtnClicked)
end

function GoldSaucerMainPanelChallengeNotesListItemView:OnRegisterGameEvent()

end

function GoldSaucerMainPanelChallengeNotesListItemView:OnRegisterBinder()
	local Params = self.Params
	if not Params then
		return
	end
	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	local Binders = {
		{ "RewardList", UIBinderUpdateBindableList.New(self, self.AdapterRewardList)},
		{ "MainIconPath", UIBinderSetImageBrush.New(self, self.IconTask)},
		{ "ContentText", UIBinderSetText.New(self, self.TextTask)},
		{ "DescriptionText", UIBinderSetText.New(self, self.TextSchedule)},
		--{ "IsDescriptionVisible", UIBinderSetIsVisible.New(self, self.TextSchedule)},
		{ "ToggleBtnState", UIBinderSetCheckedState.New(self, self.ToggleBtn) },
		{ "DisabledText", UIBinderSetText.New(self, self.TextBtnDisabled)},
		{ "IsNewRedVisible", UIBinderSetIsVisible.New(self, self.RedDot)}
	}

	self:RegisterBinders(ViewModel, Binders)
end

function GoldSaucerMainPanelChallengeNotesListItemView:OnToggleBtnClicked()
	local Btn = self.ToggleBtn
	if not Btn then
		return
	end

	local CheckState = Btn:GetCheckedState()

	if CheckState == EToggleButtonState.Locked then
		return
	end

	local Params = self.Params
	if not Params then
		return
	end
	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	local ID = ViewModel.ID
	if not ID then
		return
	end

	local NoteVM = GoldSauserMainPanelMainVM:GetGoldSauserMainPanelChallengNoteVM()
	if not NoteVM then
		return
	end

	if CheckState == EToggleButtonState.Unchecked then -- 领取
		local OnClickGet  = ViewModel.OnClickGet
		if OnClickGet then
			OnClickGet(NoteVM, ID)
		end
	elseif CheckState == EToggleButtonState.Checked then -- 前往
		local OnClickGo  = ViewModel.OnClickGo
		if OnClickGo then
			OnClickGo(NoteVM, ID)
			UIViewMgr:HideView(UIViewID.GoldSaucerMainPanelChallengeNotesWin)
		end
	end
end

return GoldSaucerMainPanelChallengeNotesListItemView