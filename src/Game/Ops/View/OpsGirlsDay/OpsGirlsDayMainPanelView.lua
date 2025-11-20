---
--- Author: yutingzhan
--- DateTime: 2025-08-27 10:50
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local OpsGirlsDayMainPanelVM = require("Game/Ops/VM/OpsGirlsDay/OpsGirlsDayMainPanelVM")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")
local ProtoCS = require("Protocol/ProtoCS")
---@class OpsGirlsDayMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAward UFButton
---@field BtnCandy UFButton
---@field BtnShop UFButton
---@field BtnStar UFButton
---@field BtnStar_1 UFButton
---@field CommInforBtn CommInforBtnView
---@field IconFate UFImage
---@field IconReceive UFImage
---@field IconTask UFImage
---@field OpsActivityTime OpsActivityTimeItemView
---@field TextAward UFTextBlock
---@field TextCandy UFTextBlock
---@field TextNow UFTextBlock
---@field TextQuantity UFTextBlock
---@field TextShop UFTextBlock
---@field TextStar UFTextBlock
---@field TextStar_1 UFTextBlock
---@field TextSubTitle UFTextBlock
---@field TextTitle UFTextBlock
---@field TopFeatures OpsCommTopFeaturesPanelView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsGirlsDayMainPanelView = LuaClass(UIView, true)

function OpsGirlsDayMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAward = nil
	--self.BtnCandy = nil
	--self.BtnShop = nil
	--self.BtnStar = nil
	--self.BtnStar_1 = nil
	--self.CommInforBtn = nil
	--self.IconFate = nil
	--self.IconReceive = nil
	--self.IconTask = nil
	--self.OpsActivityTime = nil
	--self.TextAward = nil
	--self.TextCandy = nil
	--self.TextNow = nil
	--self.TextQuantity = nil
	--self.TextShop = nil
	--self.TextStar = nil
	--self.TextStar_1 = nil
	--self.TextSubTitle = nil
	--self.TextTitle = nil
	--self.TopFeatures = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsGirlsDayMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommInforBtn)
	self:AddSubView(self.OpsActivityTime)
	self:AddSubView(self.TopFeatures)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsGirlsDayMainPanelView:OnInit()
	self.TextAward = LSTR(100171)
	self.TextNow = LSTR(100172)
	self.ViewModel = OpsGirlsDayMainPanelVM.New()
	self.Binders = {
		{"TextTitle", UIBinderSetText.New(self, self.TextTitle)},
		{"TextSubTitle", UIBinderSetText.New(self, self.TextSubTitle)},
		{"TaskTitle", UIBinderSetText.New(self, self.TextStar)},
		{"TaskFinished", UIBinderSetIsVisible.New(self, self.IconReceive)},
		{"TextShop", UIBinderSetText.New(self, self.TextShop)},
		{"TextStage", UIBinderSetText.New(self, self.TextStar_1)},
		{"TextFate", UIBinderSetText.New(self, self.TextCandy)},
		{"SnowRiceFruitNum", UIBinderSetText.New(self, self.TextQuantity)},

	}
end

function OpsGirlsDayMainPanelView:OnDestroy()

end

function OpsGirlsDayMainPanelView:OnShow()
	if self.Params == nil then
		return
	end
	if self.Params.ActivityID == nil then
		return
	end
	self.ViewModel:Update(self.Params)
	OpsActivityMgr:SendActivityNodeOperate(self.ViewModel.DaughterDayUpdateProgressNodeID, 
	ProtoCS.Game.Activity.NodeOpType.NodeOpTypeDaughterDayUpdateProgress, {})
	UIUtil.SetIsVisible(self.TopFeatures.OpsMoneySlot, false)
	UIUtil.SetIsVisible(self.TopFeatures.BtnVideo, false)
end

function OpsGirlsDayMainPanelView:OnHide()

end

function OpsGirlsDayMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnStar, self.OnClickBtnStar)
	UIUtil.AddOnClickedEvent(self, self.BtnAward, self.OnClickBtnAward)
	UIUtil.AddOnClickedEvent(self, self.BtnCandy, self.OnClickBtnCandy)
	UIUtil.AddOnClickedEvent(self, self.BtnShop, self.OnClickBtnShop)
	UIUtil.AddOnClickedEvent(self, self.BtnStar_1, self.OnClickBtnStage)
end

function OpsGirlsDayMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.OpsActivityUpdate, self.UpdateActivityUI)
	self:RegisterGameEvent(_G.EventID.OpsActivityUpdateInfo, self.OpsActivityUpdateInfo)
end

function OpsGirlsDayMainPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function OpsGirlsDayMainPanelView:UpdateActivityUI()
	if self.Params == nil then
		return
	end

	if self.Params.ActivityID == nil then
		return
	end

	local Activity = self.Params.Activity
    local Detail = _G.OpsActivityMgr.ActivityNodeMap[self.Params.ActivityID] or {}
    self.Params:UpdateVM({Activity = Activity, Detail = Detail})

	self.ViewModel:Update(self.Params)
end

function OpsGirlsDayMainPanelView:OnClickBtnShop()
	local ShopJumpInfo = self.ViewModel.ShopJumpInfo
	if ShopJumpInfo then
		_G.OpsActivityMgr:Jump(ShopJumpInfo.JumpType, ShopJumpInfo.JumpParam)
	end
end

function OpsGirlsDayMainPanelView:OnClickBtnStage()
	local StageJumpInfo = self.ViewModel.ShopJumpInfo
	if StageJumpInfo then
		_G.OpsActivityMgr:Jump(StageJumpInfo.JumpType, StageJumpInfo.JumpParam)
	end
end

function OpsGirlsDayMainPanelView:OnClickBtnCandy()
	local GiveSnowCandyTask = self.ViewModel.TaskListInfo[2]
	if GiveSnowCandyTask then
		if GiveSnowCandyTask.Node.Head.Finished then
			_G.UIViewMgr:ShowView(_G.UIViewID.OpsGirlsDayCandyPanelView, GiveSnowCandyTask)
		else
			MsgTipsUtil.ShowTips(LSTR(100174))
		end
	end
end

function OpsGirlsDayMainPanelView:OnClickBtnAward()
	local GiveSnowCandyTask = self.ViewModel.TaskListInfo[2]
	if GiveSnowCandyTask.Node.Head.Finished then
		_G.UIViewMgr:ShowView(_G.UIViewID.OpsGirlsDayAwardPanelView, {Num = self.ViewModel.SnowRiceFruitNum, ActivityID = self.Params.ActivityID, StageJumpInfo = self.ViewModel.ShopJumpInfo})
	else
		MsgTipsUtil.ShowTips(LSTR(100180))
	end
end


function OpsGirlsDayMainPanelView:OnClickBtnStar()
	_G.UIViewMgr:ShowView(_G.UIViewID.OpsGirlsDayStarPanelView, {TaskListInfo = self.ViewModel.TaskListInfo, CurrentTaskIndex = self.ViewModel.CurrentTaskIndex})
end

function OpsGirlsDayMainPanelView:OpsActivityUpdateInfo(MsgBody)
	if MsgBody == nil or MsgBody.NodeOperate == nil then
		return
	end
	local NodeOperate = MsgBody.NodeOperate
	if NodeOperate.OpType == ProtoCS.Game.Activity.NodeOpType.NodeOpTypeDaughterDayUpdateProgress then
		local DaughterDayUpdateProgress = NodeOperate.Result.DaughterDayUpdateProgressRsp
		local AccumulateSnowRiceFruitNum = DaughterDayUpdateProgress.AccumulateSnowRiceFruitNum
		self.ViewModel.SnowRiceFruitNum = AccumulateSnowRiceFruitNum
		_G.EventMgr:SendEvent(_G.EventID.RefreshSnowRiceFruitNum, { Num = AccumulateSnowRiceFruitNum })
	end
end

function OpsGirlsDayMainPanelView:OnRegisterTimer()
	self:RegisterTimer(self.RefreshSnowRiceFruitNum, 0, 1800, 0)
end

function OpsGirlsDayMainPanelView:RefreshSnowRiceFruitNum()
	OpsActivityMgr:SendActivityNodeOperate(self.ViewModel.DaughterDayUpdateProgressNodeID, 
	ProtoCS.Game.Activity.NodeOpType.NodeOpTypeDaughterDayUpdateProgress, {})
end

return OpsGirlsDayMainPanelView