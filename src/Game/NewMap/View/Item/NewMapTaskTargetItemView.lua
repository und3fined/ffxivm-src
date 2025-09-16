---
--- Author: Administrator
--- DateTime: 2024-06-24 11:38
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")
local QuestHelper = require("Game/Quest/QuestHelper")
local MapUtil = require("Game/Map/MapUtil")
local ColorUtil = require("Utils/ColorUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

local TARGET_STATUS = ProtoCS.CS_QUEST_NODE_STATUS
local DefaultColorHex = "#D5D5D5"
local FinishedColorHex = "#696969"
local EToggleButtonState = _G.UE.EToggleButtonState

---@class NewMapTaskTargetItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnFocus UFButton
---@field IconToggleButton UToggleButton
---@field ImgFocus UFImage
---@field ImgTargetBg UFImage
---@field TextTarget URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewMapTaskTargetItemView = LuaClass(UIView, true)

function NewMapTaskTargetItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnFocus = nil
	--self.IconToggleButton = nil
	--self.ImgFocus = nil
	--self.ImgTargetBg = nil
	--self.TextTarget = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewMapTaskTargetItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewMapTaskTargetItemView:OnInit()

end

function NewMapTaskTargetItemView:OnDestroy()

end

function NewMapTaskTargetItemView:OnShow()

end

function NewMapTaskTargetItemView:OnHide()

end

function NewMapTaskTargetItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnFocus, self.OnClickedBtnFocus)
end

function NewMapTaskTargetItemView:OnRegisterGameEvent()

end

function NewMapTaskTargetItemView:OnRegisterBinder()
	if nil == self.Params then return end
	local TargetVM = self.Params.Data
	if nil == TargetVM then return end
	self.ViewModel = TargetVM

	local TargetVMBinders = {
		{ "IsFocusTarget", UIBinderSetIsVisible.New(self, self.ImgFocus) },
		{ "Desc", UIBinderValueChangedCallback.New(self, nil, self.OnTargetDescChanged) },
		{ "Count", UIBinderValueChangedCallback.New(self, nil, self.OnCountChanged) },
		{ "MapTextColor", UIBinderSetColorAndOpacityHex.New(self, self.TextTarget) },
	}
	self:RegisterBinders(self.ViewModel, TargetVMBinders)

	if TargetVM.OwnerChapterVM then
		local ChapterVMBinders = {
			{ "TrackTargetID", UIBinderValueChangedCallback.New(self, nil, self.OnTargetTrackingChanged) },
		}
		self:RegisterBinders(TargetVM.OwnerChapterVM, ChapterVMBinders)
	end
end

function NewMapTaskTargetItemView:OnTargetDescChanged(Str)
	self.TextTarget:SetText(ColorUtil.ParseItemNameDarkStyle(Str))
end

function NewMapTaskTargetItemView:OnCountChanged(NewValue, OldValue)
	if nil == self.ViewModel then return end

	local IsFinished = (self.ViewModel.Status == TARGET_STATUS.CS_QUEST_NODE_STATUS_FINISHED)
	local IsFocusTarget = self.ViewModel.IsFocusTarget
	self.ViewModel.MapTextColor = IsFinished and FinishedColorHex or DefaultColorHex
	
	self.IconToggleButton:SetChecked(IsFinished)
	UIUtil.SetIsVisible(self.BtnFocus, not IsFinished and (not IsFocusTarget), true)
	UIUtil.SetIsVisible(self.ImgTargetBg, not IsFinished)
end

function NewMapTaskTargetItemView:OnTargetTrackingChanged(NewValue, OldValue)
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

function NewMapTaskTargetItemView:OnClickedBtnFocus()
	local OwnerChapterVM = self.ViewModel.OwnerChapterVM

	if OwnerChapterVM then
		local TargetID = self.ViewModel.TargetID
		if TargetID < 1000 and self.ViewModel.GroupedTargetIDList then
			TargetID = OwnerChapterVM.TrackTargetID
		end
		_G.WorldMapVM.QuestParamAfterChangeMap = {
			ChapterID = OwnerChapterVM.ChapterID,
			QuestID = OwnerChapterVM.QuestID,
			TargetID = TargetID,
			WaitChangeMap = true
		}
		self:GotoMap()
	end
end

function NewMapTaskTargetItemView:GotoMap()
	local MapID = 0
	local UIMapID = 0
	local TargetCfgItem = QuestHelper.GetTargetCfgItem(self.ViewModel.OwnerChapterVM.QuestID, self.ViewModel.TargetID)
	if TargetCfgItem then
		if TargetCfgItem.MapID > 0 then
			MapID = TargetCfgItem.MapID
		end
		if TargetCfgItem.UIMapID > 0 then
			UIMapID = TargetCfgItem.UIMapID
		end
	end
	if UIMapID == 0 then
		if MapID > 0 then
			UIMapID = MapUtil.GetUIMapID(MapID)
		else
			MapID = self.ViewModel.OwnerChapterVM.MapID
			if self.ViewModel.MapIDList and next(self.ViewModel.MapIDList) then
				local K = next(self.ViewModel.MapIDList)
				MapID = K
			end
			UIMapID = MapUtil.GetUIMapID(MapID)
		end
	end
	_G.WorldMapMgr:ShowWorldMapQuest(MapID, UIMapID)
end

return NewMapTaskTargetItemView