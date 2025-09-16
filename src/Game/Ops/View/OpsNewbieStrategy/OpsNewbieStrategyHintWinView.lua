---
--- Author: Administrator
--- DateTime: 2024-12-02 10:50
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local QuestHelper = require("Game/Quest/QuestHelper")
local HelpCfg = require("TableCfg/HelpCfg")
local QuestMgr = require("Game/Quest/QuestMgr")
local ProtoCS = require("Protocol/ProtoCS")
local MapUtil = require("Game/Map/MapUtil")
local QUEST_STATUS =  ProtoCS.CS_QUEST_STATUS

---@class OpsNewbieStrategyHintWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGoto UFButton
---@field Comm2FrameS_UIBP Comm2FrameSView
---@field Icon UFImage
---@field PanelGoto UFCanvasPanel
---@field Text UFTextBlock
---@field TextHint1 UFTextBlock
---@field TextHint2 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsNewbieStrategyHintWinView = LuaClass(UIView, true)

function OpsNewbieStrategyHintWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGoto = nil
	--self.Comm2FrameS_UIBP = nil
	--self.Icon = nil
	--self.PanelGoto = nil
	--self.Text = nil
	--self.TextHint1 = nil
	--self.TextHint2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsNewbieStrategyHintWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm2FrameS_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsNewbieStrategyHintWinView:OnInit()

end

function OpsNewbieStrategyHintWinView:OnDestroy()

end

function OpsNewbieStrategyHintWinView:OnShow()
	local Params = self.Params
	if Params == nil then
		return
	end
	---文本显示处理
	self.Comm2FrameS_UIBP:SetTitleText(Params.TitleText)
	UIUtil.SetIsVisible(self.TextHint2, false)
	self.TextHint1:SetText(Params.ContentText)
	self.TextCondition:SetText(Params.SubTitleText)
	if Params.TaskID then
		self.TaskID = Params.TaskID
		local QuestCfg = QuestHelper.GetQuestCfgItem(Params.TaskID)
		if QuestCfg == nil then
			return
		end
		local Cfg
		local StartQuest
		self.ChapterID = QuestCfg.ChapterID
		if self.ChapterID then
			Cfg = QuestHelper.GetChapterCfgItem(self.ChapterID)
		end
		if Cfg then
			local Icon = QuestMgr:GetChapterIconAtLog(self.ChapterID , nil, false) -- 任务图标
			self:SetIcon(Icon)
			self.Text:SetText(Cfg.QuestName)
			StartQuest = Cfg.StartQuest
			if StartQuest then
				local QuestStatus = _G.QuestMgr:GetQuestStatus(StartQuest)
				--任务已接取/由于是使用的开始任务ID，任务完成情况也加入判断
				if QuestStatus == QUEST_STATUS.CS_QUEST_STATUS_FINISHED or QuestStatus == QUEST_STATUS.CS_QUEST_STATUS_IN_PROGRESS   then 
					self.bCanProceed =  QuestHelper.CheckCanProceed(StartQuest)
				else
					self.bCanProceed = QuestHelper.CheckCanActivate(StartQuest)
				end
			end
		end
	end
end

function OpsNewbieStrategyHintWinView:OnHide()

end

function OpsNewbieStrategyHintWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,  self.BtnGoto, self.OnClickedGo)
end

function OpsNewbieStrategyHintWinView:OnRegisterGameEvent()

end

function OpsNewbieStrategyHintWinView:OnRegisterBinder()

end

function OpsNewbieStrategyHintWinView:SetIcon(Icon)
	UIUtil.ImageSetBrushFromAssetPath(self.Icon, Icon)
end

function OpsNewbieStrategyHintWinView:OnClickedGo()
	if self.bCanProceed then
		self:JumpTask(self.ChapterID)
		self:Hide()
	else
		-- LSTR string:任务未开放，请继续探索
		_G.MsgTipsUtil.ShowTips(LSTR(1570001))
	end
end

function OpsNewbieStrategyHintWinView:JumpTask(ChapterID)
	local ChapterCfg = QuestHelper.GetChapterCfgItem(ChapterID)
	if ChapterCfg == nil then
		return
	end
    local StartQuestCfg = QuestHelper.GetQuestCfgItem(ChapterCfg.StartQuest)
	if StartQuestCfg == nil then
		return
	end
    local Status = QuestMgr:GetQuestStatus(StartQuestCfg.id)
    local MapDefine = require("Game/Map/MapDefine")

    if Status == QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED then
        local Params = {}
        Params.MapID  = StartQuestCfg.AcceptMapID
        _G.WorldMapMgr:ShowWorldMapQuest(StartQuestCfg.AcceptMapID, nil, StartQuestCfg.id, MapDefine.MapOpenSource.RecommendTask)
    else

		local QuestMainVM = require("Game/Quest/VM/QuestMainVM")
		local AllVMs = QuestMainVM.QuestLogVM:GetAllChapterVMs()
		local TargetQuestID = StartQuestCfg.id
		for i = 1, AllVMs:Length() do
			local VM = AllVMs:Get(i)
			if VM.ChapterID == ChapterID then
				local MapID = VM.TargetMapID
				TargetQuestID = VM.QuestID
				if (MapID == nil) or (MapID == 0) then return end
				local UIMapID = MapUtil.GetUIMapID(MapID)
				---直接用maputil获取的UIMapID可能不对，有的地图有多层，比如乌尔达哈来生回廊
				local TrackTargetID = VM.TrackTargetID
				local TargetCfgItem = QuestHelper.GetTargetCfgItem(TargetQuestID, TrackTargetID)
				if TargetCfgItem then
					if TargetCfgItem.UIMapID > 0 then
						UIMapID = TargetCfgItem.UIMapID
					end
				end
				_G.WorldMapMgr:ShowWorldMapQuest(MapID, UIMapID, TargetQuestID)
				break
			end
		end
    end
end

return OpsNewbieStrategyHintWinView