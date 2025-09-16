local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local ProtoCS = require("Protocol/ProtoCS")
local OpsActivityRewardItemVM = require("Game/Ops/VM/OpsActivityRewardItemVM")
local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")
local ItemUtil = require("Utils/ItemUtil")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ItemDefine = require("Game/Item/ItemDefine")
local LSTR = _G.LSTR
---@class OpsHalloweenMancrTaskItemVM : UIViewModel
local OpsHalloweenMancrTaskItemVM = LuaClass(UIViewModel)

---Ctor
function OpsHalloweenMancrTaskItemVM:Ctor()
    self.Node = nil
    self.RewardList = UIBindableList.New(OpsActivityRewardItemVM, {ItemSlotType = ItemDefine.ItemSlotType.Item74Slot})

    self.TaskContent = nil
	self.TaskProgress = nil
	self.bShowBtnGo = nil
	self.TextBtnGo = nil

	self.LineImgColor = nil
	self.LineImg = nil
		
end

function OpsHalloweenMancrTaskItemVM:UpdateVM(Node)
    self.Node = Node
    local NodeID = Node.Head.NodeID
    local Extra = Node.Extra
    self.RewardStatus = Node.Head.RewardStatus
    local Progress = Extra.Progress.Value or 0
    local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
    if ActivityNode then
        self.TaskContent = ActivityNode.NodeDesc
	    self.TaskProgress = string.format("(%d/%d)", Progress, ActivityNode.Target)
        self.NodeDescColor = ActivityNode.NodeDescColor ~= "" and ActivityNode.NodeDescColor or "FFFFFF"
        self.ProgressColor = ActivityNode.ProgressColor ~= "" and ActivityNode.ProgressColor or "FFFFFF"
        local ItemList = {}
        for _, v in ipairs(ActivityNode.Rewards) do
            if v.ItemID and v.ItemID > 0 then
                v.RewardStatus = self.RewardStatus
		        table.insert(ItemList, v)
            end
        end
        self.RewardList:UpdateByValues(ItemList)

        if self.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo then
            self.bShowBtnGo = false
        else
            self.bShowBtnGo = true
        end
    end

    self.LineImgColor = "FFFFFFFF"
	self.LineImg = "PaperSprite'/Game/UI/Atlas/Ops/OpsHalloween/Frames/UI_Halloween_Img_Task_Line_png.UI_Halloween_Img_Task_Line_png'"
end


function OpsHalloweenMancrTaskItemVM:OnClickedGoHandle()
    if self.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
		OpsActivityMgr:SendActivityNodeGetReward(self.Node.Head.NodeID)
	end
end

function OpsHalloweenMancrTaskItemVM:SetBtnState(BtnWidget)
    if not BtnWidget then return end

    if self.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo then
		BtnWidget:SetIsNormalState(true)
	elseif self.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
        BtnWidget:SetBtnName(LSTR(1560014))
		BtnWidget:SetIsRecommendState(true)
	elseif self.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
		BtnWidget:SetIsDoneState(true, LSTR(1560015))
	end
end


function OpsHalloweenMancrTaskItemVM:IsEqualVM(Value)
    return Value ~= nil and self.Node ~= nil and self.Node.Head.NodeID == Value.Head.NodeID
end

return OpsHalloweenMancrTaskItemVM