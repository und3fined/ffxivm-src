---
--- Author: lydianwang
--- DateTime: 2023-02-20 15:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local QuestMainVM = require("Game/Quest/VM/QuestMainVM")
local QuestHelper = require("Game/Quest/QuestHelper")
local QuestDefine = require("Game/Quest/QuestDefine")

local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local CHAPTER_STATUS = QuestDefine.CHAPTER_STATUS
local TRACK_STATUS = QuestDefine.TRACK_STATUS
local QuestTrackVM = nil
local QuestMgr = nil

---@class MainQuestPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field MainlineQuest MainQuestItemView
---@field NewQuest MainQuestNewItemView
---@field OtherQuest MainQuestItemView
---@field ScrollBox UScrollBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainQuestPanelView = LuaClass(UIView, true)

function MainQuestPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.MainlineQuest = nil
	--self.NewQuest = nil
	--self.OtherQuest = nil
	--self.ScrollBox = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainQuestPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.MainlineQuest)
	self:AddSubView(self.NewQuest)
	self:AddSubView(self.OtherQuest)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainQuestPanelView:OnInit()
	QuestTrackVM = QuestMainVM.QuestTrackVM
	QuestMgr = _G.QuestMgr
end

function MainQuestPanelView:OnDestroy()

end

function MainQuestPanelView:OnShow()

end

function MainQuestPanelView:OnHide()

end

function MainQuestPanelView:OnRegisterUIEvent()

end

function MainQuestPanelView:OnRegisterGameEvent()

end

function MainQuestPanelView:OnRegisterBinder()
	local TrackVMBinders = {
		{ "CurrTrackQuestVM", UIBinderValueChangedCallback.New(self, nil, self.OnCurrTrackChanged) },
		{ "PreTrackQuestVM", UIBinderValueChangedCallback.New(self, nil, self.OnPreTrackChanged) },
	}

	self:RegisterBinders(QuestTrackVM, TrackVMBinders)

	local MainVMBinders = {
		{ "DisplayMainlineVM", UIBinderValueChangedCallback.New(self, nil, self.OnMainlineChanged) },
	}

	self:RegisterBinders(QuestMainVM, MainVMBinders)
end

function MainQuestPanelView:OnMainlineChanged(NewValue, OldValue)
	local IsOldQuestFinished = function()
		if (OldValue == nil) then return false end
		local Chapter = QuestMgr.ChapterMap[OldValue.ChapterID]
		if (Chapter == nil) then return false end
		return (Chapter.Status == CHAPTER_STATUS.FINISHED)
	end
	local bOldQuestFinished = IsOldQuestFinished()

	if (NewValue == nil) then
		if (OldValue ~= nil) and bOldQuestFinished then
			self.MainlineQuest:PushDisplayFinished(OldValue)
		else
			self.MainlineQuest:PushDisplayNormal(nil)
		end

	else
		self.MainlineQuest:PushDisplayNormal(NewValue)
	end
end

function MainQuestPanelView:OnCurrTrackChanged(NewValue, OldValue)
	local bTrackNone = (NewValue == nil)
	local bOldTrackFinished = bTrackNone and (OldValue ~= nil)
		and (OldValue.TrackStatus == TRACK_STATUS.FINISH)
	local bNewTrackMainline = (not bTrackNone) and QuestHelper.CheckIsMainline(NewValue.ChapterID)

	if bOldTrackFinished then
		if self.OtherQuest:IsChapter(OldValue.ChapterID) then
			self.OtherQuest:PushDisplayFinished(OldValue)
		end

	elseif bNewTrackMainline then
		UIUtil.SetIsVisible(self.OtherQuest, false)

	else
		self.OtherQuest:PushDisplayNormal(NewValue)
	end
end

function MainQuestPanelView:OnPreTrackChanged(NewValue)
	self.NewQuest:SetParams({ NewQuestVM = NewValue })
	UIUtil.SetIsVisible(self.NewQuest, NewValue ~= nil)

	if NewValue == nil then
		self.ScrollBox:ScrollToStart()
		return
	end

	self.ScrollBox:ScrollToEnd()
end

return MainQuestPanelView