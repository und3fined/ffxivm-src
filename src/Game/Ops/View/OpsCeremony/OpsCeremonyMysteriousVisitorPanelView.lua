---
--- Author: usakizhang
--- DateTime: 2025-02-28 16:45
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local OpsCeremonyMysteriousVisitorPanelVM = require("Game/Ops/VM/OpsCeremony/OpsCeremonyMysteriousVisitorPanelVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local OpsCeremonyDefine = require("Game/Ops/View/OpsCeremony/OpsCeremonyDefine")
local DataReportUtil = require("Utils/DataReportUtil")
local OpsSeasonActivityDefine = require("Game/Ops/OpsSeasonActivityDefine")
local JumpUtil = require("Utils/JumpUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local LSTR = _G.LSTR
---@class OpsCeremonyMysteriousVisitorPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGo UFButton
---@field CloseBtn CommonCloseBtnView
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field IconTask UFImage
---@field ImgBanner UFImage
---@field ImgPenguin UFImage
---@field ImgPenguindoudou UFImage
---@field TableViewSlot UTableView
---@field TextBtn UFTextBlock
---@field TextCompleted UFTextBlock
---@field TextDescribe UFTextBlock
---@field TextReward UFTextBlock
---@field TextTaskTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsCeremonyMysteriousVisitorPanelView = LuaClass(UIView, true)

function OpsCeremonyMysteriousVisitorPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGo = nil
	--self.CloseBtn = nil
	--self.CommonBkg02_UIBP = nil
	--self.CommonBkgMask_UIBP = nil
	--self.IconTask = nil
	--self.ImgBanner = nil
	--self.ImgPenguin = nil
	--self.ImgPenguindoudou = nil
	--self.TableViewSlot = nil
	--self.TextBtn = nil
	--self.TextCompleted = nil
	--self.TextDescribe = nil
	--self.TextReward = nil
	--self.TextTaskTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsCeremonyMysteriousVisitorPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommonBkg02_UIBP)
	self:AddSubView(self.CommonBkgMask_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsCeremonyMysteriousVisitorPanelView:OnInit()
	self.ViewModel = OpsCeremonyMysteriousVisitorPanelVM.New()
	self.RewardListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot)
	self.RewardListAdapter:SetOnClickedCallback(self.TableViewRewardClicked)
	self.Binders = {
		{ "TaskTitleText", UIBinderSetText.New(self, self.TextTaskTitle)},
		{ "TaskDescText", UIBinderSetText.New(self, self.TextDescribe)},
		{ "ButtonText", UIBinderSetText.New(self, self.TextBtn)},
		{ "PenguinIconVisiable", UIBinderSetIsVisible.New(self, self.ImgPenguindoudou)},
		{ "RewardVMList", UIBinderUpdateBindableList.New(self, self.RewardListAdapter)},
		{ "TaskIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgPenguin)},
		{ "CompletedText", UIBinderSetText.New(self, self.TextCompleted)},
		{ "Info", UIBinderSetText.New(self, self.TextMissionTips)},
	}
end

function OpsCeremonyMysteriousVisitorPanelView:OnDestroy()

end

function OpsCeremonyMysteriousVisitorPanelView:OnShow()
	self.TextReward:SetText(LSTR(1580008))
	local Params = self.Params
	if Params == nil then
		return
	end
	if Params.Node == nil then
		return
	end

	self.ViewModel:Update(self.Params)
end

function OpsCeremonyMysteriousVisitorPanelView:OnHide()

end

function OpsCeremonyMysteriousVisitorPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGo, self.OnClickGo)
end

function OpsCeremonyMysteriousVisitorPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MapFollowAdd, self.Hide)
end

function OpsCeremonyMysteriousVisitorPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function OpsCeremonyMysteriousVisitorPanelView:TableViewRewardClicked(_, ItemData, ItemView)
	if ItemData.ItemID ~= nil then
		ItemTipsUtil.ShowTipsByResID(ItemData.ItemID, ItemView)
	end
end

function OpsCeremonyMysteriousVisitorPanelView:OnClickGo()
	local ViewModel = self.ViewModel
	if ViewModel == nil then
		return
	end
	if ViewModel.TaskIsFinished then
		DataReportUtil.ReportActivityFlowData("CeremonyActionTypeClickFlow", tostring(OpsCeremonyDefine.NodeIDDefine.MysteriousVisitor), tostring(OpsSeasonActivityDefine.MysteriousVisitorActionType.ClickeGoTo2))
		_G.WorldMapMgr:OpenMapFromChatHyperlink(OpsCeremonyDefine.PenguinPosMapID, _G.UE.FVector2D(OpsCeremonyDefine.PenguinPos.x, OpsCeremonyDefine.PenguinPos.y))
	else
		DataReportUtil.ReportActivityFlowData("CeremonyActionTypeClickFlow", tostring(OpsCeremonyDefine.NodeIDDefine.MysteriousVisitor), tostring(OpsSeasonActivityDefine.MysteriousVisitorActionType.ClickeGoTo1))
		local ActivityNode = ActivityNodeCfg:FindCfgByKey(OpsCeremonyDefine.NodeIDDefine.MysteriousVisitor)
		if ActivityNode then
			_G.OpsActivityMgr:Jump(ActivityNode.JumpType, ActivityNode.JumpParam)
		end
	end

end
return OpsCeremonyMysteriousVisitorPanelView