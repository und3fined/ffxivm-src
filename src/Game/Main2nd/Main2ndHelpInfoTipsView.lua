---
--- Author: Administrator
--- DateTime: 2024-09-13 11:45
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommHelpInfoVM =  require("Game/Common/Tips/VM/CommHelpInfoVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local TipsUtil = require("Utils/TipsUtil")
local HelpCfg = require("TableCfg/HelpCfg")
local QuestMgr = require("Game/Quest/QuestMgr")
local QuestHelper = require("Game/Quest/QuestHelper")
local FVector2D = _G.UE.FVector2D
local UUIUtil = _G.UE.UUIUtil
local EventID = _G.EventID
local ProtoCS = require("Protocol/ProtoCS")
local MapUtil = require("Game/Map/MapUtil")
local QUEST_STATUS =  ProtoCS.CS_QUEST_STATUS


---@class Main2ndHelpInfoTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommJumpWay CommJumpWayItem2View
---@field ImgBg UFImage
---@field PanelTips UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field RichTextHeading URichTextBox
---@field SizeBox USizeBox
---@field TableViewContent UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local Main2ndHelpInfoTipsView = LuaClass(UIView, true)

local InfoTipMargin = {
    Left = -35,
    Top = -26,
    Right = -35,
    Bottom = -16,
}

local InfoTipGap = 10

function Main2ndHelpInfoTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommJumpWay = nil
	--self.ImgBg = nil
	--self.PanelTips = nil
	--self.PopUpBG = nil
	--self.RichTextHeading = nil
	--self.SizeBox = nil
	--self.TableViewContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function Main2ndHelpInfoTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommJumpWay)
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function Main2ndHelpInfoTipsView:OnInit()
	self.VM = CommHelpInfoVM.New()
	self.TableViewContentAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewContent)
	self.Binders = {
		{"TableViewContentList", UIBinderUpdateBindableList.New(self, self.TableViewContentAdapter)},
	}
	self.TaskID = nil
end

function Main2ndHelpInfoTipsView:OnDestroy()

end

function Main2ndHelpInfoTipsView:OnShow()
	if self.Params == nil then
		return
	end

	local Params = self.Params
	if Params.ID then
		local HelpCfgs = HelpCfg:FindAllHelpIDCfg(Params.ID)
		Params.Data = {{Content = {HelpCfgs[1].SecContent}}}
	end
	if Params.Data then
		self.VM:UpdateVM(Params.Data)
	end
	---是否是任务解锁
	if Params.TaskID and Params.IsShowTaskUI then
		self.TaskID = Params.TaskID
		UIUtil.SetIsVisible(self.CommJumpWay, true)
		local QuestCfg = QuestHelper.GetQuestCfgItem(Params.TaskID)
		if QuestCfg == nil then
			return
		end
		local Cfg
		local bCanProceed = false
		local StartQuest
		Cfg = QuestHelper.GetChapterCfgItem(QuestCfg.ChapterID)
		if Cfg then
			local Icon = QuestMgr:GetChapterIconAtLog(QuestCfg.ChapterID, nil, false) -- 任务图标
			self.CommJumpWay:SetIcon(Icon)
			-- LSTR string:级
			self.CommJumpWay:SetText(string.format("%d%s %s",Cfg.MinLevel, LSTR(1210002), Cfg.QuestName))
			StartQuest = Cfg.StartQuest
			if StartQuest then
				local QuestStatus = _G.QuestMgr:GetQuestStatus(StartQuest)
				--任务已接取/由于是使用的开始任务ID，任务完成情况也加入判断
				if QuestStatus == QUEST_STATUS.CS_QUEST_STATUS_FINISHED or QuestStatus == QUEST_STATUS.CS_QUEST_STATUS_IN_PROGRESS   then 
					bCanProceed =  QuestHelper.CheckCanProceed(StartQuest)
				else
					bCanProceed = QuestHelper.CheckCanActivate(StartQuest)
				end
			end
		end
		self.CommJumpWay:SetIsShowArrow(false)
		local Callback
		if bCanProceed then
			Callback = function()
				self:OnClickedGo(QuestCfg.ChapterID)
				self:Hide()
			end
		else
			Callback = function()
				-- LSTR string:任务未开放，请继续探索
				_G.MsgTipsUtil.ShowTips(LSTR(1570001))
			end
		end
		self.CommJumpWay:SetCallback(self, Callback)
	else
		UIUtil.SetIsVisible(self.CommJumpWay, false)
	end
	self.RichTextHeading:SetText(Params.TitleText )
	local HidePopUpBG = Params.HidePopUpBG

	if HidePopUpBG then
		UIUtil.SetIsVisible(self.PopUpBG, false, false)
	end

	if not Params.HidePopUpBG and Params.View and self.Params.HidePopUpBGCallback  then
		UIUtil.SetIsVisible(self.PopUpBG, true, true)
		self.PopUpBG:SetCallback(self.Params.View, self.Params.HidePopUpBGCallback)
	end

	---是否根据屏幕上下位置翻转
	local IsAutoFlip = Params.IsAutoFlip

	local Offset = Params.Offset or FVector2D(0, 0)	
	local Alignment = Params.Alignment or FVector2D(0, 0)

	if Params.InTargetWidget then
		local TargetWidgetSize = UUIUtil.GetLocalSize(Params.InTargetWidget)
		--Offset = FVector2D( - TargetWidgetSize.X, 0)
		Offset.X = Offset.X - TargetWidgetSize.X
		if IsAutoFlip then
			local TargetWidget = Params.InTargetWidget
			local WindowAbsolute = UIUtil.ScreenToWidgetAbsolute(FVector2D(0, 0), false) or FVector2D(0, 0)
			local ViewportSize = UIUtil.GetViewportSize()
			local TragetAbsolute = UIUtil.GetWidgetAbsolutePosition(TargetWidget)
			if TragetAbsolute.Y - WindowAbsolute.Y  > ViewportSize.Y / 2 then
				Alignment.Y = 1
				Offset.Y = Offset.Y + TargetWidgetSize.Y
			else
				Alignment.Y = 0
			end
		end

		if Alignment.X == 0.0 and Alignment.Y  == 0.0 then
			Offset.X = Offset.X - InfoTipMargin.Left - InfoTipGap
			Offset.Y = Offset.Y - InfoTipMargin.Top
		elseif Alignment.X == 1.0 and Alignment.Y == 1.0 then
			Offset.X = Offset.X + InfoTipMargin.Right - InfoTipGap
			Offset.Y = Offset.Y + InfoTipMargin.Bottom
		elseif Alignment.X == 1.0 and Alignment.Y == 0.0 then
			Offset.X = Offset.X + InfoTipMargin.Right - InfoTipGap
			Offset.Y = Offset.Y - InfoTipMargin.Top
		elseif Alignment.X == 0.0 and Alignment.Y == 1.0 then
			Offset.X = Offset.X - InfoTipMargin.Left - InfoTipGap
			Offset.Y = Offset.Y + InfoTipMargin.Bottom
		end

		UIUtil.CanvasSlotSetPosition(self.PanelTips, FVector2D(0, 0))
		UIUtil.CanvasSlotSetAlignment(self.PanelTips, FVector2D(0, 0))

		TipsUtil.AdjustTipsPosition(self.PanelTips, Params.InTargetWidget, Offset, Alignment)
	end
end

function Main2ndHelpInfoTipsView:OnHide()
	self.TaskID = nil
end

function Main2ndHelpInfoTipsView:OnRegisterUIEvent()

end

function Main2ndHelpInfoTipsView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.UpdateQuest, self.OnUpdateQuest)
end

function Main2ndHelpInfoTipsView:OnRegisterBinder()
	self:RegisterBinders(self.VM, self.Binders)
end

function Main2ndHelpInfoTipsView:OnUpdateQuest()
	---是否是任务解锁
	if self.TaskID then
		UIUtil.SetIsVisible(self.CommJumpWay, true)
		local QuestCfg = QuestHelper.GetQuestCfgItem(self.TaskID)
		if nil == QuestCfg then
			return
		end
		local Cfg = QuestHelper.GetChapterCfgItem(QuestCfg.ChapterID)
		if Cfg then
			local Icon = QuestMgr:GetChapterIconAtLog(QuestCfg.ChapterID, nil, false) -- 任务图标
			self.CommJumpWay:SetIcon(Icon)
		end
		--self.CommJumpWay:SetIsShowArrow(false)
	end
end


function Main2ndHelpInfoTipsView:OnClickedGo(ChapterID)
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

return Main2ndHelpInfoTipsView