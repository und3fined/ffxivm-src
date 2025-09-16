---
--- Author: Administrator
--- DateTime: 2025-02-26 16:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local OpsHalloweenPromPanelVM = require("Game/Ops/VM/OpsHalloween/OpsHalloweenPromPanelVM")
local OpsSeasonActivityDefine = require("Game/Ops/OpsSeasonActivityDefine")
local DataReportUtil = require("Utils/DataReportUtil")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
---@class OpsHalloweenPromPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGoto UFButton
---@field CloseBtn CommonCloseBtnView
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field IconArrow UFImage
---@field IconTask UFImage
---@field ImgBanner UFImage
---@field ImgBet UFImage
---@field ImgBet1 UFImage
---@field ImgMonster UFImage
---@field PanelGoto1 UFCanvasPanel
---@field PanelGoto2 UFCanvasPanel
---@field TableViewSlot UTableView
---@field TextGoto UFTextBlock
---@field TextHint UFTextBlock
---@field TextReward UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsHalloweenPromPanelView = LuaClass(UIView, true)

function OpsHalloweenPromPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGoto = nil
	--self.CloseBtn = nil
	--self.CommonBkg02_UIBP = nil
	--self.CommonBkgMask_UIBP = nil
	--self.IconArrow = nil
	--self.IconTask = nil
	--self.ImgBanner = nil
	--self.ImgBet = nil
	--self.ImgBet1 = nil
	--self.ImgMonster = nil
	--self.PanelGoto1 = nil
	--self.PanelGoto2 = nil
	--self.TableViewSlot = nil
	--self.TextGoto = nil
	--self.TextHint = nil
	--self.TextReward = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsHalloweenPromPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommonBkg02_UIBP)
	self:AddSubView(self.CommonBkgMask_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsHalloweenPromPanelView:OnInit()
	self.ViewModel = OpsHalloweenPromPanelVM.New()
	self.RewardListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot)
	self.RewardListAdapter:SetOnClickedCallback(self.onClickRewardIcon)

	self.Binders = {
		{"RewardList", UIBinderUpdateBindableList.New(self, self.RewardListAdapter)},
		{"TaskIcon", UIBinderSetBrushFromAssetPath.New(self, self.IconTask) },
        {"TitleText", UIBinderSetText.New(self, self.TextTitle)},
		{"BannerImg", UIBinderSetBrushFromAssetPath.New(self, self.ImgBanner)},
       	{"TaskDescText", UIBinderSetText.New(self, self.TextHint)},
		{"RewardTitleText", UIBinderSetText.New(self, self.TextReward)},
		{"GoToText", UIBinderSetText.New(self, self.TextGoto)},
		
		{"IconArrowVisible", UIBinderSetIsVisible.New(self, self.IconArrow)},

		{"WonderfulBallVisible", UIBinderSetIsVisible.New(self, self.PanelGoto1)},
		{"WonderfulBallVisible", UIBinderSetIsVisible.New(self, self.ImgBet1)},
		{"WonderfulBallVisible", UIBinderSetIsVisible.New(self, self.ImgBet)},
		{"MakeupBallVisible", UIBinderSetIsVisible.New(self, self.PanelGoto2)},
		{"MakeupBallVisible", UIBinderSetIsVisible.New(self, self.ImgMonster)},
    }
end

function OpsHalloweenPromPanelView:OnDestroy()

end

function OpsHalloweenPromPanelView:OnShow()
	if self.Params == nil then
		return
	end
	if self.Params.Node == nil then
		return
	end

	self.ViewModel:Update(self.Params)
end

function OpsHalloweenPromPanelView:OnHide()

end

function OpsHalloweenPromPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGoto, self.OnClickGotoBtn)
end

function OpsHalloweenPromPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.MapFollowAdd, self.Hide)
	self:RegisterGameEvent(_G.EventID.CrystalTransferReq, self.Hide)

end

function OpsHalloweenPromPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function OpsHalloweenPromPanelView:OnClickGotoBtn()
	if  self.ViewModel.TitleText == nil then
		return
	end
	if self.ViewModel.TitleText  ==  _G.LSTR(1560001) then
		DataReportUtil.ReportActivityFlowData("WonderfulBallActionTypeClickFlow", self.Params.Node.Head.NodeID, OpsSeasonActivityDefine.WonderfulBallActionType.ClickedGoTo)
	elseif self.ViewModel.TitleText  ==  _G.LSTR(1560004) then
		DataReportUtil.ReportActivityFlowData("MakeupBallActionTypeClickFlow", self.Params.Node.Head.NodeID, OpsSeasonActivityDefine.MakeupBallActionType.ClickeGoTo1)
	elseif self.ViewModel.TitleText  ==  _G.LSTR(1560006) then
		DataReportUtil.ReportActivityFlowData("MakeupBallActionTypeClickFlow", self.Params.Node.Head.NodeID, OpsSeasonActivityDefine.MakeupBallActionType.ClickeGoTo2)
	end

	self.ViewModel:JumpTo()
end

function OpsHalloweenPromPanelView:onClickRewardIcon(Index, ItemData, ItemView)
	if ItemData.ResID ~= nil then
		local ItemTipsUtil = require("Utils/ItemTipsUtil")
		ItemTipsUtil.ShowTipsByResID(ItemData.ResID, ItemView)
	end
end

return OpsHalloweenPromPanelView