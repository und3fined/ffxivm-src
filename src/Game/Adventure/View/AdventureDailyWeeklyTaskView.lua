---
--- Author: zhangyuhao
--- DateTime: 2025-03-07 20:40
--- Description: 日随周任务View
---

local BaseView = require("Game/Adventure/View/AdventureChildPageBaseView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local AdventureDailyWeeklyVM = require("Game/Adventure/AdventureDailyWeeklyVM")
local AdventureMgr = require("Game/Adventure/AdventureMgr")
local EventID = require("Define/EventID")
local AdventureDefine = require("Game/Adventure/AdventureDefine")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local MainTabIndex = AdventureDefine.MainTabIndex

---@class AdventureDailyWeeklyTaskView : AdventureChildPageBaseView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnReward UFButton
---@field EFF_State UFCanvasPanel
---@field PanelNoteAndRandom UFCanvasPanel
---@field PanelNoteRandomEmpty UFCanvasPanel
---@field PanelReceiveTips UFCanvasPanel
---@field RichTextDescription URichTextBox
---@field RichTextNumber URichTextBox
---@field RichTextTips URichTextBox
---@field TableViewNoteRandom UTableView
---@field TextEmptyNoteRandom UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AdventureDailyWeeklyTaskView = LuaClass(BaseView, true)

function AdventureDailyWeeklyTaskView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnReward = nil
	--self.EFF_State = nil
	--self.PanelNoteAndRandom = nil
	--self.PanelNoteRandomEmpty = nil
	--self.PanelReceiveTips = nil
	--self.RichTextDescription = nil
	--self.RichTextNumber = nil
	--self.RichTextTips = nil
	--self.TableViewNoteRandom = nil
	--self.TextEmptyNoteRandom = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AdventureDailyWeeklyTaskView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AdventureDailyWeeklyTaskView:OnInit()
	self.SurplusTime = 0
	self.VM = AdventureDailyWeeklyVM.New()
	self.AdapterNoteRandomList = UIAdapterTableView.CreateAdapter(self, self.TableViewNoteRandom)
end

function AdventureDailyWeeklyTaskView:OnShow()
	if self.Params and next(self.Params) then
		self.VM:SetCurType(self.Params.MainKey)
		self.VM:SetDiffByType()
	else
		return
	end

	local ItemListData = self.VM:GetCurTypeListData()
	self:CreatItemList(ItemListData)
	if self.Params.JumpID then
		for i, v in ipairs(ItemListData) do
			if self.Params.JumpID == v.ID then
				self.ScrollTargetIndex = i
				break
			end
		end

		self.Params.JumpID = nil
	end
	
	self:UpdateCountTimeShow()
end

function AdventureDailyWeeklyTaskView:OnActive()
	if self.VM and self.VM.Type ~= MainTabIndex.Weekly then return end
	AdventureMgr:SendChallengeLog(0)
	AdventureMgr:SendChallengelogReward()
end

function AdventureDailyWeeklyTaskView:UpdateCountTimeShow()
	self.SurplusTime = self.VM:GetSurplusTime()
	local CountTime = 0
	self:RegisterTimer(function()
		self.SurplusTime = self.SurplusTime - 1
		CountTime = CountTime + 1
		if CountTime >= 2 and self.ScrollTargetIndex then
			self.AdapterNoteRandomList:ScrollToIndex(self.ScrollTargetIndex)
			self.ScrollTargetIndex = nil
		end

		if self.SurplusTime < 0 then
			AdventureMgr:SendChallengeLog(0)
			AdventureMgr:SendChallengelogReward()
			self.SurplusTime = self.VM:GetSurplusTime()
		end

		local LocalizationUtil = require("Utils/LocalizationUtil")
		local Text = string.format(LSTR(520051), LocalizationUtil.GetCountdownTimeForLongTime(self.SurplusTime))
		self.RichTextTips:SetText(Text)
	end ,0, 1, 0)
end

function AdventureDailyWeeklyTaskView:OnHide()
	self.Super.OnHide(self)
	self.VM:HideClearData()
	self.SurplusTime = 0
end

function AdventureDailyWeeklyTaskView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnReward, self.OnClickedReward)
end

function AdventureDailyWeeklyTaskView:OnClickedReward()
	UIViewMgr:ShowView(UIViewID.AdventureCompletionPanel)
end

function AdventureDailyWeeklyTaskView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.GetChallengeLogInfo, self.OnUpdateChallengeLogs)
	self:RegisterGameEvent(EventID.GetChallengeLogCollect, self.OnUpdateChallengeLogs)
	self:RegisterGameEvent(EventID.GetChallengeLogRewardCollect, self.OnUpdateRewardLogs)
	self:RegisterGameEvent(EventID.PWorldMatchLackProfUpd, self.OnWorldMatchLackProfUpdate)
end

function AdventureDailyWeeklyTaskView:OnUpdateChallengeLogs(_)
	if self.VM and self.VM.Type == MainTabIndex.Weekly then
		local ItemListData = self.VM:GetCurTypeListData()
		if self.CreatSucess then
			self.VM:SetItemListData(ItemListData)
		else
			self:CreatItemList(ItemListData)
		end
		
		self:UpdateCountTimeShow()
	end
end

function AdventureDailyWeeklyTaskView:OnUpdateRewardLogs()
	if self.VM and self.VM.Type == MainTabIndex.Weekly then
		self.VM:UpdateWeeklyRewardStatus()
	end
end

function AdventureDailyWeeklyTaskView:OnWorldMatchLackProfUpdate()
	if self.VM and self.VM.Type == MainTabIndex.Daily then
		local ItemListData = self.VM:GetCurTypeListData()
		self.VM:UpdateDailyRewardShow(ItemListData)
	end
end

function AdventureDailyWeeklyTaskView:OnRegisterBinder()
	local Binders = {
		{"ReceiveTipsVisible", UIBinderSetIsVisible.New(self, self.PanelReceiveTips)},
		{"ItemList", UIBinderUpdateBindableList.New(self, self.AdapterNoteRandomList)},
		{"ItemListVisible", UIBinderSetIsVisible.New(self, self.AdapterNoteRandomList)},
		{"PrograssText", UIBinderSetText.New(self, self.RichTextNumber)},
		{"DescriptionText", UIBinderSetText.New(self, self.RichTextDescription)},
		{"IsEffectStateVisible", UIBinderSetIsVisible.New(self, self.EFF_State)},
		{"IsEmptyVisible", UIBinderSetIsVisible.New(self, self.PanelNoteRandomEmpty)},
		{"EmptyText", UIBinderSetText.New(self, self.TextEmptyNoteRandom)},
	}

	self:RegisterBinders(self.VM, Binders)
end

return AdventureDailyWeeklyTaskView