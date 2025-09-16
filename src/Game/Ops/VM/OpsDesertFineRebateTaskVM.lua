local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ProtoCS = require("Protocol/ProtoCS")
local OpsDesertFineRebateTaskItemVM = require("Game/Ops/VM/OpsDesertFineRebateTaskItemVM")
local UIBindableList = require("UI/UIBindableList")
local ItemVM = require("Game/Item/ItemVM")
local ItemUtil = require("Utils/ItemUtil")
local ItemDefine = require("Game/Item/ItemDefine")
local LSTR = _G.LSTR
local ActivityNodeType = ProtoRes.Game.ActivityNodeType

---@class OpsDesertFineRebateTaskVM : UIViewModel
local OpsDesertFineRebateTaskVM = LuaClass(UIViewModel)
---Ctor
function OpsDesertFineRebateTaskVM:Ctor()
    self.ItemVM1 = ItemVM.New()
    self.ItemVM2 = ItemVM.New()
    self.TaskVMList = UIBindableList.New(OpsDesertFineRebateTaskItemVM)
    self.TaskProgressText = nil
    self.TaskProgressPercent = nil
    self.Finish1Visible = nil
    self.Finish2Visible = nil
end

function OpsDesertFineRebateTaskVM:Update(ActivityData)
    local NodeList = ActivityData:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeAccumulativeFinishNode)
    if NodeList then
        for _, Node in ipairs(NodeList) do
            local NodeID  = Node.Head.NodeID
            local Extra = Node.Extra
            local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
            if ActivityNode then
                local Item = ItemUtil.CreateItem(ActivityNode.Rewards[1].ItemID, ActivityNode.Rewards[1].Num)
                if ActivityNode.Target == 1 then
                    self.AccumulativeFinishNode1 = Node
                    self.ItemVM1:UpdateVM(Item, {ItemSlotType = ItemDefine.ItemSlotType.Item96Slot})
                    self.Finish1Visible = Node.Head.RewardStatus ~= ProtoCS.Game.Activity.RewardStatus.RewardStatusNo
                    self.ItemVM1.IsSelect = Node.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet
                    self.ItemVM1.IconReceivedVisible =  Node.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone
                    self.ItemVM1.IsMask = self.ItemVM1.IconReceivedVisible
                elseif ActivityNode.Target == 2 then
                    self.AccumulativeFinishNode2 = Node
                    self.ItemVM2:UpdateVM(Item, {ItemSlotType = ItemDefine.ItemSlotType.Item96Slot})
                    local Progress = Extra.Progress.Value or 0
                    self.TaskProgressText = string.format("%s(%d/%d)", ActivityNode.NodeDesc or "", Progress, ActivityNode.Target)
                    self.TaskProgressPercent = Progress / ActivityNode.Target
                    self.Finish2Visible = Node.Head.RewardStatus ~= ProtoCS.Game.Activity.RewardStatus.RewardStatusNo
                    self.ItemVM2.IsSelect = Node.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet
                    self.ItemVM2.IconReceivedVisible =  Node.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone
                    self.ItemVM2.IsMask = self.ItemVM2.IconReceivedVisible
                end
            end
        end
    end

    local TaskList = {}
    if ActivityData.NodeList then
		for _, Node in ipairs(ActivityData.NodeList) do
			local NodeID  = Node.Head.NodeID
			local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
			if ActivityNode and ActivityNode.NodeType ~= ActivityNodeType.ActivityNodeTypeAccumulativeFinishNode and ActivityNode.NodeType ~= ActivityNodeType.ActivityNodeTypePictureShare and ActivityNode.Target > 0 then
				table.insert(TaskList, Node)
			end
		end
	end

    table.sort(TaskList, function(a, b) 
        if a.Head.Finished ~= b.Head.Finished then
            if a.Head.Finished == true then
                return false
            end
            return true
        end
    end)

    self.TaskVMList:UpdateByValues(TaskList)

end


return OpsDesertFineRebateTaskVM