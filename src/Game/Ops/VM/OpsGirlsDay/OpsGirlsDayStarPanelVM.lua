local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local ItemVM = require("Game/Item/ItemVM")
local ItemDefine = require("Game/Item/ItemDefine")
local ItemUtil = require("Utils/ItemUtil")
local OpsGirlsDayStarTabItemVM = require("Game/Ops/VM/OpsGirlsDay/OpsGirlsDayStarTabItemVM")

local LSTR = _G.LSTR

---@class OpsGirlsDayStarPanelVM : UIViewModel
local OpsGirlsDayStarPanelVM = LuaClass(UIViewModel)
---Ctor
function OpsGirlsDayStarPanelVM:Ctor()
    self.TextTitle = nil
    self.TextInfo = nil
    self.ImgBanner = nil
    self.ButtonText = nil
    self.TaskLockVisible = nil
    self.TaskListList = UIBindableList.New(OpsGirlsDayStarTabItemVM)
	self.RewardList = UIBindableList.New(ItemVM, {ItemSlotType = ItemDefine.ItemSlotType.Item96Slot, IsCanBeSelected = false, IsShowNum = true})
end

function OpsGirlsDayStarPanelVM:Update(NodeList, CurIndex)
    local ValueList = {}
    for i, Node in ipairs(NodeList) do
        local TaskTitle = LSTR(100168) .. i
        local LockVisible = false
        local bIsSelect = false
        if i > CurIndex  then
            LockVisible = true
        end
        if i == CurIndex then
            bIsSelect = true
        end
        local ReveivedVisible = Node.Head.Finished
        table.insert(ValueList, {TaskTitle = TaskTitle, LockVisible = LockVisible, ReveivedVisible = ReveivedVisible, bIsSelect = bIsSelect})
    end

    self.TaskListList:UpdateByValues(ValueList)
end

function OpsGirlsDayStarPanelVM:SetTaskInfo(Index, TaskInfo, CurIndex)
    if TaskInfo then
        local TaskFinished = TaskInfo.Node.Head.Finished
        local NodeCfg = TaskInfo.NodeCfg
        self.TextTitle = NodeCfg.NodeTitle
        self.TextInfo = NodeCfg.NodeDesc
        self.ImgBanner = NodeCfg.StrParam
        local ItemList = {}
        for _, v in ipairs(NodeCfg.Rewards) do
            if v.ItemID and v.ItemID ~= 0 then
		        local Item = ItemUtil.CreateItem(v.ItemID, v.Num)
                Item.ShowReceived = TaskFinished
                Item.IsMask = TaskFinished
		        table.insert(ItemList, Item)
            end
        end
        self.RewardList:UpdateByValues(ItemList)

        if TaskFinished then
            self.ButtonText = LSTR(100169)
            self.JumpType = nil
            self.JumpParam = nil
		else
			self.ButtonText = LSTR(100170)
            self.JumpType = NodeCfg.JumpType
            self.JumpParam = NodeCfg.JumpParam
        end

        if Index > CurIndex then
            self.TaskLockVisible = true
        else
            self.TaskLockVisible = false
        end
    end
end


function OpsGirlsDayStarPanelVM:SetTaskTabSelected(Index)
    for i = 1, self.TaskListList:Length() do
        local TaskTabVM = self.TaskListList:Get(i)
        if i == Index then
            TaskTabVM:SetSelect()
        else
            TaskTabVM:SetNormal()
        end
    end
end

function OpsGirlsDayStarPanelVM:JumpTo()
    if self.JumpType and  self.JumpParam then
        _G.OpsActivityMgr:Jump(self.JumpType, self.JumpParam)
    end
end

return OpsGirlsDayStarPanelVM