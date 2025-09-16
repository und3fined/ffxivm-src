---
--- Author: alex
--- DateTime: 2024-09-09 17:04
--- Description:挑战笔记界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local GoldSauserMainPanelMainVM = require("Game/GoldSauserMainPanel/VM/GoldSauserMainPanelMainVM")
local GoldSauserMainPanelDefine = require("Game/GoldSauserMainPanel/GoldSauserMainPanelDefine")
local GoldSauserMainPanelMgr = require("Game/GoldSauserMainPanel/GoldSauserMainPanelMgr")
local EventID = require("Define/EventID")
local AdventureMgr = require("Game/Adventure/AdventureMgr")
local TimerMgr = _G.TimerMgr
local ProtoRes = require("Protocol/ProtoRes")
local challenge_log_category = ProtoRes.challenge_log_category
local LSTR = _G.LSTR
local AudioType = GoldSauserMainPanelDefine.AudioType

---@class GoldSaucerMainPanelChallengeNotesWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewList UTableView
---@field TextTime UFTextBlock
---@field WinBG PlayStyleCommFrameLView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerMainPanelChallengeNotesWinView = LuaClass(UIView, true)

function GoldSaucerMainPanelChallengeNotesWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewList = nil
	--self.TextTime = nil
	--self.WinBG = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerMainPanelChallengeNotesWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.WinBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerMainPanelChallengeNotesWinView:InitSubViewConstStringInfo()
	self.WinBG:SetTitle(LSTR(350046))
end

function GoldSaucerMainPanelChallengeNotesWinView:OnInit()
	self.AdapterNoteList = UIAdapterTableView.CreateAdapter(self, self.TableViewList)
	self.UpdateTimerID = nil
	self.SurplusTime = 0
end

function GoldSaucerMainPanelChallengeNotesWinView:OnDestroy()

end

function GoldSaucerMainPanelChallengeNotesWinView:OnShow()
	UIUtil.SetIsVisible(self.WinBG.PanelCurrency, false)
	AdventureMgr:SendChallengeLog(challenge_log_category.CHALLENGE_LOG_CATEGORY_GOLDSAUCER)
	self:SetTheSurplusEndTime()
	self:SetSurplusTimeText()
	self.UpdateTimerID = TimerMgr:AddTimer(self, self.OnUpdateTime, 0, 1, 0)
	self:InitSubViewConstStringInfo()
end

function GoldSaucerMainPanelChallengeNotesWinView:OnHide()
	if self.UpdateTimerID then
		TimerMgr:CancelTimer(self.UpdateTimerID)
		self.UpdateTimerID = nil
	end
end

function GoldSaucerMainPanelChallengeNotesWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.WinBG.ButtonClose, self.OnClickedCloseThePanel)
end

function GoldSaucerMainPanelChallengeNotesWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.GetChallengeLogInfo, self.OnUpdateChallengeLogs)
	self:RegisterGameEvent(EventID.GetChallengeLogCollect, self.OnUpdateCollectLogs)
	--self:RegisterGameEvent(EventID.GetChallengeLogRewardCollect, self.OnUpdateRewardLogs)
end

function GoldSaucerMainPanelChallengeNotesWinView:OnRegisterBinder()
	local ViewModel = GoldSauserMainPanelMainVM:GetGoldSauserMainPanelChallengNoteVM()
	if not ViewModel then
		return
	end

	local Binders = {
		{"ItemList", UIBinderUpdateBindableList.New(self, self.AdapterNoteList)},
	}
	self:RegisterBinders(ViewModel, Binders)
end

function GoldSaucerMainPanelChallengeNotesWinView:OnClickedCloseThePanel()
	self:Hide()
	GoldSauserMainPanelMgr:PlayAudio(AudioType.SubView)
end


function GoldSaucerMainPanelChallengeNotesWinView:OnUpdateChallengeLogs()
	self:UpdateAllNoteInfos()
end

function GoldSaucerMainPanelChallengeNotesWinView:OnUpdateCollectLogs(LogID)
	self:UpdateNoteInfoAfterReceiveAward(LogID)
end

function GoldSaucerMainPanelChallengeNotesWinView:UpdateAllNoteInfos()
	local ViewModel = GoldSauserMainPanelMainVM:GetGoldSauserMainPanelChallengNoteVM()
	if not ViewModel then
		return
	end
	ViewModel:UpdateAllNoteItemList()
end

function GoldSaucerMainPanelChallengeNotesWinView:UpdateNoteInfoAfterReceiveAward(LogID)
	local ViewModel = GoldSauserMainPanelMainVM:GetGoldSauserMainPanelChallengNoteVM()
	if not ViewModel then
		return
	end
	ViewModel:UpdateNoteItemCollected(LogID)
end

function GoldSaucerMainPanelChallengeNotesWinView:SetTheSurplusEndTime()
	local ViewModel = GoldSauserMainPanelMainVM:GetGoldSauserMainPanelChallengNoteVM()
	if not ViewModel then
		return
	end
	self.SurplusTime = ViewModel:GetSurplusTime()
end

function GoldSaucerMainPanelChallengeNotesWinView:SetSurplusTimeText()
	local ViewModel = GoldSauserMainPanelMainVM:GetGoldSauserMainPanelChallengNoteVM()
	if not ViewModel then
		return
	end
	local TimeString = LocalizationUtil.GetCountdownTimeForLongTime(self.SurplusTime)
	local Text = string.format(LSTR(350022), TimeString)
	self.TextTime:SetText(Text)
end

function GoldSaucerMainPanelChallengeNotesWinView:OnUpdateTime()
	local ViewModel = GoldSauserMainPanelMainVM:GetGoldSauserMainPanelChallengNoteVM()
	if not ViewModel then
		return
	end
	
	self.SurplusTime = self.SurplusTime - 1

	if self.SurplusTime < 0 then
		self:SetTheSurplusEndTime()
		AdventureMgr:SendChallengeLog(challenge_log_category.CHALLENGE_LOG_CATEGORY_GOLDSAUCER)
	end

	self:SetSurplusTimeText()
end

return GoldSaucerMainPanelChallengeNotesWinView