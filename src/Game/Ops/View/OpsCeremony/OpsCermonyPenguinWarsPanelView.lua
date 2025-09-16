---
--- Author: usakizhang
--- DateTime: 2025-02-28 16:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local OpsCermonyPenguinWarsPanelVM = require("Game/Ops/VM/OpsCeremony/OpsCermonyPenguinWarsPanelVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local MapUtil = require("Game/Map/MapUtil")
local OpsCeremonyDefine = require("Game/Ops/View/OpsCeremony/OpsCeremonyDefine")
local ActivityCfg = require("TableCfg/ActivityCfg")
local DataReportUtil = require("Utils/DataReportUtil")
local OpsSeasonActivityDefine = require("Game/Ops/OpsSeasonActivityDefine")
local JumpUtil = require("Utils/JumpUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local LSTR = _G.LSTR
---@class OpsCermonyPenguinWarsPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGo UFButton
---@field BtnInfo USizeBox
---@field CloseBtn CommonCloseBtnView
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field IconTime UFImage
---@field InforBtn CommInforBtnView
---@field PanelStage1 UFCanvasPanel
---@field PanelStage2 UFCanvasPanel
---@field PanelTime UFCanvasPanel
---@field PanelTimeText UFHorizontalBox
---@field RichTextDescribe URichTextBox
---@field RichTextTime URichTextBox
---@field Slot1 OpsCeremony126SlotView
---@field Slot126 OpsCeremony126SlotView
---@field Slot1_1 OpsCeremony126SlotView
---@field TextBtn UFTextBlock
---@field TextDescribe1 UFTextBlock
---@field TextEmergency UFTextBlock
---@field TextTaskDescribe UFTextBlock
---@field TextTime UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsCermonyPenguinWarsPanelView = LuaClass(UIView, true)

function OpsCermonyPenguinWarsPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGo = nil
	--self.BtnInfo = nil
	--self.CloseBtn = nil
	--self.CommonBkg02_UIBP = nil
	--self.CommonBkgMask_UIBP = nil
	--self.IconTime = nil
	--self.InforBtn = nil
	--self.PanelStage1 = nil
	--self.PanelStage2 = nil
	--self.PanelTime = nil
	--self.PanelTimeText = nil
	--self.RichTextDescribe = nil
	--self.RichTextTime = nil
	--self.Slot1 = nil
	--self.Slot126 = nil
	--self.Slot1_1 = nil
	--self.TextBtn = nil
	--self.TextDescribe1 = nil
	--self.TextEmergency = nil
	--self.TextTaskDescribe = nil
	--self.TextTime = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsCermonyPenguinWarsPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommonBkg02_UIBP)
	self:AddSubView(self.CommonBkgMask_UIBP)
	self:AddSubView(self.InforBtn)
	self:AddSubView(self.Slot1)
	self:AddSubView(self.Slot126)
	self:AddSubView(self.Slot1_1)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsCermonyPenguinWarsPanelView:OnInit()
	self.ViewModel = OpsCermonyPenguinWarsPanelVM.New()
	self.Binders = {
		{ "IsFirstStage", UIBinderSetIsVisible.New(self, self.PanelStage1)},
		{ "TaskDescText", UIBinderSetText.New(self, self.TextDescribe1)},

		{ "IsSecondStage", UIBinderSetIsVisible.New(self, self.PanelStage2)},
		{ "TaskDescText", UIBinderSetText.New(self, self.RichTextDescribe)},
		{ "ActivityDescText", UIBinderSetText.New(self, self.TextTaskDescribe)},
		{ "TimeText", UIBinderSetText.New(self, self.TextTime)},
		{ "NextBattleTimeText", UIBinderSetText.New(self, self.RichTextTime)},
		{ "Info", UIBinderSetText.New(self, self.TextMissionTips)},
	}
	self.InforBtn:SetCheckClickedCallback(self, self.OnInforBtnClick)
end

function OpsCermonyPenguinWarsPanelView:OnDestroy()

end

function OpsCermonyPenguinWarsPanelView:OnShow()
	self.TextTitle:SetText(LSTR(1580002))  ---"迷失企鹅大作战"
	self.TextBtn:SetText(LSTR(1580012))    ---"前往查看"
	self.TextEmergency:SetText(LSTR(1580013)) ---"突发情况"
	---设置HelpInfo
	local Cfg = ActivityCfg:FindCfgByKey(OpsCeremonyDefine.PenguinWarsActivityID)
	if Cfg then
		self.InforBtn:SetHelpInfoID(Cfg.ChinaActivityHelpInfoID)
	end
	if self.Params == nil then
		return
	end
	if self.Params.Node == nil then
		return
	end

	self.ViewModel:Update(self.Params)
	---根据阶段更新奖励信息
	if self.ViewModel.IsFirstStage then
		self.Slot126:Update(self.ViewModel.Item1)
	elseif self.ViewModel.IsSecondStage then
		self.Slot1_1:Update(self.ViewModel.Item2)
		self.Slot1:Update(self.ViewModel.Item3)
	end
end

function OpsCermonyPenguinWarsPanelView:OnHide()

end

function OpsCermonyPenguinWarsPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGo, self.OnClickGo)
end

function OpsCermonyPenguinWarsPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MapFollowAdd, self.Hide)
end

function OpsCermonyPenguinWarsPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function OpsCermonyPenguinWarsPanelView:OnClickGo()
	local ViewModel = self.ViewModel
	if ViewModel == nil then
		return
	end
	if self.ViewModel.IsFirstStage then
		DataReportUtil.ReportActivityFlowData("CeremonyActionTypeClickFlow", tostring(OpsCeremonyDefine.PenguinWarsActivityID), tostring(OpsSeasonActivityDefine.PenguinWarsActionType.ClickedGoTo1))
		local ActivityNode = ActivityNodeCfg:FindCfgByKey(OpsCeremonyDefine.NodeIDDefine.PenguinWars)
		if ActivityNode then
			_G.OpsActivityMgr:Jump(ActivityNode.JumpType, ActivityNode.JumpParam)
		end
	else
		DataReportUtil.ReportActivityFlowData("CeremonyActionTypeClickFlow", tostring(OpsCeremonyDefine.PenguinWarsActivityID), tostring(OpsSeasonActivityDefine.PenguinWarsActionType.ClickedGoTo2))
		---根据FateID跳转到Fate
		local FateID = OpsCeremonyDefine.PenguinWarsFateID
		local FateCfg = _G.FateMgr:GetFateCfg(FateID)
		if FateCfg then
			local MapID = _G.FateMgr:GetMapIDByFateID(FateID)
			local RangeString = FateCfg.Range
			local RangeParams = string.split(RangeString, ",")
			local Point = {}
			Point.X = tonumber(RangeParams[1])
			Point.Y = tonumber(RangeParams[2])
			local UIPosX,UIPosY = MapUtil.GetUIPosByLocation(Point, MapUtil.GetUIMapID(MapID))
			_G.WorldMapMgr:OpenMapFromChatHyperlink(MapID, _G.UE.FVector2D(UIPosX, UIPosY))
		end
	end

end

function OpsCermonyPenguinWarsPanelView:OnInforBtnClick()
	DataReportUtil.ReportActivityFlowData("CeremonyActionTypeClickFlow", tostring(OpsCeremonyDefine.PenguinWarsActivityID), tostring(OpsSeasonActivityDefine.PenguinWarsActionType.ClickedInfoBtn))
end

return OpsCermonyPenguinWarsPanelView