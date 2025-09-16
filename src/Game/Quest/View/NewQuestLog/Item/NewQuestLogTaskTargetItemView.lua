---
--- Author: lydianwang
--- DateTime: 2023-05-31 11:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

local ProtoCS = require("Protocol/ProtoCS")
local TARGET_STATUS = ProtoCS.CS_QUEST_NODE_STATUS

local DefaultColorHex = "#313131"
local FinishedColorHex = "#6C6964"
local EToggleButtonState = _G.UE.EToggleButtonState

---@class NewQuestLogTaskTargetItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconToggleButton UToggleButton
---@field ImgFocus UFImage
---@field ImgTargetBg UFImage
---@field PanelRoot UFCanvasPanel
---@field TextTarget URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewQuestLogTaskTargetItemView = LuaClass(UIView, true)

function NewQuestLogTaskTargetItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconToggleButton = nil
	--self.ImgFocus = nil
	--self.ImgTargetBg = nil
	--self.PanelRoot = nil
	--self.TextTarget = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewQuestLogTaskTargetItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewQuestLogTaskTargetItemView:OnInit()

end

function NewQuestLogTaskTargetItemView:OnDestroy()

end

function NewQuestLogTaskTargetItemView:OnShow()

end

function NewQuestLogTaskTargetItemView:OnHide()

end

function NewQuestLogTaskTargetItemView:OnRegisterUIEvent()

end

function NewQuestLogTaskTargetItemView:OnRegisterGameEvent()

end

function NewQuestLogTaskTargetItemView:OnRegisterBinder()
	if nil == self.Params then return end
	local TargetVM = self.Params.Data
	if nil == TargetVM then return end

	if not self.TargetVMBinders then
		self.TargetVMBinders = {
			{ "Desc", UIBinderSetText.New(self, self.TextTarget) },
			{ "Count", UIBinderValueChangedCallback.New(self, nil, self.OnCountChanged) },
			{ "LogTextColor", UIBinderSetColorAndOpacityHex.New(self, self.TextTarget) },
			{ "IsFocusTarget", UIBinderSetIsVisible.New(self, self.ImgFocus) },
		}
	end
	self:RegisterBinders(TargetVM, self.TargetVMBinders)

	if TargetVM.OwnerChapterVM then
		local ChapterVMBinders = {
			{ "TrackTargetID", UIBinderValueChangedCallback.New(self, nil, self.OnTargetTrackingChanged) },
		}
		self:RegisterBinders(TargetVM.OwnerChapterVM, ChapterVMBinders)
	end
end

function NewQuestLogTaskTargetItemView:OnTargetTrackingChanged(NewValue, OldValue)
	if not self.Params or not self.Params.Data then
		self.IconToggleButton:SetCheckedState(0, false)
		return
	end
	
	local TargetVM = self.Params.Data
	local OldState = self.IconToggleButton:GetCheckedState()
	if OldState == EToggleButtonState.Checked then -- 已完成的目标不改图标
		return
	end

	local OwnerChapterVM = TargetVM.OwnerChapterVM
	if OwnerChapterVM then
		local NearestTarget = false
		local bTracking = OwnerChapterVM.bTracking
		local TrackTargetID = OwnerChapterVM.TrackTargetID

		if OwnerChapterVM.TargetVMList:Length() <= 1 then
			NearestTarget = true
		else
			if not TrackTargetID then
				NearestTarget = true
			else
				if TargetVM.TargetID < 1000 and TargetVM.GroupedTargetIDList then
					for _,Val in ipairs(TargetVM.GroupedTargetIDList) do
						if Val == TrackTargetID then
							NearestTarget = true
							break
						end
					end
				else
					NearestTarget = TrackTargetID == TargetVM.TargetID
				end
			end
		end

		local ShowLocked = bTracking and NearestTarget
		local NewState = ShowLocked and EToggleButtonState.Locked or EToggleButtonState.Unchecked
		self.IconToggleButton:SetCheckedState(NewState, false)
	end
end

function NewQuestLogTaskTargetItemView:OnCountChanged(_)
	if nil == self.Params then return end
	local TargetVM = self.Params.Data
	if nil == TargetVM then return end

	local IsFinished = (TargetVM.Status == TARGET_STATUS.CS_QUEST_NODE_STATUS_FINISHED)
	TargetVM.LogTextColor = IsFinished and FinishedColorHex or DefaultColorHex
	self.IconToggleButton:SetChecked(IsFinished, false)
	UIUtil.SetIsVisible(self.PanelRoot, true, not IsFinished)
	UIUtil.SetIsVisible(self.ImgTargetBg, not IsFinished, not IsFinished)

	local bShowItemView = TargetVM.IsShowItemView
	if bShowItemView and TargetVM.Count and TargetVM.MaxCount then
		local Desc = string.format("%s %d/%d", TargetVM.Desc, TargetVM.Count , TargetVM.MaxCount)
		self.TextTarget:SetText(Desc)
	else
		self.TextTarget:SetText(TargetVM.Desc)
	end
end

function NewQuestLogTaskTargetItemView:OnSelectChanged(IsSelected)
	if nil == self.Params then return end
	local TargetVM = self.Params.Data
	if nil == TargetVM then return end

	TargetVM.IsFocusTarget = IsSelected
end

return NewQuestLogTaskTargetItemView