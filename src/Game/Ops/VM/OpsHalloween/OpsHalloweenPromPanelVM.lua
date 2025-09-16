local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local UIBindableList = require("UI/UIBindableList")
local LSTR = _G.LSTR
local ItemVM = require("Game/Item/ItemVM")
local ItemUtil = require("Utils/ItemUtil")
local ItemDefine = require("Game/Item/ItemDefine")

---@class OpsHalloweenPromPanelVM : UIViewModel
local OpsHalloweenPromPanelVM = LuaClass(UIViewModel)
---Ctor
function OpsHalloweenPromPanelVM:Ctor()
    self.RewardList = UIBindableList.New(ItemVM, {ItemSlotType = ItemDefine.ItemSlotType.Item96Slot, IsCanBeSelected = false, IsShowNum = true})
    self.TaskIcon = nil
    self.TitleText = nil
    self.BannerImg = nil
    self.TaskDescText = nil
    self.RewardTitleText = nil
    self.GoToText = nil

    self.IconArrowVisible = nil
    self.RewardVisible = nil

    self.WonderfulBallVisible = nil
    self.MakeupBallVisible = nil
end

function OpsHalloweenPromPanelVM:Update(Param)
    self.TaskIcon = Param.IconPath
    local NodeID  = Param.Node.Head.NodeID
    local Finished = Param.Node.Head.Finished
	local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
    if ActivityNode then
        self.TitleText = ActivityNode.NodeTitle
        self.BannerImg = ActivityNode.StrParam
        self.TaskDescText = ActivityNode.NodeDesc

        local ItemList = {}
        for _, v in ipairs(ActivityNode.Rewards) do
            if v.ItemID and v.ItemID ~= 0 then
		        local Item = ItemUtil.CreateItem(v.ItemID, v.Num)
                Item.ShowReceived = Finished
                Item.IsMask = Finished
		        table.insert(ItemList, Item)
            end
        end

        if #ItemList > 0 then
            self.RewardTitleText = LSTR(1560005)
        else
            self.RewardTitleText = ""
        end
        
        self.RewardList:UpdateByValues(ItemList)

        self.GoToText = ActivityNode.JumpButton
        self.JumpType = ActivityNode.JumpType
        self.JumpParam = ActivityNode.JumpParam
        if ActivityNode.Target > 0 and Finished then
            self.IconArrowVisible = false
            self.GoToText = LSTR(1560008)
        else
            self.IconArrowVisible = true
        end
    end

    if Param.WonderfulBall == true then
        self.WonderfulBallVisible = true
        self.MakeupBallVisible = false
    else
        self.WonderfulBallVisible = false
        self.MakeupBallVisible = true
    end
end

function OpsHalloweenPromPanelVM:JumpTo()
    if self.IconArrowVisible == true then
        _G.OpsActivityMgr:Jump(self.JumpType, self.JumpParam)
    end
end


return OpsHalloweenPromPanelVM