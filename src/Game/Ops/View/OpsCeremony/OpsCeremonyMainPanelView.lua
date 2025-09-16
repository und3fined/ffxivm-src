---
--- Author: usakizhang
--- DateTime: 2025-02-28 11:39
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local OpsCeremonyMainPanelVM = require("Game/Ops/VM/OpsCeremony/OpsCeremonyMainPanelVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local TimeUtil = require("Utils/TimeUtil")
local UIUtil = require("Utils/UIUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ActivityCfg = require("TableCfg/ActivityCfg")
local OpsCeremonyDefine = require("Game/Ops/View/OpsCeremony/OpsCeremonyDefine")
local SaveKey = require("Define/SaveKey")
local UIViewID = require("Define/UIViewID")
local DataReportUtil = require("Utils/DataReportUtil")
local OpsSeasonActivityDefine = require("Game/Ops/OpsSeasonActivityDefine")
local NodeIDDefine = OpsCeremonyDefine.NodeIDDefine
local LSTR = _G.LSTR
---@class OpsCeremonyMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ActivityTime OpsActivityTimeItemView
---@field BtnPaly UFButton
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field EntranceBigWar OpsCeremonyEntranceItemView
---@field EntranceBless OpsCeremonyEntranceItemView
---@field EntranceCelebration OpsCeremonyEntranceItemView
---@field EntranceMysteriousVisitor OpsCeremonyEntranceItemView
---@field EntranceShop OpsCeremonyEntranceItemView
---@field ShareTips OpsActivityShareTipsItemView
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsCeremonyMainPanelView = LuaClass(UIView, true)

function OpsCeremonyMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ActivityTime = nil
	--self.BtnPaly = nil
	--self.CommonBkg02_UIBP = nil
	--self.CommonBkgMask_UIBP = nil
	--self.EntranceBigWar = nil
	--self.EntranceBless = nil
	--self.EntranceCelebration = nil
	--self.EntranceMysteriousVisitor = nil
	--self.EntranceShop = nil
	--self.ShareTips = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsCeremonyMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ActivityTime)
	self:AddSubView(self.CommonBkg02_UIBP)
	self:AddSubView(self.CommonBkgMask_UIBP)
	self:AddSubView(self.EntranceBigWar)
	self:AddSubView(self.EntranceBless)
	self:AddSubView(self.EntranceCelebration)
	self:AddSubView(self.EntranceMysteriousVisitor)
	self:AddSubView(self.EntranceShop)
	self:AddSubView(self.ShareTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsCeremonyMainPanelView:OnInit()
	self.ViewModel = OpsCeremonyMainPanelVM.New()
	self.Binders = {
		{ "TitleText", UIBinderSetText.New(self, self.TextTitle)},
	}
end

function OpsCeremonyMainPanelView:OnDestroy()
	self.ViewModel = nil
end

function OpsCeremonyMainPanelView:OnShow()
	if self.Params == nil then
		return
	end
	if self.Params.ActivityID == nil then
		return
	end
	self.ViewModel:Update(self.Params)
	--- 活动入口Item不是List，需要手动逐个更新VM
	self.EntranceMysteriousVisitor:Update(self.ViewModel.MysteriousVisitorParams)
	self.EntranceBigWar:Update(self.ViewModel.PenguinWarsParams)
	self.EntranceCelebration:Update(self.ViewModel.CelebrationParams)
	self.EntranceShop:Update(self.ViewModel.SeasonShopParams)
	self.EntranceBless:Update(self.ViewModel.FatPenguinParams)

	local LastEnterTime = _G.UE.USaveMgr.GetInt(SaveKey.OpenLightCeremonyDaily, 0, true) or 0
	local IsAutoPlayVideo = _G.UE.USaveMgr.GetInt(SaveKey.OpenLightCeremonyAutoPlayVideo, 0, true) == 1
	if LastEnterTime == 0 or not TimeUtil.GetIsCurDailyCycleTime(LastEnterTime) then
		self:PlayAnimation(self.AnimFirstShow)
	else
		self:PlayAnimation(self.AnimShow)
	end
	if not IsAutoPlayVideo then
		_G.UIViewMgr:ShowView(UIViewID.CommonVideoPlayerView, {VideoPath = self.ViewModel.VideoShowNodeInfo.StrParam})
		DataReportUtil.ReportActivityFlowData("CeremonyActionTypeClickFlow", tostring(self.Params.ActivityID), tostring(OpsSeasonActivityDefine.CeremonyActionType.AutoPlayAnim))
		_G.UE.USaveMgr.SetInt(SaveKey.OpenLightCeremonyAutoPlayVideo, 1, true)
	end
	_G.UE.USaveMgr.SetInt(SaveKey.OpenLightCeremonyDaily, TimeUtil.GetServerLogicTime(), true)

end

function OpsCeremonyMainPanelView:OnHide()

end

function OpsCeremonyMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.EntranceMysteriousVisitor.BtnProm, self.OnClicklMysteriousVisitor)
	UIUtil.AddOnClickedEvent(self, self.EntranceBigWar.BtnProm, self.OnClicklPenguinWars)
	UIUtil.AddOnClickedEvent(self, self.EntranceCelebration.BtnProm, self.OnClicklCelebration)
	UIUtil.AddOnClickedEvent(self, self.EntranceShop.BtnProm, self.OnClicklSeasonShop)
	UIUtil.AddOnClickedEvent(self, self.EntranceBless.BtnProm, self.OnClicklFatPenguin)
	UIUtil.AddOnClickedEvent(self, self.BtnPaly, self.OnClickActivityPlay)
end

function OpsCeremonyMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.OpsActivityUpdateInfo, self.OnActivityUpdateInfo)
	self:RegisterGameEvent(EventID.OpsActivityUpdate, self.UpdateOriginDataShow)

end

function OpsCeremonyMainPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function OpsCeremonyMainPanelView:OnClicklMysteriousVisitor()
	DataReportUtil.ReportActivityFlowData("CeremonyActionTypeClickFlow", tostring(self.Params.ActivityID), tostring(OpsSeasonActivityDefine.CeremonyActionType.ClickedMysteriousVisitor))
	--- 叙事任务一直都能打开，但是要处理紧急关闭的情况
	local ViewModel = self.ViewModel
	if not ViewModel then
		return
	end
	if not ViewModel.MysteriousVisitorParams.Node then
		return
	end
	---有点击的红点更新需求
	_G.OpsSeasonActivityMgr:RecordRedDotClicked(NodeIDDefine.MysteriousVisitor,_G.TimeUtil.GetServerLogicTime())
	_G.UIViewMgr:ShowView(_G.UIViewID.OpsCeremonyMysteriousVisitorPanelView, ViewModel.MysteriousVisitorParams)
end

function OpsCeremonyMainPanelView:OnClicklPenguinWars()
	DataReportUtil.ReportActivityFlowData("CeremonyActionTypeClickFlow", tostring(self.Params.ActivityID), tostring(OpsSeasonActivityDefine.CeremonyActionType.ClickedPenguinWars))
	--- 迷失企鹅大作战无特定开启事件，但是有锁定状态
	local ViewModel = self.ViewModel
	if not ViewModel then
		return
	end
	if not ViewModel.PenguinWarsParams.Node then
		return
	end
	if ViewModel.PenguinWarsParams.IsLock then
		_G.MsgTipsUtil.ShowTips(LSTR(1580006)) --"完成神秘来客寻踪之旅任务后解锁"
		return
	end
	---有点击的红点更新需求
	--- 根据完成阶段判断记录哪一次的红点
	--- 第一阶段的叙事任务未完成
	if not ViewModel.PenguinWarsParams.IsFinish then
		_G.OpsSeasonActivityMgr:RecordRedDotClicked(NodeIDDefine.PenguinWars)
	else
		_G.OpsSeasonActivityMgr:RecordRedDotClicked(NodeIDDefine.PenguinWars2)
	end
	_G.UIViewMgr:ShowView(_G.UIViewID.OpsCermonyPenguinWarsPanelView,ViewModel.PenguinWarsParams)
end

function OpsCeremonyMainPanelView:OnClicklCelebration()
	DataReportUtil.ReportActivityFlowData("CeremonyActionTypeClickFlow", tostring(self.Params.ActivityID), tostring(OpsSeasonActivityDefine.CeremonyActionType.ClickedCelebration))
	local ViewModel = self.ViewModel
	if not ViewModel then
		return
	end
	--- 未到解锁时间,目前只支持国服时间
	local Activity = ActivityCfg:FindCfgByKey(25012102)
	if not Activity then
		return
	end
	local StartTime = Activity.ChinaActivityTime.StartTime
	local ActivityDataStamp = TimeUtil.GetTimeFromString(StartTime)
	if ActivityDataStamp > TimeUtil.GetServerLogicTime() then
		local LocalLizationTime = LocalizationUtil.GetTimeForFixedFormat(StartTime)
		_G.MsgTipsUtil.ShowTips(string.format(LSTR(1580007),LocalLizationTime)) --"xxx解锁玩法"
		return
	end
	ViewModel.CelebrationParams.StartTimeText = ""
	-- 到了解锁时间，检查前置任务是否完成
	if not ViewModel.MysteriousVisitorParams.IsFinish then
		_G.MsgTipsUtil.ShowTips(LSTR(1580006)) --"完成神秘来客寻踪之旅任务后解锁"
		self.EntranceCelebration:Update(self.ViewModel.CelebrationParams)
		return
	end
	ViewModel.CelebrationParams.IsLock = false
	self.EntranceCelebration:Update(self.ViewModel.CelebrationParams)
	--有点击的红点更新需求
	_G.OpsSeasonActivityMgr:RecordRedDotClicked(NodeIDDefine.Celebration)
	_G.UIViewMgr:ShowView(_G.UIViewID.OpsCeremonyCelebrationPanelView, ViewModel.CelebrationParams)
end

function OpsCeremonyMainPanelView:OnClicklSeasonShop()
	DataReportUtil.ReportActivityFlowData("CeremonyActionTypeClickFlow", tostring(self.Params.ActivityID), tostring(OpsSeasonActivityDefine.CeremonyActionType.ClickedSeasonShop))
	local ViewModel = self.ViewModel
	if not ViewModel then
		return
	end
	local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeIDDefine.SeasonShop)
	if ActivityNode then
		_G.OpsActivityMgr:Jump(ActivityNode.JumpType, ActivityNode.JumpParam)
	end
end

function OpsCeremonyMainPanelView:OnClicklFatPenguin()
	DataReportUtil.ReportActivityFlowData("CeremonyActionTypeClickFlow", tostring(self.Params.ActivityID), tostring(OpsSeasonActivityDefine.CeremonyActionType.ClickedFatPenguin))
	local ViewModel = self.ViewModel
	if not ViewModel then
		return
	end
	local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeIDDefine.FatPenguin)
	if ActivityNode then
		_G.OpsActivityMgr:Jump(ActivityNode.JumpType, ActivityNode.JumpParam)
	end
end
function OpsCeremonyMainPanelView:OnClicklPenguinWar()
end


function OpsCeremonyMainPanelView:OnClickActivityPlay()
	DataReportUtil.ReportActivityFlowData("CeremonyActionTypeClickFlow", tostring(self.Params.ActivityID), tostring(OpsSeasonActivityDefine.CeremonyActionType.ClickPlay))
	_G.UIViewMgr:ShowView(UIViewID.CommonVideoPlayerView, {VideoPath = self.ViewModel.VideoShowNodeInfo.StrParam})
end

function OpsCeremonyMainPanelView:UpdateOriginDataShow()
	local NodeData = _G.OpsActivityMgr:GetActivtyNodeInfo(self.Params.ActivityID)
	if NodeData and NodeData.NodeList then
		self.Params.NodeList = NodeData.NodeList
	end

	self.ViewModel:Update(self.Params)
	--- 活动入口Item不是List，需要手动逐个更新VM
	self.EntranceMysteriousVisitor:Update(self.ViewModel.MysteriousVisitorParams)
	self.EntranceBigWar:Update(self.ViewModel.PenguinWarsParams)
	self.EntranceCelebration:Update(self.ViewModel.CelebrationParams)
	self.EntranceShop:Update(self.ViewModel.SeasonShopParams)
	self.EntranceBless:Update(self.ViewModel.FatPenguinParams)
end

function OpsCeremonyMainPanelView:OnActivityUpdateInfo(MsgBody)
	if MsgBody == nil or MsgBody.NodeOperate == nil or MsgBody.NodeOperate.Result == nil then
		return
	end
	local ViewModel = self.ViewModel
	if not ViewModel then
		return
	end
	--- 检查是否是拉回流活动的节点更新
	local ActivityDetail = MsgBody.NodeOperate.ActivityDetail
	if ViewModel.ActivityID ~= ActivityDetail.Head.ActivityID then
		return
	end
	local OpType = MsgBody.NodeOperate.OpType
	if OpType == ProtoCS.Game.Activity.NodeOpType.NodeOpTypeLotteryDrawNoLayBack then
		self:OnRecieveLotteryResult(MsgBody)
		return
	elseif OpType == ProtoCS.Game.Activity.NodeOpType.NodeOpTypePullBindRole then
		self:OnRecieveBindRoleInfo(MsgBody)

	end
end
return OpsCeremonyMainPanelView