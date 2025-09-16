---
--- Author: Administrator
--- DateTime: 2024-02-26 20:18
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local ProtoRes = require("Protocol/ProtoRes")
local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")
local MapDefine = require("Game/Map/MapDefine")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local QuestHelper = require("Game/Quest/QuestHelper")
local UIViewID = require("Define/UIViewID")

local TeleportCrystalCfg = require("TableCfg/TeleportCrystalCfg")

local LSTR = _G.LSTR
local WorldMapMgr = _G.WorldMapMgr
local MapMgr = _G.MapMgr
local QuestMgr = _G.QuestMgr


local TELEPORT_CRYSTAL_ACROSSMAP = ProtoRes.TELEPORT_CRYSTAL_TYPE.TELEPORT_CRYSTAL_ACROSSMAP
local TELEPORT_CRYSTAL_CURRENTMAP = ProtoRes.TELEPORT_CRYSTAL_TYPE.TELEPORT_CRYSTAL_CURRENTMAP

---@class NewMapTaskTrackingTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field IconCancelTrack UFImage
---@field IconState UFImage
---@field IconTrack UFImage
---@field PanelTips UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field TextQuestName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewMapTaskTrackingTipsView = LuaClass(UIView, true)

function NewMapTaskTrackingTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.IconCancelTrack = nil
	--self.IconState = nil
	--self.IconTrack = nil
	--self.PanelTips = nil
	--self.PopUpBG = nil
	--self.TextQuestName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewMapTaskTrackingTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewMapTaskTrackingTipsView:OnInit()
	UIUtil.SetIsVisible(self.PanelTips, false)
end

function NewMapTaskTrackingTipsView:OnDestroy()

end

function NewMapTaskTrackingTipsView:OnShow()
	self:FocusMarkerByID(self.Params.QuestID, self.Params.TargetID, self.Params.ScreenPosition)
end

function NewMapTaskTrackingTipsView:OnHide()
	UIUtil.SetIsVisible(self.PanelTips, false)
	local WorldMapPanel = _G.UIViewMgr:FindView(UIViewID.WorldMapPanel)
	if WorldMapPanel ~= nil  then
		WorldMapPanel.MapContent:FocusMarkerByID(0)
	end
end

function NewMapTaskTrackingTipsView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnBtnTrackClicked)
end

function NewMapTaskTrackingTipsView:OnRegisterGameEvent()

end

function NewMapTaskTrackingTipsView:OnRegisterBinder()

end

function NewMapTaskTrackingTipsView:OnBtnTrackClicked()
	local Params = self.Params
	if Params == nil then
		return
	end
	if Params.QuestID == QuestMgr:GetTrackingQuest() then
		self:UnTrackTask()
	else
		self:TrackTask()
	end

	self:RefreshTraceStateShow(Params.QuestID == QuestMgr:GetTrackingQuest())
end

function NewMapTaskTrackingTipsView:TrackTask()
	local Params = self.Params
	if Params == nil then
		return
	end
	local WorldMapUIMapID = WorldMapMgr:GetUIMapID()
	local MapUIMapID = MapMgr:GetUIMapID()


	local TrackFun = function()
		local UE = _G.UE
		local CrystalPortalMgr = _G.PWorldMgr:GetCrystalPortalMgr()
		local MapID = MapUtil.GetMapID(WorldMapUIMapID)
		local AllCfg = {}
		for _, Cfg in pairs( TeleportCrystalCfg:FindAllCfg()) do
			if Cfg.MapID == MapID and (Cfg.Type == TELEPORT_CRYSTAL_ACROSSMAP or Cfg.Type == TELEPORT_CRYSTAL_CURRENTMAP) then
				table.insert(AllCfg, Cfg)
			end
		end

		local MarkerPos = nil
		local ParamList = _G.QuestTrackMgr:GetMapQuestParam(MapID, Params.QuestID)
		if ParamList then
			local Param = ParamList[1]
			if Param then
				local Pos = Param.Pos or Param.AssistPos
				if Pos then
					MarkerPos = UE.FVector2D( Pos.X, Pos.Y )
				end
			end
		end

		local CrystalIDList = {}
		if MarkerPos then
			for i = 1, #AllCfg do
				local CrystalCfg = AllCfg[i]
				local CrystalID = CrystalCfg.CrystalID
				if CrystalPortalMgr:IsExistActiveCrystal(CrystalID) then
					local Crystal = {}
					Crystal.CrystalID = CrystalID
					Crystal.Distance = UE.UKismetMathLibrary.Distance2D(MarkerPos, UE.FVector2D( CrystalCfg.X, CrystalCfg.Y ))
					table.insert(CrystalIDList, Crystal)
				end
			end
			table.sort(CrystalIDList, function(CrystalA, CrystalB)
				return CrystalA.Distance < CrystalB.Distance
			end)
		end

		if #CrystalIDList > 0 then
			CrystalPortalMgr:TransferByMap(CrystalIDList[1].CrystalID)
			_G.WorldMapMgr:ReportData(MapDefine.MapReportType.CrystalTransfer, MapDefine.CrystalTransferSource.TaskTrackingTips, CrystalIDList[1].CrystalID)
			_G.WorldMapVM:ShowWorldMapTaskDetailPanel(false)
		else
			MsgTipsUtil.ShowErrorTips(LSTR(400002))
		end
		if QuestMgr:SetTrackQuest(Params.QuestID) then
			MsgTipsUtil.ShowTips(string.format(LSTR(400003), _G.QuestMgr:GetQuestName(Params.QuestID)))
		else
			MsgTipsUtil.ShowTips(LSTR(400004))
		end
		self:RefreshTraceStateShow(Params.QuestID == QuestMgr:GetTrackingQuest())
	end

	if WorldMapUIMapID == MapUIMapID then
		if QuestMgr:SetTrackQuest(Params.QuestID) then
			MsgTipsUtil.ShowTips(string.format(LSTR(400003), _G.QuestMgr:GetQuestName(Params.QuestID)))
		else
			MsgTipsUtil.ShowTips(LSTR(400004))
		end
	else
		MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(10004), LSTR(400005), TrackFun, nil, LSTR(10003), LSTR(10002))
	end
end

function NewMapTaskTrackingTipsView:UnTrackTask()
	local Params = self.Params
	if Params == nil then
		return
	end
	QuestMgr:CancelTrackQuest()
	MsgTipsUtil.ShowTips(string.format(LSTR(400006), _G.QuestMgr:GetQuestName(Params.QuestID)))
end

function NewMapTaskTrackingTipsView:RefreshTraceStateShow(Tracking)
	if Tracking then
		UIUtil.SetIsVisible(self.IconTrack, false)
		UIUtil.SetIsVisible(self.IconCancelTrack, true)
	else
		UIUtil.SetIsVisible(self.IconTrack, true)
		UIUtil.SetIsVisible(self.IconCancelTrack, false)
	end
end

function NewMapTaskTrackingTipsView:FocusMarkerByID(QuestID, TargetID, ScreenPosition)
	local WorldMapPanel = _G.UIViewMgr:FindView(UIViewID.WorldMapPanel)
	local QuestMgr = _G.QuestMgr
	local QuestName = QuestMgr:GetQuestName(QuestID) or ""
	self.TextQuestName:SetText(QuestName)

	local QuestCfgitem = QuestHelper.GetQuestCfgItem(QuestID) or {}
	local ChapterVM = _G.QuestMainVM:GetChapterVM(QuestCfgitem.ChapterID) or ""
	UIUtil.ImageSetBrushFromAssetPath(self.IconState, ChapterVM.Icon)

	self:RefreshTraceStateShow(QuestID == QuestMgr:GetTrackingQuest())

	if ScreenPosition ~= nil then
		local _, ViewportPosition = UIUtil.AbsoluteToViewport(ScreenPosition)
		local SelfSize = UIUtil.CanvasSlotGetSize(self.PanelTips)
		ViewportPosition.Y = ViewportPosition.Y - 20 - SelfSize.Y
		ViewportPosition.X = ViewportPosition.X - SelfSize.X / 2
		UIUtil.CanvasSlotSetPosition(self.PanelTips, ViewportPosition)
		WorldMapPanel.MapContent:FocusMarkerByID(QuestID, true, TargetID, false)
		UIUtil.SetIsVisible(self.PanelTips, true)
	else
		WorldMapPanel.MapContent:FocusMarkerByID(QuestID, true, TargetID, true)
		self:RegisterTimer(function ()
			local MarkerView = WorldMapPanel.MapContent:GetMapMarkerQuest(QuestID, TargetID)
			local MarkerPos = UIUtil.GetWidgetAbsolutePosition(MarkerView)
			local _, ViewportPosition = UIUtil.AbsoluteToViewport(MarkerPos)
			local SelfSize = UIUtil.CanvasSlotGetSize(self.PanelTips)
			local MarkerSize = UIUtil.GetWidgetSize(MarkerView)
			ViewportPosition.Y = ViewportPosition.Y - 20 - SelfSize.Y - MarkerSize.Y / 2
			ViewportPosition.X = ViewportPosition.X - SelfSize.X / 2
			UIUtil.CanvasSlotSetPosition(self.PanelTips, ViewportPosition)
			UIUtil.SetIsVisible(self.PanelTips, true)
		end, 0.3)
	end
end
return NewMapTaskTrackingTipsView