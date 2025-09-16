---
--- Author: lydianwang
--- DateTime: 2023-02-22 15:15
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local QuestDefine = require("Game/Quest/QuestDefine")
local QuestMainVM = require("Game/Quest/VM/QuestMainVM")

local CHAPTER_STATUS = QuestDefine.CHAPTER_STATUS
local TRACK_STATUS = QuestDefine.TRACK_STATUS
local QuestMgr = nil

local LSTR = _G.LSTR
local TextNewQuest = LSTR(593006) --593006("新任务!")
local TextProgress = LSTR(593007) --593007("可推进的任务!")
local TextSubmit = LSTR(593008) --593008("可完成的任务!")
local TextClickReplace = LSTR(593009) --593009("点击替换追踪")

---@class MainQuestNewItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnTrack UFButton
---@field QuestReplace UFCanvasPanel
---@field QuestTitleNew MainQuestTitleItemView
---@field TextTrack UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainQuestNewItemView = LuaClass(UIView, true)

function MainQuestNewItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnTrack = nil
	--self.QuestReplace = nil
	--self.QuestTitleNew = nil
	--self.TextTrack = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainQuestNewItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.QuestTitleNew)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainQuestNewItemView:OnInit()
	QuestMgr = _G.QuestMgr
	self.PreTrackCD = QuestDefine.PRE_TRACK_DURATION
end

function MainQuestNewItemView:OnDestroy()

end

function MainQuestNewItemView:OnShow()
	self:ShowTempName()
end

function MainQuestNewItemView:OnHide()

end

function MainQuestNewItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnTrack, self.OnClickedBtnTrack)
end

function MainQuestNewItemView:OnRegisterGameEvent()

end

function MainQuestNewItemView:OnRegisterBinder()

end

function MainQuestNewItemView:OnClickedBtnTrack()
	if QuestMainVM.QuestTrackVM == nil then -- 原因未知
		_G.FLOG_ERROR("MainQuestNewItemView:OnClickedBtnTrack() QuestMainVM.QuestTrackVM == nil")
		return
	end
	QuestMainVM.QuestTrackVM:OnTrackPre()
end

function MainQuestNewItemView:ShowTempName()
	if self.Params == nil then return end
	local VM = self.Params.NewQuestVM
	if VM == nil then return end

	local TempName = ""

	if VM.TrackStatus == TRACK_STATUS.ACCEPT then
		TempName = TextNewQuest

	elseif VM.TrackStatus == TRACK_STATUS.UPDATE then
		local Chapter = QuestMgr.ChapterMap[VM.ChapterID]
		if Chapter ~= nil then
			if Chapter.Status == CHAPTER_STATUS.IN_PROGRESS then
				TempName = TextProgress
			elseif Chapter.Status == CHAPTER_STATUS.CAN_SUBMIT then
				TempName = TextSubmit
			end
		end
	end

	UIUtil.SetIsVisible(self.QuestReplace, false)
	self.QuestTitleNew:SetContent(VM.Icon, TempName)
	self.QuestTitleNew:PlayAnimNew()

	self:RegisterTimer(self.ShowNewQuest, QuestDefine.NEW_ACCCEPT_DURATION, 0, 1)
end

function MainQuestNewItemView:ShowNewQuest()
	if self.Params == nil then return end
	local VM = self.Params.NewQuestVM
	if VM == nil then return end

	self.QuestTitleNew:PlayAnimNew(false)
	self.QuestTitleNew:SetContent(VM.Icon, VM.Name)
	UIUtil.SetIsVisible(self.QuestReplace, true)

	self.PreTrackCD = QuestDefine.PRE_TRACK_DURATION
	self:RegisterTimer(self.SetNewQuestContent, 0, 1, QuestDefine.PRE_TRACK_DURATION + 1)
end

function MainQuestNewItemView:SetNewQuestContent()
	if self.PreTrackCD <= 0 then
		QuestMainVM.QuestTrackVM:PreTrackQuest(nil)
		return
	end

	local Content = string.format("%s (%ds)", TextClickReplace, self.PreTrackCD)
	self.TextTrack:SetText(Content)
	self.PreTrackCD = self.PreTrackCD - 1
end

return MainQuestNewItemView