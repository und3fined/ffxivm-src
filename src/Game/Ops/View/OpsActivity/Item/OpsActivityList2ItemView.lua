---
--- Author: yutingzhan
--- DateTime: 2024-10-31 15:51
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")
local ProtoCS = require("Protocol/ProtoCS")
local DataReportUtil = require("Utils/DataReportUtil")

---@class OpsActivityList2ItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnList1 CommBtnSView
---@field BtnList2 CommBtnSView
---@field BtnSlot CommBtnSView
---@field TableViewSlot UTableView
---@field TextList1 UFTextBlock
---@field TextList2 UFTextBlock
---@field TextQuantity1 UFTextBlock
---@field TextQuantity2 UFTextBlock
---@field TextTag UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsActivityList2ItemView = LuaClass(UIView, true)

function OpsActivityList2ItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnList1 = nil
	--self.BtnList2 = nil
	--self.BtnSlot = nil
	--self.TableViewSlot = nil
	--self.TextList1 = nil
	--self.TextList2 = nil
	--self.TextQuantity1 = nil
	--self.TextQuantity2 = nil
	--self.TextTag = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsActivityList2ItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnList1)
	self:AddSubView(self.BtnList2)
	self:AddSubView(self.BtnSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsActivityList2ItemView:OnInit()
	self.TableViewRewardAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot,self.OnClickedSelectMemberItem, true)
	self.Binders = {
		{"TaskContent1", UIBinderSetText.New(self, self.TextList1)},
		{"TaskContent2", UIBinderSetText.New(self, self.TextList2)},
		{"TaskProgress1", UIBinderSetText.New(self, self.TextQuantity1)},
		{"TaskProgress2", UIBinderSetText.New(self, self.TextQuantity2)},
		{"TaskType", UIBinderSetText.New(self, self.TextTag)},
		{"bShowBtn1", UIBinderSetIsVisible.New(self, self.BtnList1)},
		{"bShowBtn2", UIBinderSetIsVisible.New(self, self.BtnList2)},
		{"JumpButton1", UIBinderSetText.New(self, self.BtnList1)},
		{"JumpButton2", UIBinderSetText.New(self, self.BtnList2)},
		{"RewardList", UIBinderUpdateBindableList.New(self, self.TableViewRewardAdapter)},
		{"NodeDescColor1", UIBinderSetColorAndOpacityHex.New(self, self.TextList1)},
		{"NodeDescColor2", UIBinderSetColorAndOpacityHex.New(self, self.TextList2)},
		{"ProgressColor1", UIBinderSetColorAndOpacityHex.New(self, self.TextQuantity1)},
		{"ProgressColor2", UIBinderSetColorAndOpacityHex.New(self, self.TextQuantity2)},
	}

end

function OpsActivityList2ItemView:OnDestroy()

end

function OpsActivityList2ItemView:OnShow()
	self:SetBtnState()
end

function OpsActivityList2ItemView:OnHide()

end

function OpsActivityList2ItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSlot, self.OnClickedBtnHandle)
	UIUtil.AddOnClickedEvent(self, self.BtnList1, self.OnClickedBtnList1)
	UIUtil.AddOnClickedEvent(self, self.BtnList2, self.OnClickedBtnList2)
end

function OpsActivityList2ItemView:OnRegisterGameEvent()
end

function OpsActivityList2ItemView:OnRegisterBinder()
	if nil == self.Params or nil == self.Params.Data then
		return
	end
	local ViewModel = self.Params.Data

	self.ViewModel = ViewModel

	self:RegisterBinders(ViewModel, self.Binders)
end


function OpsActivityList2ItemView:OnClickedSelectMemberItem(Index, ItemData, ItemView)
	if ItemData == nil or ItemData.ItemID == nil then
		return
	end
	ItemTipsUtil.ShowTipsByResID(ItemData.ItemID, ItemView, nil, nil, 30)
end

function OpsActivityList2ItemView:SetBtnState()
	if self.ViewModel == nil then
		return
	end

	if self.ViewModel.bShowBtn1 then
		self.BtnList1:SetIsNormalState(true)
		self.BtnList1:SetText(self.ViewModel.JumpButton1)
	end

	if self.ViewModel.bShowBtn2 then
		self.BtnList2:SetText(self.ViewModel.JumpButton2)
		self.BtnList2:SetIsNormalState(true)
	end

	if self.ViewModel.TaskState == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo then
		UIUtil.SetIsVisible(self.BtnSlot, false)
	elseif self.ViewModel.TaskState == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
		UIUtil.SetIsVisible(self.BtnSlot, true)
		self.BtnSlot:SetText(LSTR(100036))
		self.BtnSlot:SetIsRecommendState(true)
	elseif self.ViewModel.TaskState == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
		UIUtil.SetIsVisible(self.BtnSlot, true)
		self.BtnSlot:SetIsDoneState(true, LSTR(100037))
	end
end

function OpsActivityList2ItemView:OnClickedBtnHandle()
	if self.ViewModel and self.ViewModel.TaskState == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
		OpsActivityMgr:SendActivityNodeGetReward(self.ViewModel.NodeID)
		_G.LootMgr:SetDealyState(true)
	end
end

function OpsActivityList2ItemView:OnClickedBtnList1()
	if self.ViewModel  == nil then
		return
	end
	DataReportUtil.ReportActivityFlowData("ActivityTaskClickFlow", self.ViewModel.ActivityID, 1, tostring(self.ViewModel.NodeID1))
	OpsActivityMgr:Jump(self.ViewModel.JumpType1, self.ViewModel.JumpParam1)
end

function OpsActivityList2ItemView:OnClickedBtnList2()
	if self.ViewModel  == nil then
		return
	end
	DataReportUtil.ReportActivityFlowData("ActivityTaskClickFlow", self.ViewModel.ActivityID, 1, tostring(self.ViewModel.NodeID2))
	OpsActivityMgr:Jump(self.ViewModel.JumpType2, self.ViewModel.JumpParam2)
end

return OpsActivityList2ItemView