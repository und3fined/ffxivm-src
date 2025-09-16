---
--- Author: yutingzhan
--- DateTime: 2024-12-07 15:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local OpsSupplyStationPanelVM = require("Game/Ops/VM/OpsSupplyStationPanelVM")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local OpsActivityDefine = require("Game/Ops/OpsActivityDefine")
local EventID = require("Define/EventID")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local LootMgr = require("Game/Loot/LootMgr")
local DataReportUtil = require("Utils/DataReportUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

---@class OpsSupplyStationPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCheck UFButton
---@field BtnPoster UFButton
---@field ImgPoster UFImage
---@field PanelAvailable UFCanvasPanel
---@field PanelReceive UFCanvasPanel
---@field TableView_41 UTableView
---@field TextSubTitle UFTextBlock
---@field TextTitle UFTextBlock
---@field Time OpsActivityTimeItemView
---@field AnimDone UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsSupplyStationPanelView = LuaClass(UIView, true)

function OpsSupplyStationPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCheck = nil
	--self.BtnPoster = nil
	--self.ImgPoster = nil
	--self.PanelAvailable = nil
	--self.PanelReceive = nil
	--self.TableView_41 = nil
	--self.TextSubTitle = nil
	--self.TextTitle = nil
	--self.Time = nil
	--self.AnimDone = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsSupplyStationPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Time)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsSupplyStationPanelView:OnInit()
	self.ViewModel = OpsSupplyStationPanelVM.New()
	self.AwardTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView_41)
	self.Binders = {
        {"TextTitle", UIBinderSetText.New(self, self.TextTitle)},
		{"TextSubTitle", UIBinderSetText.New(self, self.TextSubTitle)},
        {"AwardVMList", UIBinderUpdateBindableList.New(self, self.AwardTableViewAdapter)},
		{"ImgPoster", UIBinderSetImageBrush.New(self, self.ImgPoster)},
		{"PosterDay", UIBinderSetText.New(self, self.TextDay)},
		{"PosterReceiveVisiable", UIBinderSetIsVisible.New(self, self.PanelReceive)},
		{"PosterRewardAvailable", UIBinderSetIsVisible.New(self, self.PanelAvailable)},
    }
end

function OpsSupplyStationPanelView:OnDestroy()

end

function OpsSupplyStationPanelView:OnShow()
	if self.Params == nil then
		return
	end
	if self.Params.ActivityID == nil then
		return
	end
	self.ViewModel:Update(self.Params)
end

function OpsSupplyStationPanelView:OnHide()

end

function OpsSupplyStationPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,  self.BtnPoster, self.OnBtnPosterClick)
	UIUtil.AddOnClickedEvent(self,  self.BtnCheck, self.OnBtnCheckClick)
end

function OpsSupplyStationPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ShowLoginDayReward, self.ShowLoginDayReward)
end

function OpsSupplyStationPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function OpsSupplyStationPanelView:OnBtnPosterClick()
	if self.ViewModel.PosterRewardAvailable then
		LootMgr:SetDealyState(true)
		OpsActivityMgr:SendActivityGetReward(self.Params.ActivityID)
	else
		DataReportUtil.ReportActivityClickFlowData(self.Params.ActivityID, 5)
		_G.PreviewMgr:OpenPreviewView(self.ViewModel.RewardSuitID)
	end
end

function OpsSupplyStationPanelView:OnBtnCheckClick()
	if self.ViewModel then
		DataReportUtil.ReportActivityClickFlowData(self.Params.ActivityID, 5)
		_G.PreviewMgr:OpenPreviewView(self.ViewModel.RewardSuitID)
	end
end

function OpsSupplyStationPanelView:ShowLoginDayReward()
	if self.ViewModel.AwardVMList == nil then
		return
	end
	local Params = {}
	local Rewards = {}
	for _, Item in ipairs(self.ViewModel.AwardVMList.Items) do
		if Item.IconRewardAvaiable then
			table.insert(Rewards,{ResID = Item.ItemID, Num = tonumber(Item.Num)})
		end
	end
	if self.ViewModel.PosterRewardAvailable then
		table.insert(Rewards,{ResID = self.ViewModel.PosterItemID1, Num = tonumber(self.ViewModel.PosterItemNum1)})
		table.insert(Rewards,{ResID = self.ViewModel.PosterItemID2, Num = tonumber(self.ViewModel.PosterItemNum2)})
		table.insert(Rewards,{ResID = self.ViewModel.PosterItemID3, Num = tonumber(self.ViewModel.PosterItemNum3)})
	end
	Params.ShowBtn = false
	Params.ItemList = Rewards
	local RewardView = UIViewMgr:ShowView(UIViewID.CommonRewardPanel, Params)
	if RewardView ~= nil then
		local function OnHideRewardPanel()
			if self.ViewModel then
				for i, Item in ipairs(self.ViewModel.AwardVMList.Items) do
					local ItemView = self.AwardTableViewAdapter:GetChildWidget(i)
					if Item.IconRewardAvaiable then
						Item.IconRewardAvaiable = false
						Item.IconReceivedVisible = true
						if ItemView ~= nil then
							ItemView:PlayAnimation(ItemView.AnimDone)
						end
						if i == 2 or i == 3 or i == 7 then
							Item.ImgBG = OpsActivityDefine.PropBoxType.AdvancedProp
						else
							Item.ImgBG = OpsActivityDefine.PropBoxType.OrdinaryProp
						end
					end
				end
				if self.ViewModel.PosterRewardAvailable then
					self.ViewModel.PosterRewardAvailable = false
					self.ViewModel.PosterReceiveVisiable = true
					self:PlayAnimation(self.AnimDone)
					_G.UE.UCommonUtil.ShowAppStoreRatingAlert()
				end
			end
			_G.EventMgr:SendEvent(EventID.OpsActivityUpdateInfo)
		end
		RewardView.CommonPopUpBG:SetCallback(RewardView, OnHideRewardPanel)
	end
end


return OpsSupplyStationPanelView