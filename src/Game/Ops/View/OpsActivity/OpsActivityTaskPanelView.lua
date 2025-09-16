---
--- Author: yutingzhan
--- DateTime: 2024-10-26 11:00
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local OpsActivityTaskPanelVM = require("Game/Ops/VM/OpsActivityTaskPanelVM")
local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")

---@class OpsActivityTaskPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ShareTips OpsActivityShareTipsItemView
---@field TableView_41 UTableView
---@field TextSubTitle UFTextBlock
---@field TextTitle UFTextBlock
---@field Time OpsActivityTimeItemView
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsActivityTaskPanelView = LuaClass(UIView, true)

function OpsActivityTaskPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ShareTips = nil
	--self.TableView_41 = nil
	--self.TextSubTitle = nil
	--self.TextTitle = nil
	--self.Time = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsActivityTaskPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ShareTips)
	self:AddSubView(self.Time)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsActivityTaskPanelView:OnInit()
	self.ViewModel = OpsActivityTaskPanelVM.New()
	self.TaskTableViewAdapter =  UIAdapterTableView.CreateAdapter(self, self.TableView_41)
	self.Binders = {
        {"TextTitle", UIBinderSetText.New(self, self.TextTitle)},
		{"TextSubTitle", UIBinderSetText.New(self, self.TextSubTitle)},
		{"bShowSubTitle", UIBinderSetIsVisible.New(self, self.TextSubTitle)},
		{"TaskVMList", UIBinderUpdateBindableList.New(self, self.TaskTableViewAdapter)},
    }
end

function OpsActivityTaskPanelView:OnDestroy()

end

function OpsActivityTaskPanelView:OnShow()
	if self.Params == nil then
		return
	end
	if self.Params.ActivityID == nil then
		return
	end
	self:SetTextColor()
	self.ViewModel:Update(self.Params)
end

function OpsActivityTaskPanelView:OnHide()

end

function OpsActivityTaskPanelView:OnRegisterUIEvent()
end

function OpsActivityTaskPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.OpsActivityNodeGetReward, self.OpsNodeRewardGet)
	self:RegisterGameEvent(_G.EventID.LootItemUpdateRes, self.OnLootItemUpdateRes)
end

function OpsActivityTaskPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function OpsActivityTaskPanelView:SetTextColor()
	if self.Params.Activity == nil then
		return
	end
	local FColor = _G.UE.FLinearColor
	local Activity = self.Params.Activity
	if Activity.TitleColor and Activity.TitleColor ~= "" then
		self.TextTitle:SetColorAndOpacity(FColor.FromHex(Activity.TitleColor))
	end
	if Activity.SubTitleColor and Activity.SubTitleColor ~= "" then
		self.TextSubTitle:SetColorAndOpacity(FColor.FromHex(Activity.SubTitleColor))
	end
	if Activity.InfoColor and Activity.InfoColor ~= "" then
		self.TextSubTitle:SetColorAndOpacity(FColor.FromHex(Activity.InfoColor))
	end
end

function OpsActivityTaskPanelView:OpsNodeRewardGet(MsgBody)
	local NodeData = OpsActivityMgr:GetActivtyNodeInfo(self.Params.ActivityID)
	if NodeData == nil then
		return
	end
	self.Params.NodeList = NodeData.NodeList
	self.ViewModel:Update(self.Params)
end

function OpsActivityTaskPanelView:OnLootItemUpdateRes(InLootList, InReason)
	if not InLootList or not next(InLootList) then return end
	if not string.find(InReason, "Activity") then return end

	local TaskData = self.ViewModel and self.ViewModel.Tasks or {}
	local ItemList = {}
	for i, v in ipairs(TaskData) do
		if string.find(InReason, tostring(v.NodeID)) then
			local LOOT_TYPE = ProtoCS.LOOT_TYPE
			for k, v in pairs(InLootList) do
				if v.Type == LOOT_TYPE.LOOT_TYPE_ITEM then 
					table.insert(ItemList, {ResID = v.Item.ResID, Num = v.Item.Value})
				elseif v.Type == LOOT_TYPE.LOOT_TYPE_SCORE then 
					table.insert(ItemList, {ResID = v.Score.ResID, Num = v.Score.Value})
				end
			end
			break
		end
	end

	if next(ItemList) then
		_G.UIViewMgr:ShowView(_G.UIViewID.CommonRewardPanel, {ItemList = ItemList})
	end
end


return OpsActivityTaskPanelView