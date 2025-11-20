local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local TimeUtil = require("Utils/TimeUtil")

local StarlightCelebrationTaskItemVM = require("Game/StarlightCelebration/VM/StarlightCelebrationTaskItemVM")
local UIBindableList = require("UI/UIBindableList")
local ItemVM = require("Game/Item/ItemVM")
local ItemDefine = require("Game/Item/ItemDefine")


local ItemUtil = require("Utils/ItemUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ActivityNodeType = ProtoRes.Game.ActivityNodeType
local LSTR = _G.LSTR
---@class StarlightCelebrationTaskPanelVM : UIViewModel
local StarlightCelebrationTaskPanelVM = LuaClass(UIViewModel)

---Ctor
function StarlightCelebrationTaskPanelVM:Ctor()
    self.TaskListList = UIBindableList.New(StarlightCelebrationTaskItemVM)
	self.RewardList = UIBindableList.New(ItemVM, {ItemSlotType = ItemDefine.ItemSlotType.Item96Slot, IsCanBeSelected = false, IsShowNum = true})
		
    self.TitleText = nil
    self.TaskDescText = nil
	self.RewardTitleText = nil

	self.UnlockText = nil
	self.NormalText = nil

	self.NormalVisible = nil
	self.UnLockVisible = nil
    self.BannerImg = nil
end

function StarlightCelebrationTaskPanelVM:Update(NodeList)
    local ValueList = {}
    for i = 1, #NodeList do
        table.insert(ValueList, {Index = i, NodeID = NodeList[i].Head.NodeID, Lock = (i>1 and NodeList[i-1].Head.Finished == false or false)})
    end

    self.TaskListList:UpdateByValues(ValueList)
end

function StarlightCelebrationTaskPanelVM:SetTaskInfo(Index, Node, PreNode)
	local NodeID  = Node.Head.NodeID
    local Finished = Node.Head.Finished

	local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
    if ActivityNode then
        self.TitleText = ActivityNode.NodeTitle
        self.TaskDescText = ActivityNode.NodeDesc
        self.BannerImg = ActivityNode.StrParam

        local ItemList = {}
        for _, v in ipairs(ActivityNode.Rewards) do
            if v.ItemID and v.ItemID ~= 0 then
		        local Item = ItemUtil.CreateItem(v.ItemID, v.Num)
                Item.ShowReceived = Finished
                Item.IsMask = Finished
		        table.insert(ItemList, Item)
            end
        end

		self.RewardTitleText = LSTR(1560005)
        
        self.RewardList:UpdateByValues(ItemList)

        self.JumpType = nil
        self.JumpParam = nil
        if ActivityNode.Target > 0 and Finished then
            self.NormalText = LSTR(1560008)
		else
			self.NormalText = LSTR(1700053)
            self.JumpType = ActivityNode.JumpType
            self.JumpParam = ActivityNode.JumpParam
        end

        local PreFinish = true
        if PreNode then
            PreFinish = PreNode.Head.Finished
        end
		
		self.UnLockVisible = not PreFinish
		self.NormalVisible = PreFinish

        if self.NormalVisible == false then
            self.JumpType = nil
            self.JumpParam = nil
        end

		if PreNode then
			local PreActivityNode = ActivityNodeCfg:FindCfgByKey(PreNode.Head.NodeID)
			if PreActivityNode then
				self.UnlockText = string.format(LSTR(1700054),Index - 1, PreActivityNode.NodeTitle)
			end
		end

    end
end

function StarlightCelebrationTaskPanelVM:SetTaskTabSelected(Index)
    for i = 1, self.TaskListList:Length() do
        local TaskTabVM = self.TaskListList:Get(i)
        if i == Index then
            TaskTabVM:SetSelect()
        else
            TaskTabVM:SetNormal()
        end
       
    end
end

function StarlightCelebrationTaskPanelVM:JumpTo()
    if self.JumpType and  self.JumpParam then
        _G.OpsActivityMgr:Jump(self.JumpType, self.JumpParam)
    end
end


--要返回当前类
return StarlightCelebrationTaskPanelVM