---
--- Author: Administrator
--- DateTime: 2024-11-18 14:23
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBindableList = require("UI/UIBindableList")
local OpsNewbieStrategyRewardItemVM = require("Game/Ops/VM/OpsNewbieStrategy/ItemVM/OpsNewbieStrategyRewardItemVM")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoCS = require("Protocol/ProtoCS")
local ActivityRewardStatus = ProtoCS.Game.Activity.RewardStatus
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ActivityNodeRewardType = ProtoRes.Game.ActivityNodeRewardType
local ItemUtil = require("Utils/ItemUtil")


---@class OpsNewbieStrategyAwardTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewSlot UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsNewbieStrategyAwardTipsView = LuaClass(UIView, true)

function OpsNewbieStrategyAwardTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewSlot = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsNewbieStrategyAwardTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsNewbieStrategyAwardTipsView:OnInit()
	self.TableViewActiveRewardSlotAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot)
	self.ActiveRewardList = UIBindableList.New( OpsNewbieStrategyRewardItemVM )
	self.TableViewActiveRewardSlotAdapter:SetOnClickedCallback(self.OnRewardItemClicked)
end

function OpsNewbieStrategyAwardTipsView:OnDestroy()

end

function OpsNewbieStrategyAwardTipsView:OnShow()

end

function OpsNewbieStrategyAwardTipsView:SetData(RewardList)
	if RewardList then
		self.ActiveRewardList:UpdateByValues(RewardList)
		self.TableViewActiveRewardSlotAdapter:UpdateAll(self.ActiveRewardList)
	end
end

----设置奖励状态
function OpsNewbieStrategyAwardTipsView:SetRewardStatus(RewardStatus)
	local Items = self.ActiveRewardList:GetItems()
	for _, Item in ipairs(Items) do
		Item:SetRewardStatus(RewardStatus)
	end
end

function OpsNewbieStrategyAwardTipsView:OnHide()

end

function OpsNewbieStrategyAwardTipsView:OnRegisterUIEvent()

end

function OpsNewbieStrategyAwardTipsView:OnRegisterGameEvent()

end

function OpsNewbieStrategyAwardTipsView:OnRegisterBinder()

end

function OpsNewbieStrategyAwardTipsView:SetNodeID(NodeID)
	self.NodeID = NodeID
end

function OpsNewbieStrategyAwardTipsView:OnRewardItemClicked(Index, ItemData, ItemView)
	if ItemData:GetRewardStatus() ==  ActivityRewardStatus.RewardStatusWaitGet then
		local NodeID = ItemData:GetNodeID()
		if NodeID then
			_G.OpsNewbieStrategyMgr:GetRewardByNodeID(NodeID)
		end
	else
		local ItemType = ItemData.Type
		local ItemID = ItemData.ItemID
		if ItemType == ActivityNodeRewardType.ActivityNodeRewardTypeLoot then
			--掉落
			local RewardItemList = ItemUtil.GetLootItems(ItemID)	
			if RewardItemList and #RewardItemList > 0 then
				ItemID = RewardItemList[1].ResID
			end
		end
		ItemTipsUtil.ShowTipsByResID(ItemID, ItemView, {X = 0,Y = 0}, nil)
	end
end

return OpsNewbieStrategyAwardTipsView